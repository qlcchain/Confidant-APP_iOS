//
//  FileDownUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/1/26.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "FileDownUtil.h"
#import "FileListModel.h"
#import "MyConfidant-Swift.h"
#import "OperationRecordModel.h"
#import "SystemUtil.h"
#import "RequestService.h"
#import "NSDate+Category.h"
#import "UserConfig.h"
#import "FileData.h"
#import "FileModel.h"
#import "NSDateFormatter+Category.h"
#import "SocketCountUtil.h"

@interface FileDownUtil()
{
    BOOL isTaskFile;
}

@property (nonatomic, strong) NSMutableArray *taskArr;

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
        shareObject.taskArr = [NSMutableArray array];
    });
    return shareObject;
}

// 取消当前下载
- (void) cancelDownWithFileid:(NSInteger) fileid srckey:(NSString *) srckey
{
    [self.taskArr enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FileData *fileModel = obj;
        if ([fileModel.srcKey isEqualToString:fileModel.srcKey] && fileid == fileModel.fileId) {
            if (fileModel.downloadTask) {
                [fileModel.downloadTask cancel];
            }
            *stop = YES;
        }
    }];
}

- (void) downFileWithFileModel:(FileListModel *) fileModel  progressBlock:(void(^)(CGFloat progress)) progressBlock
                       success:(void (^)(NSURLSessionDownloadTask *dataTask, NSString *filePath)) success
                       failure:(void (^)(NSURLSessionDownloadTask *dataTask, NSError *error))failure
                        downloadTaskB:(void (^)(NSURLSessionDownloadTask *downloadTask))downloadTaskB
{
    NSString *filePath = fileModel.FilePath;
    NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileModel.FileName?:@""]?:@"";
    NSString *downloadFilePath = [SystemUtil getTempDownloadFilePath:fileName];
    
    __block FileData *fileDataModel = nil;
    
    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(fileModel.UserKey),bg_sqlKey(@"msgId"),bg_sqlValue(fileModel.MsgId)] complete:^(NSArray * _Nullable array) {
        
        NSLog(@"写入数据库");
        if (array && array.count > 0) {
            fileDataModel = array[0];
        } else {
            fileDataModel = [[FileData alloc] init];
            long tempMsgid = [SocketCountUtil getShareObject].fileIDCount++;
            tempMsgid = [NSDate getTimestampFromDate:[NSDate date]]+tempMsgid;
            fileDataModel.fileId = tempMsgid;
            fileDataModel.bg_tableName = FILE_STATUS_TABNAME;
        }
        
        fileDataModel.fileSize = [fileModel.FileSize intValue];
        fileDataModel.fileType = [fileModel.FileType intValue];
        fileDataModel.progess = 0.0f;
        fileDataModel.msgId = [fileModel.MsgId intValue];
        fileDataModel.fileName = fileName;
        fileDataModel.filePath = filePath;
        fileDataModel.fileOptionType = 2;
        NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
        fileDataModel.optionTime = [formatter stringFromDate:[NSDate date]];
        fileDataModel.status = 2;
        fileDataModel.userId = [UserConfig getShareObject].userId;
        fileDataModel.srcKey = fileModel.UserKey;
        [fileDataModel bg_saveOrUpdate];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            @weakify_self
            NSURLSessionDownloadTask *task = [RequestService downFileWithBaseURLStr:filePath filePath:downloadFilePath progressBlock:^(CGFloat progress) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progressBlock(progress);
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"Http_Down_File_Progess_Noti" object:fileDataModel];
                    if (fileDataModel) {
                        fileDataModel.progess = progress;
                        fileDataModel.status = 2;
                        [[NSNotificationCenter defaultCenter] postNotificationName:File_Progess_Noti object:fileDataModel];
                    }
                    
                });
            } success:^(NSURLSessionDownloadTask *dataTask, NSString *filePath) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    success(dataTask, filePath);
                    fileDataModel.downSavePath = filePath;
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"HTTP_PULL_FILE_SUCCESS_NOTI" object:fileDataModel];
                    // 保存下载完成记录
                    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(fileModel.UserKey),bg_sqlKey(@"msgId"),bg_sqlValue(@(fileDataModel.msgId))] complete:^(NSArray * _Nullable array) {
                        NSLog(@"下载完成保存数据库**********************");
                        if (array && array.count > 0) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                FileData *fileData = array[0];
                                fileData.status = 1;
                                fileData.progess = 1.0f;
                                [fileData bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                                    [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:fileData];
                                }];
                                
                            });
                        }
                    }];
                    // 下载成功-保存操作记录
                    NSInteger timestamp = [NSDate getTimestampFromDate:[NSDate date]];
                    NSString *operationTime = [NSDate getTimeWithTimestamp:[NSString stringWithFormat:@"%@",@(timestamp)] format:@"yyyy-MM-dd HH:mm:ss" isMil:NO];
                    NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileModel.FileName?:@""];
                    [OperationRecordModel saveOrUpdateWithFileType:fileModel.FileType operationType:@(1) operationTime:operationTime operationFrom:[UserConfig getShareObject].userName operationTo:@"" fileName:fileName routerPath:fileModel.FilePath?:@"" localPath:@"" userId:[UserConfig getShareObject].userId];
                    
                    [weakSelf.taskArr removeObject:fileDataModel];
                    NSLog(@"下载列表：%@",weakSelf.taskArr);
                });
                
            } failure:^(NSURLSessionDownloadTask *dataTask, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"download error********* %@",error);
                    
                    failure(dataTask,error);
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"HTTP_PULL_FILE_FAIELD_NOTI" object:fileDataModel];
                    //            if (error.code == -999) { // 取消
                    //                [FileData bg_deleteAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(fileModel.UserKey)] complete:^(BOOL isSuccess) {
                    //                    [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:nil];
                    //                }];
                    //            } else { // 失败
                    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(fileModel.UserKey),bg_sqlKey(@"msgId"),bg_sqlValue(fileModel.MsgId)] complete:^(NSArray * _Nullable array) {
                        if (array && array.count > 0) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                FileData *fileData = array[0];
                                fileData.status = 3;
                                fileData.progess = 0.0f;
                                [fileData bg_saveOrUpdateAsync:nil];
                                [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Faield_Noti object:fileData];
                            });
                        }
                    }];
                    //            }
                    [weakSelf.taskArr removeObject:fileDataModel];
                    NSLog(@"下载列表：%@",weakSelf.taskArr);
                });
            }];
            
            if (fileDataModel) {
                fileDataModel.downloadTask = task;
                [self.taskArr addObject:fileDataModel];
            }
            
            NSLog(@"下载列表：%@",self.taskArr);
            if (downloadTaskB) {
                downloadTaskB(task);
            }
            
            
        });
        
        
        
    }];
    
    
}



- (void) deDownFileWithFileModel:(FileData *) fileModel  progressBlock:(void(^)(CGFloat progress)) progressBlock
                       success:(void (^)(NSURLSessionDownloadTask *dataTask, NSString *filePath)) success
                       failure:(void (^)(NSURLSessionDownloadTask *dataTask, NSError *error))failure
                    downloadTaskB:(void (^)(NSURLSessionDownloadTask *downloadTask))downloadTaskB
{
    NSString *filePath = fileModel.filePath;
    NSString *downloadFilePath = [SystemUtil getTempDownloadFilePath:fileModel.fileName];
    
    __block FileData *fileDataModel = nil;
    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(fileModel.srcKey),bg_sqlKey(@"msgId"),bg_sqlValue(@(fileModel.msgId))] complete:^(NSArray * _Nullable array) {
        if (array && array.count > 0) {
            
            fileDataModel = array[0];
            NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
            fileModel.optionTime = [formatter stringFromDate:[NSDate date]];
            fileDataModel.status = 2;
            [fileDataModel bg_saveOrUpdate];
            
            @weakify_self
            // 下载
            NSURLSessionDownloadTask *task = [RequestService downFileWithBaseURLStr:filePath filePath:downloadFilePath progressBlock:^(CGFloat progress) {
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
                    
                    [fileDataModel bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:fileDataModel];
                    }];
                    
                    // 下载成功-保存操作记录
                    NSInteger timestamp = [NSDate getTimestampFromDate:[NSDate date]];
                    NSString *operationTime = [NSDate getTimeWithTimestamp:[NSString stringWithFormat:@"%@",@(timestamp)] format:@"yyyy-MM-dd HH:mm:ss" isMil:NO];
                    NSString *fileName = fileModel.fileName;
                    [OperationRecordModel saveOrUpdateWithFileType:@(fileModel.fileType) operationType:@(1) operationTime:operationTime operationFrom:[UserConfig getShareObject].userName operationTo:@"" fileName:fileName routerPath:fileModel.filePath?:@"" localPath:@"" userId:[UserConfig getShareObject].userId];
                    
                    [weakSelf.taskArr removeObject:fileDataModel];
                    NSLog(@"下载列表：%@",weakSelf.taskArr);
                });
                
            } failure:^(NSURLSessionDownloadTask *dataTask, NSError *error) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"download errorcode********* %ld",(long)error.code);
                   
                    if (error.code == -1011) { // url不存在
                         [AppD.window showHint:@"File does not exist."];
                        [FileData bg_deleteAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(fileModel.srcKey)] complete:^(BOOL isSuccess) {
                             [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:nil];
                        }];
                    } else {
                        // 保存下载失败记录
                        fileDataModel.status = 3;
                        fileDataModel.progess = 0.0f;
                        [fileDataModel bg_saveOrUpdateAsync:nil];
                        [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Faield_Noti object:fileDataModel];
                    }
                    [weakSelf.taskArr removeObject:fileDataModel];
                    NSLog(@"下载列表：%@",weakSelf.taskArr);
                });
            }];
            
            fileDataModel.downloadTask = task;
            [self.taskArr addObject:fileDataModel];
            NSLog(@"下载列表：%@",self.taskArr);
            if (downloadTaskB) {
                downloadTaskB(task);
            }
        }
    }];
}
- (void) removeAllTask
{
    [self.taskArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FileData *fileModel = obj;
        if (fileModel.downloadTask) {
            [fileModel.downloadTask cancel];
        }
    }];
}

- (NSURLSessionDownloadTask *)getDownloadTask:(FileData *)fileDataM {
    __block NSURLSessionDownloadTask *downloadTask = nil;
    [self.taskArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FileData *tempFileData = obj;
        if ([tempFileData.srcKey isEqualToString:fileDataM.srcKey] && fileDataM.msgId == tempFileData.msgId) {
            downloadTask = tempFileData.downloadTask;
            *stop = YES;
        }
    }];
    
    return downloadTask;
}

- (void) toxDownFileModel:(FileListModel *) fileModel
{
    NSString *filePath = fileModel.FilePath;
    NSString *fileNameBase58 = fileModel.FileName?:@"";
    NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58]?:@"";
    
    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"msgId"),bg_sqlValue(fileModel.MsgId)] complete:^(NSArray * _Nullable array) {
        
        NSLog(@"写入数据库");
        FileData *fileDataModel = nil;
        if (array && array.count > 0) {
            fileDataModel = array[0];
        } else {
            fileDataModel = [[FileData alloc] init];
            long tempMsgid = [SocketCountUtil getShareObject].fileIDCount++;
            tempMsgid = [NSDate getTimestampFromDate:[NSDate date]]+tempMsgid;
            fileDataModel.fileId = tempMsgid;
            fileDataModel.bg_tableName = FILE_STATUS_TABNAME;
        }
        fileDataModel.fileSize = [fileModel.FileSize intValue];
        fileDataModel.fileType = [fileModel.FileType intValue];
        fileDataModel.msgId = [fileModel.MsgId intValue];
        fileDataModel.progess = 0.0f;
        fileDataModel.didStart = 0;
        fileDataModel.fileName = fileName;
        fileDataModel.filePath = filePath;
        fileDataModel.fileFrom = fileModel.FileFrom;
        fileDataModel.fileOptionType = 2;
        fileDataModel.status = 2;
        NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
        fileDataModel.optionTime = [formatter stringFromDate:[NSDate date]];
        fileDataModel.userId = [UserConfig getShareObject].userId;
        fileDataModel.srcKey = fileModel.UserKey;
        [fileDataModel bg_saveOrUpdate];
        
        
        NSString *fileOwer = [NSString stringWithFormat:@"%d",fileModel.FileFrom];
        self->isTaskFile = YES;
        [SendRequestUtil sendToxPullFileWithFromId:[UserConfig getShareObject].userId toid:[UserConfig getShareObject].userId fileName:fileModel.FileName filePath:fileModel.FilePath msgId:[NSString stringWithFormat:@"%@",fileModel.MsgId ] fileOwer:fileOwer fileFrom:@"2"];
    }];
    
   
    
}

- (void) deToxDownFileModel:(FileData *) fileModel
{
    NSString *filePath = fileModel.filePath;
    NSString *fileName = fileModel.fileName;
    
    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"msgId"),bg_sqlValue(@(fileModel.msgId))] complete:^(NSArray * _Nullable array) {
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"写入数据库");
            FileData *fileDataModel = nil;
            if (array && array.count > 0) {
                fileDataModel = array[0];
                fileDataModel.fileSize = fileModel.fileSize;
                fileDataModel.fileType = fileModel.fileType;
                fileDataModel.didStart = 0;
                fileDataModel.msgId = fileModel.msgId;
                fileDataModel.progess = 0.0f;
                fileDataModel.fileName = fileName;
                fileDataModel.filePath = filePath;
                fileDataModel.fileOptionType = 2;
                fileDataModel.status = 2;
                NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
                fileDataModel.optionTime = [formatter stringFromDate:[NSDate date]];
                fileDataModel.userId = [UserConfig getShareObject].userId;
                fileDataModel.srcKey = fileModel.srcKey;
                [fileDataModel bg_saveOrUpdate];
                
                NSString *fileOwer = [NSString stringWithFormat:@"%d",fileModel.fileFrom];
                self->isTaskFile = YES;
                [SendRequestUtil sendToxPullFileWithFromId:[UserConfig getShareObject].userId toid:[UserConfig getShareObject].userId fileName:[Base58Util Base58EncodeWithCodeName:fileName] filePath:filePath msgId:[NSString stringWithFormat:@"%d",fileModel.msgId ] fileOwer:fileOwer fileFrom:@"2"];
                
            }
            
            
        });
        
    }];

    
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
    if (fileModel.RetCode != 0) { // 下载失败 删除文件
        // 保存下载失败记录
        [AppD.window showHint:@"File does not exist."];
        [FileData bg_deleteAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"msgId"),bg_sqlValue(fileModel.MsgId)] complete:^(BOOL isSuccess) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:nil];
        }];
        
         [[NSNotificationCenter defaultCenter] postNotificationName:TOX_PULL_FILE_FAIELD_NOTI object:fileModel.MsgId];
    }
}


+ (void)downloadFileWithFileModel:(FileListModel *)fileModel {
    if ([SystemUtil isSocketConnect]) {
        [[FileDownUtil getShareObject] downFileWithFileModel:fileModel progressBlock:^(CGFloat progress) {
        } success:^(NSURLSessionDownloadTask * _Nonnull dataTask, NSString * _Nonnull filePath) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [AppD.window showHint:@"Download Success"];
            });
        } failure:^(NSURLSessionDownloadTask * _Nonnull dataTask, NSError * _Nonnull error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@     %@   %@",error.localizedDescription, error.domain,@(error.code));
                if (error.code == -999) {
                    [AppD.window showHint:@"Download Cancel"];
                } else if (error.code == -1011) { // url不存在
                    [AppD.window showHint:@"File does not exist."];
                } else {
                    [AppD.window showHint:@"Download Fail"];
                }
            });
            
        } downloadTaskB:^(NSURLSessionDownloadTask * _Nonnull downloadTask) {
        }];
    } else {
        [[FileDownUtil getShareObject] toxDownFileModel:fileModel];
    }
}





#pragma mark -  tox下载通知
- (void) downFileFaieldNoti:(NSNotification *)noti {
    int msgid = [noti.object intValue];
    
    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"msgId"),bg_sqlValue(@(msgid))] complete:^(NSArray * _Nullable array) {
        if (array && array.count > 0) {
            FileData *fileModel = array[0];
            
            fileModel.progess = 0.0;
            fileModel.fileData = [NSData data];
            [fileModel bg_saveOrUpdateAsync:^(BOOL isSuccess) {
               
            }];
            if (fileModel.status != 3) {
                fileModel.status = 3;
                [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Faield_Noti object:fileModel];
            }
           
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
            fileModel.fileData = [NSData data];
            [fileModel bg_saveOrUpdateAsync:^(BOOL isSuccess) {
                [[NSNotificationCenter defaultCenter] postNotificationName:File_Upload_Finsh_Noti object:nil];
            }];
        }
    }];
}

@end
