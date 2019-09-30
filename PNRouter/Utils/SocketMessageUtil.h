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
static NSString *Action_Recovery = @"Recovery";
static NSString *Action_Register = @"Register";
static NSString *Action_FileForward = @"FileForward";
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
static NSString *Action_PullSharedFriend = @"PullSharedFriend";
static NSString *Action_ShareFile = @"ShareFile";
static NSString *Action_GetDiskTotalInfo = @"GetDiskTotalInfo";
static NSString *Action_GetDiskDetailInfo = @"GetDiskDetailInfo";
static NSString *Action_FormatDisk = @"FormatDisk";
static NSString *Action_Reboot = @"Reboot";
static NSString *Action_EnableQlcNode = @"EnableQlcNode";
static NSString *Action_CheckQlcNode = @"CheckQlcNode";

static NSString *Action_ResetRouterName = @"ResetRouterName";
static NSString *Action_UploadAvatar = @"UploadAvatar";
static NSString *Action_UpdateAvatar = @"UpdateAvatar";
static NSString *Action_FileRename = @"FileRename";
static NSString *Action_PullTmpAccount = @"PullTmpAccount";
static NSString *Action_SysMsgPush = @"SysMsgPush";

// 群组的相关action
static NSString *Action_CreateGroup = @"CreateGroup";
static NSString *Action_GroupInvitePush = @"GroupInvitePush";
static NSString *Action_InviteGroup = @"InviteGroup";
static NSString *Action_GroupInviteDeal = @"GroupInviteDeal";
static NSString *Action_GroupVerifyPush = @"GroupVerifyPush";
static NSString *Action_GroupVerify = @"GroupVerify";
static NSString *Action_GroupQuit = @"GroupQuit";
static NSString *Action_GroupListPull = @"GroupListPull";
static NSString *Action_GroupUserPull = @"GroupUserPull";
static NSString *Action_GroupSendMsg = @"GroupSendMsg";
static NSString *Action_GroupMsgPull = @"GroupMsgPull";
static NSString *Action_GroupSendFileDone = @"GroupSendFileDone";
static NSString *Action_GroupMsgPush = @"GroupMsgPush";
static NSString *Action_GroupConfig = @"GroupConfig";
static NSString *Action_GroupSysPush = @"GroupSysPush";
static NSString *Action_GroupDelMsg = @"GroupDelMsg";
static NSString *Action_DelUser = @"DelUser";

#pragma mark -------------Email-----------------
static NSString *Action_BakupEmail = @"BakupEmail";
static NSString *Action_SaveEmailConf = @"SaveEmailConf";
static NSString *Action_GetUmailKey = @"CheckmailUkey";
static NSString *Action_BakMailsNum = @"BakMailsNum";
static NSString *Action_PullMailList = @"PullMailList";
static NSString *Action_DelEmail = @"DelEmail";
static NSString *Action_DelEmailConf = @"DelEmailConf";
static NSString *Action_BakMailsCheck = @"BakMailsCheck";
static NSString *Action_MailSendNotice = @"MailSendNotice";


@class FriendModel;

@interface SocketMessageUtil : NSObject

+ (NSDictionary *)getBaseParams;
+ (NSDictionary *)getRegiserBaseParams;
+ (void)sendVersion1WithParams:(NSDictionary *)params;
+ (void)sendVersion2WithParams:(NSDictionary *)params;
+ (void)sendVersion2WithParams:(NSDictionary *)params fetchParam:(void(^)(NSDictionary *dic))paramB;
+ (void)sendVersion3WithParams:(NSDictionary *)params;
+ (void)sendVersion4WithParams:(NSDictionary *)params;
+ (void)sendVersion5WithParams:(NSDictionary *)params;
+ (void)sendVersion6WithParams:(NSDictionary *)params;
+ (void)sendRecevieMessageWithParams5:(NSDictionary *)params;
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
+ (void)sendGroupChatTextWithParams:(NSDictionary *)params withSendMsgId:(NSString *) msgid;
// -设备管理员修改设备昵称
+ (void) sendUpdateRourerNickName:(NSString *) nickName showHud:(BOOL)showHud;

@end
