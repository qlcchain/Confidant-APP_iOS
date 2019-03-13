//
//  FileData.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/1/26.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "BBaseModel.h"
#import <BGFMDB/BGFMDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileData : BBaseModel

@property (nonatomic ,assign) int msgId;
@property (nonatomic ,assign) NSInteger fileId;
@property (nonatomic ,assign) int fileFrom;
@property (nonatomic ,assign) int backSeconds;
@property (nonatomic ,strong) NSString *userId;
@property (nonatomic ,strong) NSString *toId;
@property (nonatomic ,strong) NSString *fileName;
@property (nonatomic ,strong) NSString *filePath;
@property (nonatomic ,assign) CGFloat progess;
@property (nonatomic ,assign) int speedSize;
@property (nonatomic ,strong) NSString *srcKey;
@property (nonatomic ,strong) NSString *optionTime;
@property (nonatomic ,strong ,nullable) NSData *fileData;
@property (nonatomic ,assign) int fileSize;
@property (nonatomic ,assign) int status; // 1:完成 2:正在上传 3:上传失败
@property (nonatomic ,assign) int fileType;
@property (nonatomic ,assign) int fileOptionType; // 1:上传 2:下载
@property (nonatomic ,assign) int didStart;

@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
@property (nonatomic, strong) NSString *downSavePath;

@end

NS_ASSUME_NONNULL_END
