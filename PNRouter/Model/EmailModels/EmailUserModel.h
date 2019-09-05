//
//  EmailUserModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//



typedef enum : NSUInteger {
    UserNo,
    UserFrom,
    UserTo,
    UserCc,
    UserBcc
} UserType;

NS_ASSUME_NONNULL_BEGIN

@interface EmailUserModel : BBaseModel
@property (nonatomic, assign) UserType userType;
@property (nonatomic ,strong) NSString *userName;
@property (nonatomic ,strong) NSString *userAddress;

@end

NS_ASSUME_NONNULL_END
