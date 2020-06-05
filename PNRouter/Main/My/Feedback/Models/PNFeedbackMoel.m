//
//  PNFeedbackMoel.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/6/1.
//  Copyright © 2020 旷自辉. All rights reserved.
//
#import "PNFeedbackMoel.h"

@implementation PNFeedbackMoel
// 实现这个方法的目的：告诉MJExtension框架模型中的属性名对应着字典的哪个key
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
              @"feedbackId" : @"id"
             };
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{
        @"replayList" : @"PNFeedbackReplayModel"
    };
}
@end
