//
//  EmailAccountModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/11.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EmailAccountModel : BBaseModel

@property (nonatomic , strong) NSString *User;
@property (nonatomic , strong) NSString *hostname;
@property (nonatomic , assign) int port;
@property (nonatomic ,assign) int connectionType;
@property (nonatomic , strong) NSString *UserPass;
@property (nonatomic , assign) int Type;
@property (nonatomic , assign) BOOL isConnect;

+ (NSArray *) getLocalAllEmailAccounts;
+ (EmailAccountModel *) getConnectEmailAccount;
+ (void) addEmailAccountWith:(EmailAccountModel *) accountModel;
+ (BOOL) isEixtEmailAccount:(EmailAccountModel *) accountModel;
+ (void) updateEmailAccountPass:(EmailAccountModel *) accountModel;
+ (void) updateEmailAccountConnectStatus:(EmailAccountModel *) accountModel;
@end

NS_ASSUME_NONNULL_END
