//
//  TaskOngoingCell.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "TaskOngoingCell.h"
#import "FileData.h"
#import "SystemUtil.h"
#import "SocketDataUtil.h"
#import "SocketManageUtil.h"
#import "FileDownUtil.h"
#import "UploadFileManager.h"
#import "UserConfig.h"
#import "PNRouter-Swift.h"
#import "MD5Util.h"
#import "NSDateFormatter+Category.h"

@interface TaskOngoingCell ()

@end

@implementation TaskOngoingCell

// 重新上传文件
- (void) deUploadFile
{
    if ([SystemUtil isSocketConnect]) { // 是socket
        SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
        dataUtil.srcKey = self.fileModel.srcKey;
        dataUtil.fileid = [NSString stringWithFormat:@"%d",self.fileModel.fileId];
        [dataUtil sendFileId:@"" fileName:self.fileModel.fileName fileData:self.fileModel.fileData fileid:self.fileModel.fileId fileType:self.fileModel.fileType messageid:@"" srcKey:self.fileModel.srcKey dstKey:@""];
        [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
    } else { // tox
        NSString *fileMd5 = @"";
        NSString *filePath = self.fileModel.filePath;
        if ([SystemUtil filePathisExist:self.fileModel.filePath]) {
            fileMd5 = [MD5Util md5WithPath:self.fileModel.filePath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":[UserConfig getShareObject].userId,@"ToId":@"",@"FileName":[Base58Util Base58EncodeWithCodeName:self.fileModel.fileName],@"FileMD5":[MD5Util md5WithPath:filePath],@"FileSize":@(self.fileModel.fileSize),@"FileType":@(self.fileModel.fileType),@"SrcKey":self.fileModel.srcKey,@"DstKey":@"",@"FileId":@(self.fileModel.fileId)};
                [SendToxRequestUtil uploadFileWithFilePath:filePath parames:parames fileData:self.fileModel.fileData];
            });
            
        } else {
            filePath = [[SystemUtil getTempUploadVideoBaseFilePath] stringByAppendingPathComponent:self.fileModel.fileName];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                BOOL isSuccess = [self.fileModel.fileData writeToFile:filePath atomically:YES];
                if (isSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":[UserConfig getShareObject].userId,@"ToId":@"",@"FileName":[Base58Util Base58EncodeWithCodeName:self.fileModel.fileName],@"FileMD5":[MD5Util md5WithPath:filePath],@"FileSize":@(self.fileModel.fileSize),@"FileType":@(self.fileModel.fileType),@"SrcKey":self.fileModel.srcKey,@"DstKey":@"",@"FileId":@(self.fileModel.fileId)};
                        [SendToxRequestUtil uploadFileWithFilePath:filePath parames:parames fileData:self.fileModel.fileData];
                    });
                }
            });
        }
    }
}

- (IBAction)optionAction:(id)sender {
    
   
    // 更新下载时间
    NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
    self.fileModel.optionTime = [formatter stringFromDate:[NSDate date]];
    
    
    [_optionBtn setImage:[UIImage imageNamed:@"icon_stop_gray"] forState:UIControlStateNormal];
    self.fileModel.status = 2;
    _optionBtn.userInteractionEnabled = NO;
    
    if (self.fileModel.fileOptionType == 1) { // 上传
        
        if (!self.fileModel.fileData || self.fileModel.fileData.length == 0) {
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSString *sql  = [NSString stringWithFormat:@"select %@ from %@ where %@=%@ and %@=%@",bg_sqlKey(@"fileData"),FILE_STATUS_TABNAME,bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(self.fileModel.srcKey)];
                
                NSArray *results = bg_executeSql(sql, FILE_STATUS_TABNAME,[FileData class]);
                if (results && results.count > 0) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        FileData *resultModel = results[0];
                        self.fileModel.fileData = resultModel.fileData;
                        [self deUploadFile];
                    });
                }
                
            });
        } else {
            [self deUploadFile];
        }
        
        
    } else { // 下载
         if ([SystemUtil isSocketConnect]) { // 是socket
             
             if (_fileModel.status == 5) { // 如果下载中 停止下载
                 NSURLSessionDownloadTask *downloadTask = [[FileDownUtil getShareObject] getDownloadTask:_fileModel];
                 if (downloadTask) {
                     [downloadTask cancel];
                 }
             } else { // 未下载 则开始下载
//                 @weakify_self
                 [[FileDownUtil getShareObject] deDownFileWithFileModel:self.fileModel progressBlock:^(CGFloat progress) {
                 } success:^(NSURLSessionDownloadTask * _Nonnull dataTask, NSString * _Nonnull filePath) {
                 } failure:^(NSURLSessionDownloadTask * _Nonnull dataTask, NSError * _Nonnull error) {
                 } downloadTaskB:^(NSURLSessionDownloadTask * _Nonnull downloadTask) {
                     dispatch_async(dispatch_get_main_queue(), ^{
//                         weakSelf.downloadTask = downloadTask;
                     });
                 }];
             }
             
         } else { // tox
              [[FileDownUtil getShareObject] deToxDownFileModel:self.fileModel];
         }
        
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void) setFileModel:(FileData *) model
{
    _fileModel = model;
    if (model.status == 2) {
        [_optionBtn setImage:[UIImage imageNamed:@"icon_stop_gray"] forState:UIControlStateNormal];
       _lblProgess.text = [[SystemUtil transformedZSValue:model.speedSize] stringByAppendingString:@"/s"];
        _optionBtn.userInteractionEnabled = NO;
    } else {
        [_optionBtn setImage:[UIImage imageNamed:@"icon_continue_gray"] forState:UIControlStateNormal];
        _lblProgess.text = @"0 KB/s";
        _optionBtn.userInteractionEnabled = YES;
    }
    _lblTitle.text = model.fileName;
    _lblSize.text = [SystemUtil transformedValue:model.fileSize];//[NSString stringWithFormat:@"%d kb",model.fileSize/1024];
    if (model.fileOptionType == 1) {
      
        _iconImgView.image = [UIImage imageNamed:@"icon_upload_small_gray"];
    } else {
        _iconImgView.image = [UIImage imageNamed:@"icon_download_small_gray"];
    }
    NSString *fileTypeImgName = @"";
    switch (model.fileType) {
        case 1:
            fileTypeImgName = @"icon_picture_small_gray";
            break;
        case 2:
            fileTypeImgName = @"icon_video_small_gray";
            break;
        case 4:
            fileTypeImgName = @"icon_video_small_gray";
            break;
        case 5:
            fileTypeImgName = @"icon_document_small_gray";
            break;
            
        default:
            fileTypeImgName = @"icon_other_small_gray";
            break;
    }
    _fileImgView.image = [UIImage imageNamed:fileTypeImgName];
    _progess.progress = model.progess;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
