//
//  EmailAccountModel.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/11.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EmailAccountModel.h"
#import "KeyCUtil.h"

static NSString *emailKey = @"emailKey_arr";

@implementation EmailAccountModel

+ (NSArray *) getLocalAllEmailAccounts
{
    NSString *userid = emailKey; //[UserModel getUserModel].userId;
    NSArray *emailAccountArr = [KeyCUtil getRouterWithKey:userid]?:@[];
    NSMutableArray *resultArr = [NSMutableArray array];
    [emailAccountArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EmailAccountModel *model = [EmailAccountModel getObjectWithKeyValues:obj];
        [resultArr addObject:model];
    }];
    return resultArr;
}
+ (void) addEmailAccountWith:(EmailAccountModel *) accountModel
{
    if ([EmailAccountModel getLocalAllEmailAccounts].count == 0) {
        accountModel.isConnect = YES;
    }
    if (![EmailAccountModel isEixtEmailAccount:accountModel]) {
        NSString *userid = emailKey;//[UserModel getUserModel].userId;
        [KeyCUtil saveRouterTokeychainWithValue:accountModel.mj_keyValues key:userid];
    } else {
        if (accountModel.Type == 4) { // google
            
            NSMutableArray *resultArr = [NSMutableArray array];
            NSString *userid = emailKey;
            NSArray *emailAccounts = [KeyCUtil getRouterWithKey:userid]?:@[];
            
            [emailAccounts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                EmailAccountModel *model = [EmailAccountModel getObjectWithKeyValues:obj];
                if ([model.User isEqualToString:accountModel.User]) {
                    model.UserPass = accountModel.UserPass;
                    model.smtpUserPass = accountModel.smtpUserName;
                    model.port = accountModel.port;
                    model.smtpPort = accountModel.smtpPort;
                    model.connectionType = accountModel.connectionType;
                    model.smtpConnectionType = accountModel.smtpConnectionType;
                    model.userName = accountModel.userName;
                    model.smtpUserName = accountModel.smtpUserName;
                    model.hostname = accountModel.hostname;
                    model.smtpHostname = accountModel.smtpHostname;
                    model.userId = accountModel.userId;
                    model.userToken = accountModel.userToken;
                }
                [resultArr addObject:model.mj_keyValues];
            }];
            
            [KeyCUtil saveRouterTokeychainWithArr:resultArr key:userid];
            
        }
        
    }
}
+ (BOOL) isEixtEmailAccount:(EmailAccountModel *) accountModel
{
    NSArray *emailAccounts = [EmailAccountModel getLocalAllEmailAccounts];
    __block BOOL isEixt = NO;
    [emailAccounts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         EmailAccountModel *model = [EmailAccountModel getObjectWithKeyValues:obj];
        if ([model.User isEqualToString:accountModel.User]) {
            isEixt = YES;
            *stop = YES;
        }
    }];
    return isEixt;
}
+ (void) updateEmailAccountPass:(EmailAccountModel *) accountModel
{
    NSString *userid = emailKey;//[UserModel getUserModel].userId;
    NSArray *emailAccounts = [KeyCUtil getRouterWithKey:userid]?:@[];
    NSMutableArray *resultArr = [NSMutableArray array];
    [emailAccounts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EmailAccountModel *model = [EmailAccountModel getObjectWithKeyValues:obj];
        if ([model.User isEqualToString:accountModel.User]) {
            model.UserPass = accountModel.UserPass;
            model.smtpUserPass = accountModel.smtpUserName;
            model.port = accountModel.port;
            model.smtpPort = accountModel.smtpPort;
            model.connectionType = accountModel.connectionType;
            model.smtpConnectionType = accountModel.smtpConnectionType;
            model.userName = accountModel.userName;
            model.smtpUserName = accountModel.smtpUserName;
            model.hostname = accountModel.hostname;
            model.smtpHostname = accountModel.smtpHostname;
        }
        [resultArr addObject:model.mj_keyValues];
    }];
    
    [KeyCUtil saveRouterTokeychainWithArr:resultArr key:userid];
}
+ (void) updateFirstEmailConnect
{
    NSString *userid = emailKey;//[UserModel getUserModel].userId;
    NSArray *emailAccounts = [KeyCUtil getRouterWithKey:userid]?:@[];
    if (emailAccounts.count == 0) {
        return;
    }
    NSMutableArray *resultArr = [NSMutableArray array];
    [emailAccounts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EmailAccountModel *model = [EmailAccountModel getObjectWithKeyValues:obj];
        if (idx == 0) {
            model.isConnect = YES;
        } else {
            model.isConnect = NO;
        }
        [resultArr addObject:model.mj_keyValues];
    }];
    [KeyCUtil saveRouterTokeychainWithArr:resultArr key:userid];
}
+ (void) updateEmailAccountUnReadCount:(EmailAccountModel *) accountModel
{
    NSString *userid = emailKey;//[UserModel getUserModel].userId;
    NSArray *emailAccounts = [KeyCUtil getRouterWithKey:userid]?:@[];
    NSMutableArray *resultArr = [NSMutableArray array];
    [emailAccounts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EmailAccountModel *model = [EmailAccountModel getObjectWithKeyValues:obj];
        if ([model.User isEqualToString:accountModel.User]) {
            model.unReadCount = accountModel.unReadCount;
        }
        [resultArr addObject:model.mj_keyValues];
    }];
    
    [KeyCUtil saveRouterTokeychainWithArr:resultArr key:userid];
}
+ (void) updateEmailAccountConnectStatus:(EmailAccountModel *) accountModel
{
    NSString *userid = emailKey;//[UserModel getUserModel].userId;
    NSArray *emailAccounts = [KeyCUtil getRouterWithKey:userid]?:@[];
    NSMutableArray *resultArr = [NSMutableArray array];
    [emailAccounts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EmailAccountModel *model = [EmailAccountModel getObjectWithKeyValues:obj];
        if ([model.User isEqualToString:accountModel.User]) {
            model.isConnect = YES;
        } else {
            model.isConnect = NO;
        }
        [resultArr addObject:model.mj_keyValues];
    }];
    [KeyCUtil saveRouterTokeychainWithArr:resultArr key:userid];
}

+ (EmailAccountModel *) getConnectEmailAccount
{
   __block EmailAccountModel *accountModel = nil;
    NSString *userid = emailKey;//[UserModel getUserModel].userId;
    NSArray *emailAccounts = [KeyCUtil getRouterWithKey:userid]?:@[];
    [emailAccounts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EmailAccountModel *model = [EmailAccountModel getObjectWithKeyValues:obj];
        if (model.isConnect) {
            accountModel = model;
            *stop = YES;
        }
    }];
    return accountModel;
}

+ (void)deleteEmailWithUser:(NSString *) user {
    NSArray *emailAccounts = [KeyCUtil getRouterWithKey:emailKey]?:@[];
    NSMutableArray *dicArr = [NSMutableArray array];
    [emailAccounts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EmailAccountModel *model = [EmailAccountModel getObjectWithKeyValues:obj];
        if (![model.User isEqualToString:user]) {
            [dicArr addObject:model.mj_keyValues];
        }
    }];
    [KeyCUtil saveRouterTokeychainWithArr:dicArr key:emailKey];
}

+ (void)deleteEmail
{
    NSArray *emailAccounts = [KeyCUtil getRouterWithKey:emailKey]?:@[];
    NSMutableArray *dicArr = [NSMutableArray array];
    [emailAccounts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EmailAccountModel *model = [EmailAccountModel getObjectWithKeyValues:obj];
        if (model.UserPass && model.UserPass.length >0) {
            [dicArr addObject:model.mj_keyValues];
        }
    }];
    [KeyCUtil saveRouterTokeychainWithArr:dicArr key:emailKey];
}
@end
