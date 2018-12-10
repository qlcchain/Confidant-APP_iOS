//
//  HWUserdefault.h
//  GemPay
//
//  Created by Gempay on 15/2/6.
//  Copyright (c) 2015年 GemPay. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HWUserdefault : NSObject

+ (void)updateObject:(id)obj withKey:(NSString *)key;
+ (id)getObjectWithKey:(NSString *)key;
+ (void)deleteObjectWithKey:(NSString *)key;
+ (void)updateArrWithObject:(id)obj withKey:(NSString *)key;

@end
