//
//  CTHelper.m
//  CDLabel
//
//  Created by chdo on 2017/12/4.
//

#import "CTHelper.h"


@implementation CTHelper

+(instancetype)share{
    static dispatch_once_t onceToken;
    static CTHelper *helper;
    dispatch_once(&onceToken, ^{
        helper = [[CTHelper alloc] init];
        helper.environment = 1;
    });
    return helper;
}


@end
