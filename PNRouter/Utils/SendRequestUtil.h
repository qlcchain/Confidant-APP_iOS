//
//  SendRequestUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/13.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SendRequestUtil : NSObject

+ (void) sendUserFindWithToxid:(NSString *) toxid usesn:(NSString *) sn;
+ (void) sendUserRegisterWithUserPass:(NSString *) pass username:(NSString *) userName code:(NSString *) code;
+ (void) sendUserLoginWithPass:(NSString *) usersn userid:(NSString *) userid showHud:(BOOL) showHud;
+ (void) sendPullUserList;
+ (void) sendAddFriendWithFriendId:(NSString *) friendId msg:(NSString *) msg;
+ (void) sendToxPullFileWithFromId:(NSString *) fromId toid:(NSString *) toid filePath:(NSString *) filePath msgid:(NSString *) msgId;
+ (void) createRouterUserWithRouterId:(NSString *) routerId mnemonic:(NSString *) mnemonic code:(NSString *) code;
+ (void) sendRedMsgWithFriendId:(NSString *) friendId msgid:(NSString *) msgId;
+ (void) sendUpdateWithNickName:(NSString *) nickName;
+ (void) sendLogOut;
+ (void) sendToxSendFileWithParames:(NSDictionary *) parames;
+ (void) sendToxPullFileWithFromId:(NSString *) fromId toid:(NSString *) toId fileName:(NSString *) fileName msgId:(NSString *) msgId fileOwer:(NSString *) fileOwer fileFrom:(NSString *) fileFrom;
+ (void) sendRegidReqeust;
#pragma mark -添加好友备注
+ (void) sendAddFriendNickName:(NSString *) nickName friendId:(NSString *) friendId;
+ (void) sendQueryFriendWithFriendId:(NSString *) friendId;

+ (void)sendRouterLoginWithMac:(NSString *)mac loginKey:(NSString *)loginKey showHud:(BOOL)showHud;
+ (void)sendResetRouterKeyWithRouterId:(NSString *)RouterId OldKey:(NSString *)OldKey NewKey:(NSString *)NewKey showHud:(BOOL)showHud;
+ (void)sendResetUserIdcodeWithRouterId:(NSString *)RouterId UserSn:(NSString *)UserSn OldCode:(NSString *)OldCode NewCode:(NSString *)NewCode showHud:(BOOL)showHud;

+ (void)sendPullFileListWithUserId:(NSString *)UserId MsgStartId:(NSNumber *)MsgStartId MsgNum:(NSNumber *)MsgNum Category:(NSNumber *)Category FileType:(NSNumber *)FileType showHud:(BOOL)showHud;
+ (void)sendUploadFileReqWithUserId:(NSString *)UserId FileName:(NSString *)FileName FileSize:(NSNumber *)FileSize FileType:(NSNumber *)FileType showHud:(BOOL)showHud fetchParam:(void(^)(NSDictionary *dic))paramB;
+ (void)sendUploadFileWithUserId:(NSString *)UserId FileName:(NSString *)FileName FileMD5:(NSString *)FileMD5 FileSize:(NSNumber *)FileSize FileType:(NSNumber *)FileType UserKey:(NSString *)UserKey showHud:(BOOL)showHud;
+ (void)sendDelFileWithUserId:(NSString *)UserId FileName:(NSString *)FileName showHud:(BOOL)showHud;
+ (void)sendPullSharedFriendWithUserId:(NSString *)UserId showHud:(BOOL)showHud;
+ (void)sendShareFileWithFromId:(NSString *)FromId ToId:(NSString *)ToId FileName:(NSString *)FileName DstKey:(NSString *)DstKey showHud:(BOOL)showHud;

+ (void)sendGetDiskTotalInfoWithShowHud:(BOOL)showHud;
+ (void)sendGetDiskDetailInfoWithSlot:(NSNumber *)Slot showHud:(BOOL)showHud;
+ (void)sendFormatDiskWithMode:(NSString *)Mode showHud:(BOOL)showHud;
+ (void)sendRebootWithShowHud:(BOOL)showHud;
+ (void)sendFileRenameWithMsgId:(NSNumber *)MsgId Filename:(NSString *)Filename Rename:(NSString *)Rename showHud:(BOOL)showHud;
// 文件转发
+ (void) sendFileForwardMsgid:(NSString *) msgid toid:(NSString *) toid fileName:(NSString *) fileName filekey:(NSString *) filekey fileInfo:(NSString *) fileInfo;

+ (void)sendUploadAvatarWithFileName:(NSString *)FileName FileMd5:(NSString *)FileMd5 showHud:(BOOL)showHud;
+ (void)sendUpdateAvatarWithFid:(NSString *)Fid Md5:(NSString *)Md5 showHud:(BOOL)showHud;

+ (void) sendCreateGroupWithName:(NSString *) groupName userKey:(NSString *) userKey verifyMode:(NSString *) verifyMode friendId:(NSString *) friendId friendKey:(NSString *) friendKey showHud:(BOOL)showHud;
+ (void) sendPullGroupListWithShowHud:(BOOL)showHud;

+ (void)sendGroupUserPullWithGId:(NSString *)GId TargetNum:(NSNumber *)TargetNum StartId:(NSString *)StartId showHud:(BOOL)showHud;
+ (void) sendAddGroupWithGId:(NSString *) gid friendId:(NSString *) friendids friendKey:(NSString *) friendkeys showHud:(BOOL)showHud;
+ (void) sendGroupMessageWithGid:(NSString *) gid point:(NSString *) point msg:(NSString *) msg msgid:(NSString *) msgid;
+ (void) sendPullGroupMessageListWithGId:(NSString *) gid MsgType:(NSString *) msgType msgStartId:(NSString *) msgStartId msgNum:(NSString *) msgNum;
+ (void) sendGroupFilePretreatmentWithGID:(NSString *) gid fileName:(NSString *) fileName fileSize:(NSNumber *) fileSize fileType:(NSNumber *) fileType;

+ (void)sendGroupConfigWithGId:(NSString *)GId Type:(NSString *)Type ToId:(nullable NSString *)ToId Name:(nullable NSString *)Name NeedVerify:(nullable NSNumber *)NeedVerify showHud:(BOOL)showHud;

@end

NS_ASSUME_NONNULL_END
