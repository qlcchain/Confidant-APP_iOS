//
//  UserConfig.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/12/25.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "UserConfig.h"

@implementation UserConfig
+ (instancetype) getShareObject
{
    static UserConfig *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
    });
    return shareObject;
}
@end
