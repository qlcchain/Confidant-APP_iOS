//
//  UploadFileManager.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/1/25.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "UploadFileManager.h"
#import "UserConfig.h"
#import "SystemUtil.h"
#import "MD5Util.h"
#import "PNRouter-Swift.h"
#import "NSString+File.h"

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
    
    //  [[NSNotificationCenter defaultCenter] postNotificationName:FILE_UPLOAD_NOTI object:@[@(weakSelf.retCode),self.fileName,self.fileData,@(self.fileType),self.srcKey]];
    
    NSArray *resultArr = noti.object;
    if (resultArr && resultArr.count>0 && [resultArr[0] integerValue] == 0) { // 成功
        
        NSString *fileName = resultArr[1];
        NSData *fileData = resultArr[2];
        
        // 保存到本地
        fileName = [Base58Util Base58DecodeWithCodeName:fileName];
        DDLogDebug(@"上传成功:%@",fileName);
        NSString *uploadDocPath = [SystemUtil getOwerUploadFilePathWithFileName:fileName];
        
        [fileData writeToFile:uploadDocPath atomically:YES];
        if (![SystemUtil isSocketConnect]) {
            NSNumber *fileType = resultArr[3];
            NSString *srckey = resultArr[4];
            NSInteger fileSize = [NSString fileSizeAtPath:uploadDocPath];
            NSString *fileMd5 =  [MD5Util md5WithPath:uploadDocPath];
            
            [SendRequestUtil sendUploadFileWithUserId:[UserConfig getShareObject].userId FileName:fileName FileMD5:fileMd5 FileSize:@(fileSize) FileType:fileType UserKey:srckey showHud:NO];
        }
        
    } else { // 上传失败
        
    }
}
@end
