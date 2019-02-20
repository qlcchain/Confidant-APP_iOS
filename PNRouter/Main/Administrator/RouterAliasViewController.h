//
//  RouterAliasViewController.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/2/20.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface RouterAliasViewController : PNBaseViewController

@property (nonatomic, strong) NSString *RouterId;
@property (nonatomic, strong) NSString *Qrcode;
@property (nonatomic, strong) NSString *IdentifyCode;
@property (nonatomic, strong) NSString *UserSn;
@property (nonatomic, strong) NSString *RouterPW;

@end

NS_ASSUME_NONNULL_END
