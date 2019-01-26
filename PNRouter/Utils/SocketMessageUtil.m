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
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:[SocketMessageUtil getRecevieBaseParams:[msgid integerValue]]];
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
    
    if (!([action isEqualToString:Action_login] || [action isEqualToString: Aciont_Register] || [action isEqualToString: Aciont_Recovery] || [action isEqualToString: Action_RouterLogin] || [action isEqualToString: Action_ResetRouterKey] || [action isEqualToString: Action_ResetUserIdcode])) {
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
    } else if ([action isEqualToString:Aciont_Recovery]) { //APP用户找回
         [SocketMessageUtil handleFindRouter:receiveDic];
    }  else if ([action isEqualToString:Aciont_Register]) { //APP用户注册
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
        [[NSNotificationCenter defaultCenter] postNotificationName:REGISTER_PUSH_NOTI object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:USER_REGISTER_RECEVIE_NOTI object:receiveDic];
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
}

#pragma mark -tox pull文件
+ (void) handlePullFile:(NSDictionary *)receiveDic {
    NSDictionary *jsonDic = receiveDic[@"params"];
    FileModel *fileModel = [FileModel mj_objectWithKeyValues:jsonDic];
    [[NSNotificationCenter defaultCenter] postNotificationName:REVER_FILE_PULL_NOTI object:fileModel];
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
    model.msg= receiveDic[@"params"][@"Msg"];
    model.requestTime = [NSDate date];
    model.bg_createTime = [NSString stringWithFormat:@"%@",receiveDic[@"params"][@"timestamp"]];
    model.owerId = [UserConfig getShareObject].userId;
    model.bg_tableName = FRIEND_REQUEST_TABNAME;
    
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
            AppD.showHD = YES;
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
            AppD.showHD = YES;
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
    
    NSString *retcode = @"0"; // 0：请求接收到   1：其他错误
    NSDictionary *params = @{@"Action":@"AddFriendPush",@"Retcode":retcode,@"Msg":@"",@"ToId":[UserConfig getShareObject].userId};
    NSLog(@"msgid = %@",[receiveDic objectForKey:@"msgid"]);
    
     NSInteger tempmsgid = [receiveDic objectForKey:@"msgid"]?[[receiveDic objectForKey:@"msgid"] integerValue]:0;
    [SocketMessageUtil sendRecevieMessageWithParams3:params tempmsgid:tempmsgid];
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
    NSInteger Result = [receiveDic[@"params"][@"Result"] integerValue];
    if (Result == 0) { // 同意添加
        
    } else if (Result == 1) { // 拒绝好友添加
        
    }
    NSString *retcode = @"0"; // 0：消息接收到  1：其他错误
    NSDictionary *params = @{@"Action":@"AddFriendReply",@"Retcode":retcode,@"Msg":@"",@"ToId":[UserConfig getShareObject].userId};
    NSInteger tempmsgid = [receiveDic objectForKey:@"msgid"]?[[receiveDic objectForKey:@"msgid"] integerValue]:0;
    [SocketMessageUtil sendRecevieMessageWithParams3:params tempmsgid:tempmsgid];
    
    FriendModel *model = [[FriendModel alloc] init];
    model.userId = UserId;
    model.username = [NickName base64DecodedString];
    model.bg_tableName = FRIEND_LIST_TABNAME;
    [model bg_saveOrUpdateAsync:^(BOOL isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:FRIEND_LIST_CHANGE_NOTI object:nil];
        });
        
    }];
    
     NSArray *finfAlls = [FriendModel bg_find:FRIEND_REQUEST_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue(UserId),bg_sqlKey(@"owerId"),bg_sqlValue([UserModel getUserModel].userId)]];
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
   // NSString *Msg = receiveDic[@"params"][@"Msg"];
  //  NSString *FromId = receiveDic[@"params"][@"FromId"];
  //  NSString *ToId = receiveDic[@"params"][@"ToId"];
    NSString *sendMsgID = [NSString stringWithFormat:@"%@",receiveDic[@"msgid"]];
    if (retCode == 0) { // 0：消息发送成功
//        CDMessageModel *model = [[CDMessageModel alloc] init];
//        model.FromId = FromId;
//        model.ToId = ToId;
//        model.messageId = MsgId;
//        model.sendMsgId = sendMsgID;
//        model.msg = Msg;
//
//
    } else if (retCode == 1) { // 1：目标不可达
       // [AppD.window showHint:@"Message sending failed"];
    } else if (retCode == 2) { // 2：其他错误
       // [AppD.window showHint:@"Message sending failed"];
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
                [HWUserdefault updateObject:[format stringFromDate:[NSDate date]]withKey:PLAY_KEY];
            }
        } else {
             [SystemUtil playSystemSound];
             [HWUserdefault updateObject:[format stringFromDate:[NSDate date]]withKey:PLAY_KEY];
        }
       
    }
    [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_MESSAGE_NOTI object:model];
    NSString *retcode = @"0"; // 0：消息接收成功   1：目标不可达   2：其他错误
    NSDictionary *params = @{@"Action":@"PushMsg",@"Retcode":retcode,@"Msg":@"",@"ToId":model.ToId};
    NSInteger tempmsgid = [receiveDic objectForKey:@"msgid"]?[[receiveDic objectForKey:@"msgid"] integerValue]:0;
    [SocketMessageUtil sendRecevieMessageWithParams3:params tempmsgid:tempmsgid];
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
    NSDictionary *params = @{@"Action":@"PushDelMsg",@"Retcode":retcode,@"Msg":@""  ,@"ToId":UserId};
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
    [[NSNotificationCenter defaultCenter] postNotificationName:ADD_FRIEND_NOTI object:@(retCode)];
    
}

+ (void)handleLogin:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    NSString *userId = receiveDic[@"params"][@"UserId"];
    NSInteger needSynch = [receiveDic[@"params"][@"NeedSynch"] integerValue];
    NSString *userName = receiveDic[@"params"][@"NickName"];
    NSString *userSn = receiveDic[@"params"][@"UserSn"];
    NSString *hashid = receiveDic[@"params"][@"Index"];
    NSInteger dataFileVersion = [receiveDic[@"params"][@"DataFileVersion"] integerValue];
    NSString *dataFilePay = receiveDic[@"params"][@"DataFilePay"];
    
    [UserConfig getShareObject].userId = userId;
    [UserConfig getShareObject].userName = [userName base64DecodedString];
    [UserConfig getShareObject].usersn = userSn;
    [UserConfig getShareObject].dataFileVersion = dataFileVersion;
    [UserConfig getShareObject].dataFilePay = dataFilePay;
    
    if (retCode == 0) { // 成功
        if (userId.length > 0) {
            [UserModel updateUserLocalWithUserId:userId withUserName:userName userSn:userSn hashid:hashid];
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
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:PullFileList_Complete_Noti object:receiveDic];
    }
}

+ (void)handleUploadFileReq:(NSDictionary *)receiveDic {
    [AppD.window hideHud];
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    NSString *msgId = [NSString stringWithFormat:@"%@",receiveDic[@"msgid"]];
    if (retCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UploadFileReq_Success_Noti object:msgId];
    } else if (retCode == 1) {
        [AppD.window showHint:@"Existing file with the same name"];
    } else if (retCode == 2) {
        [AppD.window showHint:@"Not enough space"];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:Delegate_File_Noti object:nil];
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

#pragma mark - Base
+ (NSDictionary *)getBaseParams {
    NSString *timestamp = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    return @{@"appid":@"MIFI",@"timestamp":timestamp,@"apiversion":SOCKET_APIVERSION,@"msgid":[NSString stringWithFormat:@"%ld",(long)[ChatListDataUtil getShareObject].tempMsgId++],@"offset":@"0",@"more":@"0"};
}
+ (NSDictionary *)getBaseParams3 {
    NSString *timestamp = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    return @{@"appid":@"MIFI",@"timestamp":timestamp,@"apiversion":APIVERSION3,@"msgid":[NSString stringWithFormat:@"%ld",(long)[ChatListDataUtil getShareObject].tempMsgId++],@"offset":@"0",@"more":@"0"};
}

+ (NSDictionary *)getMutBaseParamsWithMore {
    NSString *timestamp = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    return @{@"appid":@"MIFI",@"timestamp":timestamp,@"apiversion":SOCKET_APIVERSION,@"msgid":[NSString stringWithFormat:@"%ld",(long)[ChatListDataUtil getShareObject].tempMsgId++],@"offset":@"0",@"more":@"0"};
}

+ (NSDictionary *)getRegiserBaseParams {
    NSString *timestamp = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    return @{@"appid":@"MIFI",@"timestamp":timestamp,@"apiversion":APIVERSION,@"msgid":[NSString stringWithFormat:@"%ld",(long)[ChatListDataUtil getShareObject].tempMsgId++],@"offset":@"0",@"more":@"0"};
}

+ (NSDictionary *)getRecevieBaseParams:(NSInteger) tempmsgid {
    NSString *timestamp = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    return @{@"appid":@"MIFI",@"timestamp":timestamp,@"apiversion":SOCKET_APIVERSION,@"msgid":[NSString stringWithFormat:@"%ld",(long)tempmsgid],@"offset":@"0",@"more":@"0"};
}
+ (NSDictionary *)getRecevieBaseParams3:(NSInteger) tempmsgid {
    NSString *timestamp = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    return @{@"appid":@"MIFI",@"timestamp":timestamp,@"apiversion":APIVERSION3,@"msgid":[NSString stringWithFormat:@"%ld",(long)tempmsgid],@"offset":@"0",@"more":@"0"};
}

+ (NSDictionary *)getRecevieBaseVersion2Params:(NSInteger) tempmsgid {
    NSString *timestamp = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    return @{@"appid":@"MIFI",@"timestamp":timestamp,@"apiversion":APIVERSION,@"msgid":[NSString stringWithFormat:@"%ld",(long)tempmsgid],@"offset":@"0",@"more":@"0"};
}


#pragma -mark 同意或拒绝好友请求
+ (void) sendAgreedOrRefusedWithFriendMode:(FriendModel *) model withType:(NSString *)type
{
   
    UserModel *userM = [UserModel getUserModel];
    NSString *result = type; // 0：同意添加   1：拒绝好友添加
    NSString *friendName = model.username?:@"";
    NSString *friendId = model.userId?:@"";
    NSDictionary *params = @{@"Action":@"AddFriendDeal",@"Nickname":[userM.username base64EncodedString]?:@"",@"FriendName":[friendName base64EncodedString]?:@"",@"UserId":userM.userId?:@"",@"FriendId":friendId,@"UserKey":[EntryModel getShareObject].signPublicKey,@"Result":result,@"FriendKey":model.publicKey?:@""};
    [SocketMessageUtil sendVersion3WithParams:params];
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
    [SocketMessageUtil sendVersion3WithParams:params];
}
#pragma -mark 发送data文件
+ (void) sendDataFileNeedSynch:(NSInteger) synch
{
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_SynchDataFile,@"UserId":userM.userId?:@"",@"NeedSynch":@(synch),@"UserDataVersion":@"1.0",@"DataPay":@"database64"};
    [SocketMessageUtil sendVersion1WithParams:params];
}

@end
