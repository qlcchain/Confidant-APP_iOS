//
//  FileDownUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/1/26.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FileListModel;
@class FileData;
@class FileModel;

NS_ASSUME_NONNULL_BEGIN

@interface FileDownUtil : NSObject

+ (instancetype) getShareObject;
- (void) downFileWithFileModel:(FileListModel *) fileModel  progressBlock:(void(^)(CGFloat progress)) progressBlock
                success:(void (^)(NSURLSessionDownloadTask *dataTask, NSString *filePath)) success
                       failure:(void (^)(NSURLSessionDownloadTask *dataTask, NSError *error))failure
                downloadTaskB:(void (^)(NSURLSessionDownloadTask *downloadTask))downloadTaskB;
- (void) deDownFileWithFileModel:(FileData *) fileModel  progressBlock:(void(^)(CGFloat progress)) progressBlock
                       success:(void (^)(NSURLSessionDownloadTask *dataTask, NSString *filePath)) success
                       failure:(void (^)(NSURLSessionDownloadTask *dataTask, NSError *error))failure
                   downloadTaskB:(void (^)(NSURLSessionDownloadTask *downloadTask))downloadTaskB;

- (NSURLSessionDownloadTask *)getDownloadTask:(FileData *)fileDataM;

- (void) toxDownFileModel:(FileListModel *) fileModel;
- (BOOL) isTaskFileOption;
- (void) setTaskFile:(BOOL) isFile;
- (void) updateFileDataBaseWithFileModel:(FileModel *) fileModel;
- (void) deToxDownFileModel:(FileData *) fileModel;
- (void) removeAllTask;
- (void) cancelDownWithFileid:(NSInteger) fileid srckey:(NSString *) srckey;
+ (void)downloadFileWithFileModel:(FileListModel *)fileModel;

@end

NS_ASSUME_NONNULL_END
