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
+ (NSString *) getBaseFileTimePathWithToid:(NSString *) toId;
// 清除所有数据
+ (void) clearAppAllData;
+ (NSString *)getTempUploadPhotoBaseFilePath;
+ (NSString *)getTempUploadVideoBaseFilePath;
+ (NSString *)getTempDownloadFilePath:(NSString *)fileName;
+ (NSString *) getDoc32AESKey;
+ (void) removeDocmentAudio;
// iOS将文件大小转换文KB\MB\GB
+ (NSString *)transformedValue:(CGFloat) convertedValue;
+ (NSString *)transformedZSValue:(NSInteger) convertedValue;
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
// 得到自己上传文件的 filepath
+ (NSString *) getOwerUploadFilePathWithFileName:(NSString *) fileName;
// 解密后文件的临时目录
+ (NSString *)getTempDeFilePath:(NSString *)fileName ;
+ (void) appFirstOpen;
/**
 app退出时。配置
 */
+ (void) configureAPPTerminate;
+ (NSString *) getCurrentUserBaseFilePath;
+ (void) saveImageForTtimeWithToid:(NSString *) toid fileName:(NSString *) fileName fileTime:(NSInteger) fileTime;
+ (NSArray<NSTextCheckingResult *> *)findAllAtWithString:(NSString *) textString;
    
+ (NSString *)getTempEmailAttchFilePath;
+ (NSString *)getDocEmailAttchFilePathWithUid:(NSString *) uid user:(NSString *) user;
+ (NSString *)getDocEmailBasePath;
// 加密相册解密后文件的临时目录
+ (NSString *)getPhotoTempDeFloderId:(NSString *)floderId fid:(NSString *) fid;
@end
