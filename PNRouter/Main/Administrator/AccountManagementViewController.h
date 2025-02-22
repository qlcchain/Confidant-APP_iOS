//
//  AccountManagementViewController.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AccountManagementViewController : PNBaseViewController

@property (nonatomic, strong) NSString *RouterId;
@property (nonatomic, strong) NSString *Qrcode;
@property (nonatomic, strong) NSString *IdentifyCode;
@property (nonatomic, strong) NSString *UserSn;
@property (nonatomic, strong) NSString *RouterPW;
@property (nonatomic, strong) NSString *routerAlias;

@end

NS_ASSUME_NONNULL_END
