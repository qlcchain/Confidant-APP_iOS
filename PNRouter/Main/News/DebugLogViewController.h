//
//  DebugLogViewController.h
//  Qlink
//
//  Created by Jelly Foo on 2018/4/16.
//  Copyright © 2018年 pan. All rights reserved.
//

#import "PNBaseViewController.h"

typedef enum : NSUInteger {
    DebugLogTypeSystem,
    DebugLogTypeTest1000,
} DebugLogType;

@interface DebugLogViewController : PNBaseViewController

@property (nonatomic) DebugLogType inputType;

@end
