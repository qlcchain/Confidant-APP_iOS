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
+ (void) sendUserLoginWithPass:(NSString *) passWord userid:(NSString *) userid showHud:(BOOL) showHud;
+ (void) sendPullUserList;
+ (void) sendAddFriendWithFriendId:(NSString *) friendId msg:(NSString *) msg;
+ (void) sendToxPullFileWithFromId:(NSString *) fromId toid:(NSString *) toid filePath:(NSString *) filePath msgid:(NSString *) msgId;
+ (void) createRouterUserWithRouterId:(NSString *) routerId mnemonic:(NSString *) mnemonic code:(NSString *) code;
+ (void) sendRedMsgWithFriendId:(NSString *) friendId msgid:(NSString *) msgId;
+ (void) sendUpdateWithNickName:(NSString *) nickName;
+ (void) sendLogOut;
+ (void) sendToxSendFileWithParames:(NSDictionary *) parames;
+ (void) sendToxPullFileWithFromId:(NSString *) fromId toid:(NSString *) toId fileName:(NSString *) fileName msgId:(NSString *) msgId fileOwer:(NSString *) fileOwer;
+ (void) sendRegidReqeust;
#pragma mark -添加好友备注
+ (void) sendAddFriendNickName:(NSString *) nickName friendId:(NSString *) friendId;
+ (void) sendQueryFriendWithFriendId:(NSString *) friendId;

+ (void)sendRouterLoginWithMac:(NSString *)mac loginKey:(NSString *)loginKey showHud:(BOOL)showHud;
+ (void)sendResetRouterKeyWithRouterId:(NSString *)RouterId OldKey:(NSString *)OldKey NewKey:(NSString *)NewKey showHud:(BOOL)showHud;
+ (void)sendResetUserIdcodeWithRouterId:(NSString *)RouterId UserSn:(NSString *)UserSn OldCode:(NSString *)OldCode NewCode:(NSString *)NewCode showHud:(BOOL)showHud;

+ (void)sendPullFileListWithUserId:(NSString *)UserId MsgStartId:(NSNumber *)MsgStartId MsgNum:(NSNumber *)MsgNum Category:(NSNumber *)Category FileType:(NSNumber *)FileType showHud:(BOOL)showHud;
+ (void)sendUploadFileReqWithUserId:(NSString *)UserId FileName:(NSString *)FileName FileSize:(NSNumber *)FileSize FileType:(NSNumber *)FileType showHud:(BOOL)showHud;
+ (void)sendUploadFileWithUserId:(NSString *)UserId FileName:(NSString *)FileName FileMD5:(NSString *)FileMD5 FileSize:(NSNumber *)FileSize FileType:(NSNumber *)FileType UserKey:(NSString *)UserKey showHud:(BOOL)showHud;
+ (void)sendDelFileWithUserId:(NSString *)UserId FileName:(NSString *)FileName showHud:(BOOL)showHud;
+ (void)sendPullSharedFriendWithUserId:(NSString *)UserId showHud:(BOOL)showHud;
+ (void)sendShareFileWithFromId:(NSString *)FromId ToId:(NSString *)ToId FileName:(NSString *)FileName DstKey:(NSString *)DstKey showHud:(BOOL)showHud;

@end

NS_ASSUME_NONNULL_END
