//
//  PNFileModel.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/28.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNFileModel.h"

@implementation PNFileModel
+ (NSDictionary *)replacedKeyFromPropertyName {
    return @{
        @"fId":@"Id"
    };
}
@end
