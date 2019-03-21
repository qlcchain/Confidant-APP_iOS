//
//  GroupVerifyModel.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "GroupVerifyModel.h"
#import "NSDate+Category.h"

@implementation GroupVerifyModel

- (NSInteger)status {
    // 判断是否过期
    NSInteger day = labs([_requestTime daysAfterDate:[NSDate date]]);
    if (day > 7) { // 过期
        _status = 3;
    }
    return _status;
}

@end
