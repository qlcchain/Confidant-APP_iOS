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
#import "RouterConfig.h"
#import "NSDateFormatter+Category.h"
#import "ChatListDataUtil.h"
#import "FriendModel.h"
#import "UserConfig.h"
#import "UserModel.h"
#import "NSData+Base64.h"
#import "FileData.h"
#import "OperationRecordModel.h"
#import "KeyCUtil.h"
#import "PNFileModel.h"
#import <Contacts/Contacts.h>

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
    if (![[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterIp] isEmptyString]) {
        connectURL = [NSString stringWithFormat:@"https://%@:%@",[RouterConfig getRouterConfig].currentRouterIp,[RouterConfig getRouterConfig].currentRouterPort];
    }
    return connectURL;
}

+ (NSString *) connectFileUrl
{
    NSString *connectURL = @"";
    if (![[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterIp] isEmptyString]) {
        connectURL = [NSString stringWithFormat:@"https://%@:%d",[RouterConfig getRouterConfig].currentRouterIp,[[RouterConfig getRouterConfig].currentRouterPort integerValue]+1];
    }
    return connectURL;
}
+ (NSString *)getDocEmailBasePath
{
    NSFileManager *manage = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *filePath = [NSString stringWithFormat:@"%@/emails",@"Documents"];
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:filePath];
    BOOL isexit = [manage fileExistsAtPath:docPath isDirectory:&isDir];
    if (!isexit || !isDir) {
        if (isexit && !isDir) {
            [SystemUtil removeDocmentFilePath:docPath];
        }
        [manage createDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:filePath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSHomeDirectory() stringByAppendingPathComponent:filePath];
}
+ (NSString *)getDocEmailAttchFilePathWithUid:(NSString *) uid user:(NSString *)user
{
    NSFileManager *manage = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *filePath = [NSString stringWithFormat:@"%@/emails/%@",@"Documents",user];
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:filePath];
    BOOL isexit = [manage fileExistsAtPath:docPath isDirectory:&isDir];
    if (!isexit || !isDir) {
        if (isexit && !isDir) {
            [SystemUtil removeDocmentFilePath:docPath];
        }
        [manage createDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:filePath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSHomeDirectory() stringByAppendingPathComponent:[filePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",uid]]];
}

+ (NSString *) getBaseFilePath:(NSString *) friendid
{
   NSFileManager *manage = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *filePath = [NSString stringWithFormat:@"%@/files/%@/%@",@"Documents",[UserConfig getShareObject].userId,friendid];
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:filePath];
    BOOL isexit = [manage fileExistsAtPath:docPath isDirectory:&isDir];
    if (!isexit || !isDir) {
        if (isexit && !isDir) {
            [SystemUtil removeDocmentFilePath:docPath];
        }
       [manage createDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:filePath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSHomeDirectory() stringByAppendingPathComponent:filePath];
}

+ (NSString *) getCampaignFilePath
{
   NSFileManager *manage = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *filePath = [NSString stringWithFormat:@"%@/campaign/%@/campaign",@"Documents",[UserConfig getShareObject].userId];
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:filePath];
    BOOL isexit = [manage fileExistsAtPath:docPath isDirectory:&isDir];
    if (!isexit || !isDir) {
        if (isexit && !isDir) {
            [SystemUtil removeDocmentFilePath:docPath];
        }
       [manage createDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:filePath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSHomeDirectory() stringByAppendingPathComponent:filePath];
}

+ (NSString *) getBaseFileTimePathWithToid:(NSString *) toId
{
    NSFileManager *manage = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *filePath = [NSString stringWithFormat:@"%@/filetimes/%@/%@",@"Documents",[UserConfig getShareObject].userId,toId];
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:filePath];
    BOOL isexit = [manage fileExistsAtPath:docPath isDirectory:&isDir];
    if (!isexit || !isDir) {
        if (isexit && !isDir) {
            [SystemUtil removeDocmentFilePath:docPath];
        }
        [manage createDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:filePath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSHomeDirectory() stringByAppendingPathComponent:filePath];
}

+ (NSString *) getCurrentUserBaseFilePath
{
    NSFileManager *manage = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *filePath = [NSString stringWithFormat:@"%@/files/%@",@"Documents",[UserConfig getShareObject].userId];
    NSString *docPath = [NSHomeDirectory() stringByAppendingPathComponent:filePath];
    BOOL isexit = [manage fileExistsAtPath:docPath isDirectory:&isDir];
    if (!isexit || !isDir) {
        if (isexit && !isDir) {
            [SystemUtil removeDocmentFilePath:docPath];
        }
        [manage createDirectoryAtPath:[NSHomeDirectory() stringByAppendingPathComponent:filePath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSHomeDirectory() stringByAppendingPathComponent:filePath];
}

+ (NSString *) getTempBaseFilePath:(NSString *) friendid
{
    
    NSFileManager *manage = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *filePath = [NSString stringWithFormat:@"tempFiles/%@",friendid];
    BOOL isexit = [manage fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filePath] isDirectory:&isDir];
    if (!isexit || !isDir) {
        [manage createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filePath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSTemporaryDirectory() stringByAppendingPathComponent:filePath];
}


// 得到自己上传文件的 filepath
+ (NSString *) getOwerUploadFilePathWithFileName:(NSString *) fileName
{
    NSFileManager *manage = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *filePath = [NSString stringWithFormat:@"uploadFiles/%@_upload/%@",[UserConfig getShareObject].userId,fileName];

    NSString *filePathDir = [NSString stringWithFormat:@"uploadFiles/%@_upload",[UserConfig getShareObject].userId];
    NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    BOOL isexit = [manage fileExistsAtPath:[documentPath stringByAppendingPathComponent:filePathDir] isDirectory:&isDir];
    
    if (!isexit || !isDir) {
        [manage createDirectoryAtPath:[documentPath stringByAppendingPathComponent:filePathDir] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *path = [documentPath stringByAppendingPathComponent:filePath];
    return path;
}

+ (NSString *)getTempUploadPhotoBaseFilePath {
    NSFileManager *manage = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *filePath = @"upload_photo";
    BOOL isexit = [manage fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filePath] isDirectory:&isDir];
    if (!isexit || !isDir) {
        [manage createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filePath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSTemporaryDirectory() stringByAppendingPathComponent:filePath];
}

+ (NSString *)getTempUploadVideoBaseFilePath {
    NSFileManager *manage = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *filePath = @"upload_video";
    BOOL isexit = [manage fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filePath] isDirectory:&isDir];
    if (!isexit || !isDir) {
        [manage createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filePath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSTemporaryDirectory() stringByAppendingPathComponent:filePath];
}
    
+ (NSString *)getTempEmailAttchFilePath {
    NSFileManager *manage = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *filePath = @"email_tempPath";
    BOOL isexit = [manage fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filePath] isDirectory:&isDir];
    if (!isexit || !isDir) {
        [manage createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filePath] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSTemporaryDirectory() stringByAppendingPathComponent:filePath];
}

+ (NSString *)getTempDownloadFilePath:(NSString *)fileName {
    NSFileManager *manage = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *filePath = [NSString stringWithFormat:@"Download/%@",fileName];
    NSString *filePathDir = @"Download";
    BOOL isexit = [manage fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filePathDir] isDirectory:&isDir];
    if (!isexit || !isDir) {
        [manage createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filePathDir] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSTemporaryDirectory() stringByAppendingPathComponent:filePath];
}
// 解密后文件的临时目录
+ (NSString *)getTempDeFilePath:(NSString *)fileName {
    NSFileManager *manage = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *filePath = [NSString stringWithFormat:@"Defiles/%@",fileName];
    NSString *filePathDir = @"Defiles";
    BOOL isexit = [manage fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filePathDir] isDirectory:&isDir];
    if (!isexit || !isDir) {
        [manage createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filePathDir] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSTemporaryDirectory() stringByAppendingPathComponent:filePath];
}

// 加密相册解密后文件的临时目录
+ (NSString *)getPhotoTempDeFloderId:(NSString *)floderId fid:(NSString *) fid {
    NSFileManager *manage = [NSFileManager defaultManager];
    BOOL isDir = NO;
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",floderId,fid];
    NSString *filePathDir = floderId;
    BOOL isexit = [manage fileExistsAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filePathDir] isDirectory:&isDir];
    if (!isexit || !isDir) {
        [manage createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:filePathDir] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSTemporaryDirectory() stringByAppendingPathComponent:filePath];
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

+ (void) removeDocmentFilePath:(NSString *) filePath
{
    NSFileManager *manage = [NSFileManager defaultManager];
    [manage removeItemAtPath:filePath error:nil];
}

// iOS将文件大小转换文KB\MB\GB
+ (NSString *)transformedValue:(CGFloat) convertedValue
{
    int multiplyFactor = 0;
    NSArray *tokens = [NSArray arrayWithObjects:@"B",@"KB",@"MB",@"GB",@"TB",nil];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    if (convertedValue == 0) {
        convertedValue = 1;
    }
    return [NSString stringWithFormat:@"%4.1f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

+ (NSString *)transformedZSValue:(NSInteger) convertedValue
{
    int multiplyFactor = 0;
    NSArray *tokens = [NSArray arrayWithObjects:@"B",@"KB",@"MB",@"GB",@"TB",nil];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    return [NSString stringWithFormat:@"%ld %@",(long)convertedValue, [tokens objectAtIndex:multiplyFactor]];
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
    
    for (int x=0;x<16;data[x++] = (char)('A' + (arc4random_uniform(1))));

    return [[NSString alloc] initWithBytes:data length:16 encoding:NSUTF8StringEncoding];
 
}

+ (NSString *) get32AESKey
{
    char data[32];
    
    for (int x=0;x<32;data[x++] = (char)('A' + (arc4random_uniform(32))));
    
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
    
   // NSData *enstrData = [NSData dataWithBytesNoCopy:data length:32 freeWhenDone:NO];
   // return [enstrData base64EncodedString];

    
}

+ (NSString *) getDoc32AESKey
{
    char data[32];
    
    for (int x=0;x<32;data[x++] = (char)('A' + (arc4random_uniform(32))));
    
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
    
    // NSData *enstrData = [NSData dataWithBytesNoCopy:data length:32 freeWhenDone:NO];
    // return [enstrData base64EncodedString];
    
    
}
+ (BOOL) isSocketConnect {
    return  ![[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterIp] isEmptyString];
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
                if([[NSString getNotNullValue:[NSString stringWithUTF8String:temp_addr->ifa_name]] isEqualToString:@"en0"]) {
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
+ (BOOL) isFriendWithFriendid:(NSString *) friendId
{
    __block BOOL isEixt = NO;
    [[ChatListDataUtil getShareObject].friendArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        if ([model.userId isEqualToString:friendId]) {
            isEixt = YES;
            *stop = YES;
        }
    }];
    return isEixt;
}

+ (BOOL) writeDataToFileWithFilePath:(NSString *) filePath withData:(NSData *) data
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if(![fileManager fileExistsAtPath:filePath]) //如果不存在
        
    {
        
        NSLog(@"-------文件不存在，写入文件----------");
        
        [data writeToFile:filePath atomically:YES];
        
    }
    
    else//追加写入文件，而不是覆盖原来的文件
        
    {

        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePath];
        [fileHandle seekToEndOfFile];  //将节点跳到文件的末尾
        [fileHandle writeData:data]; //追加写入数据
        [fileHandle closeFile];
        
    }
    
   
    return YES;
}


+ (BOOL)isVPNOn
{
    BOOL flag = NO;
    NSString *version = [UIDevice currentDevice].systemVersion;
    // need two ways to judge this.
    if (version.doubleValue >= 9.0)
    {
        NSDictionary *dict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
        NSArray *keys = [dict[@"__SCOPED__"] allKeys];
        for (NSString *key in keys) {
            if ([key rangeOfString:@"tap"].location != NSNotFound ||
                [key rangeOfString:@"tun"].location != NSNotFound ||
                [key rangeOfString:@"ipsec"].location != NSNotFound ||
                [key rangeOfString:@"ppp"].location != NSNotFound){
                flag = YES;
                break;
            }
        }
    }
    else
    {
        struct ifaddrs *interfaces = NULL;
        struct ifaddrs *temp_addr = NULL;
        int success = 0;
        
        // retrieve the current interfaces - returns 0 on success
        success = getifaddrs(&interfaces);
        if (success == 0)
        {
            // Loop through linked list of interfaces
            temp_addr = interfaces;
            while (temp_addr != NULL)
            {
                NSString *string = [NSString stringWithFormat:@"%s" , temp_addr->ifa_name];
                if ([string rangeOfString:@"tap"].location != NSNotFound ||
                    [string rangeOfString:@"tun"].location != NSNotFound ||
                    [string rangeOfString:@"ipsec"].location != NSNotFound ||
                    [string rangeOfString:@"ppp"].location != NSNotFound)
                {
                    flag = YES;
                    break;
                }
                temp_addr = temp_addr->ifa_next;
            }
        }
        
        // Free memory
        freeifaddrs(interfaces);
    }
    
    
    return flag;
}



/**
 app退出时。配置
 */
+ (void) configureAPPTerminate {
    
//    NSArray *uploadTasks = [FileData bg_find:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"status"),bg_sqlValue(@(2))]];
//    [uploadTasks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        FileData *model = obj;
//        model.progess = 0.0f;
//        model.status = 3;
//        [model bg_saveOrUpdate];
//    }];
}

// app 打开时
+ (void) appFirstOpen
{    
    NSArray *uploadTasks = [PNFileModel bg_find:EN_FILE_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"uploadStatus"),bg_sqlValue(@(1))]];
    [uploadTasks enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PNFileModel *model = obj;
            model.progressV = 0.0f;
            model.uploadStatus = -1;
            [model bg_saveOrUpdateAsync:nil];
    }];
    
}
// 清除app所有数据
+ (void) clearAppAllData
{
    [KeyCUtil deleteAllKey];
    [FriendModel bg_drop:FRIEND_LIST_TABNAME];
    [FriendModel bg_drop:FRIEND_REQUEST_TABNAME];
    [OperationRecordModel bg_drop:OperationRecord_Table];
    NSString *documentPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    [SystemUtil removeDocmentFilePath:[documentPath stringByAppendingPathComponent:@"files"]];
    [SystemUtil removeDocmentFilePath:[documentPath stringByAppendingPathComponent:@"filetimes"]];
    [SystemUtil removeDocmentFilePath:[documentPath stringByAppendingPathComponent:@"uploadFiles/%@_upload"]];
    
}


#pragma mark --存储图片时间--filename key
+ (void) saveImageForTtimeWithToid:(NSString *) toid fileName:(NSString *) fileName fileTime:(NSInteger) fileTime
{
    NSString *timePath = [[SystemUtil getBaseFileTimePathWithToid:toid] stringByAppendingPathComponent:@"times"];
    NSMutableDictionary *timesDic = [NSMutableDictionary dictionaryWithContentsOfFile:timePath];
    if (!timesDic) {
        timesDic = [NSMutableDictionary dictionary];
    }
    [timesDic setObject:@(fileTime) forKey:fileName];
    [timesDic writeToFile:timePath atomically:YES];
}
+ (NSArray<NSTextCheckingResult *> *)findAllAtWithString:(NSString *) textString
{
    // 找到文本中所有的@
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kATRegular options:NSRegularExpressionCaseInsensitive error:nil];
    NSArray *matches = [regex matchesInString:textString options:NSMatchingReportProgress range:NSMakeRange(0, [textString length])];
    return matches;
}

+ (NSArray *) checkLocalContacts
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *plistPath = [paths objectAtIndex:0];
    NSString *filePath =[plistPath stringByAppendingPathComponent:@"contacts.vcf"];
   
    if ([SystemUtil filePathisExist:filePath]) {
        
        //读取出来的文件信息
        NSString *contactString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
        NSData *contactData = [contactString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSArray *contactArray = [CNContactVCardSerialization contactsWithData:contactData error:&error];
        return contactArray?:@[];
    }
   return @[];
}

+ (NSInteger) getLoacContactCount
{
    CNContactStore*store = [[CNContactStore alloc]init];
    NSError*fetchError;
    CNContactFetchRequest*request = [[CNContactFetchRequest alloc]initWithKeysToFetch:@[[CNContactVCardSerialization descriptorForRequiredKeys],[CNContactFormatter descriptorForRequiredKeysForStyle:CNContactFormatterStyleFullName]]];
    __block NSInteger contactCount = 0;
    [store enumerateContactsWithFetchRequest:request error:&fetchError usingBlock:^(CNContact*contact,BOOL*stop) {
        contactCount++;
    }];
    return contactCount;
}
// data 转 16进制 字符串
+ (NSString*)dataToHexString:(NSData*)data {
    if (data == nil) {
        return @"";
    }
    Byte *dateByte = (Byte *)[data bytes];
    NSString *hexStr=@"";
    for(int i=0;i<[data length];i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",dateByte[i]&0xff]; ///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}
// 16进制 字符串 转 data
+ (NSData *)HexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
 
    return hexData;
}
+ (NSString *) genterEnUtilNonce
{
    NSString *nonce = @"AAAAAAAAAAAAAAAAAAAAAAAA";
    unsigned char css[nonce.length];
    memcpy(css, [nonce cStringUsingEncoding:NSUTF8StringEncoding], nonce.length);
    NSData *nonceData = [NSData dataWithBytesNoCopy:css length:24 freeWhenDone:NO];
    return [nonceData base64EncodedString];
}

#pragma mark-------根据文件名得到文件类型
+ (NSInteger) getAttNameType:(NSString *) attName
{
    NSString *fileHz = [[attName componentsSeparatedByString:@"."] lastObject]?:@"";
    fileHz = [fileHz lowercaseString];
    if ([fileHz isEqualToString:@"webp"] || [fileHz isEqualToString:@"bmp"] || [fileHz isEqualToString:@"jpg"] || [fileHz isEqualToString:@"png"] || [fileHz isEqualToString:@"tif"] || [fileHz isEqualToString:@"jpeg"]) {
        return 1;
    } else {
        fileHz = [fileHz uppercaseString];
        NSArray *mvs = @[@"AVI",@"WMV",@"RM",@"RMVB",@"MPEG1",@"MPEG2",@"MPEG4",@"MP4",@"3GP",@"ASF",@"SWF",@"VOB",@"DAT",@"MOV",@"M4V",@"FLV",@"F4V",@"MKV",@"MTS",@"TS",@"MP3"];
        if ([mvs containsObject:fileHz]) {
            return 4;
        } else {
            return 5;
        }
    }
}

// 获取当前显示vc
+ (UIViewController *)getCurrentVC {
    UIViewController *result = nil;
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    if ([nextResponder isKindOfClass:[UIViewController class]]) {
        result = nextResponder;
    } else {
        result = window.rootViewController;
    }
    return result;
}

/**
 @method 获取指定宽度情况ixa，字符串value的高度
 */
+ (float) heightForString:(NSString *)value font:(UIFont *)font andWidth:(float)width
{
    return  [value boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName :font} context:nil].size.height;
}
@end
