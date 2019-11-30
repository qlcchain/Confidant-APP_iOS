//
//  PNFloderModel.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNFloderModel.h"

@implementation PNFloderModel

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{
        @"fId":@"Id"
    };
}

/**
 自定义 “联合主键” 函数, 如果需要自定义 “联合主键”,则在类中自己实现该函数.
 @return 返回值是 “联合主键” 的字段名(即相对应的变量名).
 注：当“联合主键”和“唯一约束”同时定义时，“联合主键”优先级大于“唯一约束”.
 */
+(NSArray* _Nonnull)bg_unionPrimaryKeys
{
    return @[@"PathName"];
}
@end
