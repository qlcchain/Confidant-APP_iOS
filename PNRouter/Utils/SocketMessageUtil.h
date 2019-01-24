//
//  SocketMessageUtil.h
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/7.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *Action_login = @"Login";
static NSString *Action_Destory = @"Destory";
static NSString *Action_AddFriendReq = @"AddFriendReq";
static NSString *Action_AddFriendPush = @"AddFriendPush";
static NSString *Action_AddFriendDeal = @"AddFriendDeal";
static NSString *Action_AddFriendReply = @"AddFriendReply";
static NSString *Action_DelFriendCmd = @"DelFriendCmd";
static NSString *Action_DelFriendPush = @"DelFriendPush";
static NSString *Action_SendMsg = @"SendMsg";
static NSString *Action_PushMsg = @"PushMsg";
static NSString *Action_DelMsg = @"DelMsg";
static NSString *Action_PushDelMsg = @"PushDelMsg";
static NSString *Action_HeartBeat = @"HeartBeat";
static NSString *Action_OnlineStatusCheck = @"OnlineStatusCheck";
static NSString *Action_OnlineStatusPush = @"OnlineStatusPush";
static NSString *Action_PullMsg = @"PullMsg";
static NSString *Action_PullFriend = @"PullFriend";
static NSString *Action_PushFile = @"PushFile";
static NSString *Action_SynchDataFile = @"SynchDataFile";
static NSString *Aciont_Recovery = @"Recovery";
static NSString *Aciont_Register = @"Register";
static NSString *Action_PullUserList = @"PullUserList";
static NSString *Action_CreateNormalUser = @"CreateNormalUser";
static NSString *Action_ReadMsgPush = @"ReadMsgPush";
static NSString *Action_LogOut = @"LogOut";
static NSString *Action_UserInfoUpdate = @"UserInfoUpdate";
static NSString *Action_SendFile = @"SendFile";
static NSString *Action_PullFile = @"PullFile";
static NSString *Action_ChangeRemarks = @"ChangeRemarks";
static NSString *Action_QueryFriend = @"QueryFriend";
static NSString *Action_PushLogout = @"PushLogout";
static NSString *Action_RouterLogin = @"RouterLogin";
static NSString *Action_ResetRouterKey = @"ResetRouterKey";
static NSString *Action_ResetUserIdcode = @"ResetUserIdcode";
static NSString *Action_PullFileList = @"PullFileList";
static NSString *Action_UploadFileReq = @"UploadFileReq";
static NSString *Action_UploadFile = @"UploadFile";
static NSString *Action_DelFile = @"DelFile";

@class FriendModel;

@interface SocketMessageUtil : NSObject

+ (NSDictionary *)getBaseParams;
+ (NSDictionary *)getRegiserBaseParams;
+ (void)sendVersion1WithParams:(NSDictionary *)params;
+ (void)sendVersion2WithParams:(NSDictionary *)params;
+ (void)sendVersion3WithParams:(NSDictionary *)params;
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
