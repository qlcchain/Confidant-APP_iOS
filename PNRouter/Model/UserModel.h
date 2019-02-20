//
//  UserModel.h
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

@interface UserModel : BBaseModel

@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *userId;
//@property (nonatomic, copy) NSString *hashId;
@property (nonatomic, copy) NSString *userSn;
@property (nonatomic, assign) NSInteger dataFileVersion;
@property (nonatomic, copy) NSString *dataFilePay;
@property (nonatomic, copy) NSString *pass;

@property (nonatomic, strong) NSString *headBaseStr;
@property (nonatomic, copy) NSString *position;
@property (nonatomic, copy) NSString *commpany;
@property (nonatomic, copy) NSString *location;

+ (void)updateUserLocalWithPass:(NSString *) pass;
+ (UserModel *)getUserModel;
+ (void)createUserLocalWithName:(NSString *)name;
+ (void)createUserLocalWithName:(NSString *)name userid:(NSString *) userid version:(NSInteger) version filePay:(NSString *) filePay userpass:(NSString *) pass userSn:(NSString *) userSn hashid:(NSString *) hashid;
+ (void)updateUserLocalWithUserId:(NSString *)userId withUserName:(NSString *) userName userSn:(NSString *) userSn hashid:(NSString *) hashid;
- (void)saveUserModeToKeyChain;
+ (void)isLogin;
+ (instancetype) getShareObject;
+ (BOOL)existLocalNick;

@end
