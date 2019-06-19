//
//  LoginViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/14.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

typedef enum : NSUInteger {
    RouterType,
    MacType,
    ImportType
} LoginType;
NS_ASSUME_NONNULL_BEGIN

@interface LoginViewController : PNBaseViewController

@property (nonatomic ,assign) LoginType loginType; // 登陆类型

- (instancetype) initWithLoginType:(LoginType) type;

@end

NS_ASSUME_NONNULL_END
