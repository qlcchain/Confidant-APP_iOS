//
//  SendCacheChatUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/2/27.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "SendCacheChatUtil.h"
#import "ChatModel.h"
#import "UserModel.h"
#import "NSDate+Category.h"
#import "SocketMessageUtil.h"
#import "LibsodiumUtil.h"
#import "EntryModel.h"
#import "SocketDataUtil.h"
#import "SocketManageUtil.h"
#import "AESCipher.h"
#import "SystemUtil.h"

const NSInteger sendTime = 10;
const NSInteger timerTime = 10;

@interface SendCacheChatUtil ()
{
    dispatch_source_t _timer;
}
@end

@implementation SendCacheChatUtil
+ (instancetype) getSendCacheChatUtilShare
{
    static SendCacheChatUtil *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
    });
    return shareObject;
}

- (void)start
{
    if (![SystemUtil isSocketConnect]) {
        return;
    }
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    //dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0 * NSEC_PER_SEC); // 开始时间
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),timerTime*NSEC_PER_SEC, 0); //每10秒执行
    @weakify_self
    dispatch_source_set_event_handler(_timer, ^{
       
        [weakSelf sendCacheChat];
    });
    dispatch_resume(_timer);
}

- (void) stop {
    if (_timer) {
        dispatch_cancel(_timer);
    }
}

- (void) sendCacheChat
{
    NSArray *chats = [ChatModel bg_find:CHAT_CACHE_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"fromId"),bg_sqlValue([UserModel getUserModel].userId)]];
    if (chats && chats.count > 0) {
        @weakify_self
        [chats enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChatModel *model = obj;
            if (model.msgType == 0) { // 文字
               NSDate *sendDate = [NSDate dateWithTimeIntervalSince1970:model.sendTime];
              NSInteger secons = [sendDate millesAfterDate:[NSDate date]];
                if (labs(secons) >= sendTime) {
                    // 如果 10s 没有发送成功，就重发
                    [weakSelf sendTextMessageWithChatModel:model];
                }
            } else {
                // 如果是文件，发送失败则重发
                if (model.isSendFailed) {
                    // 更新状态为正在发送
                    model.isSendFailed = NO;
                    [model bg_saveOrUpdate];
                    [weakSelf sendFileWithChatModel:model];
                }
            }
        }];
    }
}
// 发送文件
- (void) sendFileWithChatModel:(ChatModel *) model
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *msgKeyData =[[model.msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
        NSString *filePath = [[SystemUtil getBaseFilePath:model.toId] stringByAppendingPathComponent:model.fileName];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        if (fileData) {
            fileData = aesEncryptData(fileData,msgKeyData);
            dispatch_async(dispatch_get_main_queue(), ^{
                SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
                [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
                [dataUtil sendFileId:model.toId fileName:model.fileName fileData:fileData fileid:(int)model.msgid fileType:model.msgType messageid:[NSString stringWithFormat:@"%ld",model.msgid] srcKey:model.srcKey dstKey:model.dsKey];
            });
        }
    });
}

// 发送文字消息
- (void) sendTextMessageWithChatModel:(ChatModel *) model
{
    // 生成签名
    NSString *signString = [LibsodiumUtil getOwenrSignPrivateKeySignOwenrTempPublickKey];
    // 生成nonce
    NSString *nonceString = [LibsodiumUtil getGenterSysmetryNonce];
    // 生成对称密钥
    NSString *symmetryString = [LibsodiumUtil getSymmetryWithPrivate:[EntryModel getShareObject].tempPrivateKey publicKey:model.toPublicKey];
    // 加密消息
    NSString *msg = [LibsodiumUtil encryMsgPairWithSymmetry:symmetryString enMsg:model.messageMsg?:@"" nonce:nonceString];
    // 加密对称密钥
    NSString *enSymmetString = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetryString enPK:[EntryModel getShareObject].publicKey];
    
    NSDictionary *params = @{@"Action":@"SendMsg",@"To":model.toId?:@"",@"From":model.fromId?:@"",@"Msg":msg?:@"",@"Sign":signString?:@"",@"Nonce":nonceString?:@"",@"PriKey":enSymmetString?:@""};
    [SocketMessageUtil sendChatTextWithParams:params withSendMsgId:[NSString stringWithFormat:@"%ld",model.msgid]];
}

@end
