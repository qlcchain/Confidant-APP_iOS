//
//  SendRequestUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/13.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "SendRequestUtil.h"
#import "SocketMessageUtil.h"
#import "RoutherConfig.h"
#import "UserModel.h"
#import "NSString+Base64.h"
#import "RSAModel.h"

@implementation SendRequestUtil

#pragma mark - 用户找回
+ (void) sendUserFindWithToxid:(NSString *) toxid usesn:(NSString *) sn {
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    NSDictionary *params = @{@"Action":@"Recovery",@"RouteId":toxid?:@"",@"UserSn":sn?:@""};
    [SocketMessageUtil sendVersion2WithParams:params];
}
#pragma mark - 用户注册
+ (void) sendUserRegisterWithUserPass:(NSString *) pass username:(NSString *) userName code:(NSString *) code
{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    NSDictionary *params = @{@"Action":@"Register",@"RouteId":[RoutherConfig getRoutherConfig].currentRouterToxid?:@"",@"UserSn":[RoutherConfig getRoutherConfig].currentRouterSn?:@"",@"IdentifyCode":code,@"LoginKey":pass,@"NickName":userName};
    [SocketMessageUtil sendVersion2WithParams:params];
}
#pragma mark - 用户登陆
+ (void) sendUserLoginWithPass:(NSString *) passWord userid:(NSString *) userid  {
    if (AppD.isDisConnectLogin) {
        AppD.isDisConnectLogin = NO;
    } else {
        [AppD.window showHudInView:AppD.window hint:@"Login..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":@"Login",@"RouteId":[RoutherConfig getRoutherConfig].currentRouterToxid?:@"",@"UserSn":[RoutherConfig getRoutherConfig].currentRouterSn?:@"",@"UserId":userid?:@"",@"LoginKey":passWord,@"DataFileVersion":[NSString stringWithFormat:@"%zd",[UserModel getUserModel].dataFileVersion]};
    [SocketMessageUtil sendVersion2WithParams:params];
}
#pragma mark -派生类拉取用户
+ (void) sendPullUserList
{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    
    NSDictionary *params = @{@"Action":@"PullUserList",@"UserType":@(0),@"UserNum":@(0),@"UserStartSN":@"0"};
    [SocketMessageUtil sendVersion2WithParams:params];
}
#pragma mark -创建帐户
+ (void) createRouterUserWithRouterId:(NSString *) routerId mnemonic:(NSString *) mnemonic code:(NSString *) code
{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
     UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":@"CreateNormalUser",@"RouterId":routerId,@"AdminUserId":userM.userId,@"Mnemonic":mnemonic,@"IdentifyCode":code};
    [SocketMessageUtil sendVersion2WithParams:params];
}
+ (void) sendAddFriendWithFriendId:(NSString *) friendId
{
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":@"AddFriendReq",@"NickName":[userM.username base64EncodedString]?:@"",@"UserId":userM.userId?:@"",@"FriendId":friendId?:@"",@"UserKey":[RSAModel getCurrentRASModel].publicKey,@"Msg":@""};
    [SocketMessageUtil sendTextWithParams:params];
}
#pragma mark -tox pull文件
+ (void) sendToxPullFileWithFromId:(NSString *) fromId toid:(NSString *) toid filePath:(NSString *) filePath msgid:(NSString *) msgId

{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    NSDictionary *params = @{};
    [SocketMessageUtil sendTextWithParams:params];
}
#pragma mark -发送已读
+ (void) sendRedMsgWithFriendId:(NSString *) friendId msgid:(NSString *) msgId
{
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":@"ReadMsg",@"UserId":userM.userId,@"FriendId":friendId,@"ReadMsgs":msgId};
    [SocketMessageUtil sendVersion2WithParams:params];
}
#pragma mark - 登陆退出
+ (void) sendLogOut
{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":@"LogOut",@"UserId":userM.userId,@"RouterId":[RoutherConfig getRoutherConfig].currentRouterToxid?:@"",@"UserSn":[RoutherConfig getRoutherConfig].currentRouterSn?:@""};
    [SocketMessageUtil sendVersion2WithParams:params];
}
#pragma mark -修改昵称
+ (void) sendUpdateWithNickName:(NSString *) nickName
{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":@"UserInfoUpdate",@"UserId":userM.userId,@"NickName":[nickName base64EncodedString]};
    [SocketMessageUtil sendVersion2WithParams:params];
}
#pragma mark -sendfile tox
+ (void) sendToxSendFileWithParames:(NSDictionary *) parames
{
    [SocketMessageUtil sendTextWithParams:parames];
}

#pragma mark tox_拉取文件
+ (void) sendToxPullFileWithFromId:(NSString *) fromId toid:(NSString *) toId fileName:(NSString *) fileName msgId:(NSString *) msgId
{
    NSDictionary *params = @{@"Action":@"PullFile",@"FromId":fromId,@"ToId":toId,@"FileName":fileName,@"MsgId":msgId};
    [SocketMessageUtil sendTextWithParams:params];
}
@end
