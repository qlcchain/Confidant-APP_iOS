//
//  PNCampaignModel.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/19.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNCampaignModel.h"

@implementation PNCampaignModel
// 实现这个方法的目的：告诉MJExtension框架模型中的属性名对应着字典的哪个key
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
              @"subject" : @"title",
              @"campaignId" : @"id"
             };
}
@end
