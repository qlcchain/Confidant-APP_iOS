//
//  SocketMessageUtil.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/7.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "SocketMessageUtil.h"
#import "PNRouter-Swift.h"
#import "NSDate+Category.h"
#import "NSDateFormatter+Category.h"
#import "NSString+UrlEncode.h"
#import "UserModel.h"
#import "RouterModel.h"
#import "FriendModel.h"
#import "NotifactionView.h"
//#import "MessageListUtil.h"
#import "CDMessageModel.h"
#import "PayloadModel.h"
#import "HeartBeatUtil.h"
#import "ChatListDataUtil.h"
#import "ChatListModel.h"
#import "NSDate+Category.h"
#import "SocketCountUtil.h"
#import "SystemUtil.h"
#import "NSDate+Category.h"
#import "FileModel.h"
#import "AESCipher.h"
#import "RSAUtil.h"
#import "RSAModel.h"
#import "NSString+Base64.h"
#import "RouterUserModel.h"
#import "MutManagerUtil.h"
#import "UserConfig.h"
#import "EntryModel.h"
#import "LibsodiumUtil.h"
#import "FileDownUtil.h"
#import "RouterConfig.h"
#import "ChatModel.h"
#import "SendCacheChatUtil.h"
#import "UserHeadUtil.h"
#import "GroupInfoModel.h"
#import "GroupMembersModel.h"
#import "NSString+HexStr.h"
#import "GroupVerifyModel.h"

#define PLAY_TIME 10.0f
#define PLAY_KEY @"PLAY_KEY"

@implementation SocketMessageUtil

/**
 发送文本消息
 */
+ (void)sendVersion1WithParams:(NSDictionary *)params{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:[SocketMessageUtil getBaseParams]];
//    NSString *paramsJson = params.mj_JSONString;
//    paramsJson = [paramsJson urlEncodeUsingEncoding:NSUTF8StringEncoding];
    [muDic setObject:params forKey:@"params"];
    NSString *text = muDic.mj_JSONString;

    dispatch_async(dispatch_get_main_queue(), ^{
        if (AppD.manager) {
            [SendToxRequestUtil sendTextMessageWithText:text manager:AppD.manager];
        } else {
            [SocketUtil.shareInstance sendWithText:text];
        }
    });
    
}

/**
 发送文本消息 3
 */
+ (void)sendVersion3WithParams:(NSDictionary *)params{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:[SocketMessageUtil getBaseParams3]];
    //    NSString *paramsJson = params.mj_JSONString;
    //    paramsJson = [paramsJson urlEncodeUsingEncoding:NSUTF8StringEncoding];
    [muDic setObject:params forKey:@"params"];
    NSString *text = muDic.mj_JSONString;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (AppD.manager) {
            [SendToxRequestUtil sendTextMessageWithText:text manager:AppD.manager];
        } else {
            [SocketUtil.shareInstance sendWithText:text];
        }
    });
    
}

/**
 发送文本消息 4
 */
+ (void)sendVersion4WithParams:(NSDictionary *)params {
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:[SocketMessageUtil getBaseParams4]];
    //    NSString *paramsJson = params.mj_JSONString;
    //    paramsJson = [paramsJson urlEncodeUsingEncoding:NSUTF8StringEncoding];
  
     NSMutableDictionary *paramsDic = [NSMutableDictionary dictionaryWithDictionary:params];
    if ([[NSString getNotNullValue:params[@"Action"]] isEqualToString:Action_Register] || [[NSString getNotNullValue:params[@"Action"]] isEqualToString:Action_login] ||[[NSString getNotNullValue:params[@"Action"]] isEqualToString:Action_AddFriendDeal]) {
        NSString *timestamp = muDic[@"timestamp"];
        NSString *signTime = [LibsodiumUtil getOwenrSignTemp:timestamp];
        [paramsDic setObject:signTime forKey:@"Sign"];
    }
    [muDic setObject:paramsDic forKey:@"params"];
    NSString *text = muDic.mj_JSONString;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (AppD.manager) {
            [SendToxRequestUtil sendTextMessageWithText:text manager:AppD.manager];
        } else {
            [SocketUtil.shareInstance sendWithText:text];
        }
    });
    
}


/**
 回复多段文本消息
 */
+ (void)sendMutTextWithParams:(NSDictionary *)params{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:params];
    
    [muDic setObject:@"" forKey:@"params"];
    
    NSString *text = muDic.mj_JSONString;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (AppD.manager) {
            [SendToxRequestUtil sendTextMessageWithText:text manager:AppD.manager];
        } else {
            [SocketUtil.shareInstance sendWithText:text];
        }
    });
    
}

/**
 发送注册登录找回文本消息  version2
 */
+ (void)sendVersion2WithParams:(NSDictionary *)params{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:[SocketMessageUtil getRegiserBaseParams]];
    //    NSString *paramsJson = params.mj_JSONString;
    //    paramsJson = [paramsJson urlEncodeUsingEncoding:NSUTF8StringEncoding];
    [muDic setObject:params forKey:@"params"];
    NSString *text = muDic.mj_JSONString;
    if (AppD.manager) {
        [SendToxRequestUtil sendTextMessageWithText:text manager:AppD.manager];
    } else {
        [SocketUtil.shareInstance sendWithText:text];
    }
}

+ (void)sendVersion2WithParams:(NSDictionary *)params fetchParam:(void(^)(NSDictionary *dic))paramB {
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:[SocketMessageUtil getRegiserBaseParams]];
    if (paramB) {
        paramB(muDic);
    }
    //    NSString *paramsJson = params.mj_JSONString;
    //    paramsJson = [paramsJson urlEncodeUsingEncoding:NSUTF8StringEncoding];
    [muDic setObject:params forKey:@"params"];
    NSString *text = muDic.mj_JSONString;
    if (AppD.manager) {
        [SendToxRequestUtil sendTextMessageWithText:text manager:AppD.manager];
    } else {
        [SocketUtil.shareInstance sendWithText:text];
    }
}


/**
 发送文本聊天消息 ->msgid
 */
+ (NSString *)sendChatTextWithParams:(NSDictionary *)params{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:[SocketMessageUtil getBaseParams3]];
    //    NSString *paramsJson = params.mj_JSONString;
    //    paramsJson = [paramsJson urlEncodeUsingEncoding:NSUTF8StringEncoding];
    [muDic setObject:params forKey:@"params"];
    NSString *text = muDic.mj_JSONString;
    
    if (AppD.manager) {
        [SendToxRequestUtil sendTextMessageWithText:text manager:AppD.manager];
    } else {
         [SocketUtil.shareInstance sendWithText:text];
    }
    return muDic[@"msgid"];
}

/**
 重新发送文本聊天消息 ->msgid
 */
+ (void)sendChatTextWithParams:(NSDictionary *)params withSendMsgId:(NSString *) msgid {
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:[SocketMessageUtil getRecevieBaseParams3:[msgid integerValue]]];
    //    NSString *paramsJson = params.mj_JSONString;
    //    paramsJson = [paramsJson urlEncodeUsingEncoding:NSUTF8StringEncoding];
    [muDic setObject:params forKey:@"params"];
    NSString *text = muDic.mj_JSONString;
    
    if (AppD.manager) {
        [SendToxRequestUtil sendTextMessageWithText:text manager:AppD.manager];
    } else {
        [SocketUtil.shareInstance sendWithText:text];
    }
}

/**
 发送群组消息文本聊天消息 ->msgid
 */
+ (void)sendGroupChatTextWithParams:(NSDictionary *)params withSendMsgId:(NSString *) msgid {
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:[SocketMessageUtil getRecevieBaseParams4:[msgid integerValue]]];
    //    NSString *paramsJson = params.mj_JSONString;
    //    paramsJson = [paramsJson urlEncodeUsingEncoding:NSUTF8StringEncoding];
    [muDic setObject:params forKey:@"params"];
    NSString *text = muDic.mj_JSONString;
    
    if (AppD.manager) {
        [SendToxRequestUtil sendTextMessageWithText:text manager:AppD.manager];
    } else {
        [SocketUtil.shareInstance sendWithText:text];
    }
}

/**
 发送文本消息  app->router
 */
+ (void)sendRecevieMessageWithParams:(NSDictionary *)params tempmsgid:(NSInteger) msgid{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:[SocketMessageUtil getRecevieBaseParams:msgid]];
    //    NSString *paramsJson = params.mj_JSONString;
    //    paramsJson = [paramsJson urlEncodeUsingEncoding:NSUTF8StringEncoding];
    [muDic setObject:params forKey:@"params"];
    NSString *text = muDic.mj_JSONString;
    
    if (AppD.manager) {
        [SendToxRequestUtil sendTextMessageWithText:text manager:AppD.manager];
    } else {
        [SocketUtil.shareInstance sendWithText:text];
    }
}

/**
 发送文本消息  app->router
 */
+ (void)sendRecevieMessageWithParams3:(NSDictionary *)params tempmsgid:(NSInteger) msgid{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:[SocketMessageUtil getRecevieBaseParams3:msgid]];
    //    NSString *paramsJson = params.mj_JSONString;
    //    paramsJson = [paramsJson urlEncodeUsingEncoding:NSUTF8StringEncoding];
    [muDic setObject:params forKey:@"params"];
    NSString *text = muDic.mj_JSONString;
    
    if (AppD.manager) {
        [SendToxRequestUtil sendTextMessageWithText:text manager:AppD.manager];
    } else {
        [SocketUtil.shareInstance sendWithText:text];
    }
}

+ (void)sendRecevieMessageWithParams4:(NSDictionary *)params tempmsgid:(NSInteger) msgid{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:[SocketMessageUtil getRecevieBaseParams4:msgid]];
    [muDic setObject:params forKey:@"params"];
    NSString *text = muDic.mj_JSONString;
    
    if (AppD.manager) {
        [SendToxRequestUtil sendTextMessageWithText:text manager:AppD.manager];
    } else {
        [SocketUtil.shareInstance sendWithText:text];
    }
}

/**
 发送文本消息  app->router
 */
+ (void)sendVersion2RecevieMessageWithParams:(NSDictionary *)params tempmsgid:(NSInteger) msgid{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:[SocketMessageUtil getRecevieBaseVersion2Params:msgid]];
    //    NSString *paramsJson = params.mj_JSONString;
    //    paramsJson = [paramsJson urlEncodeUsingEncoding:NSUTF8StringEncoding];
    [muDic setObject:params forKey:@"params"];
    NSString *text = muDic.mj_JSONString;
    
    if (AppD.manager) {
        [SendToxRequestUtil sendTextMessageWithText:text manager:AppD.manager];
    } else {
        [SocketUtil.shareInstance sendWithText:text];
    }
}
/**
 发送文本消息
 */
+ (void)sendText:(NSString *)text
{
    NSMutableDictionary *receiveDic = [NSMutableDictionary dictionaryWithDictionary:text.mj_JSONObject];
    NSString *action = receiveDic[@"params"][@"Action"];
    if (![Action_HeartBeat isEqualToString:action?:@""]) {
        DDLogDebug(@"发送消息: %@",text);
    }
    
}

/**
 接收文本消息
 */
+ (void)receiveText:(NSString *)text {

    NSMutableDictionary *receiveDic = [NSMutableDictionary dictionaryWithDictionary:text.mj_JSONObject];
    
    if (receiveDic[@"more"]) {
        NSString *params = receiveDic[@"params"];
        NSLog(@"params = %@",params);
        NSString *msgId = [NSString stringWithFormat:@"%@",receiveDic[@"msgid"]];
        
        // 当是第一块时，如果数据存在就删除
        if ([receiveDic[@"offset"] integerValue] == 0) {
            if (![[NSString getNotNullValue:[[MutManagerUtil getShareObject].mutTempDic objectForKey:msgId]] isEmptyString]) {
                [[MutManagerUtil getShareObject].mutTempDic removeObjectForKey:msgId];
            }
        }
        
        if ([receiveDic[@"more"] integerValue] == 1) {
            
            [[MutManagerUtil getShareObject].mutTempDic setObject:[NSString stringWithFormat:@"%@%@",[NSString getNotNullValue:[MutManagerUtil getShareObject].mutTempDic[msgId]],params?:@""] forKey:msgId];
            
             NSLog(@"mutTempDic = %@",[NSString getNotNullValue:[MutManagerUtil getShareObject].mutTempDic[msgId]]);
            
            NSMutableDictionary *parameDic = [NSMutableDictionary dictionaryWithDictionary:receiveDic];
            [parameDic removeObjectForKey:@"params"];
            parameDic[@"offset"] = [NSString stringWithFormat:@"%ld",[parameDic[@"offset"] integerValue] + 1100];
            [SocketMessageUtil sendMutTextWithParams:parameDic];
            
             return;
            
        } else {
            
             [[MutManagerUtil getShareObject].mutTempDic setObject:[NSString stringWithFormat:@"%@%@",[NSString getNotNullValue:[MutManagerUtil getShareObject].mutTempDic[msgId]],params?:@""] forKey:msgId];
            NSString *paramStr = [MutManagerUtil getShareObject].mutTempDic[msgId]?:@"";
            paramStr = [paramStr stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            [receiveDic setObject:paramStr.mj_JSONObject forKey:@"params"];
        }
       
    }
    
    NSString *action = receiveDic[@"params"][@"Action"];
    
    if (!([action isEqualToString:Action_login] || [action isEqualToString: Action_Register] || [action isEqualToString: Action_Recovery] || [action isEqualToString: Action_RouterLogin] || [action isEqualToString: Action_ResetRouterKey] || [action isEqualToString: Action_ResetUserIdcode])) {
        if (AppD.isLogOut) {
            return;
        }
    }
    
    if (![Action_HeartBeat isEqualToString:action]) {
        DDLogDebug(@"收到回复: %@",text);
    }
    
    if ([action isEqualToString:Action_login]) {
        [SocketMessageUtil handleLogin:receiveDic];
    } else if ([action isEqualToString:Action_Destory]) {
        
    } else if ([action isEqualToString:Action_AddFriendReq]) { // 发送添加好友请求
        [SocketMessageUtil handleAddFriendReq:receiveDic];
    } else if ([action isEqualToString:Action_AddFriendPush]) { // 收到加好友请求
        [SocketMessageUtil handleAddFriendPush:receiveDic];
    } else if ([action isEqualToString:Action_AddFriendDeal]) { // 用户可以选择是否允许对方添加自己好友  服务器收到回调
        [SocketMessageUtil handleAddFriendDeal:receiveDic];
    } else if ([action isEqualToString:Action_AddFriendReply]) { // 有好友通过或拒绝加您为好友回调
        [SocketMessageUtil handleAddFriendReply:receiveDic];
        
    } else if ([action isEqualToString:Action_DelFriendCmd]) {
        [SocketMessageUtil handleDelFriendCmd:receiveDic];
        
    } else if ([action isEqualToString:Action_DelFriendPush]) {
        [SocketMessageUtil handleDelFriendPush:receiveDic];
        
        
    } else if ([action isEqualToString:Action_SendMsg]) {
        [SocketMessageUtil handleSendMsg:receiveDic];
    } else if ([action isEqualToString:Action_PushMsg]) { // 收到消息
        [SocketMessageUtil handlePushMsg:receiveDic];
        
    } else if ([action isEqualToString:Action_DelMsg]) {
        [SocketMessageUtil handleDelMsg:receiveDic];
        
    } else if ([action isEqualToString:Action_PushDelMsg]) {
        [SocketMessageUtil handlePushDelMsg:receiveDic];
        
    } else if ([action isEqualToString:Action_HeartBeat]) {
        [SocketMessageUtil handleHeartBeat:receiveDic];
    } else if ([action isEqualToString:Action_OnlineStatusCheck]) { //APP向router请求单个好友在线状态回调
        [SocketMessageUtil handleOnlineStatusCheck:receiveDic];
        
    } else if ([action isEqualToString:Action_OnlineStatusPush]) { // 好友状态发生改变 0：离线 1：在线 2：隐身 3：忙碌
        [SocketMessageUtil handleOnlineStatusPush:receiveDic];
        
    } else if ([action isEqualToString:Action_PullMsg]) {
        [SocketMessageUtil handlePullMsg:receiveDic];
        
        
    } else if ([action isEqualToString:Action_PullFriend]) { // 拉取好友回调
        [SocketMessageUtil handlePullFriend:receiveDic];
    } else if ([action isEqualToString:Action_PushFile]) { //接收文件
        [SocketMessageUtil handlePushFile:receiveDic];
    } else if ([action isEqualToString:Action_Recovery]) { //APP用户找回
         [SocketMessageUtil handleFindRouter:receiveDic];
    }  else if ([action isEqualToString:Action_Register]) { //APP用户注册
        [SocketMessageUtil handleRegiserRouter:receiveDic];
    } else if ([action isEqualToString:Action_PullUserList]) {// 拉取派生帐户下的用户
        [SocketMessageUtil handlePullUserList:receiveDic];
    } else if ([action isEqualToString:Action_CreateNormalUser]) {//派生帐户创建普通帐户
        [SocketMessageUtil handleCreateNormalUser:receiveDic];
    } else if ([action isEqualToString:Action_ReadMsgPush]) { // 已读消息推送
        [SocketMessageUtil handleRedMsgPush:receiveDic];
    } else if ([action isEqualToString:Action_LogOut]) { // 登陆退出
        [SocketMessageUtil handleLogOut:receiveDic];
    } else if ([action isEqualToString:Action_UserInfoUpdate]) { // 修改昵称
        [SocketMessageUtil handleUserInfoUpdate:receiveDic];
    } else if ([action isEqualToString:Action_SendFile]) { // tox sendfile 回调
        [SocketMessageUtil handleSendFile:receiveDic];
    } else if ([action isEqualToString:Action_PullFile]) { // tox拉取文件回调
        [SocketMessageUtil handlePullFile:receiveDic];
    } else if ([action isEqualToString:Action_ChangeRemarks]) { //修改好友备注
        [SocketMessageUtil handleChangeRemarks:receiveDic];
    } else if ([action isEqualToString:Action_QueryFriend]) { //查看好友关系
        [SocketMessageUtil handleChangeQueryFriend:receiveDic];
    } else if ([action isEqualToString:Action_PushLogout]) { // app收到登出消息
        [SocketMessageUtil handlePushLogout:receiveDic];
    } else if ([action isEqualToString:Action_RouterLogin]) { // 路由器管理账户登陆
        [SocketMessageUtil handleDeviceLogin:receiveDic];
    } else if ([action isEqualToString:Action_ResetRouterKey]) { // 路由器修改管理密码
        [SocketMessageUtil handleResetRouterKey:receiveDic];
    } else if ([action isEqualToString:Action_ResetUserIdcode]) { // 路由器修改管理密码
        [SocketMessageUtil handleResetUserIdcode:receiveDic];
    } else if ([action isEqualToString:Action_PullFileList]) { // 拉取文件列表
        [SocketMessageUtil handlePullFileList:receiveDic];
    } else if ([action isEqualToString:Action_UploadFileReq]) { // 上传文件请求
        [SocketMessageUtil handleUploadFileReq:receiveDic];
    } else if ([action isEqualToString:Action_UploadFile]) { // 上传文件
        [SocketMessageUtil handleUploadFile:receiveDic];
    } else if ([action isEqualToString:Action_DelFile]) { // 删除文件
        [SocketMessageUtil handleDelFile:receiveDic];
    } else if ([action isEqualToString:Action_PullSharedFriend]) { // 拉取可分享文件好友列表
        [SocketMessageUtil handlePullSharedFriend:receiveDic];
    } else if ([action isEqualToString:Action_ShareFile]) { // 分享文件
        [SocketMessageUtil handleShareFile:receiveDic];
    } else if ([action isEqualToString:Action_GetDiskTotalInfo]) { // 设备磁盘统计信息
        [SocketMessageUtil handleGetDiskTotalInfo:receiveDic];
    } else if ([action isEqualToString:Action_GetDiskDetailInfo]) { // 设备磁盘详细信息
        [SocketMessageUtil handleGetDiskDetailInfo:receiveDic];
    } else if ([action isEqualToString:Action_FormatDisk]) { // 设备磁盘模式配置
        [SocketMessageUtil handleFormatDisk:receiveDic];
    } else if ([action isEqualToString:Action_Reboot]) { // 设备重启
        [SocketMessageUtil handleReboot:receiveDic];
    } else if ([action isEqualToString:Action_ResetRouterName]) { // 设备管理员修改设备昵称
        [SocketMessageUtil handleResetRouterName:receiveDic];
    } else if ([action isEqualToString:Action_FileRename]) { // 文件重命名
        [SocketMessageUtil handleFileRename:receiveDic];
    } else if ([action isEqualToString:Action_FileForward]) { // 文件转发
         [SocketMessageUtil handleFileForward:receiveDic];
    } else if ([action isEqualToString:Action_UploadAvatar]) { // 用户上传头像
        [SocketMessageUtil handleUploadAvatar:receiveDic];
    } else if ([action isEqualToString:Action_UpdateAvatar]) { // 更新好友头像
        [SocketMessageUtil handleUpdateAvatar:receiveDic];
    } else if ([action isEqualToString:Action_CreateGroup]) { // 创建群组
        [SocketMessageUtil handleCreateGroup:receiveDic];
    } else if ([action isEqualToString:Action_GroupListPull]) { // 拉取群组
        [SocketMessageUtil handleGroupListPull:receiveDic];
    } else if ([action isEqualToString:Action_GroupUserPull]) { // 拉取群好友信息
        [SocketMessageUtil handleGroupUserPull:receiveDic];
    } else if ([action isEqualToString:Action_InviteGroup]) { // 加入群聊
        [SocketMessageUtil handleInviteGroup:receiveDic];
    } else if ([action isEqualToString:Action_GroupSendMsg]) { // 发送消息
        [SocketMessageUtil handleGroupSendMsg:receiveDic];
    } else if ([action isEqualToString:Action_GroupMsgPull]) { // 拉取群聊消息
         [SocketMessageUtil handleGroupMsgPull:receiveDic];
    } else if ([action isEqualToString:Action_GroupSendFileDone]){ // 发送群聊文件成功
        [SocketMessageUtil handleGroupSendFilePre:receiveDic];
    } else if ([action isEqualToString:Action_GroupMsgPush]) { // 群消息推送
         [SocketMessageUtil handleGroupMsgPush:receiveDic];
    } else if ([action isEqualToString:Action_GroupConfig]) { // 77.    群属性设置
        [SocketMessageUtil handleGroupConfig:receiveDic];
    } else if ([action isEqualToString:Action_GroupSysPush]) { // 群消息系统推送
        [SocketMessageUtil handleGroupSysPush:receiveDic];
    } else if ([action isEqualToString:Action_GroupDelMsg]) { // 删除群消息
        [SocketMessageUtil handleGroupDelMsg:receiveDic];
    } else if ([action isEqualToString:Action_GroupQuit]) { // 68.    用户退群
        [SocketMessageUtil handleGroupQuit:receiveDic];
    } else if ([action isEqualToString:Action_GroupVerifyPush]) { // 65.    邀请用户入群审核推送
        [SocketMessageUtil handleGroupVerifyPush:receiveDic];
    } else if ([action isEqualToString:Action_GroupVerify]) { // 66.    邀请用户入群审核处理
        [SocketMessageUtil handleGroupVerify:receiveDic];
    } else if ([action isEqualToString:Action_PullTmpAccount]) { // 拉取临时通信二维码
        [SocketMessageUtil handlePullTmpAccount:receiveDic];
    }
}

#pragma mark -APP新用户预注册
/*
 0：目标账号已激活
 1：目标账号未激活
 2：rid错误
 3：临时账户
 4：其他错误
 */
+ (void) handleFindRouter:(NSDictionary *) receiveDic
{
    [AppD.window hideHud];
     NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    if (retCode == 2) {
        [AppD.window showHint:@"Router id error"];
    } else if (retCode == 4){
        [AppD.window showHint:@"Other error"];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:USER_FIND_RECEVIE_NOTI object:receiveDic];
    }
}
#pragma mark - 注册回调
+ (void) handleRegiserRouter:(NSDictionary *) receiveDic
{
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    if (retCode == 1) {
        [AppD.window showHint:@"Router id error"];
    } else if (retCode == 2) {
        [AppD.window showHint:@"The qr code has been activated by other users"];
    } else if (retCode == 3) {
        [AppD.window showHint:@"Error verification coder"];
    }else if (retCode == 4) {
        [AppD.window showHint:@"Other error"];
    } else if (retCode == 0) {
        // 开始心跳
        [HeartBeatUtil start];
         [[NSNotificationCenter defaultCenter] postNotificationName:USER_REGISTER_RECEVIE_NOTI object:receiveDic];
        [[NSNotificationCenter defaultCenter] postNotificationName:REGISTER_PUSH_NOTI object:nil];
        // 发送未完成消息
        [[SendCacheChatUtil getSendCacheChatUtilShare] start];
    }
}
#pragma mark -拉取用户
+ (void) handlePullUserList:(NSDictionary *) receiveDic
{
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    if (retCode == 0) {
        NSString *Payload = receiveDic[@"params"][@"Payload"];
        NSArray *payloadArr = [RouterUserModel mj_objectArrayWithKeyValuesArray:Payload.mj_JSONObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:USER_PULL_SUCCESS_NOTI object:payloadArr];
    } else {
        [AppD.window showHint:@"User pull failed"];
    }
}

#pragma mark -派生创建普通
+ (void) handleCreateNormalUser:(NSDictionary *) receiveDic
{
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    if (retCode == 0) {
        NSString *qrCode = receiveDic[@"params"][@"Qrcode"];
        [[NSNotificationCenter defaultCenter] postNotificationName:CREATE_USER_SUCCESS_NOTI object:qrCode];
    } else if (retCode == 1){
        [AppD.window showHint:@"Rid error."];
    } else if (retCode == 2){
        [AppD.window showHint:@"Have no legal power"];
    } else if (retCode == 3){
        [AppD.window showHint:@"The user limit has been reached"];
    }
}
#pragma mark - 已读消息回调
+ (void) handleRedMsgPush:(NSDictionary *)receiveDic {
    
    // 回复router
    NSInteger tempmsgid = [receiveDic objectForKey:@"msgid"]?[[receiveDic objectForKey:@"msgid"] integerValue]:0;
    NSDictionary *parames = @{@"Action":Action_ReadMsgPush,@"RetCode":@"0",@"Msg":@"",@"ToId":[UserConfig getShareObject].userId};
    [SocketMessageUtil sendVersion2RecevieMessageWithParams:parames tempmsgid:tempmsgid];
    
    NSString *fromId = receiveDic[@"params"][@"UserId"];
    NSString *msgIds = [NSString stringWithFormat:@"%@",receiveDic[@"params"][@"ReadMsgs"]];
    [[NSNotificationCenter defaultCenter] postNotificationName:REVER_RED_MSG_NOTI object:@[fromId,msgIds]];
}

#pragma mark - 退出登陆
+ (void) handleLogOut:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:REVER_LOGOUT_SUCCESS_NOTI object:nil];
    } else {
        [AppD.window showHint:@"LogOut Failure."];
    }
}
#pragma mark - 修改昵称
+ (void) handleUserInfoUpdate:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:REVER_UPDATE_NICKNAME_SUCCESS_NOTI object:nil];
    } else {
        [AppD.window showHint:@"Update NickName Failure."];
    }
}
#pragma mark - 修改好友昵称
+ (void) handleChangeRemarks:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:REVER_UPDATE_FRIEND_NICKNAME_SUCCESS_NOTI object:nil];
    } else {
        [AppD.window showHint:@"Update NickName Failure."];
    }
}
#pragma mark -sendfile 回调
+ (void) handleSendFile:(NSDictionary *)receiveDic {
     NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
     NSString *toId = receiveDic[@"params"][@"ToId"];
     NSString *msgId = [NSString stringWithFormat:@"%@",receiveDic[@"params"][@"MsgId"]];
     NSString *fileId = [NSString stringWithFormat:@"%@",receiveDic[@"params"][@"FileId"]];
    NSString *fileType = [NSString stringWithFormat:@"%@",receiveDic[@"params"][@"FileType"]];
    
     [[NSNotificationCenter defaultCenter] postNotificationName:FILE_SEND_NOTI object:@[@(retCode),msgId,toId,fileType,fileId,msgId]];
    
    if (retCode == 0) {
        // 添加到chatlist
        ChatListModel *chatModel = [[ChatListModel alloc] init];
        chatModel.myID = [UserConfig getShareObject].userId;
        chatModel.friendID = toId;
        chatModel.chatTime = [NSDate date];
        chatModel.isHD = NO;
        NSInteger msgType = [fileType integerValue];
        if (msgType == 1) {
            chatModel.lastMessage = @"[photo]";
        } else if (msgType == 2) {
            chatModel.lastMessage = @"[voice]";
        } else if (msgType == 5){
            chatModel.lastMessage = @"[file]";
        } else if (msgType == 4){
            chatModel.lastMessage = @"[video]";
        }
        [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
    }
}

#pragma mark -tox pull文件
+ (void) handlePullFile:(NSDictionary *)receiveDic {
    NSDictionary *jsonDic = receiveDic[@"params"];
    FileModel *fileModel = [FileModel mj_objectWithKeyValues:jsonDic];
    if ([[FileDownUtil getShareObject] isTaskFileOption]) {
        [[FileDownUtil getShareObject] setTaskFile:NO];
        [[FileDownUtil getShareObject] updateFileDataBaseWithFileModel:fileModel];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:REVER_FILE_PULL_NOTI object:fileModel];
    }
   
}


// route-app 接受文件
+ (void) handlePushFile:(NSDictionary *) receiveDic {

    NSDictionary *jsonDic = receiveDic[@"params"];
    NSInteger tempmsgid = [receiveDic objectForKey:@"msgid"]?[[receiveDic objectForKey:@"msgid"] integerValue]:0;
    FileModel *fileModel = [FileModel mj_objectWithKeyValues:jsonDic];
    fileModel.timestamp = [receiveDic[@"timestamp"] integerValue];
    NSString *retcode = @"0"; // 0：请求接收到   1：其他错误
    NSDictionary *params = @{@"Action":Action_PushFile,@"Retcode":retcode,@"FromId":fileModel.FromId,@"ToId":fileModel.ToId,@"MsgId":fileModel.MsgId};
    [SocketMessageUtil sendRecevieMessageWithParams:params tempmsgid:tempmsgid];
    
    // 添加到chatlist
    ChatListModel *chatModel = [[ChatListModel alloc] init];
    chatModel.myID = fileModel.ToId;
    chatModel.friendID = fileModel.FromId;
    chatModel.chatTime = [NSDate date];
    chatModel.isHD = ![chatModel.friendID isEqualToString:[SocketCountUtil getShareObject].chatToId];
    if (fileModel.FileType == 1) {
        chatModel.lastMessage = @"[photo]";
    } else if (fileModel.FileType == 2) {
        chatModel.lastMessage = @"[voice]";
    } else if (fileModel.FileType == 5){
        chatModel.lastMessage = @"[file]";
    } else if (fileModel.FileType == 4) {
        chatModel.lastMessage = @"[video]";
    }
    
    // 收到好友消息播放系统声音
    if (!([SocketCountUtil getShareObject].chatToId && [[SocketCountUtil getShareObject].chatToId isEqualToString:chatModel.friendID])) { // 不在当前聊天界面
        // 判断时间 间隔10秒
        NSString *formatDate = [HWUserdefault getObjectWithKey:PLAY_KEY];
        NSDateFormatter *format =[NSDateFormatter defaultDateFormatter];
        if (formatDate) {
            NSDate *date = [format dateFromString:formatDate];
            NSTimeInterval timeInterval =  [[NSDate date] timeIntervalSinceDate:date];
            if (timeInterval >PLAY_TIME) {
                [SystemUtil playSystemSound];
                [HWUserdefault updateObject:[format stringFromDate:[NSDate date]]withKey:PLAY_KEY];
            }
        } else {
            [SystemUtil playSystemSound];
            [HWUserdefault updateObject:[format stringFromDate:[NSDate date]]withKey:PLAY_KEY];
        }
        
    }
    [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEVIE_FILE_NOTI object:fileModel];
    
}

+ (void) handleChangeQueryFriend:(NSDictionary *)receiveDic {
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    if (retCode == 1) {
         NSString *toId = receiveDic[@"params"][@"FriendId"];
        [[NSNotificationCenter defaultCenter] postNotificationName:REVER_QUERY_FRIEND_NOTI object:toId?:@""];
    }
}

+ (void) handlePushLogout:(NSDictionary *)receiveDic {
    
   NSString *userId = receiveDic[@"params"][@"UserId"];
    if ([[NSString getNotNullValue:userId] isEqualToString:[UserConfig getShareObject].userId]) {
        NSDictionary *params = @{@"Action":Action_PushLogout,@"RetCode":@(0),@"ToId":[UserConfig getShareObject].userId,@"Msg":@""};
        [SocketMessageUtil sendVersion1WithParams:params];
        [[NSNotificationCenter defaultCenter] postNotificationName:REVER_APP_LOGOUT_NOTI object:nil];
    }
}



+ (void)handleAddFriendPush:(NSDictionary *)receiveDic {
    FriendModel *model = [[FriendModel alloc] init];
    //model.userId = receiveDic[@"params"][@"UserId"];
    model.userId = receiveDic[@"params"][@"FriendId"];
    model.username= [receiveDic[@"params"][@"NickName"] base64DecodedString];
    model.publicKey= receiveDic[@"params"][@"UserKey"];
    model.signPublicKey= receiveDic[@"params"][@"UserKey"];
    model.msg= receiveDic[@"params"][@"Msg"];
    model.requestTime = [NSDate date];
    model.isUnRead = YES;
    model.bg_createTime = [NSString stringWithFormat:@"%@",receiveDic[@"params"][@"timestamp"]];
    model.owerId = [UserConfig getShareObject].userId;
    model.bg_tableName = FRIEND_REQUEST_TABNAME;
    
    NSString *retcode = @"0"; // 0：请求接收到   1：其他错误
    NSDictionary *params = @{@"Action":@"AddFriendPush",@"Retcode":retcode,@"Msg":@"",@"ToId":[UserConfig getShareObject].userId};
    NSLog(@"msgid = %@",[receiveDic objectForKey:@"msgid"]);
    
    NSInteger tempmsgid = [receiveDic objectForKey:@"msgid"]?[[receiveDic objectForKey:@"msgid"] integerValue]:0;
    [SocketMessageUtil sendRecevieMessageWithParams4:params tempmsgid:tempmsgid];
    
    NSArray *finfAlls = [FriendModel bg_find:FRIEND_REQUEST_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue(model.userId),bg_sqlKey(@"owerId"),bg_sqlValue(model.owerId)]];
    if (!finfAlls || finfAlls.count == 0) {
        if ([SystemUtil isFriendWithFriendid:model.userId]) {
            model.dealStaus = 1;
            [SocketMessageUtil sendAgreedOrRefusedWithFriendMode:model withType:[NSString stringWithFormat:@"%d",0]];
            [model bg_saveOrUpdate];
        } else {
            // 弹出对方请求加您为好友的通知
            NotifactionView *notiView = [NotifactionView loadNotifactionView];
            notiView.lblTtile.text = [NSString stringWithFormat:@"\"%@\" Request to friend you",model.username];
            [notiView show];
            // 播放系统声音
            [SystemUtil playSystemSound];
            AppD.showNewFriendAddRequestRedDot = YES;
            [model bg_saveOrUpdate];
            [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_CONTACT_HD_NOTI object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:REQEUST_ADD_FRIEND_NOTI object:nil];
        }
    } else {
        FriendModel *model1 = [finfAlls firstObject];
         model1.requestTime = [NSDate date];
        if (model1.dealStaus == 2) {
            model1.dealStaus = 0;
            // 弹出对方请求加您为好友的通知
            NotifactionView *notiView = [NotifactionView loadNotifactionView];
            notiView.lblTtile.text = [NSString stringWithFormat:@"\"%@\" Request to friend you",model.username];
            [notiView show];
            // 播放系统声音
            [SystemUtil playSystemSound];
            AppD.showNewFriendAddRequestRedDot = YES;
            [model1 bg_saveOrUpdate];
            [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_CONTACT_HD_NOTI object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:REQEUST_ADD_FRIEND_NOTI object:nil];
        } else {
            model1.dealStaus = 1;
            model1.publicKey= receiveDic[@"params"][@"UserKey"];
            model1.bg_createTime = model.bg_createTime;
            [SocketMessageUtil sendAgreedOrRefusedWithFriendMode:model1 withType:[NSString stringWithFormat:@"%d",0]];
            [model1 bg_saveOrUpdate];
        }
    }
    
    [[UserHeadUtil getUserHeadUtilShare] sendUpdateAvatarWithFid:model.userId md5:@"0" showHud:NO];
}

+ (void)handleAddFriendDeal:(NSDictionary *)receiveDic {
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    if (retCode == 0) { // 消息接收到
        [[NSNotificationCenter defaultCenter] postNotificationName:DEAL_FRIEND_NOTI object:@"1"];
    } else if (retCode == 1) { // 其他错误
        [[NSNotificationCenter defaultCenter] postNotificationName:DEAL_FRIEND_NOTI object:@"0"];
    }
    //        NSString *retcode = @"0"; // 0：消息接收到  1：其他错误
    //        NSDictionary *params = @{@"Action":Action_AddFriendDeal,@"Retcode":retcode,@"Msg":@""};
    //        [SocketMessageUtil sendVersion1WithParams:params];
}

+ (void)handleAddFriendReply:(NSDictionary *)receiveDic {
    NSString *UserId = receiveDic[@"params"][@"UserId"];
    NSString *FriendId = receiveDic[@"params"][@"FriendId"];
    NSString *NickName = receiveDic[@"params"][@"Nickname"];
    NSString *FriendName = receiveDic[@"params"][@"FriendName"];
    NSString *UserKey = receiveDic[@"params"][@"UserKey"];
    NSString *Sign = receiveDic[@"params"][@"Sign"];
    NSString *timestamp = receiveDic[@"timestamp"];
    BOOL isUserKeyOK = NO;
    BOOL isSignOK = NO;
    
     NSArray *finfAlls = [FriendModel bg_find:FRIEND_REQUEST_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue(UserId),bg_sqlKey(@"owerId"),bg_sqlValue([UserConfig getShareObject].userId)]];
    
    if (finfAlls.count>0) {
        FriendModel *model = finfAlls[0];
        if ([UserKey isEqualToString:model.signPublicKey]) {
            isUserKeyOK = YES;
        }
        if (isUserKeyOK) {
            // 解密sign
            isSignOK = [LibsodiumUtil verifySign:Sign withSignPublickey:model.signPublicKey timestamp:timestamp];
        }
        
    }

    NSInteger Result = [receiveDic[@"params"][@"Result"] integerValue];
    if (Result == 0) { // 同意添加
        [[UserHeadUtil getUserHeadUtilShare] sendUpdateAvatarWithFid:FriendId md5:@"0" showHud:NO];
    } else if (Result == 1) { // 拒绝好友添加
        [AppD.window showHint:@"User refuse to add friend"];
    }
    
    NSString *retcode = @"0"; // 0：消息接收到  1：其他错误
    if (!isUserKeyOK || !isSignOK) {
        retcode = @"1";
    }
    NSDictionary *params = @{@"Action":Action_AddFriendReply,@"Retcode":retcode,@"Msg":@"",@"ToId":[UserConfig getShareObject].userId};
    NSInteger tempmsgid = [receiveDic objectForKey:@"msgid"]?[[receiveDic objectForKey:@"msgid"] integerValue]:0;
    [SocketMessageUtil sendRecevieMessageWithParams4:params tempmsgid:tempmsgid];
    
    FriendModel *model = [[FriendModel alloc] init];
    model.userId = UserId;
    model.username = [NickName base64DecodedString];
    model.bg_tableName = FRIEND_LIST_TABNAME;
    [model bg_saveOrUpdateAsync:^(BOOL isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:FRIEND_LIST_CHANGE_NOTI object:nil];
        });
        
    }];
    
    if (finfAlls && finfAlls.count > 0) {
        FriendModel *model = finfAlls[0];
        model.dealStaus = 1;
        [model bg_saveOrUpdate];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FRIEND_ACCEPED_NOTI object:UserId];
}

+ (void)handleDelFriendCmd:(NSDictionary *)receiveDic {
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    NSString *msg = receiveDic[@"params"][@"Msg"];
    
    if (retCode == 0) { // 0：删除成功
        [[NSNotificationCenter defaultCenter] postNotificationName:SOCKET_DELETE_FRIEND_SUCCESS_NOTI object:nil];
    } else if (retCode == 1) { // 1：其他错误
        
    }
}

+ (void)handleDelFriendPush:(NSDictionary *)receiveDic {
    
    NSString *FriendId= receiveDic[@"params"][@"UserId"]?:@"";
    NSString *UserId = receiveDic[@"params"][@"FriendId"]?:@"";
    
    // 删除本地聊天列表
    [[ChatListDataUtil getShareObject] removeChatModelWithFriendID:FriendId];
    [FriendModel bg_delete:FRIEND_REQUEST_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"userId"),bg_sqlValue(FriendId)]];
    
    NSString *retcode = @"0"; // 0：删除成功  1：其他错误
    NSDictionary *params = @{@"Action":Action_DelFriendPush,@"Retcode":retcode,@"Msg":@"",@"ToId":UserId};
    NSInteger tempmsgid = [receiveDic objectForKey:@"msgid"]?[[receiveDic objectForKey:@"msgid"] integerValue]:0;
    [SocketMessageUtil sendRecevieMessageWithParams:params tempmsgid:tempmsgid];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FRIEND_DELETE_MY_NOTI object:nil];
}
#pragma mark -消息发送成功
+ (void)handleSendMsg:(NSDictionary *)receiveDic {
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    NSString *MsgId = [NSString stringWithFormat:@"%@",receiveDic[@"params"][@"MsgId"]];
    NSString *Msg = receiveDic[@"params"][@"Msg"];
    NSString *FromId = receiveDic[@"params"][@"From"];
    NSString *ToId = receiveDic[@"params"][@"To"];
    NSString *PriKey = receiveDic[@"params"][@"PriKey"];
    NSString *Nonce = receiveDic[@"params"][@"Nonce"];
    NSString *sendMsgID = [NSString stringWithFormat:@"%@",receiveDic[@"msgid"]];
    if (retCode == 0) { // 0：消息发送成功
        // 添加到chatlist
        ChatListModel *chatListModel = [[ChatListModel alloc] init];
        chatListModel.myID = FromId;
        chatListModel.friendID = ToId;
        chatListModel.chatTime = [NSDate date];
        chatListModel.isHD = NO;
        // 解密消息
        NSString *symmetKey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:PriKey];
        chatListModel.lastMessage = [LibsodiumUtil decryMsgPairWithSymmetry:symmetKey enMsg:Msg nonce:Nonce];
        [[ChatListDataUtil getShareObject] addFriendModel:chatListModel];
        
       // NSArray *chats = [ChatModel bg_find:CHAT_CACHE_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"fromId"),bg_sqlValue(FromId),bg_sqlKey(@"msgid"),bg_sqlValue(MsgId)]];
    
      // 发送成功，删除记录.
      [ChatModel bg_delete:CHAT_CACHE_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"fromId"),bg_sqlValue(FromId),bg_sqlKey(@"msgid"),bg_sqlValue(sendMsgID)]];
      
        
    } else if (retCode == 1) { // 1：目标不可达
       
    } else if (retCode == 2) { // 2：其他错误
        
        // 对方已经不是好友，删除记录.
        [ChatModel bg_delete:CHAT_CACHE_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"fromId"),bg_sqlValue(FromId),bg_sqlKey(@"msgid"),bg_sqlValue(MsgId)]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SEND_CHATMESSAGE_SUCCESS_NOTI object:@[@(retCode),MsgId,sendMsgID?:@""]];
}

+ (void)handlePushMsg:(NSDictionary *)receiveDic {
    
    NSString *FromId = receiveDic[@"params"][@"From"];
    NSString *ToId = receiveDic[@"params"][@"To"];
    NSString *MsgId = receiveDic[@"params"][@"MsgId"];
    NSString *Msg = receiveDic[@"params"][@"Msg"];
    NSString *signKey = receiveDic[@"params"][@"Sign"];
    NSString *nonceKey = receiveDic[@"params"][@"Nonce"];
    NSString *symmetkey = receiveDic[@"params"][@"PriKey"];
    
    // 回复路由
    NSString *retcode = @"0"; // 0：消息接收成功   1：目标不可达   2：其他错误
    NSDictionary *params = @{@"Action":Action_PushMsg,@"Retcode":retcode,@"Msg":@"",@"ToId":ToId};
    NSInteger tempmsgid = [receiveDic objectForKey:@"msgid"]?[[receiveDic objectForKey:@"msgid"] integerValue]:0;
    [SocketMessageUtil sendRecevieMessageWithParams3:params tempmsgid:tempmsgid];
    // 保存记录
    CDMessageModel *model = [[CDMessageModel alloc] init];
    model.FromId = FromId;
    model.ToId = ToId;
    model.TimeStatmp = [receiveDic[@"timestamp"] integerValue];
    model.messageId = MsgId;
    model.signKey = signKey;
    model.nonceKey = nonceKey;
    model.symmetKey = symmetkey;
    
   NSString *signPublickey = [[ChatListDataUtil getShareObject] getFriendSignPublickeyWithFriendid:FromId];
    if ([signPublickey isEmptyString]) {
        return;
    }
    // 解签名
    NSString *tempPublickey = [LibsodiumUtil verifySignWithSignPublickey:signPublickey verifyMsg:signKey];
    if ([tempPublickey isEmptyString]) {
        NSString *retcode = @"0"; // 0：消息接收成功   1：目标不可达   2：其他错误
        NSDictionary *params = @{@"Action":@"PushMsg",@"Retcode":retcode,@"Msg":@"",@"ToId":model.ToId};
        NSInteger tempmsgid = [receiveDic objectForKey:@"msgid"]?[[receiveDic objectForKey:@"msgid"] integerValue]:0;
        [SocketMessageUtil sendRecevieMessageWithParams3:params tempmsgid:tempmsgid];
        return;
    }
    // 生成对称密钥
    NSString *deSymmetKey = [LibsodiumUtil getSymmetryWithPrivate:[EntryModel getShareObject].privateKey publicKey:tempPublickey];
    NSString *deMsg = [LibsodiumUtil decryMsgPairWithSymmetry:deSymmetKey enMsg:Msg nonce:nonceKey];
    if (![deMsg isEmptyString]) {
        model.msg = deMsg;
    }
   
    // 添加到chatlist
    ChatListModel *chatModel = [[ChatListModel alloc] init];
    chatModel.myID = model.ToId;
    chatModel.friendID = model.FromId;
    chatModel.chatTime = [NSDate date];
    chatModel.isHD = ![chatModel.friendID isEqualToString:[SocketCountUtil getShareObject].chatToId];
    chatModel.lastMessage = model.msg;
    
    // 收到好友消息播放系统声音
    if (!([SocketCountUtil getShareObject].chatToId && [[SocketCountUtil getShareObject].chatToId isEqualToString:chatModel.friendID])) { // 不在当前聊天界面
        // 判断时间 间隔10秒
       NSString *formatDate = [HWUserdefault getObjectWithKey:PLAY_KEY];
         NSDateFormatter *format =[NSDateFormatter defaultDateFormatter];
        if (formatDate) {
            NSDate *date = [format dateFromString:formatDate];
            NSTimeInterval timeInterval =  [[NSDate date] timeIntervalSinceDate:date];
            if (timeInterval >PLAY_TIME) {
                [SystemUtil playSystemSound];
                [HWUserdefault updateObject:[format stringFromDate:[NSDate date]] withKey:PLAY_KEY];
            }
        } else {
             [SystemUtil playSystemSound];
             [HWUserdefault updateObject:[format stringFromDate:[NSDate date]] withKey:PLAY_KEY];
        }
       
    }
    [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_MESSAGE_NOTI object:model];
   
}

+ (void)handleDelMsg:(NSDictionary *)receiveDic {
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    NSString *Msg = receiveDic[@"params"][@"Msg"];
    NSString *MsgId = [NSString stringWithFormat:@"%@",receiveDic[@"params"][@"MsgId"]];
    if (retCode == 0) { // 0：消息删除成功
        [[NSNotificationCenter defaultCenter] postNotificationName:DELET_MESSAGE_SUCCESS_NOTI object:MsgId];
    } else if (retCode == 1) { // 1：目标不可达
        [AppD.window showHint:@"Message deletion failed"];
    } else if (retCode == 2) { // 2：其他错误
        [AppD.window showHint:@"Message deletion failed"];
    }
}

#pragma mark- 好友删除自己消息的回调
+ (void)handlePushDelMsg:(NSDictionary *)receiveDic {
    NSString *FriendId = receiveDic[@"params"][@"UserId"];
    NSString *UserId = receiveDic[@"params"][@"FriendId"];
    NSString *MsgId =  [NSString stringWithFormat:@"%@",receiveDic[@"params"][@"MsgId"]];; // 目标需要删除的消息id，为0，表示两个用户间的所有历史消息全部删除
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_DELET_MESSAGE_NOTI object:@[MsgId,FriendId]];
    
    NSString *retcode = @"0"; // 0：消息删除成功   1：目标不可达   2：其他错误
    NSDictionary *params = @{@"Action":Action_PushDelMsg,@"Retcode":retcode,@"Msg":@""  ,@"ToId":UserId};
    NSInteger tempmsgid = [receiveDic objectForKey:@"msgid"]?[[receiveDic objectForKey:@"msgid"] integerValue]:0;
    [SocketMessageUtil sendRecevieMessageWithParams:params tempmsgid:tempmsgid];
}

+ (void)handleHeartBeat:(NSDictionary *)receiveDic {
    
}

+ (void)handleOnlineStatusPush:(NSDictionary *)receiveDic {
    NSString *UserId = receiveDic[@"params"][@"UserId"];
    NSInteger OnlineStatus = [receiveDic[@"params"][@"OnlineStatus"] integerValue];
    
    NSString *retcode = @"0"; // 0：消息删除成功   1：目标不可达   2：其他错误
    NSDictionary *params = @{@"Action":Action_OnlineStatusPush,@"Retcode":retcode,@"Msg":@"",@"ToId":[UserConfig getShareObject].userId};
    NSInteger tempmsgid = [receiveDic objectForKey:@"msgid"]?[[receiveDic objectForKey:@"msgid"] integerValue]:0;
    [SocketMessageUtil sendRecevieMessageWithParams:params tempmsgid:tempmsgid];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FRIENT_ONLINE_CHANGE_NOTI object:nil];
}

+ (void)handleOnlineStatusCheck:(NSDictionary *)receiveDic { // 0：离线 1：在线 2：隐身 3：忙碌
    NSInteger userOnLineStatu = [receiveDic[@"params"][@"OnlineStatus"] integerValue];
    NSString *TargetUserId = receiveDic[@"params"][@"TargetUserId"];
    NSLog(@"friend_statu = %ld",(long)userOnLineStatu);
    UserModel *userM = [UserModel getUserModel];
    
    
    
    if ([userM.userId isEqualToString:TargetUserId]) { // 发送自己是否在线的通知
        [[NSNotificationCenter defaultCenter] postNotificationName:OWNER_ONLINE_NOTI object:@(userOnLineStatu)];
    } else { // 发送好友是否在线的通知
        
    }
}

+ (void)handlePullMsg:(NSDictionary *)receiveDic {
    
    
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    NSInteger MsgNum = [receiveDic[@"params"][@"MsgNum"] integerValue]; // 拉取的消息条数（默认10条，不能超过20条）
    NSString *Payload = receiveDic[@"params"][@"Payload"];
    
    NSString *friendId = receiveDic[@"params"][@"FriendId"];
    NSInteger more = [receiveDic[@"more"] integerValue];

    if (retCode == 0) { // 0：消息拉取成功
        if (more == 1) {
             NSInteger offset = [receiveDic[@"offset"] integerValue];
           // [SocketMessageUtil sendVersion1WithParams:@{}];
        }
        
        if (([SocketCountUtil getShareObject].chatToId && [[SocketCountUtil getShareObject].chatToId isEqualToString:friendId])) {
            NSArray *payloadArr = [PayloadModel mj_objectArrayWithKeyValuesArray:Payload.mj_JSONObject];
            [[NSNotificationCenter defaultCenter] postNotificationName:ADD_MESSAGE_BEFORE_NOTI object:payloadArr];
        }
       
    } else if (retCode == 1) { // 1：用户没权限
        
    } else if (retCode == 2) { // 2：其他错误
        
    }
}

+ (void)handlePullFriend:(NSDictionary *)receiveDic {
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    NSString *msg = receiveDic[@"params"][@"Payload"];
    if (retCode == 0) { // 0：拉取成功
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_FRIEND_LIST_NOTI object:msg];
    } else {
        [AppD.window showHint:@"Friend pull failed"];
    }
}

+ (void)handleAddFriendReq:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    NSString *FriendId = receiveDic[@"params"][@"FriendId"]?:@"";
    [[NSNotificationCenter defaultCenter] postNotificationName:ADD_FRIEND_NOTI object:@(retCode)];
}

+ (void)handleLogin:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    NSString *userId = receiveDic[@"params"][@"UserId"];
    NSInteger needSynch = [receiveDic[@"params"][@"NeedSynch"] integerValue];
    NSString *routerName = receiveDic[@"params"][@"RouterName"];
    NSString *userSn = receiveDic[@"params"][@"UserSn"];
    NSString *hashid = receiveDic[@"params"][@"Index"];
    NSString *routeId = receiveDic[@"params"][@"Routerid"];
   
    
    [UserConfig getShareObject].userId = userId;
    [UserConfig getShareObject].usersn = userSn;
    [UserConfig getShareObject].hashId = hashid;
    [UserConfig getShareObject].userName = [UserModel getUserModel].username;
    
    
    if (retCode == 0) { // 成功
        if (userId.length > 0) {
            [UserModel updateHashid:hashid usersn:userSn userid:userId needasysn:needSynch];
            [RouterModel addRouterName:routerName routerid:routeId usersn:userSn userid:userId];
            [RouterModel updateRouterConnectStatusWithSn:userSn];
            // 开启未发送成功消息发送
            [[SendCacheChatUtil getSendCacheChatUtilShare] start];
        }
        // 同步data文件
        if (needSynch == 0) { // 不需要 同步
            
        } else if (needSynch == 1) { // app向router上传data文件
            
        } else if (needSynch == 2) { // app从router拉取data文件
            
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:REGISTER_PUSH_NOTI object:nil];
       // 开始心跳
        [HeartBeatUtil start];
    } 
    [[NSNotificationCenter defaultCenter] postNotificationName:SOCKET_LOGIN_SUCCESS_NOTI object:@(retCode)];
}

+ (void)handleDeviceLogin:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
//    NSString *RouterId = receiveDic[@"params"][@"RouterId"];
//    NSString *Qrcode = receiveDic[@"params"][@"Qrcode"];
//    NSString *IdentifyCode = receiveDic[@"params"][@"IdentifyCode"];
//    NSString *UserSn = receiveDic[@"params"][@"UserSn"];
    
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DEVICE_LOGIN_SUCCESS_NOTI object:receiveDic];
    } else if (retCode == 1) {
        [AppD.window showHint:@"The device is temporarily unavailable"];
    } else if (retCode == 2) {
        [AppD.window showHint:@"Device MAC error"];
    } else if (retCode == 3) {
        [AppD.window showHint:@"Password error"];
    } else {
        [AppD.window showHint:@"Other error"];
    }
}

+ (void)handleResetRouterKey:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ResetRouterKey_SUCCESS_NOTI object:receiveDic];
    } else if (retCode == 1) {
        [AppD.window showHint:@"The target device id is incorrect"];
    } else if (retCode == 2) {
        [AppD.window showHint:@"Password error"];
    } else {
        [AppD.window showHint:@"Other error"];
    }
}

+ (void)handleResetUserIdcode:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
//    NSString *UserSn = receiveDic[@"params"][@"UserSn"];
    
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ResetUserIdcode_SUCCESS_NOTI object:receiveDic];
    } else if (retCode == 1) {
        [AppD.window showHint:@"The target device id is incorrect"];
    } else if (retCode == 2) {
        [AppD.window showHint:@"Input parameter error"];
    } else if (retCode == 3) {
        [AppD.window showHint:@"Original code error"];
    } else {
        [AppD.window showHint:@"Other error"];
    }
}

+ (void)handlePullFileList:(NSDictionary *)receiveDic {
   // [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PullFileList_Complete_Noti object:receiveDic];
    }
}

+ (void)handleUploadFileReq:(NSDictionary *)receiveDic {
    
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    NSString *msgId = [NSString stringWithFormat:@"%@",receiveDic[@"msgid"]];
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UploadFileReq_Success_Noti object:msgId];
    } else if (retCode == 1) {
        [AppD.window hideHud];
        [AppD.window showHint:@"Existing file with the same name"];
    } else if (retCode == 2) {
        [AppD.window hideHud];
        [AppD.window showHint:@"Not enough space"];
    } else {
        [AppD.window hideHud];
    }
}

+ (void)handleUploadFile:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
    }
}

+ (void)handleDelFile:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Delete_File_Noti object:nil];
    } else if (retCode == 1) {
        [AppD.window showHint:@"File does not exist."];
    } else {
        [AppD.window showHint:@"Have no legal power."];
    }
}

+ (void)handlePullSharedFriend:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PullSharedFriend_Noti object:receiveDic];
    }
}

+ (void)handleShareFile:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
    }
}

+ (void)handleGetDiskTotalInfo:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GetDiskTotalInfo_Noti object:receiveDic];
    } else if (retCode == 1) {
        [AppD.window showHint:@"The system is busy, please check later"];
    }
}

+ (void)handleGetDiskDetailInfo:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:GetDiskDetailInfo_Noti object:receiveDic];
    } else if (retCode == 1) {
        [AppD.window showHint:@"The system is busy, please check later"];
    }
}

+ (void)handleFormatDisk:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FormatDisk_Success_Noti object:receiveDic];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:FormatDisk_Fail_Noti object:receiveDic];
        if (retCode == 1) {
            [AppD.window showHint:@"Unsupported mode"];
        } else if (retCode == 2) {
            [AppD.window showHint:@"The system is busy, please check later"];
        }
    }
}

+ (void)handleReboot:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:Reboot_Success_Noti object:receiveDic];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:Reboot_Fail_Noti object:receiveDic];
        if (retCode == 1) {
            [AppD.window showHint:@"The system is busy, please check later"];
        }
    }
}

+ (void)handleResetRouterName:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ResetRouterName_Success_Noti object:receiveDic];
        [AppD.window showHint:@"Reset device nickname successfully"];
    } else {
        if (retCode == 1) {
            [AppD.window showHint:@"User does not have permission"];
        } else if (retCode == 2) {
            [AppD.window showHint:@"Other errors"];
        }
    }
}

+ (void)handleFileRename:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:FileRename_Success_Noti object:receiveDic];
//        [AppD.window showHint:@"Reset device nickname successfully"];
    } else {
        if (retCode == 1) {
            [AppD.window showHint:@"User id error"];
        } else if (retCode == 2) {
            [AppD.window showHint:@"The renamed file already exists"];
        } else if (retCode == 3) {
            [AppD.window showHint:@"Other errors"];
        }
    }
}
+ (void) handleFileForward:(NSDictionary *)receiveDic {
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
//    0：成功
//    1：用户id错误
//    2：目标文件错误
//    3：目标不可达
//    4：其他错误
    if (retCode == 0) {
        
    } else {
        if (retCode == 1) {
           
        } else if (retCode == 2) {
           
        } else if (retCode == 3) {
           
        }
    }
}

+ (void)handleUploadAvatar:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UploadAvatar_Success_Noti object:receiveDic];
    } else {
        if (retCode == 1) {
            [AppD.window showHint:@"User id error"];
        } else if (retCode == 2) {
            [AppD.window showHint:@"Target file error"];
        } else if (retCode == 3) {
//            [AppD.window showHint:@"The profile image has not changed"];
        } else if (retCode == 4) {
            [AppD.window showHint:@"Other errors"];
        }
    }
}

+ (void)handleUpdateAvatar:(NSDictionary *)receiveDic {
//    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateAvatar_Success_Noti object:receiveDic];
    } else {
        if (retCode == 1) {
            [AppD.window showHint:@"User id error"];
        } else if (retCode == 2) {
//            [AppD.window showHint:@"Avatars are up to date"];
        } else if (retCode == 3) {
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateAvatar_FileNotExist_Noti object:receiveDic];
//            [AppD.window showHint:@"The user profile does not exist"];
        } else if (retCode == 4) {
            [AppD.window showHint:@"Other errors"];
        }
    }
}

+ (void)handlePullTmpAccount:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PullTmpAccount_Success_Noti object:receiveDic[@"params"]];
    } else {
        if (retCode == 1) {
            [AppD.window showHint:@"Other errors"];
        }
    }
}


#pragma mark --------------群组 ----------------

+ (void)handleCreateGroup:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:CREATE_GROUP_SUCCESS_NOTI object:receiveDic[@"params"]];
    } else {
        if (retCode == 1) {
            [AppD.window showHint:@"User id error"];
        } else if (retCode == 2) {
            [AppD.window showHint:@"Input parameter error"];
        } else if (retCode == 3) {
           
            [AppD.window showHint:@"The group has reached the upper limit"];
        } else {
            [AppD.window showHint:@"Other errors"];
        }
    }
}
// 拉取群组
+ (void) handleGroupListPull:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        NSString *Payload = receiveDic[@"params"][@"Payload"];
        NSArray *payloadArr = [GroupInfoModel mj_objectArrayWithKeyValuesArray:Payload.mj_JSONObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:PULL_GROUP_SUCCESS_NOTI object:payloadArr];
    } else {
       
        [AppD.window showHint:@"Other errors"];
        
    }
}

#pragma mark - 拉取群好友信息
+ (void)handleGroupUserPull:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        NSNumber *Verify = receiveDic[@"params"][@"Verify"]?:@(0);
        NSString *Payload = receiveDic[@"params"][@"Payload"];
        NSArray *payloadArr = [GroupMembersModel mj_objectArrayWithKeyValuesArray:Payload.mj_JSONObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:GroupUserPull_SUCCESS_NOTI object:payloadArr userInfo:@{@"Verify":Verify}];
    } else {
        if (retCode == 1) {
            [AppD.window showHint:@"Other errors"];
        }        
    }
}
#pragma mark - 加入群聊
+ (void)handleInviteGroup:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ADD_GROUP_SUCCESS_NOTI object:nil];
    } else {
        if (retCode == 1) {
            [AppD.window showHint:@" The target group does not exist."];
        } else {
             [AppD.window showHint:@"Other errors."];
        }
    }
}
#pragma mark - 发送群聊消息
+ (void)handleGroupSendMsg:(NSDictionary *)receiveDic {
   
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    NSString *MsgId = [NSString stringWithFormat:@"%@",receiveDic[@"params"][@"MsgId"]];
    NSString *Msg = receiveDic[@"params"][@"Msg"];
    NSString *gId = receiveDic[@"params"][@"GId"];
    NSString *ToId = receiveDic[@"params"][@"ToId"];
    NSString *UserKey = receiveDic[@"params"][@"UserKey"];
    NSString *GName = receiveDic[@"params"][@"Gname"];
    NSString *Remark = receiveDic[@"params"][@"Gname"];
    NSString *Repeat = receiveDic[@"params"][@"Repeat"];
    NSString *sendMsgID = [NSString stringWithFormat:@"%@",receiveDic[@"msgid"]];
    
     [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_MESSAGE_SEND_SUCCESS_NOTI object:@[@(retCode),gId,MsgId,sendMsgID]];
    
    if (retCode == 0) {
        // 添加到chatlist
        ChatListModel *chatListModel = [[ChatListModel alloc] init];
        chatListModel.myID = ToId;
        chatListModel.isGroup = YES;
        chatListModel.friendID = [UserConfig getShareObject].userId;
        chatListModel.groupID = gId;
        chatListModel.groupName = [GName base64DecodedString]?:GName;
//        chatListModel.groupAlias = [Remark base64DecodedString]?:Remark;
        chatListModel.groupUserkey = UserKey;
        chatListModel.chatTime = [NSDate date];
        chatListModel.isHD = NO;
        // 解密消息
        // 自己私钥解密
        NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:UserKey];
        // 截取前16位
        datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
        if (datakey) {
            chatListModel.lastMessage = aesDecryptString(Msg, datakey);
            [[ChatListDataUtil getShareObject] addFriendModel:chatListModel];
        }
    } else {
        
    }
    
}
#pragma mark ---拉取群聊消息列表
+ (void)handleGroupMsgPull:(NSDictionary *)receiveDic {
    
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    NSString *Payload = receiveDic[@"params"][@"Payload"];
    
    NSString *GId = receiveDic[@"params"][@"GId"];
    int userType = [receiveDic[@"params"][@"UserType"] intValue];
    
    if (retCode == 0) { // 0：消息拉取成功
        
        
        if (([SocketCountUtil getShareObject].groupChatId && [[SocketCountUtil getShareObject].groupChatId isEqualToString:GId])) {
            NSArray *payloadArr = [PayloadModel mj_objectArrayWithKeyValuesArray:Payload.mj_JSONObject];
            [[NSNotificationCenter defaultCenter] postNotificationName:PULL_GROUP_MESSAGE_SUCCESS_NOTI object:@[payloadArr,@(userType)]];
        }
        
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:PULL_GROUP_MESSAGE_SUCCESS_NOTI object:nil];
    }
}
#pragma mark ----发送群聊文件预处理
+ (void)handleGroupSendFilePre:(NSDictionary *)receiveDic {
    
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    NSDictionary *resultDic = receiveDic[@"params"];
    NSString *GId = receiveDic[@"params"][@"GId"];
    NSString *fileID = receiveDic[@"params"][@"FileId"];
     NSString *GName = receiveDic[@"params"][@"Gname"];
    NSString *Remark = receiveDic[@"params"][@"Gname"];
     int fileType = [receiveDic[@"params"][@"FileType"] intValue];
     NSString *Userkey = receiveDic[@"params"][@"Userkey"];
    if (retCode == 0) { // 0：文件发送成功
        
        
        // 添加到chatlist
        ChatListModel *chatModel = [[ChatListModel alloc] init];
        chatModel.myID = [UserConfig getShareObject].userId;
        chatModel.chatTime = [NSDate date];
        chatModel.isHD = NO;
        NSInteger msgType = fileType;
        chatModel.friendID = [UserConfig getShareObject].userId;
        chatModel.isGroup = YES;
        chatModel.groupID = GId;
        chatModel.groupName = [GName base64DecodedString]?:GName;
//        chatModel.groupAlias = [Remark base64DecodedString]?:Remark;
        chatModel.groupUserkey = Userkey;
        if (msgType == 1) {
            chatModel.lastMessage = @"[photo]";
        } else if (msgType == 2) {
            chatModel.lastMessage = @"[voice]";
        } else if (msgType == 5){
            chatModel.lastMessage = @"[file]";
        } else if (msgType == 4){
            chatModel.lastMessage = @"[video]";
        }
        [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
        
        if (([SocketCountUtil getShareObject].groupChatId && [[SocketCountUtil getShareObject].groupChatId isEqualToString:GId])) {
            [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_FILE_SEND_SUCCESS_NOTI object:resultDic];
        }
        
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_FILE_SEND_FAIELD_NOTI object:@[@(retCode),GId?:@"",fileID?:@""]];
    }
}
#pragma mark -群消息推送
+ (void)handleGroupMsgPush:(NSDictionary *)receiveDic {
    
   PayloadModel *messageModel = [PayloadModel mj_objectWithKeyValues:receiveDic[@"params"]];
    
    // 回复router
    NSString *retcode = @"0"; // 0：消息接收成功   1：目标不可达   2：其他错误
    NSDictionary *params = @{@"Action":Action_GroupMsgPush,@"Retcode":retcode,@"Msg":@"",@"ToId":messageModel.To,@"GId":messageModel.GId};
    NSInteger tempmsgid = [receiveDic objectForKey:@"msgid"]?[[receiveDic objectForKey:@"msgid"] integerValue]:0;
    [SocketMessageUtil sendRecevieMessageWithParams4:params tempmsgid:tempmsgid];
    
    
    if (([SocketCountUtil getShareObject].groupChatId && [[SocketCountUtil getShareObject].groupChatId isEqualToString:messageModel.GId])) {
        // 判断时间 间隔10秒 收到好友消息播放系统声音
        NSString *formatDate = [HWUserdefault getObjectWithKey:PLAY_KEY];
        NSDateFormatter *format =[NSDateFormatter defaultDateFormatter];
        if (formatDate) {
            NSDate *date = [format dateFromString:formatDate];
            NSTimeInterval timeInterval =  [[NSDate date] timeIntervalSinceDate:date];
            if (timeInterval >PLAY_TIME) {
                [SystemUtil playSystemSound];
                [HWUserdefault updateObject:[format stringFromDate:[NSDate date]] withKey:PLAY_KEY];
            }
        } else {
            [SystemUtil playSystemSound];
            [HWUserdefault updateObject:[format stringFromDate:[NSDate date]] withKey:PLAY_KEY];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:RECEVIED_GROUP_MESSAGE_SUCCESS_NOTI object:messageModel];
    }
    
    // 添加到chatlist
    ChatListModel *chatListModel = [[ChatListModel alloc] init];
    chatListModel.myID = [UserConfig getShareObject].userId;
    chatListModel.friendID = messageModel.From;
    chatListModel.isGroup = YES;
    chatListModel.groupID = messageModel.GId;
    chatListModel.groupName = [messageModel.GroupName base64DecodedString]?:messageModel.GroupName;
//    chatListModel.groupAlias = [messageModel.GroupName base64DecodedString]?:messageModel.GroupName;
    chatListModel.friendName = [messageModel.UserName base64DecodedString];
    chatListModel.groupUserkey = messageModel.SelfKey;
    chatListModel.chatTime = [NSDate date];
    chatListModel.isHD = ![messageModel.GId isEqualToString:[SocketCountUtil getShareObject].groupChatId];
    
    if (messageModel.MsgType== 0) {
        // 解密消息
        // 自己私钥解密
        NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:messageModel.SelfKey];
        if (datakey && datakey.length>0) {
            // 截取前16位
            datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
            if (datakey) {
                chatListModel.lastMessage = aesDecryptString(messageModel.Msg, datakey);
            }
        }
        
    } else {
        if (messageModel.MsgType == 1) {
            chatListModel.lastMessage = @"[photo]";
        } else if (messageModel.MsgType == 2) {
            chatListModel.lastMessage = @"[voice]";
        } else if (messageModel.MsgType == 5){
            chatListModel.lastMessage = @"[file]";
        } else if (messageModel.MsgType == 4) {
            chatListModel.lastMessage = @"[video]";
        }
    }
    [[ChatListDataUtil getShareObject] addFriendModel:chatListModel];
    
}

#pragma mark - 77.    群属性设置
+ (void)handleGroupConfig:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    NSString *GId = receiveDic[@"params"][@"GId"];
    NSNumber *Type = receiveDic[@"params"][@"Type"];
    if ([Type integerValue] == 1) { // 修改群名称，只有群管理员有权限
        
    } else if ([Type integerValue] == 2) { // 设置是否需要群管理审核入群，只有管理员有权限
        if (retCode == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:Set_Approve_Invitations_SUCCESS_NOTI object:nil];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:Set_Approve_Invitations_FAIL_NOTI object:nil];
            if (retCode == 1) {
                [AppD.window showHint:@"Configuration Failed."];
            }
        }
    } else if ([Type integerValue] == 3) { // 踢出某个用户，只有管理员有权限
        if (retCode == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:Remove_Group_Member_SUCCESS_NOTI object:nil];
        } else {
            if (retCode == 1) {
                [AppD.window showHint:@"Remove Group Member Failed."];
            }
        }
    } else if ([Type integerValue] == [NSString numberWithHexString:@"F1"]) { // 修改群别名
        if (retCode == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:Revise_Group_Alias_SUCCESS_NOTI object:GId];
        } else {
            if (retCode == 1) {
                [AppD.window showHint:@"Revise Group Alias Failed."];
            }
        }
    } else if ([Type integerValue] == [[NSString stringFromHexString:@"F2"] integerValue]) { // 修改群友别名
        
    } else if ([Type integerValue] == [[NSString stringFromHexString:@"F3"] integerValue]) { // 设置自己群中显示的别名
        
    }
    
    
    
}

#pragma makr -群系统消息推送
+ (void)handleGroupSysPush:(NSDictionary *)receiveDic {
    
    NSString *UserId = receiveDic[@"params"][@"UserId"];
    NSString *GId = receiveDic[@"params"][@"GId"];
    int Type = [receiveDic[@"params"][@"Type"] intValue];
    NSString *From = receiveDic[@"params"][@"From"];
    NSString *To = receiveDic[@"params"][@"To"];
    NSInteger MsgId = [receiveDic[@"params"][@"MsgId"] integerValue];
    NSString *Name = receiveDic[@"params"][@"Name"];
    int NeedVerify = [receiveDic[@"params"][@"NeedVerify"] intValue];
    NSString *FromUserName = receiveDic[@"params"][@"FromUserName"];
    
    // 回复router
    NSString *retcode = @"0"; // 0：消息接收成功   1：目标不可达   2：其他错误
    NSDictionary *params = @{@"Action":Action_GroupSysPush,@"Retcode":retcode,@"ToId":UserId};
    NSInteger tempmsgid = [receiveDic objectForKey:@"msgid"]?[[receiveDic objectForKey:@"msgid"] integerValue]:0;
    [SocketMessageUtil sendRecevieMessageWithParams4:params tempmsgid:tempmsgid];
    
    /*
     群系统推送类型：
     0x01：群名称修改
     0x02：群审核权限变更
     0x03: 撤回某条消息
     0x04:群主删除某条消息
     0xF1:新用户入群
     0xF2:有用户退群
     0xF3:有用户被踢出群
     0xF4:有用户被踢出群

     */
    if (Type == 0xF3) {
        // 自己被踢出群聊
        if ([To isEqualToString:[UserConfig getShareObject].userId]) {
            [AppD.window showHint:[NSString stringWithFormat:@"\"%@\" removed you from the group",FromUserName]];
            [[NSNotificationCenter defaultCenter] postNotificationName:GroupQuit_SUCCESS_NOTI object:GId];
        }
    } else if (Type == 0xF4) {
        
        [AppD.window showHint:[NSString stringWithFormat:@"\"%@\" dissolves \"%@\"",[FromUserName base64DecodedString],[Name base64DecodedString]]];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:GroupQuit_SUCCESS_NOTI object:GId];
    }
    
    if (([SocketCountUtil getShareObject].groupChatId && [[SocketCountUtil getShareObject].groupChatId isEqualToString:GId])) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:RECEVIED_GROUP_SYSMSG_SUCCESS_NOTI object:receiveDic[@"params"]];
    }
}
#pragma mark ----删除群消息
+ (void)handleGroupDelMsg:(NSDictionary *)receiveDic {
    
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    NSString *GId = receiveDic[@"params"][@"GId"];
    NSInteger msgId = [receiveDic[@"params"][@"MsgId"] integerValue];
    
    
    if (retCode == 0) { // 0：消息拉取成功
        
        
        if (([SocketCountUtil getShareObject].groupChatId && [[SocketCountUtil getShareObject].groupChatId isEqualToString:GId])) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RECEVIED_Del_GROUP_MESSAGE_SUCCESS_NOTI object:@(msgId)];
        }
        
    } else {
        if (retCode == 1) {
            [AppD.window showHint:@"No permission to withdraw"];
        } else {
            [AppD.window showHint:@"Other error"];
        }
    }
}

#pragma mark - 68.    用户退群
+ (void)handleGroupQuit:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        NSString *GId = receiveDic[@"params"][@"GId"];
        [[NSNotificationCenter defaultCenter] postNotificationName:GroupQuit_SUCCESS_NOTI object:GId];
    } else {
        if (retCode == 1) {
            [AppD.window showHint:@"Refund group fail."];
        }
    }
}

#pragma mark - 65.    邀请用户入群审核推送
+ (void)handleGroupVerifyPush:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSString *Aduit = receiveDic[@"params"][@"Aduit"]; // 审核人
    // 回复router
    UserModel *userM = [UserModel getUserModel];
    NSInteger retCode = [userM.userId isEqualToString:Aduit]?0:1; // 0：成功   1：用户没有审核权限
    NSDictionary *params = @{@"Action":Action_GroupVerifyPush,@"Retcode":@(retCode),@"ToId":userM.userId?:@"",@"Msg":@""};
    NSInteger tempmsgid = [receiveDic objectForKey:@"msgid"]?[[receiveDic objectForKey:@"msgid"] integerValue]:0;
    [SocketMessageUtil sendRecevieMessageWithParams4:params tempmsgid:tempmsgid];
    
    if (retCode == 0) {
        GroupVerifyModel *model = [GroupVerifyModel getObjectWithKeyValues:receiveDic[@"params"]];
        NSArray *finfAlls = [GroupVerifyModel bg_find:Group_New_Requests_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@ and %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserModel getUserModel].userId),bg_sqlKey(@"From"),bg_sqlValue(model.From),bg_sqlKey(@"To"),bg_sqlValue(model.To),bg_sqlKey(@"GId"),bg_sqlValue(model.GId)]];
        if (finfAlls && finfAlls.count > 0) { // 如果数据库有直接更新
            model = finfAlls.firstObject;
        }
        model.requestTime = [NSDate date];
        model.isUnRead = YES;
        AppD.showNewGroupAddRequestRedDot = YES;
        model.status = 0; // 新的邀请需要审核人同意
        model.userId = [UserModel getUserModel].userId;
        model.bg_tableName = Group_New_Requests_TABNAME;
        [model bg_saveOrUpdate];
        [[NSNotificationCenter defaultCenter] postNotificationName:GroupVerify_Push_NOTI object:model];
        
        // 弹出群组邀请入群审核推送
        NSString *toName = [model.ToName base64DecodedString]?:model.ToName;
        NSString *gName = [model.Gname base64DecodedString]?:model.Gname;
        NSString *fromName = [model.FromName base64DecodedString]?:model.FromName;
        NotifactionView *notiView = [NotifactionView loadNotifactionView];
        notiView.lblTtile.text = [NSString stringWithFormat:@"\"%@\" Requested to join \"%@\" invited by \"%@\"",toName,gName,fromName];
        [notiView show];
        // 播放系统声音
        [SystemUtil playSystemSound];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_CONTACT_HD_NOTI object:nil];
        
    } else {
        if (retCode == 1) {
//            [AppD.window showHint:@"The user does not have permission to audit."];
        }
    }
}

#pragma mark - 66.    邀请用户入群审核处理
+ (void)handleGroupVerify:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        NSString *GId = receiveDic[@"params"][@"GId"];
        [[NSNotificationCenter defaultCenter] postNotificationName:GroupVerify_SUCCESS_NOTI object:GId];
    } else {
        if (retCode == 1) {
            [AppD.window showHint:@"The user does not have permission to audit."];
        }
    }
}




#pragma mark - Base
+ (NSDictionary *)getBaseParams {
    NSString *timestamp = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    return @{@"appid":@"MIFI",@"timestamp":timestamp,@"apiversion":APIVERSION1,@"msgid":[NSString stringWithFormat:@"%ld",(long)[ChatListDataUtil getShareObject].tempMsgId++],@"offset":@"0",@"more":@"0"};
}
+ (NSDictionary *)getBaseParams3 {
    NSString *timestamp = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    return @{@"appid":@"MIFI",@"timestamp":timestamp,@"apiversion":APIVERSION3,@"msgid":[NSString stringWithFormat:@"%ld",(long)[ChatListDataUtil getShareObject].tempMsgId++],@"offset":@"0",@"more":@"0"};
}
+ (NSDictionary *)getBaseParams4 {
    NSString *timestamp = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    return @{@"appid":@"MIFI",@"timestamp":timestamp,@"apiversion":APIVERSION4,@"msgid":[NSString stringWithFormat:@"%ld",(long)[ChatListDataUtil getShareObject].tempMsgId++],@"offset":@"0",@"more":@"0"};
}

+ (NSDictionary *)getMutBaseParamsWithMore {
    NSString *timestamp = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    return @{@"appid":@"MIFI",@"timestamp":timestamp,@"apiversion":APIVERSION1,@"msgid":[NSString stringWithFormat:@"%ld",(long)[ChatListDataUtil getShareObject].tempMsgId++],@"offset":@"0",@"more":@"0"};
}

+ (NSDictionary *)getRegiserBaseParams {
    NSString *timestamp = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    return @{@"appid":@"MIFI",@"timestamp":timestamp,@"apiversion":APIVERSION2,@"msgid":[NSString stringWithFormat:@"%ld",(long)[ChatListDataUtil getShareObject].tempMsgId++],@"offset":@"0",@"more":@"0"};
}

+ (NSDictionary *)getRecevieBaseParams:(NSInteger) tempmsgid {
    NSString *timestamp = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    return @{@"appid":@"MIFI",@"timestamp":timestamp,@"apiversion":APIVERSION1,@"msgid":[NSString stringWithFormat:@"%ld",(long)tempmsgid],@"offset":@"0",@"more":@"0"};
}

+ (NSDictionary *)getRecevieBaseParams3:(NSInteger) tempmsgid {
    NSString *timestamp = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    return @{@"appid":@"MIFI",@"timestamp":timestamp,@"apiversion":APIVERSION3,@"msgid":[NSString stringWithFormat:@"%ld",(long)tempmsgid],@"offset":@"0",@"more":@"0"};
}

+ (NSDictionary *)getRecevieBaseParams4:(NSInteger) tempmsgid {
    NSString *timestamp = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    return @{@"appid":@"MIFI",@"timestamp":timestamp,@"apiversion":APIVERSION4,@"msgid":[NSString stringWithFormat:@"%ld",(long)tempmsgid],@"offset":@"0",@"more":@"0"};
}

+ (NSDictionary *)getRecevieBaseVersion2Params:(NSInteger) tempmsgid {
    NSString *timestamp = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    return @{@"appid":@"MIFI",@"timestamp":timestamp,@"apiversion":APIVERSION2,@"msgid":[NSString stringWithFormat:@"%ld",(long)tempmsgid],@"offset":@"0",@"more":@"0"};
}


#pragma -mark 同意或拒绝好友请求
+ (void) sendAgreedOrRefusedWithFriendMode:(FriendModel *) model withType:(NSString *)type
{
    UserModel *userM = [UserModel getUserModel];
    NSString *result = type; // 0：同意添加   1：拒绝好友添加
    NSString *friendName = model.username?:@"";
    NSString *friendId = model.userId?:@"";
    NSDictionary *params = @{@"Action":Action_AddFriendDeal,@"Nickname":[userM.username base64EncodedString]?:@"",@"FriendName":[friendName base64EncodedString]?:@"",@"UserId":userM.userId?:@"",@"FriendId":friendId,@"UserKey":[EntryModel getShareObject].signPublicKey,@"Result":result,@"FriendKey":model.publicKey?:@"",@"Sign":@""};
    [SocketMessageUtil sendVersion4WithParams:params];
}

#pragma -mark 查询用户是否在线
+ (void) sendUserIsOnLine:(NSString *) friendUserId
{
    UserModel *userM = [UserModel getUserModel];
    NSString *friendId =friendUserId?:@"";
    NSDictionary *params = @{@"Action":@"OnlineStatusCheck",@"UserId":userM.userId?:@"",@"TargetUserId":friendId};
    [SocketMessageUtil sendVersion1WithParams:params];
}
#pragma -mark 发送拉取好友列表请求
+ (void) sendFriendListRequest
{
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_PullFriend,@"UserId":userM.userId?:@""};
    [SocketMessageUtil sendVersion4WithParams:params];
}
#pragma -mark 发送data文件
+ (void) sendDataFileNeedSynch:(NSInteger) synch
{
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_SynchDataFile,@"UserId":userM.userId?:@"",@"NeedSynch":@(synch),@"UserDataVersion":@"1.0",@"DataPay":@"database64"};

    [SocketMessageUtil sendVersion1WithParams:params];
}

// ---------------------v4---------------------------
#pragma mark -设备管理员修改设备昵称
+ (void) sendUpdateRourerNickName:(NSString *) nickName showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Load..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_ResetRouterName,@"RouterId":[RouterConfig getRouterConfig].currentRouterToxid?:@"",@"Name":[nickName base64EncodedString]};
    [SocketMessageUtil sendVersion4WithParams:params];
}
#pragma mark -新用户注册
+ (void) sendUserRegisterSn:(NSString *) sn code:(NSString *) code nickName:(NSString *) nickName
{
    NSDictionary *params = @{@"Action":Action_Register,@"RouterId":[RouterConfig getRouterConfig].currentRouterToxid?:@"",@"UserSn":sn,@"IdentifyCode":code,@"Sign":@"",@"UserKey":[EntryModel getShareObject].publicKey,@"NickName":[nickName base64EncodedString]};
    [SocketMessageUtil sendVersion4WithParams:params];
}

@end
