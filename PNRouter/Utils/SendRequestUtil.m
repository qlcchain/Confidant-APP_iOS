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

#import "MyConfidant-Swift.h"
#import "EmailAccountModel.h"

@implementation SendRequestUtil

#pragma mark - 用户找回
+ (void) sendUserFindWithToxid:(NSString *) toxid usesn:(NSString *) sn  {
    [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    NSDictionary *params = @{@"Action":@"Recovery",@"RouteId":toxid?:@"",@"UserSn":sn?:@"",@"Pubkey":[EntryModel getShareObject].signPublicKey};
    [SocketMessageUtil sendVersion4WithParams:params];
}
+ (void) sendUserFindWithToxid:(NSString *) toxid usesn:(NSString *) sn showHud:(BOOL) isShow {
    if (isShow) {
         [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":@"Recovery",@"RouteId":toxid?:@"",@"UserSn":sn?:@"",@"Pubkey":[EntryModel getShareObject].signPublicKey};
    [SocketMessageUtil sendVersion4WithParams:params];
}
#pragma mark - 用户注册
+ (void) sendUserRegisterWithUserPass:(NSString *) pass username:(NSString *) userName code:(NSString *) code showHUD:(BOOL) isShow
{
    if (isShow) {
         [AppD.window showHudInView:AppD.window hint:@"Register..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
   
    NSDictionary *params = @{@"Action":@"Register",@"RouteId":[RouterConfig getRouterConfig].currentRouterToxid?:@"",@"UserSn":[RouterConfig getRouterConfig].currentRouterSn?:@"",@"Sign":@"",@"Pubkey":[EntryModel getShareObject].signPublicKey,@"NickName":userName,@"Termial":@(2)};
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
    NSDictionary *params = @{@"Action":@"Login",@"RouteId":[RouterConfig getRouterConfig].currentRouterToxid?:@"",@"UserId":userid?:@"",@"UserSn":loginUsersn?:@"",@"Sign":@"",@"DataFileVersion":[NSString stringWithFormat:@"%zd",[UserModel getUserModel].dataFileVersion],@"NickName":[[UserModel getUserModel].username base64EncodedString],@"Termial":@(2)};
    [SocketMessageUtil sendVersion4WithParams:params];
    
}
#pragma mark -派生类拉取用户
+ (void) sendPullUserListWithShowLoad:(BOOL)show {
    if (show) {
        [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
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
+ (void) sendAddFriendWithFriendId:(NSString *) friendId msg:(NSString *) msg showHud:(BOOL)showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    
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
    // 隐藏connect cirle...状态栏
    [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_SOCKET_FAILD_NOTI object:@"1"];
    
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
#pragma mark -sendfile tox 单聊
+ (void) sendToxSendFileWithParames:(NSDictionary *) parames
{
    [SocketMessageUtil sendVersion1WithParams:parames];
}
#pragma mark -sendfile tox 群聊
+ (void) sendToxSendGroupFileWithParames:(NSDictionary *) parames
{
    [SocketMessageUtil sendVersion4WithParams:parames];
}

#pragma mark tox_拉取文件
+ (void) sendToxPullFileWithFromId:(NSString *) fromId toid:(NSString *) toId fileName:(NSString *) fileName filePath:(NSString *) filePath msgId:(NSString *) msgId fileOwer:(NSString *) fileOwer fileFrom:(NSString *) fileFrom
{
    NSDictionary *params = @{@"Action":@"PullFile",@"FromId":fromId,@"ToId":toId,@"FileName":fileName?:@"",@"FilePath":filePath?:@"",@"MsgId":msgId,@"FileOwner":fileOwer,@"FileFrom":fileFrom};
    [SocketMessageUtil sendVersion5WithParams:params];
}

#pragma mark -注册小米推送 邦定regid
+ (void) sendRegidReqeust
{
    if (AppD.regId && ![AppD.regId isEmptyString]) {
        
        NSDictionary *params = @{@"os":pushType,@"regtype":@(2),@"appversion":APP_Version,@"regid":AppD.regId,@"routerid":[RouterConfig getRouterConfig].currentRouterToxid,@"userid":[UserConfig getShareObject].userId?:@"",@"usersn":[UserConfig getShareObject].usersn?:@""};
        
        NSLog(@"parames = %@",params);
       
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
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_ResetRouterKey,@"RouterId":RouterId?:@"",@"OldKey":OldKey?:@"",@"NewKey":NewKey?:@""};
    [SocketMessageUtil sendVersion2WithParams:params];
}

#pragma mark - 路由器修改账户激活码
+ (void)sendResetUserIdcodeWithRouterId:(NSString *)RouterId UserSn:(NSString *)UserSn OldCode:(NSString *)OldCode NewCode:(NSString *)NewCode showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_ResetUserIdcode,@"RouterId":RouterId?:@"",@"UserSn":UserSn?:@"",@"OldCode":OldCode?:@"",@"NewCode":NewCode?:@""};
    [SocketMessageUtil sendVersion2WithParams:params];
}

#pragma mark - 拉取文件列表
+ (void)sendPullFileListWithUserId:(NSString *)UserId MsgStartId:(NSNumber *)MsgStartId MsgNum:(NSNumber *)MsgNum Category:(NSNumber *)Category FileType:(NSNumber *)FileType showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_PullFileList,@"UserId":UserId?:@"",@"MsgStartId":MsgStartId?:@"",@"MsgNum":MsgNum?:@"",@"Category":Category?:@"",@"FileType":FileType?:@""};
    [SocketMessageUtil sendVersion5WithParams:params];
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
+ (void)sendUploadFileWithUserId:(NSString *)UserId FileName:(NSString *)FileName FileMD5:(NSString *)FileMD5 FileSize:(NSNumber *)FileSize FileType:(NSNumber *)FileType UserKey:(NSString *)UserKey fileInfo:(NSString *) fileInfo showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_UploadFile,@"UserId":UserId?:@"",@"FileName":FileName?:@"",@"FileMD5":FileMD5?:@"",@"FileSize":FileSize?:@"",@"FileType":FileType?:@"",@"UserKey":UserKey?:@"",@"FileInfo":fileInfo};
    [SocketMessageUtil sendVersion2WithParams:params];
}

#pragma mark - 删除文件
+ (void)sendDelFileWithUserId:(NSString *)UserId FileName:(NSString *)FileName filePath:(NSString *) filePath showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Deleting_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_DelFile,@"UserId":UserId?:@"",@"FileName":FileName?:@"",@"FilePath":filePath?:@""};
    [SocketMessageUtil sendVersion5WithParams:params];
}

#pragma mark - 拉取可分享文件好友列表
+ (void)sendPullSharedFriendWithUserId:(NSString *)UserId showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_PullSharedFriend,@"UserId":UserId?:@""};
    [SocketMessageUtil sendVersion2WithParams:params];
}

#pragma mark - 分享文件
+ (void)sendShareFileWithFromId:(NSString *)FromId ToId:(NSString *)ToId FileName:(NSString *)FileName DstKey:(NSString *)DstKey showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_ShareFile,@"FromId":FromId?:@"",@"ToId":ToId?:@"",@"FileName":FileName?:@"",@"DstKey":DstKey?:@""};
    [SocketMessageUtil sendVersion2WithParams:params];
}

#pragma mark - 设备磁盘统计信息
+ (void)sendGetDiskTotalInfoWithShowHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_GetDiskTotalInfo};
    [SocketMessageUtil sendVersion3WithParams:params];
}

#pragma mark - 设备磁盘详细信息
+ (void)sendGetDiskDetailInfoWithSlot:(NSNumber *)Slot showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_GetDiskDetailInfo, @"Slot":Slot};
    [SocketMessageUtil sendVersion3WithParams:params];
}

#pragma mark - 设备磁盘模式配置
+ (void)sendFormatDiskWithMode:(NSString *)Mode showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_FormatDisk, @"Mode":Mode};
    [SocketMessageUtil sendVersion3WithParams:params];
}

#pragma mark - 设备重启
+ (void)sendRebootWithShowHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Rebooting..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_Reboot,@"User":[UserModel getUserModel].userId?:@""};
    [SocketMessageUtil sendVersion3WithParams:params];
}

#pragma mark - 文件重命名
+ (void)sendFileRenameWithMsgId:(NSNumber *)MsgId Filename:(NSString *)Filename Rename:(NSString *)Rename showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Updateing_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_FileRename, @"UserId":userM.userId?:@"", @"MsgId":MsgId, @"Filename":[Base58Util Base58EncodeWithCodeName:Filename], @"Rename":[Base58Util Base58EncodeWithCodeName:Rename]};
    [SocketMessageUtil sendVersion5WithParams:params];
}

#pragma mark -转发
+ (void) sendFileForwardMsgid:(NSString *) msgid toid:(NSString *) toid fileName:(NSString *) fileName filePath:(NSString *) filePath filekey:(NSString *) filekey fileInfo:(NSString *) fileInfo
{
    NSDictionary *params = @{@"Action":Action_FileForward,@"MsgId":msgid?:@"",@"FromId":[UserConfig getShareObject].userId?:@"",@"ToId":toid,@"FileName":fileName?:@"",@"FilePath":filePath?:@"",@"FileKey":filekey?:@"",@"FileInfo":fileInfo?:@""};
    [SocketMessageUtil sendVersion4WithParams:params];
}

#pragma mark - 用户上传头像
+ (void)sendUploadAvatarWithFileName:(NSString *)FileName FileMd5:(NSString *)FileMd5 showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_UploadAvatar,@"Uid":userM.userId?:@"",@"FileName":[Base58Util Base58EncodeWithCodeName:FileName],@"FileMd5":FileMd5};
    [SocketMessageUtil sendVersion4WithParams:params];
}

#pragma mark - 更新好友头像
+ (void)sendUpdateAvatarWithFid:(NSString *)Fid Md5:(NSString *)Md5 showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_UpdateAvatar,@"Uid":userM.userId?:@"",@"Fid":Fid,@"Md5":Md5};
    [SocketMessageUtil sendVersion4WithParams:params];
}

#pragma mark - 拉取临时通信二维码
+ (void)sendPullTmpAccountWithShowHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_PullTmpAccount,@"UserId":userM.userId?:@""};
    [SocketMessageUtil sendVersion4WithParams:params];
}




#pragma mark ------------group chat---------------
+ (void) sendCreateGroupWithName:(NSString *) groupName userKey:(NSString *) userKey verifyMode:(NSString *) verifyMode friendId:(NSString *) friendId friendKey:(NSString *) friendKey showHud:(BOOL)showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_CreateGroup,@"UserId":userM.userId?:@"",@"GroupName":groupName?:@"",@"UserKey":userKey?:@"",@"VerifyMode":verifyMode,@"FriendId":friendId,@"FriendKey":friendKey?:@""};
    [SocketMessageUtil sendVersion4WithParams:params];
}
+ (void) sendPullGroupListWithShowHud:(BOOL)showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_GroupListPull,@"UserId":userM.userId?:@"",@"RouterId":[RouterConfig getRouterConfig].currentRouterToxid?:@"",@"TargetNum":@"0",@"StartId":@"0"};
    [SocketMessageUtil sendVersion4WithParams:params];
}

#pragma mark - 拉取群好友信息
+ (void)sendGroupUserPullWithGId:(NSString *)GId TargetNum:(NSNumber *)TargetNum StartId:(NSString *)StartId showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_GroupUserPull,@"UserId":userM.userId?:@"",@"RouterId":[RouterConfig getRouterConfig].currentRouterToxid?:@"",@"GId":GId,@"TargetNum":TargetNum,@"StartId":StartId};
    [SocketMessageUtil sendVersion4WithParams:params];
}
#pragma mark ---拉取好友进群
+ (void) sendAddGroupWithGId:(NSString *) gid friendId:(NSString *) friendids friendKey:(NSString *) friendkeys showHud:(BOOL)showHud{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_InviteGroup,@"UserId":userM.userId?:@"",@"FriendId":friendids?:@"",@"GId":gid,@"FriendKey":friendkeys};
    [SocketMessageUtil sendVersion4WithParams:params];
}
#pragma mark ---发送群组文字消息
+ (void) sendGroupMessageWithGid:(NSString *) gid point:(NSString *) point msg:(NSString *) msg msgid:(NSString *) msgid repId:(NSNumber *) repId{
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_GroupSendMsg,@"UserId":userM.userId?:@"",@"Point":point?:@"",@"GId":gid,@"Msg":msg,@"AssocId":repId};
    [SocketMessageUtil sendGroupChatTextWithParams:params withSendMsgId:msgid];
}
#pragma mark --拉取群消息列表
+ (void) sendPullGroupMessageListWithGId:(NSString *) gid MsgType:(NSString *) msgType msgStartId:(NSString *) msgStartId msgNum:(NSString *) msgNum srcMsgId:(NSString *) srcMsgId
{
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_GroupMsgPull,@"UserId":userM.userId?:@"",@"RouterId":[RouterConfig getRouterConfig].currentRouterToxid?:@"",@"GId":gid,@"MsgType":msgType,@"MsgNum":msgNum,@"MsgStartId":msgStartId,@"SrcMsgId":srcMsgId};
    [SocketMessageUtil sendVersion5WithParams:params];
}
#pragma mark ---群组发送文件成功
+ (void) sendGroupFilePretreatmentWithGID:(NSString *) gid fileName:(NSString *) fileName fileSize:(NSNumber *) fileSize fileType:(NSNumber *) fileType fileMD5:(NSString *) fileMd5 fileInfo:(NSString *) fileInfo fileId:(NSString *) fileId
{
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_GroupSendFileDone,@"UserId":userM.userId?:@"",@"FileMD5":fileMd5?:@"",@"GId":gid,@"FileName":fileName,@"FileSize":fileSize,@"FileType":fileType,@"FileInfo":fileInfo,@"FileId":fileId};
    [SocketMessageUtil sendVersion5WithParams:params];
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
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_GroupConfig,@"UserId":userM.userId?:@"",@"GId":GId,@"Type":Type,@"ToId":ToId?:@"",@"Name":Name?:@"",@"NeedVerify":NeedVerify?:@(-1)};
    [SocketMessageUtil sendVersion4WithParams:params];
}

#pragma mark - 68.    用户退群
+ (void)sendGroupQuitWithGId:(NSString *)GId GroupName:(nullable NSString *)GroupName showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":Action_GroupQuit,@"UserId":userM.userId?:@"",@"GId":GId,@"GroupName":GroupName?:@""};
    [SocketMessageUtil sendVersion4WithParams:params];
}

#pragma mark - 66.    邀请用户入群审核处理
+ (void)sendGroupVerifyWithFrom:(NSString *)From To:(NSString *)To Aduit:(NSString *)Aduit GId:(NSString *)GId GName:(nullable NSString *)GName Result:(NSNumber *)Result UserKey:(nullable NSString *)UserKey showHud:(BOOL)showHud {
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_GroupVerify,@"From":From,@"To":To,@"Aduit":Aduit,@"GId":GId,@"GName":GName?:@"",@"Result":Result,@"UserKey":UserKey};
    [SocketMessageUtil sendVersion4WithParams:params];
}

+ (void) sendDelUserWithFromTid:(NSString *) fromTid toTid:(NSString *) toTid sn:(NSString *) sn showHud:(BOOL) showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Remove..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_DelUser,@"From":fromTid,@"To":toTid?:@"",@"Sn":sn?:@""};
    [SocketMessageUtil sendVersion4WithParams:params];
}
+ (void) sendRebootWithToxid:(NSString *) toxID showHud:(BOOL)showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Reboot..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_Reboot,@"User":toxID?:@""};
    [SocketMessageUtil sendVersion3WithParams:params];
}


+ (void) sendQLCNodeWithEnable:(NSNumber *) enable seed:(NSString *) seed showHud:(BOOL) showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_EnableQlcNode,@"Enable":enable,@"Seed":@""};
    [SocketMessageUtil sendVersion6WithParams:params];
}
+ (void) sendCheckNodeWithShowHud:(BOOL) showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_CheckQlcNode};
    [SocketMessageUtil sendVersion6WithParams:params];
}

//------------------------email ----------------------
+ (void) sendEmailFileWithFileid:(NSString *) fileid fileSize:(NSNumber *) fileSize fileMd5:(NSString *) fileMd5 mailInfo:(NSString *) mailInfo srcKey:(NSString *) srcKey uid:(NSString *) uid ShowHud:(BOOL) showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Uploading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    NSDictionary *params = @{@"Action":Action_BakupEmail,@"Type":@(accountM.Type),@"FileId":fileid,@"FileSize":fileSize,@"FileMd5":fileMd5,@"User":[accountM.User base64EncodedString],@"UserKey":srcKey?:@"",@"MailInfo":mailInfo?:@"",@"Uuid":uid};
    [SocketMessageUtil sendVersion6WithParams:params];
}

+ (void) sendEmailConfigWithEmailAddress:(NSString *) address type:(NSNumber *) type caller:(NSNumber *) caller configJson:(NSString *) configJosn ShowHud:(BOOL) showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    address = [address lowercaseString];
    NSDictionary *params = @{@"Action":Action_SaveEmailConf,@"Type":type,@"Version":@(1),@"User":[address base64EncodedString],@"UserKey":[EntryModel getShareObject].signPublicKey?:@"",@"Config":configJosn?:@"",@"Caller":caller};
    [SocketMessageUtil sendVersion6WithParams:params];
}
+ (void) sendEmailUserkeyWithUsers:(NSString *) users unum:(NSNumber *) num ShowHud:(BOOL) showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_GetUmailKey,@"Unum":num,@"Users":users,@"Type":@(1)};
    [SocketMessageUtil sendVersion6WithParams:params];
}
+ (void) sendEmailCheckNodeCountShowHud:(BOOL) showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
     EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    NSDictionary *params = @{@"Action":Action_BakMailsNum,@"User":[accountM.User base64EncodedString]};
    [SocketMessageUtil sendVersion6WithParams:params];
}

+ (void) sendPullEmailWithStarid:(NSNumber *) starId num:(NSNumber *) num showHud:(BOOL) showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    NSDictionary *params = @{@"Action":Action_PullMailList,@"User":[accountM.User base64EncodedString],@"Type":@(accountM.Type),@"StartId":starId,@"Num":num};
    [SocketMessageUtil sendVersion6WithParams:params];
}
+ (void) sendEmailDelNodeWithUid:(NSString *) uid showHud:(BOOL) showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Deleting_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    NSDictionary *params = @{@"Action":Action_DelEmail,@"Type":@(accountM.Type),@"MailId":uid};
    [SocketMessageUtil sendVersion6WithParams:params];
}
+ (void) sendEmailDelConfigWithShowHud:(BOOL) showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Deleting_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    NSDictionary *params = @{@"Action":Action_DelEmailConf,@"Type":@(accountM.Type),@"User":[[accountM.User lowercaseString] base64EncodedString]};
    [SocketMessageUtil sendVersion6WithParams:params];
}

+ (void) sendEmailCheckNodeWithUid:(NSString *) uid showHud:(BOOL) showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Deleting_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    NSDictionary *params = @{@"Action":Action_BakMailsCheck,@"User":[[accountM.User lowercaseString] base64EncodedString],@"Uuid":uid};
    [SocketMessageUtil sendVersion6WithParams:params];
}

+ (void) sendEmailSendNotiWithEmails:(NSString *)emails showHud:(BOOL)showHud
{
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:Loading_Str userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    NSDictionary *params = @{@"Action":Action_MailSendNotice,@"MailsTo":emails};
    [SocketMessageUtil sendVersion6WithParams:params];
    
}
@end

