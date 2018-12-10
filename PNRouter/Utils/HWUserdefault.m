//
//  HWUserdefault.m
//  GemPay
//
//  Created by Gempay on 15/2/6.
//  Copyright (c) 2015年 GemPay. All rights reserved.
//

#import "HWUserdefault.h"

@implementation HWUserdefault

+ (void)updateObject:(id)obj withKey:(NSString *)key {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:key];
    [user setObject:obj forKey:key];
    [user synchronize];
}

+ (void)updateArrWithObject:(id)obj withKey:(NSString *)key {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSArray *arr = [user objectForKey:key];
    if (!arr) {
        [user setObject:@[obj] forKey:key];
    } else {
        NSMutableArray *muArr = [NSMutableArray arrayWithArray:arr];
        [muArr addObject:obj];
        [user setObject:muArr forKey:key];
    }
    [user synchronize];
}

+ (id)getObjectWithKey:(NSString *)key {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    id object = [user objectForKey:key];
    return object;
}

+ (void)deleteObjectWithKey:(NSString *)key {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user removeObjectForKey:key];
}

@end
