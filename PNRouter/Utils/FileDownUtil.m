//
//  FileDownUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/1/26.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "FileDownUtil.h"
#import "FileListModel.h"
#import "PNRouter-Swift.h"
#import "OperationRecordModel.h"
#import "SystemUtil.h"
#import "RequestService.h"
#import "NSDate+Category.h"
#import "UserConfig.h"
#import "FileData.h"
#import "FileModel.h"

@interface FileDownUtil()
{
    BOOL isTaskFile;
}
@end

@implementation FileDownUtil

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void) addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downFileFaieldNoti:) name:TOX_PULL_FILE_FAIELD_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downFileSuccessNoti:) name:TOX_PULL_FILE_SUCCESS_NOTI object:nil];
}

+ (instancetype) getShareObject
{
    static FileDownUtil *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
        [shareObject addObserver];
    });
    return shareObject;
}

- (void) downFileWithFileModel:(FileListModel *) fileModel  progressBlock:(void(^)(CGFloat progress)) progressBlock
                       success:(void (^)(NSURLSessionDownloadTask *dataTask, NSString *filePath)) success
                       failure:(void (^)(NSURLSessionDownloadTask *dataTask, NSError *error))failure
{
    NSString *filePath = fileModel.FileName;
    NSString *fileNameBase58 = fileModel.FileName.lastPathComponent;
    NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58]?:@"";
    NSString *downloadFilePath = [SystemUtil getTempDownloadFilePath:fileName];
    
   __block FileData *fileDataModel = nil;
    
    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(fileModel.UserKey)] complete:^(NSArray * _Nullable array) {
        
        NSLog(@"写入数据库");
        if (array && array.count > 0) {
            fileDataModel = array[0];
        } else {
            fileDataModel = [[FileData alloc] init];
            fileDataModel.bg_tableName = FILE_STATUS_TABNAME;
        }
        NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
        NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
        fileDataModel.fileId = [mill intValue];
        fileDataModel.fileSize = [fileModel.FileSize intValue];
        fileDataModel.fileType = [fileModel.FileType intValue];
        fileDataModel.progess = 0.0f;
        fileDataModel.fileName = fileName;
        fileDataModel.filePath = filePath;
        fileDataModel.fileOptionType = 2;
        fileDataModel.status = 2;
        fileDataModel.userId = [UserConfig getShareObject].userId;
        fileDataModel.srcKey = fileModel.UserKey;
        [fileDataModel bg_saveOrUpdateAsync:nil];
    }];
    
    [RequestService downFileWithBaseURLStr:filePath filePath:downloadFilePath progressBlock:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            progressBlock(progress);
//            NSLog(@"progress**********************");
            if (fileDataModel) {
                fileDataModel.progess = progress;
                fileDataModel.status = 2;
                [[NSNotificationCenter defaultCenter] postNotificationName:File_Progess_Noti object:fileDataModel];
            }
            
        });
    } success:^(NSURLSessionDownloadTask *dataTask, NSString *filePath) {
        dispatch_async(dispatch_get_main_queue(), ^{
             success(dataTask, filePath);
            // 保存下载完成记录
            [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(fileModel.UserKey)] complete:^(NSArray * _Nullable array) {
                NSLog(@"下载完成保存数据库**********************");
                if (array && array.count > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        FileData *fileData = array[0];
                        fileData.status = 1;
                        fileData.progess = 1.0f;
                        [fileData bg_saveOrUpdateAsync:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:fileData];
                    });
                    
                }
            }];
            // 下载成功-保存操作记录
            NSInteger timestamp = [NSDate getTimestampFromDate:[NSDate date]];
            NSString *operationTime = [NSDate getTimeWithTimestamp:[NSString stringWithFormat:@"%@",@(timestamp)] format:@"yyyy-MM-dd HH:mm:ss" isMil:NO];
            NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileModel.FileName.lastPathComponent];
            [OperationRecordModel saveOrUpdateWithFileType:fileModel.FileType operationType:@(1) operationTime:operationTime operationFrom:[UserConfig getShareObject].userName operationTo:@"" fileName:fileName routerPath:fileModel.FileName?:@"" localPath:@"" userId:[UserConfig getShareObject].userId];
        });
        
    } failure:^(NSURLSessionDownloadTask *dataTask, NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"download error********* %@",error);
            failure(dataTask,error);
            // 保存下载完成记录
            [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(fileModel.UserKey)] complete:^(NSArray * _Nullable array) {
                if (array && array.count > 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        FileData *fileData = array[0];
                        fileData.status = 3;
                        fileData.progess = 0.0f;
                        [fileData bg_saveOrUpdateAsync:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:fileData];
                    });
                }
            }];
        });
    }];
}



- (void) deDownFileWithFileModel:(FileData *) fileModel  progressBlock:(void(^)(CGFloat progress)) progressBlock
                       success:(void (^)(NSURLSessionDownloadTask *dataTask, NSString *filePath)) success
                       failure:(void (^)(NSURLSessionDownloadTask *dataTask, NSError *error))failure
{
    NSString *filePath = fileModel.filePath;
    NSString *downloadFilePath = [SystemUtil getTempDownloadFilePath:fileModel.fileName];
    
    __block FileData *fileDataModel = nil;
    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(fileModel.srcKey)] complete:^(NSArray * _Nullable array) {
        if (array && array.count > 0) {
            
            fileDataModel = array[0];
            fileDataModel.status = 2;
            [fileDataModel bg_saveOrUpdateAsync:nil];
            
            // 下载
            [RequestService downFileWithBaseURLStr:filePath filePath:downloadFilePath progressBlock:^(CGFloat progress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressBlock(progress);
                    
                    fileDataModel.progess = progress;
                    fileDataModel.status = 2;
                  //  [fileData bg_saveOrUpdateAsync:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:File_Progess_Noti object:fileDataModel];
                });
            } success:^(NSURLSessionDownloadTask *dataTask, NSString *filePath) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 保存下载完成记录
                    fileDataModel.status = 1;
                    fileDataModel.progess = 1.0f;
                    [fileDataModel bg_saveOrUpdateAsync:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:fileDataModel];
                    // 下载成功-保存操作记录
                    NSInteger timestamp = [NSDate getTimestampFromDate:[NSDate date]];
                    NSString *operationTime = [NSDate getTimeWithTimestamp:[NSString stringWithFormat:@"%@",@(timestamp)] format:@"yyyy-MM-dd HH:mm:ss" isMil:NO];
                    NSString *fileName = fileModel.fileName;
                    [OperationRecordModel saveOrUpdateWithFileType:@(fileModel.fileType) operationType:@(1) operationTime:operationTime operationFrom:[UserConfig getShareObject].userName operationTo:@"" fileName:fileName routerPath:fileModel.filePath?:@"" localPath:@"" userId:[UserConfig getShareObject].userId];
                });
                
            } failure:^(NSURLSessionDownloadTask *dataTask, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"download error********* %@",error);
                    // 保存下载失败记录
                    fileDataModel.status = 3;
                    fileDataModel.progess = 0.0f;
                    [fileDataModel bg_saveOrUpdateAsync:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:fileDataModel];
                });
            }];
        }
    }];
}

- (void) toxDownFileModel:(FileListModel *) fileModel
{
    NSString *filePath = fileModel.FileName;
    NSString *fileNameBase58 = fileModel.FileName.lastPathComponent;
    NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58]?:@"";
    
    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(fileModel.UserKey)] complete:^(NSArray * _Nullable array) {
        
        NSLog(@"写入数据库");
        FileData *fileDataModel = nil;
        if (array && array.count > 0) {
            fileDataModel = array[0];
        } else {
            fileDataModel = [[FileData alloc] init];
            fileDataModel.bg_tableName = FILE_STATUS_TABNAME;
        }
        NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
        NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
        fileDataModel.fileId = [mill intValue];
        fileDataModel.fileSize = [fileModel.FileSize intValue];
        fileDataModel.fileType = [fileModel.FileType intValue];
        fileDataModel.msgId = [fileModel.MsgId intValue];
        fileDataModel.progess = 0.0f;
        fileDataModel.fileName = fileName;
        fileDataModel.filePath = filePath;
        fileDataModel.fileOptionType = 2;
        fileDataModel.status = 2;
        fileDataModel.userId = [UserConfig getShareObject].userId;
        fileDataModel.srcKey = fileModel.UserKey;
        [fileDataModel bg_saveOrUpdateAsync:nil];
    }];
    
     NSArray *pathArr = [fileModel.FileName componentsSeparatedByString:@"/"];
    if (pathArr && pathArr.count >2) {
        NSString *result = pathArr[2];
        NSString *fileOwer = @"";
        // /u/表示是上传的   如果是/s/是发送的，/r/是接收的
        if ([result isEqualToString:@"s"]) {
            fileOwer = @"1";
        } else if ([result isEqualToString:@"r"]) {
            fileOwer = @"2";
        } else {
            fileOwer = @"3";
        }
        isTaskFile = YES;
        [SendRequestUtil sendToxPullFileWithFromId:[UserConfig getShareObject].userId toid:[UserConfig getShareObject].userId fileName:fileModel.FileName.lastPathComponent msgId:[NSString stringWithFormat:@"%@",fileModel.MsgId ] fileOwer:fileOwer fileFrom:@"2"];
    }
}

- (void) deToxDownFileModel:(FileData *) fileModel
{
    NSString *filePath = fileModel.filePath;
    NSString *fileName = fileModel.fileName;
    
    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(fileModel.srcKey)] complete:^(NSArray * _Nullable array) {
        
        NSLog(@"写入数据库");
        FileData *fileDataModel = nil;
        if (array && array.count > 0) {
            fileDataModel = array[0];
        } else {
            fileDataModel = [[FileData alloc] init];
            fileDataModel.bg_tableName = FILE_STATUS_TABNAME;
        }
        NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
        NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
        fileDataModel.fileId = [mill intValue];
        fileDataModel.fileSize = fileModel.fileSize;
        fileDataModel.fileType = fileModel.fileType;
        fileDataModel.msgId = fileModel.msgId;
        fileDataModel.progess = 0.0f;
        fileDataModel.fileName = fileName;
        fileDataModel.filePath = filePath;
        fileDataModel.fileOptionType = 2;
        fileDataModel.status = 2;
        fileDataModel.userId = [UserConfig getShareObject].userId;
        fileDataModel.srcKey = fileModel.srcKey;
        [fileDataModel bg_saveOrUpdateAsync:nil];
    }];
    
    NSArray *pathArr = [fileModel.filePath componentsSeparatedByString:@"/"];
    if (pathArr && pathArr.count >2) {
        NSString *result = pathArr[2];
        NSString *fileOwer = @"";
        // /u/表示是上传的   如果是/s/是发送的，/r/是接收的
        if ([result isEqualToString:@"s"]) {
            fileOwer = @"1";
        } else if ([result isEqualToString:@"r"]) {
            fileOwer = @"2";
        } else {
            fileOwer = @"3";
        }
        isTaskFile = YES;
        [SendRequestUtil sendToxPullFileWithFromId:[UserConfig getShareObject].userId toid:[UserConfig getShareObject].userId fileName:[Base58Util Base58EncodeWithCodeName:fileName] msgId:[NSString stringWithFormat:@"%d",fileModel.msgId ] fileOwer:fileOwer fileFrom:@"2"];
    }
}

- (BOOL) isTaskFileOption
{
    return isTaskFile;
}
- (void) setTaskFile:(BOOL) isFile
{
    isTaskFile = isFile;
}
- (void) updateFileDataBaseWithFileModel:(FileModel *) fileModel
{
    if (fileModel.RetCode != 0) { // 下载失败
        // 保存下载失败记录
         [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"msgId"),bg_sqlValue(fileModel.MsgId)] complete:^(NSArray * _Nullable array) {
             if (array && array.count > 0) {
                 FileData *fileDataModel = array[0];
                 fileDataModel.status = 3;
                 fileDataModel.progess = 0.0f;
                 [fileDataModel bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                     [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:nil];
                 }];
             }
         }];
         [[NSNotificationCenter defaultCenter] postNotificationName:TOX_PULL_FILE_FAIELD_NOTI object:fileModel.MsgId];
    }
}








#pragma mark -  tox下载通知
- (void) downFileFaieldNoti:(NSNotification *)noti {
    int msgid = [noti.object intValue];
    
    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"msgId"),bg_sqlValue(@(msgid))] complete:^(NSArray * _Nullable array) {
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
- (void) downFileSuccessNoti:(NSNotification *)noti {
    NSArray *arr = noti.object;
    int msgid = [arr[2] intValue];
    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"msgId"),bg_sqlValue(@(msgid))] complete:^(NSArray * _Nullable array) {
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
}

@end
