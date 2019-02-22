//
//  RouterAliasViewController.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/2/20.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^RouterAliasFinishBlock)(NSString *alias);

@interface RouterAliasViewController : PNBaseViewController

@property (nonatomic, strong) NSString *RouterId;
@property (nonatomic, strong) NSString *Qrcode;
@property (nonatomic, strong) NSString *IdentifyCode;
@property (nonatomic, strong) NSString *UserSn;
@property (nonatomic, strong) NSString *RouterPW;
@property (nonatomic, strong) NSString *inputRouterAlias;
@property (nonatomic) BOOL finishBack;
@property (nonatomic, copy) RouterAliasFinishBlock finishB;

@end

NS_ASSUME_NONNULL_END
