//
//  GoogleMessageModel.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/10/17.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "GoogleMessageModel.h"

@implementation GoogleMessageModel
//+ (NSDictionary *)mj_objectClassInArray{
//    return @{@"stuarray" : @"Student"};//前边，是属性数组的名字，后边就是类名
//}

+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{
        @"messageId":@"id"
    };
}
@end
