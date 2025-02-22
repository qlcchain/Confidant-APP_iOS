//
//  EmailAccountModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/11.
//  Copyright © 2019 旷自辉. All rights reserved.
//



NS_ASSUME_NONNULL_BEGIN

@interface EmailAccountModel : BBaseModel

@property (nonatomic , strong) NSString *userName;
@property (nonatomic , strong) NSString *User;
@property (nonatomic , strong) NSString *hostname;
@property (nonatomic , assign) int port;
@property (nonatomic ,assign) int connectionType;
@property (nonatomic ,assign) int unReadCount;
@property (nonatomic , strong) NSString *UserPass;
@property (nonatomic , assign) int Type;
@property (nonatomic , assign) BOOL isConnect;


@property (nonatomic , assign) int smtpPort;
@property (nonatomic , strong) NSString *smtpHostname;
@property (nonatomic ,assign) int smtpConnectionType;
@property (nonatomic , strong) NSString *smtpUserName;
@property (nonatomic , strong) NSString *smtpUserPass;

@property (nonatomic , strong) NSString *userId;
@property (nonatomic , strong) NSString *userToken;

+ (NSArray *) getLocalAllEmailAccounts;
+ (EmailAccountModel *) getConnectEmailAccount;
+ (void) addEmailAccountWith:(EmailAccountModel *) accountModel;
+ (BOOL) isEixtEmailAccount:(EmailAccountModel *) accountModel;
+ (void) updateEmailAccountPass:(EmailAccountModel *) accountModel;
+ (void) updateEmailAccountConnectStatus:(EmailAccountModel *) accountModel;
+ (void) updateEmailAccountUnReadCount:(EmailAccountModel *) accountModel;
+ (void)deleteEmailWithUser:(NSString *) user;
+ (void)deleteEmail;
+ (void) updateFirstEmailConnect;
@end

NS_ASSUME_NONNULL_END
