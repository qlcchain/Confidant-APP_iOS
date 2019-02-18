//
//  UnitUtil.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/2/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "UnitUtil.h"

@implementation UnitUtil

+ (CGFloat)getDigitalOfM:(NSString *)capacity {
    NSString *useLast = [capacity substringFromIndex:capacity.length - 1];
    CGFloat capacityDigital = [[capacity substringToIndex:capacity.length - 1] floatValue];
    CGFloat digital = [useLast isEqualToString:@"K"]?capacityDigital/1024:[useLast isEqualToString:@"M"]?capacityDigital:[useLast isEqualToString:@"G"]?capacityDigital*1024:[useLast isEqualToString:@"T"]?capacityDigital*1024*1024:capacityDigital;
    
    return digital;
}

@end
