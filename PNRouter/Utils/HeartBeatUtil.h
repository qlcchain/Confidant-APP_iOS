//
//  HeartBeatUtil.h
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/13.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HeartBeatUtil : NSObject

singleton_interface(HeartBeatUtil)

+ (void)start;
+ (void)stop;

@end
