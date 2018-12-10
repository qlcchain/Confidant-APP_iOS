//
//  MutManagerUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/30.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "MutManagerUtil.h"

@implementation MutManagerUtil
+ (instancetype) getShareObject
{
    static MutManagerUtil *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
        shareObject.mutTempDic = [[NSMutableDictionary alloc] init];
    });
    return shareObject;
}
@end
