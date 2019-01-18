//
//  EntryModel.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/1/17.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EntryModel.h"

@implementation EntryModel
+ (instancetype) getShareObject
{
    static EntryModel *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
    });
    return shareObject;
}
@end
