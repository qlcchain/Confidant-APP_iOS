//
//  QNTabbarViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCTManager.h"

@interface PNTabbarViewController : UITabBarController
- (instancetype)initWithManager:(id<OCTManager>) manager;
@end
