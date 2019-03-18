//
//  InvitationQRCodeViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/13.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"
@class RouterModel;
@class RouterUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface InvitationQRCodeViewController : PNBaseViewController

@property (nonatomic,assign) NSInteger userManageType;

@property (nonatomic, strong) RouterModel *routerM;
@property (nonatomic , strong) RouterUserModel *routerUserModel;
@end

NS_ASSUME_NONNULL_END
