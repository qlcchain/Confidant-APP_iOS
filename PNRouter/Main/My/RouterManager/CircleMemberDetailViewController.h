//
//  CircleMemberDetailViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/4/17.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"
@class RouterUserModel;

NS_ASSUME_NONNULL_BEGIN

@interface CircleMemberDetailViewController : PNBaseViewController
@property (nonatomic , strong) RouterUserModel *routerUserModel;
@end

NS_ASSUME_NONNULL_END
