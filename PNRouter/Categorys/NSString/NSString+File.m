//
//  NSString+File.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/25.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "NSString+File.h"
#import "MyConfidant-Swift.h"

static NSInteger UploadFileNameLength = 160;

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

+ (BOOL)uploadFileNameIsOverLength:(NSString *)str {
    BOOL isOver = NO;
    NSString *base58Str = [Base58Util Base58EncodeWithCodeName:str];
    if (base58Str.length > UploadFileNameLength) {
        isOver = YES;
    }
    return isOver;
}

+ (NSString *)getUploadFileNameOfCorrectLength:(NSString *)str {
    if (!str || str.length <=0) {
        return @"";
    }
    
    NSString *pathExtension = str.pathExtension;
    NSString *temp = str.stringByDeletingPathExtension;
    NSString *result = pathExtension?[temp stringByAppendingPathExtension:pathExtension]:temp;
    NSString *base58Str = [Base58Util Base58EncodeWithCodeName:result];
    while (base58Str.length > UploadFileNameLength) {
        temp = [temp substringToIndex:temp.length - 1];
        result = pathExtension?[temp stringByAppendingPathExtension:pathExtension]:temp;
        base58Str = [Base58Util Base58EncodeWithCodeName:result];
    }
    return result;
}

@end
