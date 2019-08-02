//
//  EmailOptionUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/19.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EmailOptionUtil.h"
#import "EmailManage.h"
#import "EmailAccountModel.h"
#import "EmailFloderConfig.h"
#import "NSString+HexStr.h"

@implementation EmailOptionUtil

+ (void) setEmailStaredUid:(NSInteger)uid folderPath:(NSString *)folderPath isAdd:(BOOL) isAdd complete:(void (^)(BOOL success)) complete
{
    MCOIMAPOperation * op2 = [EmailManage.sharedEmailManage.imapSeeion storeFlagsOperationWithFolder:folderPath
                                                                                                uids:[MCOIndexSet indexSetWithIndex:uid]
                                                                                                kind:(isAdd?MCOIMAPStoreFlagsRequestKindAdd: MCOIMAPStoreFlagsRequestKindRemove)
                                                                                               flags:MCOMessageFlagFlagged];
    [op2 start:^(NSError * error) {
        if (error) {
            complete(NO);
        } else {
            complete(YES);
        }
    }];
}

+ (void) setEmailReaded:(BOOL)readed uid:(NSInteger)uid folderPath:(NSString *)folderPath complete:(void (^)(BOOL success)) complete
{
    MCOIMAPOperation * op2 = [EmailManage.sharedEmailManage.imapSeeion storeFlagsOperationWithFolder:folderPath
                                                                                                uids:[MCOIndexSet indexSetWithIndex:uid]
                                                                                                kind:(readed?MCOIMAPStoreFlagsRequestKindSet:MCOIMAPStoreFlagsRequestKindRemove)
                                                                                               flags:MCOMessageFlagSeen];
    [op2 start:^(NSError * error) {
        if (error) {
            complete(NO);
        } else {
            complete(YES);
        }
    }];
}

/**
 *  删除操作步骤，先copy一份到已删除，再设置删除flag，再清理收件箱
 *  这里注意，如果是已删除和草稿箱这两个文件夹，那么我们不必再保存一份到已删除了，而是直接删除就可以了
 */
+ (void)deleteEmailUid:(NSInteger)uid folderPath:(NSString *)folderPath folderName:(NSString *) folderName complete:(void (^)(BOOL success)) complete
{
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    // 读取本地配置
    NSDictionary *floderConfigDic = [EmailFloderConfig getFloderConfigWithEmailType:accountM.Type];
    
    //这里判断是不是“已删除”和“草稿箱”两个文件夹，如果不是那么使用copyMessage来复制邮件到“已删除”
    if (![Trash isEqualToString:folderName] && ![Drafts isEqualToString:folderName]) {
        MCOIMAPCopyMessagesOperation *op = [EmailManage.sharedEmailManage.imapSeeion copyMessagesOperationWithFolder:folderPath uids:[MCOIndexSet indexSetWithIndex:uid] destFolder:floderConfigDic[Trash]];
   
        [op start:^(NSError *error, NSDictionary *uidMapping) {
            if (!error) {
                [EmailOptionUtil unturnedDelete:uid floderPath:folderPath complete:complete];
            } else {
                complete(NO);
            }
        }];
    }else{
        [EmailOptionUtil unturnedDelete:uid floderPath:folderPath complete:complete];
    }
}

// 完全删除邮件操作
+ (void) unturnedDelete:(NSInteger) uid floderPath:(NSString *) floderPath complete:(void (^)(BOOL success)) complete
{
    //先添加删除flags
    MCOIMAPOperation * op2 = [EmailManage.sharedEmailManage.imapSeeion storeFlagsOperationWithFolder:floderPath
                                                                                                uids:[MCOIndexSet indexSetWithIndex:uid]
                                                                                                kind:MCOIMAPStoreFlagsRequestKindSet
                                                                                               flags:MCOMessageFlagDeleted];
    [op2 start:^(NSError * error) {
        //添加成功之后对当前文件夹进行expunge操作
        if (error) {
             complete(NO);
        } else {
            MCOIMAPOperation *deleteOp = [EmailManage.sharedEmailManage.imapSeeion expungeOperation:floderPath];
            [deleteOp start:^(NSError *error) {
                if (error) {
                    complete(NO);
                }else{
                    complete(YES);
                }
            }];
        }
    }];
}

// 创建草稿箱
+ (void)createDraft:(NSData *)data complete:(void (^)(BOOL success)) complete
{
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    // 读取本地配置
    NSDictionary *floderConfigDic = [EmailFloderConfig getFloderConfigWithEmailType:accountM.Type];
    NSString *folder = floderConfigDic[Drafts];
    MCOIMAPAppendMessageOperation *op = [EmailManage.sharedEmailManage.imapSeeion appendMessageOperationWithFolder:folder messageData:data flags:MCOMessageFlagDraft];
    [op start:^(NSError *error, uint32_t createdUID) {
        NSLog(@"create message :%@",@(createdUID));
        if (error) {
            complete(NO);
        }else{
            complete(YES);
        }
    }];
}

// copy 到已发送
+ (void)copySent:(NSData *)data complete:(void (^)(BOOL success)) complete
{
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    if (accountM.Type != 2) { // 目前只有qq邮箱需要手动维护
        complete(YES);
        return;
    }
    // 读取本地配置
    NSDictionary *floderConfigDic = [EmailFloderConfig getFloderConfigWithEmailType:accountM.Type];
    NSString *folder = floderConfigDic[Sent];
    MCOIMAPAppendMessageOperation *op = [EmailManage.sharedEmailManage.imapSeeion appendMessageOperationWithFolder:folder messageData:data flags:MCOMessageFlagMDNSent];
    [op start:^(NSError *error, uint32_t createdUID) {
        NSLog(@"create sent message :%@",@(createdUID));
        if (error) {
            complete(NO);
        }else{
            complete(YES);
        }
    }];
}

// 复制邮件到 -指定文件夹 是否删除原邮件
+ (void) copyEmailToFloderWithFloderPath:(NSString *) floderPath toFloderName:(NSString *) toFloderName uid:(NSInteger) uid isDel:(BOOL) isDel complete:(void (^)(BOOL success)) complete
{
    
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    // 读取本地配置
    NSDictionary *floderConfigDic = [EmailFloderConfig getFloderConfigWithEmailType:accountM.Type];
    
    MCOIMAPCopyMessagesOperation *op = [EmailManage.sharedEmailManage.imapSeeion copyMessagesOperationWithFolder:floderPath uids:[MCOIndexSet indexSetWithIndex:uid] destFolder:floderConfigDic[toFloderName]];
    
    [op start:^(NSError *error, NSDictionary *uidMapping) {
        if (!error) {
            if (isDel) {
                [EmailOptionUtil unturnedDelete:uid floderPath:floderPath complete:complete];
            } else {
                complete(YES);
            }
            
        } else {
            complete(NO);
        }
    }];
}

+ (BOOL) checkEmailStar:(int)flags
{
    NSString *starBinary = [NSString convertBinarySystemFromDecimalSystem:[NSString stringWithFormat:@"%d",flags]];
    if (starBinary && starBinary.length>=3) {
        if ([[starBinary substringWithRange:NSMakeRange(2, 1)] isEqualToString:@"1"]) {
            return YES;
        }
        
    }
    return NO;
}
@end
