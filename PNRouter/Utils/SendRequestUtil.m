//
//  SendRequestUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/13.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "SendRequestUtil.h"
#import "SocketMessageUtil.h"
#import "RouterConfig.h"
#import "UserModel.h"
#import "NSString+Base64.h"
#import "RSAModel.h"
#import "HeartBeatUtil.h"
#import "AFHTTPClientV2.h"
#import "UserConfig.h"
#import "EntryModel.h"
#import "PNRouter-Swift.h"

@implementation SendRequestUtil

#pragma mark - 用户找回
+ (void) sendUserFindWithToxid:(NSString *) toxid usesn:(NSString *) sn  {
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    NSDictionary *params = @{@"Action":@"Recovery",@"RouteId":toxid?:@"",@"UserSn":sn?:@"",@"Pubkey":[EntryModel getShareObject].signPublicKey};
    [SocketMessageUtil sendVersion4WithParams:params];
}
#pragma mark - 用户注册
+ (void) sendUserRegisterWithUserPass:(NSString *) pass username:(NSString *) userName code:(NSString *) code
{
    [AppD.window showHudInView:AppD.window hint:@"Register..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    NSDictionary *params = @{@"Action":@"Register",@"RouteId":[RouterConfig getRouterConfig].currentRouterToxid?:@"",@"UserSn":[RouterConfig getRouterConfig].currentRouterSn?:@"",@"Sign":@"",@"Pubkey":[EntryModel getShareObject].signPublicKey,@"NickName":userName};
    [SocketMessageUtil sendVersion4WithParams:params];
}
#pragma mark - 用户登陆
+ (void) sendUserLoginWithPass:(NSString *) usersn userid:(NSString *) userid showHud:(BOOL) showHud {
    
    if (showHud) {
       [AppD.window showHudInView:AppD.window hint:@"Login..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSString *loginUsersn = [RouterConfig getRouterConfig].currentRouterSn;
    if (![[NSString getNotNullValue:usersn] isEmptyString]) {
        loginUsersn = usersn;
    }
    NSDictionary *params = @{@"Action":@"Login",@"RouteId":[RouterConfig getRouterConfig].currentRouterToxid?:@"",@"UserId":userid?:@"",@"UserSn":loginUsersn?:@"",@"Sign":@"",@"DataFileVersion":[NSString stringWithFormat:@"%zd",[UserModel getUserModel].dataFileVersion],@"NickName":[[UserModel getUserModel].username base64EncodedString]};
    [SocketMessageUtil sendVersion4WithParams:params];
    
}
#pragma mark -派生类拉取用户
+ (void) sendPullUserList
{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    NSDictionary *params = @{@"Action":Action_PullUserList,@"UserType":@(0),@"UserNum":@(0),@"UserStartSN":@"0"};
    [SocketMessageUtil sendVersion2WithParams:params];
}
#pragma mark -创建帐户
+ (void) createRouterUserWithRouterId:(NSString *) routerId mnemonic:(NSString *) mnemonic
{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_CreateNormalUser,@"RouterId":routerId,@"AdminUserId":userM.userId,@"Mnemonic":mnemonic,@"IdentifyCode":@""};
    [SocketMessageUtil sendVersion2WithParams:params];
}
+ (void) sendAddFriendWithFriendId:(NSString *) friendId msg:(NSString *) msg
{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":@"AddFriendReq",@"NickName":[userM.username base64EncodedString]?:@"",@"UserId":userM.userId?:@"",@"FriendId":friendId?:@"",@"UserKey":[EntryModel getShareObject].signPublicKey?:@"",@"Msg":msg?:@""};
    [SocketMessageUtil sendVersion4WithParams:params];
}
#pragma mark -tox pull文件
+ (void) sendToxPullFileWithFromId:(NSString *) fromId toid:(NSString *) toid filePath:(NSString *) filePath msgid:(NSString *) msgId

{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    NSDictionary *params = @{};
    [SocketMessageUtil sendVersion1WithParams:params];
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
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":@"LogOut",@"UserId":userM.userId,@"RouterId":[RouterConfig getRouterConfig].currentRouterToxid?:@"",@"UserSn":[RouterConfig getRouterConfig].currentRouterSn?:@""};
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
    [SocketMessageUtil sendVersion1WithParams:parames];
}

#pragma mark tox_拉取文件
+ (void) sendToxPullFileWithFromId:(NSString *) fromId toid:(NSString *) toId fileName:(NSString *) fileName msgId:(NSString *) msgId fileOwer:(NSString *) fileOwer fileFrom:(NSString *) fileFrom
{
    NSDictionary *params = @{@"Action":@"PullFile",@"FromId":fromId,@"ToId":toId,@"FileName":fileName,@"MsgId":msgId,@"FileOwner":fileOwer,@"FileFrom":fileFrom};
    [SocketMessageUtil sendVersion1WithParams:params];
}

#pragma mark -注册小米推送 邦定regid
+ (void) sendRegidReqeust
{
    if (AppD.regId && ![AppD.regId isEmptyString]) {
      //  NSDictionary *params = @{@"os":@"1",@"appversion":APP_Version,@"regid":AppD.regId,@"topicid":@"",@"routerid":[RoutherConfig getRouterConfig].currentRouterToxid,@"userid":[UserModel getUserModel].userId?:@"",@"usersn":[UserModel getUserModel].userSn?:@""};
        
         NSDictionary *params = @{@"os":@"1",@"appversion":APP_Version,@"regid":AppD.regId,@"routerid":[RouterConfig getRouterConfig].currentRouterToxid,@"userid":[UserConfig getShareObject].userId?:@"",@"usersn":[UserConfig getShareObject].usersn?:@""};
       
        [AFHTTPClientV2 requestWithBaseURLStr:PUSH_ONLINE_URL params:params httpMethod:HttpMethodPost successBlock:^(NSURLSessionDataTask *dataTask, id responseObject) {
            int retCode = [responseObject[@"Ret"] intValue];
            if (retCode == 0) {
                NSLog(@"注册推送成功!");
            } else {
                NSLog(@"注册推送失败!");
            }
        } failedBlock:^(NSURLSessionDataTask *dataTask, NSError *error) {
            NSLog(@"注册推送失败!!!!!!!!");
        }];
    }
    
}
#pragma mark -添加好友备注
+ (void) sendAddFriendNickName:(NSString *) nickName friendId:(NSString *) friendId
{
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":@"ChangeRemarks",@"UserId":userM.userId,@"FriendId":friendId,@"Remarks":[nickName base64EncodedString]};
    [SocketMessageUtil sendVersion2WithParams:params];
}
#pragma mark -查询好友关系状态
+ (void) sendQueryFriendWithFriendId:(NSString *) friendId
{
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":@"QueryFriend",@"UserId":userM.userId,@"FriendId":friendId};
    [SocketMessageUtil sendVersion2WithParams:params];
}

#pragma mark - 登录设备
+ (void)sendRouterLoginWithMac:(NSString *)mac loginKey:(NSString *)loginKey showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Login..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_RouterLogin,@"Mac":mac?:@"",@"LoginKey":loginKey?:@""};
    [SocketMessageUtil sendVersion2WithParams:params];
}

#pragma mark - 路由器修改管理密码
+ (void)sendResetRouterKeyWithRouterId:(NSString *)RouterId OldKey:(NSString *)OldKey NewKey:(NSString *)NewKey showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_ResetRouterKey,@"RouterId":RouterId?:@"",@"OldKey":OldKey?:@"",@"NewKey":NewKey?:@""};
    [SocketMessageUtil sendVersion2WithParams:params];
}

#pragma mark - 路由器修改账户激活码
+ (void)sendResetUserIdcodeWithRouterId:(NSString *)RouterId UserSn:(NSString *)UserSn OldCode:(NSString *)OldCode NewCode:(NSString *)NewCode showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_ResetUserIdcode,@"RouterId":RouterId?:@"",@"UserSn":UserSn?:@"",@"OldCode":OldCode?:@"",@"NewCode":NewCode?:@""};
    [SocketMessageUtil sendVersion2WithParams:params];
}

#pragma mark - 拉取文件列表
+ (void)sendPullFileListWithUserId:(NSString *)UserId MsgStartId:(NSNumber *)MsgStartId MsgNum:(NSNumber *)MsgNum Category:(NSNumber *)Category FileType:(NSNumber *)FileType showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_PullFileList,@"UserId":UserId?:@"",@"MsgStartId":MsgStartId?:@"",@"MsgNum":MsgNum?:@"",@"Category":Category?:@"",@"FileType":FileType?:@""};
    [SocketMessageUtil sendVersion2WithParams:params];
}

#pragma mark - 上传文件请求
+ (void)sendUploadFileReqWithUserId:(NSString *)UserId FileName:(NSString *)FileName FileSize:(NSNumber *)FileSize FileType:(NSNumber *)FileType showHud:(BOOL)showHud fetchParam:(void(^)(NSDictionary *dic))paramB {
    if (showHud) {
       // File encrypting
        [AppD.window showHudInView:AppD.window hint:@"Upload..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_UploadFileReq,@"UserId":UserId?:@"",@"FileName":FileName?:@"",@"FileSize":FileSize?:@"",@"FileType":FileType?:@""};
    [SocketMessageUtil sendVersion2WithParams:params fetchParam:^(NSDictionary *dic) {
        if (paramB) {
            paramB(dic);
        }
    }];
}

#pragma mark - 上传文件
+ (void)sendUploadFileWithUserId:(NSString *)UserId FileName:(NSString *)FileName FileMD5:(NSString *)FileMD5 FileSize:(NSNumber *)FileSize FileType:(NSNumber *)FileType UserKey:(NSString *)UserKey showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_UploadFile,@"UserId":UserId?:@"",@"FileName":FileName?:@"",@"FileMD5":FileMD5?:@"",@"FileSize":FileSize?:@"",@"FileType":FileType?:@"",@"UserKey":UserKey?:@""};
    [SocketMessageUtil sendVersion2WithParams:params];
}

#pragma mark - 删除文件
+ (void)sendDelFileWithUserId:(NSString *)UserId FileName:(NSString *)FileName showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_DelFile,@"UserId":UserId?:@"",@"FileName":FileName?:@""};
    [SocketMessageUtil sendVersion2WithParams:params];
}

#pragma mark - 拉取可分享文件好友列表
+ (void)sendPullSharedFriendWithUserId:(NSString *)UserId showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_PullSharedFriend,@"UserId":UserId?:@""};
    [SocketMessageUtil sendVersion2WithParams:params];
}

#pragma mark - 分享文件
+ (void)sendShareFileWithFromId:(NSString *)FromId ToId:(NSString *)ToId FileName:(NSString *)FileName DstKey:(NSString *)DstKey showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_ShareFile,@"FromId":FromId?:@"",@"ToId":ToId?:@"",@"FileName":FileName?:@"",@"DstKey":DstKey?:@""};
    [SocketMessageUtil sendVersion2WithParams:params];
}

#pragma mark - 设备磁盘统计信息
+ (void)sendGetDiskTotalInfoWithShowHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_GetDiskTotalInfo};
    [SocketMessageUtil sendVersion3WithParams:params];
}

#pragma mark - 设备磁盘详细信息
+ (void)sendGetDiskDetailInfoWithSlot:(NSNumber *)Slot showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_GetDiskDetailInfo, @"Slot":Slot};
    [SocketMessageUtil sendVersion3WithParams:params];
}

#pragma mark - 设备磁盘模式配置
+ (void)sendFormatDiskWithMode:(NSString *)Mode showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_FormatDisk, @"Mode":Mode};
    [SocketMessageUtil sendVersion3WithParams:params];
}

#pragma mark - 设备重启
+ (void)sendRebootWithShowHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_Reboot};
    [SocketMessageUtil sendVersion3WithParams:params];
}

#pragma mark - 文件重命名
+ (void)sendFileRenameWithMsgId:(NSNumber *)MsgId Filename:(NSString *)Filename Rename:(NSString *)Rename showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_FileRename, @"UserId":userM.userId?:@"", @"MsgId":MsgId, @"Filename":[Base58Util Base58EncodeWithCodeName:Filename], @"Rename":[Base58Util Base58EncodeWithCodeName:Rename]};
    [SocketMessageUtil sendVersion4WithParams:params];
}

#pragma mark -转发
+ (void) sendFileForwardMsgid:(NSString *) msgid toid:(NSString *) toid fileName:(NSString *) fileName filekey:(NSString *) filekey fileInfo:(NSString *) fileInfo
{
    NSDictionary *params = @{@"Action":Action_FileForward,@"MsgId":msgid?:@"",@"FromId":[UserConfig getShareObject].userId?:@"",@"ToId":toid,@"FileName":fileName?:@"",@"FileKey":filekey?:@"",@"FileInfo":fileInfo?:@""};
    [SocketMessageUtil sendVersion4WithParams:params];
}

#pragma mark - 用户上传头像
+ (void)sendUploadAvatarWithFileName:(NSString *)FileName FileMd5:(NSString *)FileMd5 showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_UploadAvatar,@"Uid":userM.userId?:@"",@"FileName":[Base58Util Base58EncodeWithCodeName:FileName],@"FileMd5":FileMd5};
    [SocketMessageUtil sendVersion4WithParams:params];
}

#pragma mark - 更新好友头像
+ (void)sendUpdateAvatarWithFid:(NSString *)Fid Md5:(NSString *)Md5 showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_UpdateAvatar,@"Uid":userM.userId?:@"",@"Fid":Fid,@"Md5":Md5};
    [SocketMessageUtil sendVersion4WithParams:params];
}



#pragma mark ------------group chat---------------
+ (void) sendCreateGroupWithName:(NSString *) groupName userKey:(NSString *) userKey verifyMode:(NSString *) verifyMode friendId:(NSString *) friendId friendKey:(NSString *) friendKey showHud:(BOOL)showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_CreateGroup,@"UserId":userM.userId?:@"",@"GroupName":groupName?:@"",@"UserKey":userKey?:@"",@"VerifyMode":verifyMode,@"FriendId":friendId,@"FriendKey":friendKey?:@""};
    [SocketMessageUtil sendVersion4WithParams:params];
}
+ (void) sendPullGroupListWithShowHud:(BOOL)showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_GroupListPull,@"UserId":userM.userId?:@"",@"RouterId":[RouterConfig getRouterConfig].currentRouterToxid?:@"",@"TargetNum":@"0",@"StartId":@"0"};
    [SocketMessageUtil sendVersion4WithParams:params];
}

#pragma mark - 拉取群好友信息
+ (void)sendGroupUserPullWithGId:(NSString *)GId TargetNum:(NSNumber *)TargetNum StartId:(NSString *)StartId showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_GroupUserPull,@"UserId":userM.userId?:@"",@"RouterId":[RouterConfig getRouterConfig].currentRouterToxid?:@"",@"GId":GId,@"TargetNum":TargetNum,@"StartId":StartId};
    [SocketMessageUtil sendVersion4WithParams:params];
}
#pragma mark ---拉取好友进群
+ (void) sendAddGroupWithGId:(NSString *) gid friendId:(NSString *) friendids friendKey:(NSString *) friendkeys showHud:(BOOL)showHud{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_InviteGroup,@"UserId":userM.userId?:@"",@"FriendId":friendids?:@"",@"GId":gid,@"FriendKey":friendkeys};
    [SocketMessageUtil sendVersion4WithParams:params];
}
#pragma mark ---发送群组文字消息
+ (void) sendGroupMessageWithGid:(NSString *) gid point:(NSString *) point msg:(NSString *) msg msgid:(NSString *) msgid
{
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_GroupSendMsg,@"UserId":userM.userId?:@"",@"Point":point?:@"",@"GId":gid,@"Msg":msg};
    [SocketMessageUtil sendGroupChatTextWithParams:params withSendMsgId:msgid];
}
#pragma mark --拉取群消息列表
+ (void) sendPullGroupMessageListWithGId:(NSString *) gid MsgType:(NSString *) msgType msgStartId:(NSString *) msgStartId msgNum:(NSString *) msgNum
{
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_GroupMsgPull,@"UserId":userM.userId?:@"",@"RouterId":[RouterConfig getRouterConfig].currentRouterToxid?:@"",@"GId":gid,@"MsgType":msgType,@"MsgNum":msgNum,@"MsgStartId":msgStartId};
    [SocketMessageUtil sendVersion4WithParams:params];
}
#pragma mark ---群组发送文件成功
+ (void) sendGroupFilePretreatmentWithGID:(NSString *) gid fileName:(NSString *) fileName fileSize:(NSNumber *) fileSize fileType:(NSNumber *) fileType fileMD5:(NSString *) fileMd5 fileInfo:(NSString *) fileInfo fileId:(NSString *) fileId
{
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_GroupSendFileDone,@"UserId":userM.userId?:@"",@"FileMD5":fileMd5?:@"",@"GId":gid,@"FileName":fileName,@"FileSize":fileSize,@"FileType":fileType,@"FileInfo":fileInfo,@"FileId":fileId};
    [SocketMessageUtil sendVersion4WithParams:params];
}
#pragma mark --删除群消息
+ (void) sendDelGroupMessageWithType:(NSNumber *) type GId:(NSString *) gid MsgId:(NSString *) msgid FromID:(NSString *) formID
{
    NSDictionary *params = @{@"Action":Action_GroupDelMsg,@"Type":type,@"From":formID?:@"",@"GId":gid,@"MsgId":msgid};
    [SocketMessageUtil sendVersion4WithParams:params];
}
#pragma mark - 77.    群属性设置
+ (void)sendGroupConfigWithGId:(NSString *)GId Type:(NSNumber *)Type ToId:(nullable NSString *)ToId Name:(nullable NSString *)Name NeedVerify:(nullable NSNumber *)NeedVerify showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_GroupConfig,@"UserId":userM.userId?:@"",@"GId":GId,@"Type":Type,@"ToId":ToId?:@"",@"Name":Name?:@"",@"NeedVerify":NeedVerify?:@(-1)};
    [SocketMessageUtil sendVersion4WithParams:params];
}

#pragma mark - 68.    用户退群
+ (void)sendGroupQuitWithGId:(NSString *)GId GroupName:(nullable NSString *)GroupName showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_GroupQuit,@"UserId":userM.userId?:@"",@"GId":GId,@"GroupName":GroupName?:@""};
    [SocketMessageUtil sendVersion4WithParams:params];
}

#pragma mark - 66.    邀请用户入群审核处理
+ (void)sendGroupVerifyWithFrom:(NSString *)From To:(NSString *)To Aduit:(NSString *)Aduit GId:(NSString *)GId GName:(nullable NSString *)GName Result:(NSNumber *)Result UserKey:(nullable NSString *)UserKey showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Loading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_GroupVerify,@"From":From,@"To":To,@"Aduit":Aduit,@"GId":GId,@"GName":GName?:@"",@"Result":Result,@"UserKey":UserKey};
    [SocketMessageUtil sendVersion4WithParams:params];
}



@end
