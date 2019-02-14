//
//  DiskDetailViewController.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/28.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class GetDiskTotalInfo;

@interface DiskDetailViewController : PNBaseViewController

@property (nonatomic, strong) GetDiskTotalInfo *getDiskTotalInfo;

@end

NS_ASSUME_NONNULL_END
