//
//  SystemUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/7.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "SystemUtil.h"
#import <AudioToolbox/AudioToolbox.h>
#import "getgateway.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <ifaddrs.h>
#import <SystemConfiguration/SCNetworkReachability.h>
#include <sys/socket.h>
#import <AFNetworking/AFNetworking.h>
#import <AVFoundation/AVFoundation.h>
#import "RoutherConfig.h"
#import "NSDateFormatter+Category.h"

@implementation SystemUtil
+ (void) playSystemSound
{
    AudioServicesPlaySystemSound(1007);
}

+ (NSString *) getRouterIpAddress
{
    BOOL isWIFI = NO;
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    NSString *localIP = @"";
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        //*/
        while(temp_addr != NULL)
        /*/
         int i=255;
         while((i--)>0)
         //*/
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    isWIFI = YES;
                    // Get NSString from C String //ifa_addr
                    //ifa->ifa_dstaddr is the broadcast address, which explains the "255's"
                    //                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)];

                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    DDLogDebug(@"address address--%@",address);
                    //routerIP----192.168.1.255 广播地址
                    DDLogDebug(@"broadcast address--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_dstaddr)->sin_addr)]);
                    //--192.168.1.106 本机地址
                   localIP = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    DDLogDebug(@"local device ip--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]);
                    //--255.255.255.0 子网掩码地址
                    DDLogDebug(@"netmask--%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)]);
                    //--en0 端口地址
                    DDLogDebug(@"interface--%@",[NSString stringWithUTF8String:temp_addr->ifa_name]);

                }

            }

            temp_addr = temp_addr->ifa_next;
        }
    }

    // Free memory
    freeifaddrs(interfaces);

    in_addr_t i =inet_addr([address cStringUsingEncoding:NSUTF8StringEncoding]);
    in_addr_t* x =&i;
    unsigned char *s=getdefaultgateway(x);
    NSString *ip=[NSString stringWithFormat:@"%d.%d.%d.%d",s[0],s[1],s[2],s[3]];
    free(s);
    return isWIFI? localIP : @"";
}

+ (UIImage *) genterViewToImage:(UIView *) imgView
{
    CGSize s = imgView.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(s, NO, [UIScreen mainScreen].scale);
    [imgView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (NSString *) connectUrl
{
    NSString *connectURL = @"";
    if (![[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterIp] isEmptyString]) {
        connectURL = [NSString stringWithFormat:@"https://%@:%@",[RoutherConfig getRoutherConfig].currentRouterIp,[RoutherConfig getRoutherConfig].currentRouterPort];
    }
    return connectURL;
}

+ (NSString *) connectFileUrl
{
    NSString *connectURL = @"";
    if (![[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterIp] isEmptyString]) {
        connectURL = [NSString stringWithFormat:@"https://%@:%ld",[RoutherConfig getRoutherConfig].currentRouterIp,[[RoutherConfig getRoutherConfig].currentRouterPort integerValue]+1];
    }
    return connectURL;
}

+ (NSString *) getBaseFilePath:(NSString *) friendid
{
   NSFileManager *manage = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *filePath = [NSString stringWithFormat:@"%@/files/%@",@"Documents",friendid];
    BOOL isexit = [manage fileExistsAtPath:[NSHomeDirectory() stringByAppendingPathComponent:filePath] isDirectory:&isDir];
    if (!isexit || !isDir) {
        [manage createDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:filePath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSHomeDirectory() stringByAppendingPathComponent:filePath];
}

+ (BOOL) filePathisExist:(NSString *) filePath
{
     NSFileManager *manage = [NSFileManager defaultManager];
     return  [manage fileExistsAtPath:filePath];
}

+ (void) removeDocmentAudio
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",@"audio"]];
     NSFileManager *manage = [NSFileManager defaultManager];
    [manage removeItemAtPath:path error:nil];
}

+ (void) removeDocmentFileName:(NSString *) fileName friendid:(NSString *) friendid
{
    if (fileName) {
        NSString *filePath = [[SystemUtil getBaseFilePath:friendid] stringByAppendingPathComponent:fileName];
        NSFileManager *manage = [NSFileManager defaultManager];
        [manage removeItemAtPath:filePath error:nil];
    }
   
}

// iOS将文件大小转换文KB\MB\GB
+ (NSString *)transformedValue:(CGFloat) convertedValue
{
    int multiplyFactor = 0;
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",nil];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

//获取视频封面，本地视频，网络视频都可以用

+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL {
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(2.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    UIImage *thumbImg = [[UIImage alloc] initWithCGImage:image];
    
    return thumbImg;
    
}

+ (NSString *) get16AESKey
{
    char data[16];
    
    for (int x=0;x<16;data[x++] = (char)('A' + (arc4random_uniform(26))));

    return [[NSString alloc] initWithBytes:data length:16 encoding:NSUTF8StringEncoding];
 
}
+ (BOOL) isSocketConnect {
    return  ![[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterIp] isEmptyString];
}

+ (NSString *)getIPAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}


@end
