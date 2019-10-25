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
#import "MyConfidant-Swift.h"
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toxConnectStatusNoti:) name:TOX_CONNECT_STATUS_NOTI object:nil];
}

#pragma mark -文件上传成功通知
- (void) uploadFileFinshNoti:(NSNotification *) noti
{
    
    //  [[NSNotificationCenter defaultCenter] postNotificationName:FILE_UPLOAD_NOTI object:@[@(weakSelf.retCode),self.fileName,self.fileData,@(self.fileType),self.srcKey]];
    
    NSArray *resultArr = noti.object;
    if (resultArr && resultArr.count>0 && [resultArr[0] integerValue] == 0) { // 成功
        
        NSString *srckey = resultArr[4];
        NSInteger fileid = [[resultArr lastObject] integerValue];
        
        [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(srckey),bg_sqlKey(@"fileId"),bg_sqlValue(@(fileid))] complete:^(NSArray * _Nullable array) {
            if (array && array.count > 0) {
                FileData *fileModel = array[0];
                fileModel.status = 1;
                fileModel.progess = 0;
                fileModel.fileData = [[NSData alloc] init];
                [fileModel bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:nil];
                }];
            }
        }];
       

       
         NSString *fileName = resultArr[1];
         fileName = [Base58Util Base58DecodeWithCodeName:fileName];
        
        NSNumber *fileType = resultArr[3];
        if (![SystemUtil isSocketConnect]) {
            NSString *srckey = resultArr[4];
            // 保存到本地
            NSString *fileInfo = [resultArr lastObject];
            DDLogDebug(@"上传成功:%@",fileName);
           // NSString *uploadDocPath = [SystemUtil getOwerUploadFilePathWithFileName:fileName];
            //  [fileData writeToFile:uploadDocPath atomically:YES];
            
            NSString *fileMd5 =  resultArr[5];
            NSNumber *fileSize = resultArr[6];
            [SendRequestUtil sendUploadFileWithUserId:[UserConfig getShareObject].userId FileName:[Base58Util Base58EncodeWithCodeName:fileName] FileMD5:fileMd5 FileSize:fileSize FileType:fileType UserKey:srckey fileInfo:fileInfo showHud:NO];
        }
        
        // 上传成功-保存操作记录
        NSInteger timestamp = [NSDate getTimestampFromDate:[NSDate date]];
        NSString *operationTime = [NSDate getTimeWithTimestamp:[NSString stringWithFormat:@"%@",@(timestamp)] format:@"yyyy-MM-dd HH:mm:ss" isMil:NO];
        [OperationRecordModel saveOrUpdateWithFileType:fileType operationType:@(0) operationTime:operationTime operationFrom:[UserConfig getShareObject].userName operationTo:@"" fileName:fileName routerPath:@"" localPath:@"" userId:[UserConfig getShareObject].userId];
        
    } else { // 上传失败
        NSString *srckey = resultArr[4];
         NSInteger fileid = [[resultArr lastObject] integerValue];
        [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(srckey),bg_sqlKey(@"fileId"),bg_sqlValue(@(fileid))] complete:^(NSArray * _Nullable array) {
            if (array && array.count > 0) {
                FileData *fileModel = array[0];
               
                fileModel.progess = 0.0;
                fileModel.fileData = [NSData data];
                if (fileModel.status != 3) {
                     fileModel.status = 3;
                    [fileModel bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Faield_Noti object:fileModel];
                    }];
                }
            }
        }];
    }
}
// tox 断开连接通知
- (void) toxConnectStatusNoti:(NSNotification *) noti
{
    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"status"),bg_sqlValue(@(2))] complete:^(NSArray * _Nullable array) {
        if (array && array.count > 0) {
            [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FileData *fileM = obj;
                fileM.status = 3;
                fileM.progess = 0.0f;
                [fileM bg_saveOrUpdate];
                [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Faield_Noti object:fileM];
            }];
        }
    }];
}
@end
