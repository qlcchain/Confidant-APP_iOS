//
//  StringUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "StringUtil.h"

@implementation StringUtil
+ (NSString *) getUserNameFirstWithName:(NSString *) userName
{
    if ([userName isEmptyString]) {
        return @"";
    }
    NSArray *array = [userName componentsSeparatedByString:@" "];
    __block NSString *firstName = @"";
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *name = (NSString *)obj;
        if (![name isEmptyString]) {
            name = [[name substringToIndex:1] uppercaseString];
            firstName = [firstName stringByAppendingString:name];
            if (firstName.length == 2) {
                *stop = YES;
            }
        }
        
    }];
    return firstName;
}
@end
