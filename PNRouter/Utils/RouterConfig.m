//
//  RoutherConfig.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/14.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "RouterConfig.h"

@implementation RouterConfig
+ (instancetype) getRouterConfig
{
    static RouterConfig *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
        shareObject.routherArray = [[NSMutableArray alloc] init];
    });
    return shareObject;
}
#pragma mark -添加并去重
- (void) addRoutherWithArray:(NSArray *)arr
{
    __block BOOL isexit = NO;
    [[RouterConfig getRouterConfig].routherArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *array = obj;
        if ([arr[1] isEqualToString:array[1]]) {
            isexit = YES;
            *stop = YES;
        }
    }];
    if (!isexit) {
       [[RouterConfig getRouterConfig].routherArray addObject:arr];
    }
}

- (NSArray *) getCurrentRoutherWithToxid:(NSString *) toxid
{
    __block NSInteger index = 0;
    __block BOOL isexit = NO;
    [[RouterConfig getRouterConfig].routherArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray *array = obj;
        if ([toxid isEqualToString:array[1]]) {
            isexit = YES;
            index = idx;
            *stop = YES;
        }
    }];
    if (isexit) {
        return [RouterConfig getRouterConfig].routherArray[index];
    }
    return nil;
}
@end
