//
//  SystemUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/7.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SystemUtil : NSObject

// 获取当前wifi的路由ip
+ (NSString *) getRouterIpAddress;
+ (UIImage *) genterViewToImage:(UIView *) imgView;
+ (void) playSystemSound;
+ (NSString *) connectUrl;
+ (NSString *) connectFileUrl;
+ (NSString *) getBaseFilePath:(NSString *) friendid;

+ (NSString *)getTempUploadPhotoBaseFilePath;
+ (NSString *)getTempUploadVideoBaseFilePath;

+ (void) removeDocmentAudio;
// iOS将文件大小转换文KB\MB\GB
+ (NSString *)transformedValue:(CGFloat) convertedValue;
//获取视频封面，本地视频，网络视频都可以用
+ (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL;
// 文件路径是否存在
+ (BOOL) filePathisExist:(NSString *) filePath;
+ (void) removeDocmentFileName:(NSString *) fileName friendid:(NSString *) friendid;
+ (void) removeDocmentFilePath:(NSString *) filePath;
// 32位key
+ (NSString *) get16AESKey;
+ (NSString *) get32AESKey;
+ (BOOL) isSocketConnect;
+ (NSString *)getIPAddress;
+ (NSString *) getTempBaseFilePath:(NSString *) friendid;
+ (BOOL) isFriendWithFriendid:(NSString *) friendId;
+ (BOOL) writeDataToFileWithFilePath:(NSString *) filePath withData:(NSData *) data;
+ (BOOL)isVPNOn;
@end
