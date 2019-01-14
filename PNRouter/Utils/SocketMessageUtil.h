//
//  SocketMessageUtil.h
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/7.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FriendModel;

@interface SocketMessageUtil : NSObject
+ (NSDictionary *)getBaseParams;
+ (NSDictionary *)getRegiserBaseParams;
+ (void)sendTextWithParams:(NSDictionary *)params;
+ (void)sendVersion2WithParams:(NSDictionary *)params;
// 回复router
+ (void)sendRecevieMessageWithParams:(NSDictionary *)params tempmsgid:(NSInteger) msgid;
+ (void)receiveText:(NSString *)text;
+ (void)sendText:(NSString *)text;
// 同意或拒绝好友请求
+ (void) sendAgreedOrRefusedWithFriendMode:(FriendModel *) model withType:(NSString *) type;
// 查询用户是否在线
+ (void) sendUserIsOnLine:(NSString *) friendUserId;
// 发送拉取好友列表请求
+ (void) sendFriendListRequest;
+ (NSString *)sendChatTextWithParams:(NSDictionary *)params;
/**
 重新发送文本聊天消息 ->msgid
 */
+ (void)sendChatTextWithParams:(NSDictionary *)params withSendMsgId:(NSString *) msgid;
@end
