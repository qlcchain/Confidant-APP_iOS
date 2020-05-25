//
//  PNMessageSendManage.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/4/26.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNMessageSendManage.h"
#import "FriendModel.h"
#import "ChatListDataUtil.h"
#import "NSDate+Category.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "ChatModel.h"
#import "UserConfig.h"
#import "SocketDataUtil.h"
#import "SocketManageUtil.h"
#import "MD5Util.h"
#import "SystemUtil.h"
#import "AESCipher.h"
#import "MyConfidant-Swift.h"
#import "SocketMessageUtil.h"

@implementation PNMessageSendManage

+(void) sendMessageWithContacts:(NSMutableArray *) contactArray fileUrl:(nonnull NSURL *)fileURL
{
    NSArray *contacts = (NSArray *)contactArray;
    if (!contacts || contacts.count == 0) {
        return;
    }
    NSURL *fileUrl = fileURL;
    NSData *localFileData = [NSData dataWithContentsOfURL:fileURL];
    if (!localFileData) {
        [AppD.window showHint:@"File unavailable"];
        return;
    }
    NSString *fileName = [fileURL lastPathComponent];
    NSInteger fileT = [SystemUtil getAttNameType:fileName];
    @weakify_self
    [contacts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        long tempMsgid = (long)[ChatListDataUtil getShareObject].tempMsgId++;
        tempMsgid = [NSDate getTimestampFromDate:[NSDate date]]+tempMsgid;
                
        if (fileT == 1) {
            [SystemUtil saveImageForTtimeWithToid:model.userId fileName:fileName fileTime:[NSDate getTimestampFromDate:[NSDate date]]];
        }
                
                if (model.isGroup) { // 转发到群聊
                    // 自己私钥解密
                    NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:model.publicKey];
                    // 截取前16位
                    if (!datakey || datakey.length == 0) {
                        return;
                    }
                    datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
                    
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            
                            NSString *mills = [NSString stringWithFormat:@"%llu",[NSDate getMillisecondTimestampFromDate:[NSDate date]]];
                            NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
                            int msgid = [mill intValue];
                            
                            // 自己私钥解密
                            NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:model.publicKey];
                            NSString *symmetKey = [[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding];
                            NSData *msgKeyData =[[symmetKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
                            NSData *fileDatas = aesEncryptData(localFileData,msgKeyData);
                            
                            NSString *fileInfo = @"";
                            if (fileT == 1) {
                                UIImage *img = [UIImage imageWithData:localFileData];
                                if (img) {
                                    fileInfo = [NSString stringWithFormat:@"%f*%f",img.size.width,img.size.height];
                                }
                                
                            } else if (fileT == 5) {
                                UIImage *img = [SystemUtil thumbnailImageForVideo:fileUrl];
                                if (img) {
                                    fileInfo = [NSString stringWithFormat:@"%f*%f",img.size.width,img.size.height];
                                }
                            }
                            
                            [weakSelf sendGroupFileWithToid:model.userId fileName:fileName fileData:fileDatas fileId:msgid fileType:(int)fileT messageId:[NSString stringWithFormat:@"%d",msgid] srcKey:@"" dsKey:@"" publicKey:model.publicKey msgKey:@"" fileInfo:fileInfo];
                            
                        });
                    
                    
                } else {
                    model.publicKey = [model.publicKey stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            
                           
                            NSString *mills = [NSString stringWithFormat:@"%llu",[NSDate getMillisecondTimestampFromDate:[NSDate date]]];
                            NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
                            int msgid = [mill intValue];
                            
                            // 生成32位对称密钥
                            NSString *msgKey = [SystemUtil get32AESKey];
                           
                            NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
                            NSString *symmetKey = [symmetData base64EncodedString];
                            // 好友公钥加密对称密钥
                            NSString *dsKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:model.publicKey];
                            // 自己公钥加密对称密钥
                            NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
                            
                            NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
                            NSData *enData = aesEncryptData(localFileData,msgKeyData);
                            
                            NSString *fileInfo = @"";
                            if (fileT == 1) {
                                UIImage *img = [UIImage imageWithData:localFileData];
                                if (img) {
                                    fileInfo = [NSString stringWithFormat:@"%f*%f",img.size.width,img.size.height];
                                }
                                
                            } else if (fileT == 5) {
                                UIImage *img = [SystemUtil thumbnailImageForVideo:fileUrl];
                                if (img) {
                                    fileInfo = [NSString stringWithFormat:@"%f*%f",img.size.width,img.size.height];
                                }
                            }
                            
                            [weakSelf sendFileWithToid:model.userId fileName:fileName fileData:enData fileId:msgid fileType:(int)fileT messageId:[NSString stringWithFormat:@"%d",msgid] srcKey:srcKey dsKey:dsKey publicKey:model.publicKey msgKey:msgKey fileInfo:fileInfo];
                            
                        });
                }
        
        if (idx == contacts.count-1) {
            [AppD.window showHint:@"Has been sent"];
        }
    }];
}

#pragma mark --------群聊发送文件---------
+ (void) sendGroupFileWithToid:(NSString *) toId fileName:(NSString *) fileName fileData:(NSData *) fileData fileId:(int) fileId fileType:(int) fileType messageId:(NSString *) messageId srcKey:(NSString *) srcKey dsKey:(NSString *) dsKey publicKey:(NSString *) publicKey msgKey:(NSString *) msgKey fileInfo:(NSString *) fileInfo
{
    if ([SystemUtil isSocketConnect]) {
        
        ChatModel *chatModel = [[ChatModel alloc] init];
        chatModel.fromId = [UserConfig getShareObject].userId;
        chatModel.toId = toId;
        chatModel.fileInfo = fileInfo;
        chatModel.toPublicKey = publicKey;
        chatModel.msgType = fileType;
        chatModel.fileSize = fileData.length;
        chatModel.msgid = (long)[messageId integerValue];
        chatModel.bg_tableName = CHAT_CACHE_TABNAME;
        chatModel.fileName = fileName;
        chatModel.filePath =[[SystemUtil getBaseFilePath:toId] stringByAppendingPathComponent:fileName];
        chatModel.srcKey = srcKey;
        chatModel.dsKey = dsKey;
        chatModel.msgKey = msgKey;
        chatModel.sendTime = [NSDate getTimestampFromDate:[NSDate date]];
        [chatModel bg_save];
        
        
        SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
        dataUtil.fileInfo = fileInfo;
        [dataUtil sendFileId:toId fileName:fileName fileData:fileData fileid:fileId fileType:fileType messageid:messageId srcKey:srcKey dstKey:dsKey isGroup:YES];
        [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
    } else {
        
        NSString *filePath = [[SystemUtil getTempBaseFilePath:toId] stringByAppendingPathComponent:[Base58Util Base58EncodeWithCodeName:fileName]];
        
        if ([fileData writeToFile:filePath atomically:YES]) {
            NSDictionary *parames = @{@"Action":@"GroupSendFileDone",@"UserId":[UserConfig getShareObject].userId,@"GId":toId,@"FileName":[Base58Util Base58EncodeWithCodeName:fileName],@"FileMD5":[MD5Util md5WithPath:filePath],@"FileSize":@(fileData.length),@"FileType":@(fileType),@"DstKey":dsKey,@"FileId":messageId,@"FileInfo":fileInfo};
            [SendToxRequestUtil sendFileWithFilePath:filePath parames:parames];
        }
    }
}

/**
 发送文件

 @param toId toid
 @param fileName fileName
 @param fileData fileData
 @param fileId fileId
 @param fileType fileType
 @param messageId messageId
 @param srcKey srcKey
 @param dsKey dsKey
 @param publicKey publicKey
 @param msgKey msgKey
 @param fileInfo fileInfo
 */
+ (void) sendFileWithToid:(NSString *) toId fileName:(NSString *) fileName fileData:(NSData *) fileData fileId:(int) fileId fileType:(int) fileType messageId:(NSString *) messageId srcKey:(NSString *) srcKey dsKey:(NSString *) dsKey publicKey:(NSString *) publicKey msgKey:(NSString *) msgKey fileInfo:(NSString *) fileInfo
{
    if ([SystemUtil isSocketConnect]) {
        ChatModel *chatModel = [[ChatModel alloc] init];
        chatModel.fromId = [UserConfig getShareObject].userId;
        chatModel.toId = toId;
        chatModel.toPublicKey = publicKey;
        chatModel.msgType = fileType;
        chatModel.fileSize = fileData.length;
        chatModel.msgid = (long)[messageId integerValue];
        chatModel.bg_tableName = CHAT_CACHE_TABNAME;
        chatModel.fileName = fileName;
        //chatModel.filePath =[[SystemUtil getBaseFilePath:toId] stringByAppendingPathComponent:fileName];
        chatModel.srcKey = srcKey;
        chatModel.dsKey = dsKey;
        chatModel.msgKey = msgKey;
        chatModel.sendTime = [NSDate getTimestampFromDate:[NSDate date]];
       
        NSString *fileNameInfo = fileName;
        if (fileInfo && fileInfo.length>0) {
            fileNameInfo = [NSString stringWithFormat:@"%@,%@",fileNameInfo,fileInfo];
            chatModel.fileName = fileNameInfo;
        }
        [chatModel bg_save];
        SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
        [dataUtil sendFileId:toId fileName:fileNameInfo fileData:fileData fileid:fileId fileType:fileType messageid:messageId srcKey:srcKey dstKey:dsKey isGroup:NO];
        [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
    } else {
        NSString *filePath = [[SystemUtil getTempBaseFilePath:toId] stringByAppendingPathComponent:[Base58Util Base58EncodeWithCodeName:fileName]];
        
        if ([fileData writeToFile:filePath atomically:YES]) {
            
            if (fileInfo && fileInfo.length > 0) {
                NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":[UserConfig getShareObject].userId,@"ToId":toId,@"FileName":[Base58Util Base58EncodeWithCodeName:fileName],@"FileMD5":[MD5Util md5WithPath:filePath],@"FileSize":@(fileData.length),@"FileType":@(fileType),@"SrcKey":srcKey,@"DstKey":dsKey,@"FileId":messageId,@"FileInfo":fileInfo};
                [SendToxRequestUtil sendFileWithFilePath:filePath parames:parames];
            } else {
                NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":[UserConfig getShareObject].userId,@"ToId":toId,@"FileName":[Base58Util Base58EncodeWithCodeName:fileName],@"FileMD5":[MD5Util md5WithPath:filePath],@"FileSize":@(fileData.length),@"FileType":@(fileType),@"SrcKey":srcKey,@"DstKey":dsKey,@"FileId":messageId,@"FileInfo":fileInfo};
                [SendToxRequestUtil sendFileWithFilePath:filePath parames:parames];
            }
        }
    }
    
    [FIRAnalytics logEventWithName:kFIREventSelectContent
    parameters:@{
                 kFIRParameterItemID:FIR_CHAT_SEND_FILE,
                 kFIRParameterItemName:FIR_CHAT_SEND_FILE,
                 kFIRParameterContentType:FIR_CHAT_SEND_FILE
                 }];
}

+(void) sendMessageWithContacts:(NSArray *) contactArray messageStr:(NSString *) messageStr
{

    FriendModel *friendModel = contactArray[0];
    NSDictionary *params = @{@"Action":@"SendMsg",@"To":friendModel.userId?:@"",@"From":[UserConfig getShareObject].userId?:@"",@"Msg":[messageStr base64EncodedString]?:@"",@"Sign":@"",@"Nonce":@"",@"PriKey":@"",@"AssocId":@(0),@"MsgType":@(0x11)};
    
    long tempMsgid = (long)[ChatListDataUtil getShareObject].tempMsgId++;
    tempMsgid = [NSDate getTimestampFromDate:[NSDate date]]+tempMsgid;
    NSString *messageId = [NSString stringWithFormat:@"%ld",(long)tempMsgid];
    
    [SocketMessageUtil sendChatTextWithParams:params withSendMsgId:messageId];
}
@end
