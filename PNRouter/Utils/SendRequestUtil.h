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

@end

NS_ASSUME_NONNULL_END
