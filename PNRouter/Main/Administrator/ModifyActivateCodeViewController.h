//
//  LoginDeviceViewController.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ModifyActivateCodeViewController : PNBaseViewController

@property (nonatomic, strong) NSString *RouterId;
@property (nonatomic, strong) NSString *IdentifyCode;
@property (nonatomic, strong) NSString *UserSn;

@end

NS_ASSUME_NONNULL_END
