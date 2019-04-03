//
//  ChatImgCacheUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/4/2.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "ChatImgCacheUtil.h"

@implementation ChatImgCacheUtil
+ (instancetype) getChatImgCacheUtilShare
{
    static ChatImgCacheUtil *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
        shareObject.imgCacheDic = [NSMutableDictionary dictionary];
    });
    return shareObject;
}
@end
