//
//  RouterUserModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/23.
//  Copyright © 2018 旷自辉. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface RouterUserModel : BBaseModel

@property (nonatomic , strong) NSString *UserSN;
@property (nonatomic , assign) NSInteger UserType; // 用户类型：0：所有账户类型1.管理派生账户；2.普通账户；3.临时账户；
@property (nonatomic , assign) NSInteger Active;
@property (nonatomic , strong) NSString *NickName;
@property (nonatomic , strong) NSString *IdentifyCode;
@property (nonatomic , strong) NSString *Mnemonic;
@property (nonatomic , strong) NSString *UserId;
@property (nonatomic , strong) NSString *Qrcode;
@property (nonatomic , assign) NSInteger LastLoginTime;
@property (nonatomic , assign) NSInteger CreateTime;
@property (nonatomic , strong) NSString *UserKey;

@property (nonatomic , strong) NSString *aliaName;
@end

NS_ASSUME_NONNULL_END
