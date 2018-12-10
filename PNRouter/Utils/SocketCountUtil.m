//
//  SocketCountUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/15.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "SocketCountUtil.h"

@implementation SocketCountUtil

+ (instancetype) getShareObject
{
    // 重连的菊花hidden
    [AppD.window hideHud];
    static id shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
    });
    return shareObject;
}

@end
