//
//  VPNUtil.m
//  Qlink
//
//  Created by 旷自辉 on 2018/4/20.
//  Copyright © 2018年 pan. All rights reserved.
//

#import "VPNFileUtil.h"


static NSString *vpnPath = @"otherFiles";
@implementation VPNFileUtil

// 获取vpn存储路径
+ (NSString *) getVPNDataPath
{
    NSArray *library = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);// 沙盒路径
    return [library[0] stringByAppendingPathComponent:vpnPath];
}

+ (NSString *)getTempPath {
    NSString *tmpDir = NSTemporaryDirectory();
    return tmpDir;
}

+ (void)removeVPNFile
{
    NSString *dataPath = [VPNFileUtil getVPNDataPath];
    NSFileManager *fileManage = [NSFileManager defaultManager];
    if ([fileManage fileExistsAtPath:dataPath]) {
        [fileManage removeItemAtPath:dataPath error:nil];
    }
}

/**
将vpn配置文件保存到沙盒并保存到keychain

 @param data vpn配置文件
 @param fileName vpn名字
 */
+ (void) saveVPNDataToLibrayPath:(NSData *) data withFileName:(NSString *) fileName
{
    NSString *dataPath = [VPNFileUtil getVPNDataPath];
    NSLog(@"dataPath = %@",dataPath);

    NSFileManager *fileManage = [NSFileManager defaultManager];
    if (![fileManage fileExistsAtPath:dataPath]) {
        [fileManage createDirectoryAtPath:dataPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [data writeToFile:[dataPath stringByAppendingString:fileName] atomically:YES];
    
}

// 根据文件名得到路径
+ (NSString *) getVPNPathWithFileName:(NSString *) fileName
{
    NSString *dataPath = [VPNFileUtil getVPNDataPath];
    return [dataPath stringByAppendingPathComponent:fileName];
}

@end
