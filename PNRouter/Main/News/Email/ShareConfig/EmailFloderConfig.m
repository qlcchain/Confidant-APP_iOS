//
//  EmailFloderConfig.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/17.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EmailFloderConfig.h"

@implementation EmailFloderConfig
singleton_implementation(EmailFloderConfig)

+ (NSDictionary *) getFloderConfigWithEmailType:(int) type
{
   NSString *filePath = [[NSBundle mainBundle] pathForResource:@"EmailConfigure" ofType:@"plist"];
    NSDictionary *floderDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
    return [floderDic objectForKey:[NSString stringWithFormat:@"%d",type]];
}
@end
