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
#import "FileData.h"
#import "OperationRecordModel.h"
#import "NSDate+Category.h"
//#import "NSDateFormatter+Category.h"

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
        
        NSString *srckey = resultArr[4];
        [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(srckey)] complete:^(NSArray * _Nullable array) {
            if (array && array.count > 0) {
                FileData *fileModel = array[0];
                fileModel.status = 1;
                fileModel.progess = 1;
                fileModel.fileData = nil;
                [fileModel bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:nil];
                }];
            }
        }];
       

       
         NSString *fileName = resultArr[1];
         fileName = [Base58Util Base58DecodeWithCodeName:fileName];
        
        NSNumber *fileType = resultArr[3];
        if (![SystemUtil isSocketConnect]) {
           
           // NSData *fileData = resultArr[2];
            NSString *srckey = resultArr[4];
            // 保存到本地
           
            DDLogDebug(@"上传成功:%@",fileName);
            NSString *uploadDocPath = [SystemUtil getOwerUploadFilePathWithFileName:fileName];
            //  [fileData writeToFile:uploadDocPath atomically:YES];
            NSInteger fileSize = [NSString fileSizeAtPath:uploadDocPath];
            NSString *fileMd5 =  [MD5Util md5WithPath:uploadDocPath];
            
            [SendRequestUtil sendUploadFileWithUserId:[UserConfig getShareObject].userId FileName:fileName FileMD5:fileMd5 FileSize:@(fileSize) FileType:fileType UserKey:srckey showHud:NO];
        }
        
        // 上传成功-保存操作记录
        NSInteger timestamp = [NSDate getTimestampFromDate:[NSDate date]];
        NSString *operationTime = [NSDate getTimeWithTimestamp:[NSString stringWithFormat:@"%@",@(timestamp)] format:@"yyyy-MM-dd HH:mm:ss" isMil:NO];
        [OperationRecordModel saveOrUpdateWithFileType:fileType operationType:@(0) operationTime:operationTime operationFrom:[UserConfig getShareObject].userName operationTo:@"" fileName:fileName routerPath:@"" localPath:@""];
    } else { // 上传失败
        NSString *srckey = resultArr[4];
        [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(srckey)] complete:^(NSArray * _Nullable array) {
            if (array && array.count > 0) {
                FileData *fileModel = array[0];
                fileModel.status = 3;
                fileModel.progess = 0.0;
                fileModel.fileData = nil;
                [fileModel bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:nil];
                }];
            }
        }];
    }
}

@end
