//
//  RouterModel.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "RouterModel.h"
#import "KeyCUtil.h"

@implementation RouterModel

+ (BOOL)routerIsExitsWithToxid:(NSString *)toxid {
    if (!toxid) {
        return NO;
    }
    // 更新本地路由器
    NSArray *routerArr = [KeyCUtil getRouterWithKey:ROUTER_ARR]?:@[];
    __block BOOL isExist = NO;
    [routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RouterModel *model = [RouterModel getObjectWithKeyValues:obj];
        if ([model.toxid isEqualToString:toxid]) {
            isExist = YES;
            *stop = YES;
        }
    }];
    return isExist;
}

+ (BOOL)routerIsExitsWithSn:(NSString *)sn {
    if (!sn) {
        return NO;
    }
    // 更新本地路由器
    NSArray *routerArr = [KeyCUtil getRouterWithKey:ROUTER_ARR]?:@[];
    __block BOOL isExist = NO;
    [routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RouterModel *model = [RouterModel getObjectWithKeyValues:obj];
        if ([model.userSn isEqualToString:sn]) {
            isExist = YES;
            *stop = YES;
        }
    }];
    return isExist;
}

+ (RouterModel *) checkRoutherWithSn:(NSString *) sn {
    if (!sn) {
        return nil;
    }
    // 更新本地路由器
    NSArray *routerArr = [KeyCUtil getRouterWithKey:ROUTER_ARR]?:@[];
    __block BOOL isExist = NO;
    __block NSInteger index = 0;
    [routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RouterModel *model = [RouterModel getObjectWithKeyValues:obj];
        if ([model.userSn isEqualToString:sn]) {
            isExist = YES;
            index = idx;
            *stop = YES;
        }
    }];
    if (isExist) {
        return [RouterModel getObjectWithKeyValues:[routerArr objectAtIndex:index]];
    }
    return nil;
}

+ (RouterModel *) checkRoutherWithToxid:(NSString *)toxid {
    if (!toxid) {
        return nil;
    }
    // 更新本地路由器
    NSArray *routerArr = [KeyCUtil getRouterWithKey:ROUTER_ARR]?:@[];
    __block BOOL isExist = NO;
    __block NSInteger index = 0;
    [routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RouterModel *model = [RouterModel getObjectWithKeyValues:obj];
        if ([model.toxid isEqualToString:toxid]) {
            isExist = YES;
            index = idx;
            *stop = YES;
        }
    }];
    if (isExist) {
        return [RouterModel getObjectWithKeyValues:[routerArr objectAtIndex:index]];
    }
    return nil;
}

+ (NSMutableArray *) checkRoutherArrayWithToxid:(NSString *)toxid {
    if (!toxid) {
        return nil;
    }
    // 更新本地路由器
    NSArray *routerArr = [KeyCUtil getRouterWithKey:ROUTER_ARR]?:@[];
   __block NSMutableArray *result = [NSMutableArray array];
    [routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RouterModel *model = [RouterModel getObjectWithKeyValues:obj];
        if ([model.toxid isEqualToString:toxid]) {
            [result addObject:model];
        }
    }];
    return result;
}


+ (void)addRouterWithToxid:(NSString *)toxid {
    if (!toxid) {
        return;
    }
    // 更新本地路由器
    NSArray *routerArr = [KeyCUtil getRouterWithKey:ROUTER_ARR]?:@[];
    RouterModel *routerM = [[RouterModel alloc] init];
    routerM.toxid = toxid;
    NSInteger nameCount = routerArr==nil?1:routerArr.count+1;
    routerM.name = [NSString stringWithFormat:@"Router %@",@(nameCount)];
    // 去重
    __block BOOL isExist = NO;
    [routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RouterModel *model = [RouterModel getObjectWithKeyValues:obj];
        if ([model.toxid isEqualToString:toxid]) {
            isExist = YES;
            *stop = YES;
        }
    }];
    if (!isExist) {
        DDLogDebug(@"新添加一个本地Router");
        [KeyCUtil saveRouterTokeychainWithValue:routerM.mj_keyValues key:ROUTER_ARR];
    }
}

+ (void)addRouterWithToxid:(NSString *)toxid usesn:(NSString *) usesn userid:(NSString *)uesrid
{
    if (!usesn) {
        return;
    }
    // 更新本地路由器
    NSArray *routerArr = [KeyCUtil getRouterWithKey:ROUTER_ARR]?:@[];
    RouterModel *routerM = [[RouterModel alloc] init];
    routerM.toxid = toxid;
    routerM.userSn = usesn;
    routerM.userid = uesrid;
    NSInteger nameCount = routerArr==nil?1:routerArr.count+1;
    routerM.name = [NSString stringWithFormat:@"Router %@",@(nameCount)];
    // 去重
    __block BOOL isExist = NO;
    [routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RouterModel *model = [RouterModel getObjectWithKeyValues:obj];
        if ([model.userSn isEqualToString:usesn]) {
            isExist = YES;
            *stop = YES;
        }
    }];
    if (!isExist) {
        DDLogDebug(@"新添加一个本地Router");
        [KeyCUtil saveRouterTokeychainWithValue:routerM.mj_keyValues key:ROUTER_ARR];
    }
}

+ (NSArray *)getLocalRouter {
    NSArray *routeArr = [KeyCUtil getRouterWithKey:ROUTER_ARR]?:@[];
    NSMutableArray *resultArr = [NSMutableArray array];
    [routeArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RouterModel *model = [RouterModel getObjectWithKeyValues:obj];
        [resultArr addObject:model];
    }];
    return resultArr;
}

+ (void)updateRouterName:(NSString *)name usersn:(NSString *)sn {
    NSArray *routerArr = [KeyCUtil getRouterWithKey:ROUTER_ARR]?:@[];
    NSMutableArray *resultArr = [NSMutableArray array];
    [routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RouterModel *model = [RouterModel getObjectWithKeyValues:obj];
        if ([model.userSn isEqualToString:sn]) {
            model.name = name;
        }
        [resultArr addObject:model.mj_keyValues];
    }];
    
    [KeyCUtil saveRouterTokeychainWithArr:resultArr key:ROUTER_ARR];
}
+ (void)updateRouterPassWithSn:(NSString *)sn pass:(NSString *) pass
{
    NSArray *routerArr = [KeyCUtil getRouterWithKey:ROUTER_ARR]?:@[];
    NSMutableArray *resultArr = [NSMutableArray array];
    [routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RouterModel *model = [RouterModel getObjectWithKeyValues:obj];
        if ([model.userSn isEqualToString:sn]) {
            model.userPass = pass;
        }
        [resultArr addObject:model.mj_keyValues];
    }];
    
    [KeyCUtil saveRouterTokeychainWithArr:resultArr key:ROUTER_ARR];
}
+ (void)updateRouterNumberWithSn:(NSString *)sn toxNumber:(int ) toxNumber
{
    NSArray *routerArr = [KeyCUtil getRouterWithKey:ROUTER_ARR]?:@[];
    NSMutableArray *resultArr = [NSMutableArray array];
    [resultArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RouterModel *model = [RouterModel getObjectWithKeyValues:obj];
        if ([model.userSn isEqualToString:sn]) {
            model.routerToxNumber = toxNumber;
        }
        [resultArr addObject:model.mj_keyValues];
    }];
    
    [KeyCUtil saveRouterTokeychainWithArr:resultArr key:ROUTER_ARR];
}

+ (void)updateRouterConnectStatusWithSn:(NSString *)sn {
    NSArray *routerArr = [KeyCUtil getRouterWithKey:ROUTER_ARR]?:@[];
    NSMutableArray *dicArr = [NSMutableArray array];
    [routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RouterModel *model = [RouterModel getObjectWithKeyValues:obj];
        model.isConnected = [model.userSn isEqualToString:sn]?YES:NO;
        [dicArr addObject:model.mj_keyValues];
    }];
    
    [KeyCUtil saveRouterTokeychainWithArr:dicArr key:ROUTER_ARR];
}
+ (void)updateRouterLoginSwitchWithSn:(NSString *)sn isOpen:(BOOL) isOpen
{
    NSArray *routerArr = [KeyCUtil getRouterWithKey:ROUTER_ARR]?:@[];
    NSMutableArray *dicArr = [NSMutableArray array];
    
    [routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RouterModel *model = [RouterModel getObjectWithKeyValues:obj];
            model.isOpen = [model.userSn isEqualToString:sn]?isOpen:NO;
            [dicArr addObject:model.mj_keyValues];
    }];
    
    [KeyCUtil saveRouterTokeychainWithArr:dicArr key:ROUTER_ARR];
}
+ (RouterModel *)getConnectRouter {
    __block RouterModel *resultM = nil;
    NSArray *routeArr = [KeyCUtil getRouterWithKey:ROUTER_ARR]?:@[];
    [routeArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RouterModel *model = [RouterModel getObjectWithKeyValues:obj];
        if (model.isConnected) {
            resultM = model;
            *stop = YES;
        }
    }];
    return resultM;
}

+ (NSArray *)getRouterExceptConnect {
    NSArray *routeArr = [KeyCUtil getRouterWithKey:ROUTER_ARR]?:@[];
    NSMutableArray *resultArr = [NSMutableArray array];
    [routeArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RouterModel *model = [RouterModel getObjectWithKeyValues:obj];
        if (!model.isConnected) {
            [resultArr addObject:model];
        }
    }];
    return resultArr;
}

+ (void)deleteRouterWithUsersn:(NSString *)sn {
    NSArray *routerArr = [KeyCUtil getRouterWithKey:ROUTER_ARR]?:@[];
    NSMutableArray *dicArr = [NSMutableArray array];
    [routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RouterModel *model = [RouterModel getObjectWithKeyValues:obj];
        if (![model.userSn isEqualToString:sn]) {
            [dicArr addObject:model.mj_keyValues];
        }
    }];
    
    [KeyCUtil saveRouterTokeychainWithArr:dicArr key:ROUTER_ARR];
}

@end
