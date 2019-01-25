//
//  NSString+File.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/25.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "NSString+File.h"

@implementation NSString (File)

//单个文件的大小
+ (NSInteger)fileSizeAtPath:(NSString*)filePath {
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]) {
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    } else {
        NSLog(@"计算文件大小：文件不存在");
    }
    return 0;
}

@end
