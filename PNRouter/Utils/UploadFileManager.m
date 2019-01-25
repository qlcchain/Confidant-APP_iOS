//
//  UploadFileManager.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/1/25.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "UploadFileManager.h"
#import "UserConfig.h"

@implementation UploadFileManager
+ (instancetype) getShareObject
{
    static UploadFileManager *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
        [shareObject addObserver];
    });
    return shareObject;
}
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void) addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFileFinshNoti:) name:FILE_UPLOAD_NOTI object:nil];
}

#pragma mark -文件上传成功通知
- (void) uploadFileFinshNoti:(NSNotification *) noti
{
    NSArray *resultArr = noti.object;
    if (resultArr && resultArr.count>0 && [resultArr[0] integerValue] == 0) { // 成功
        NSString *fileName = resultArr[1];
        NSString *fileMd5 = resultArr[2];
        NSNumber *fileSize = resultArr[3];
        NSNumber *fileType = resultArr[4];
        NSString *srckey = resultArr[5];
        [SendRequestUtil sendUploadFileWithUserId:[UserConfig getShareObject].userId FileName:fileName FileMD5:fileMd5 FileSize:fileSize FileType:fileType UserKey:srckey showHud:NO];
        
    } else {
        
    }
}
@end
