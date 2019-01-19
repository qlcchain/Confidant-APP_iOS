//
//  RoutherConfig.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/14.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RoutherConfig : NSObject

+ (instancetype) getRoutherConfig;

@property (nonatomic, strong) NSMutableArray *routherArray;
@property (nonatomic, copy) NSString *currentRouterIp;
@property (nonatomic, copy) NSString *currentRouterSn;
@property (nonatomic, copy) NSString *currentRouterToxid;
@property (nonatomic, copy) NSString *currentRouterPort;
@property (nonatomic, copy) NSString *currentRouterMAC;

- (void) addRoutherWithArray:(NSArray *) arr;
- (NSArray *) getCurrentRoutherWithToxid:(NSString *) toxid;

@end

NS_ASSUME_NONNULL_END
