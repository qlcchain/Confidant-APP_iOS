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
#import "MyConfidant-Swift.h"
#import "MD5Util.h"
#import "NSDateFormatter+Category.h"
#import "ChatListDataUtil.h"
#import "PNFileModel.h"
#import "NSDate+Category.h"

@interface TaskOngoingCell ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftContraintW;
@property (weak, nonatomic) IBOutlet UIImageView *selectImgView;

@end

@implementation TaskOngoingCell
- (IBAction)selectAction:(id)sender {
    
    if (_selectBlock) {
        _selectBlock(@[_fileModel.srcKey,@(_fileModel.fileId),@(2),@(_fileModel.fileOptionType),_fileModel.fileName,@(_fileModel.msgId)]);
    }
}

// 重新上传文件
- (void) deUploadFile
{
    if ([SystemUtil isSocketConnect]) { // 是socket
        SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
        dataUtil.srcKey = self.fileModel.srcKey;
        dataUtil.fileid = [NSString stringWithFormat:@"%ld",(long)self.fileModel.fileId];
        [dataUtil sendFileId:@"" fileName:self.fileModel.fileName fileData:self.fileModel.fileData fileid:self.fileModel.fileId fileType:self.fileModel.fileType messageid:@"" srcKey:self.fileModel.srcKey dstKey:@"" isGroup:NO];
        [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
    } else { // tox
        NSString *fileMd5 = @"";
        NSString *filePath = self.fileModel.filePath;
        if ([SystemUtil filePathisExist:self.fileModel.filePath]) {
            fileMd5 = [MD5Util md5WithPath:self.fileModel.filePath];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":[UserConfig getShareObject].userId,@"ToId":@"",@"FileName":[Base58Util Base58EncodeWithCodeName:self.fileModel.fileName],@"FileMD5":[MD5Util md5WithPath:filePath],@"FileSize":@(self.fileModel.fileSize),@"FileType":@(self.fileModel.fileType),@"SrcKey":self.fileModel.srcKey,@"DstKey":@"",@"FileId":@(self.fileModel.fileId)};
                [SendToxRequestUtil deUploadFileWithFilePath:filePath parames:parames fileData:self.fileModel.fileData];
            });
            
        } else {
            filePath = [[SystemUtil getTempUploadVideoBaseFilePath] stringByAppendingPathComponent:self.fileModel.fileName];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                BOOL isSuccess = [self.fileModel.fileData writeToFile:filePath atomically:YES];
                if (isSuccess) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":[UserConfig getShareObject].userId,@"ToId":@"",@"FileName":[Base58Util Base58EncodeWithCodeName:self.fileModel.fileName],@"FileMD5":[MD5Util md5WithPath:filePath],@"FileSize":@(self.fileModel.fileSize),@"FileType":@(self.fileModel.fileType),@"SrcKey":self.fileModel.srcKey,@"DstKey":@"",@"FileId":@(self.fileModel.fileId)};
                        [SendToxRequestUtil deUploadFileWithFilePath:filePath parames:parames fileData:self.fileModel.fileData];
                    });
                }
            });
        }
    }
}
// 取消上传
- (void) cancelUploadFile
{
    _progess.progress = 0;
    if ([SystemUtil isSocketConnect]) {
        [[SocketManageUtil getShareObject] cancelFileOptionWithSrcKey:self.fileModel.srcKey fileid:self.fileModel.fileId];
    } else {
        [SendToxRequestUtil cancelToxFileUploadWithFileid:[NSString stringWithFormat:@"%ld",(long)self.fileModel.fileId]];
    }
}
// 取消相册文件上传
- (void) cancelPhotoUploadFile
{
    _progess.progress = 0;
    if ([SystemUtil isSocketConnect]) {
        [[SocketManageUtil getShareObject] cancelFileOptionWithSrcKey:self.fileM.FKey fileid:self.fileM.fId];
    }
}
// 重新下载
- (void) deDownFile
{
    if ([SystemUtil isSocketConnect]) {
        [[FileDownUtil getShareObject] deDownFileWithFileModel:self.fileModel progressBlock:^(CGFloat progress) {
        } success:^(NSURLSessionDownloadTask * _Nonnull dataTask, NSString * _Nonnull filePath) {
        } failure:^(NSURLSessionDownloadTask * _Nonnull dataTask, NSError * _Nonnull error) {
        } downloadTaskB:^(NSURLSessionDownloadTask * _Nonnull downloadTask) {
            dispatch_async(dispatch_get_main_queue(), ^{
                
            });
        }];
    } else {
         [[FileDownUtil getShareObject] deToxDownFileModel:self.fileModel];
    }
}
// 取消下载
- (void) cancelFileDown
{
    if ([SystemUtil isSocketConnect]) {
        NSURLSessionDownloadTask *downTask = [[FileDownUtil getShareObject] getDownloadTask:_fileModel];
        [downTask cancel];
    } else {
        [SendToxRequestUtil cancelToxFileDownWithMsgid:[NSString stringWithFormat:@"%ld",(long)self.fileModel.msgId]];
    }
}

- (IBAction)optionAction:(UIButton *)sender {
    
    // 相册上传
    sender.userInteractionEnabled = NO;
    if (self.fileM.uploadStatus == 1) { // 取消
        self.fileM.uploadStatus = -1;
        self.fileM.progressV = 0;
        
        _lblProgess.text = @"";
        _progess.progress = 0;
        [sender setImage:[UIImage imageNamed:@"noun_play_b"] forState:UIControlStateNormal];
        // 取消文件上传
        [self cancelPhotoUploadFile];
        sender.userInteractionEnabled = YES;
    } else { // 重新上传
        self.fileM.uploadStatus = 1;
        self.fileM.LastModify = [NSDate getTimestampFromDate:[NSDate date]];
        [sender setImage:[UIImage imageNamed:@"noun_pause_a"] forState:UIControlStateNormal];
        _lblProgess.text = @"0 KB/s";
        // 开始文件上传
        [self performSelector:@selector(uploadNodeWithFloderId:) withObject:@(self.fileM.toFloderId) afterDelay:0.5];
        
    }
    
    
    /*
    // 更新下载时间
    NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
    self.fileModel.optionTime = [formatter stringFromDate:[NSDate date]];

    if (self.fileModel.status == 3) {
        
        self.fileModel.status = 2;
        self.fileModel.speedSize = 0;
        self.fileModel.progess = 0;
        if (![SystemUtil isSocketConnect]) {
             self.optionBtn.hidden = YES;
        }
       
         _progess.progress = 0;
        [_optionBtn setImage:[UIImage imageNamed:@"icon_stop_gray"] forState:UIControlStateNormal];
        
    } else {
        self.fileModel.status = 3;
        self.fileModel.speedSize = 0;
        self.fileModel.progess = 0;
         _progess.progress = 0;
        [_optionBtn setImage:[UIImage imageNamed:@"icon_continue_gray"] forState:UIControlStateNormal];
        _lblProgess.text = @"0 KB/s";
    }
    self.fileModel.backSeconds = 0;
    // 更新数据库
    [FileData bg_update:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"set %@=%@,%@=%@,%@=%@ where %@=%@ and %@=%@",bg_sqlKey(@"status"),bg_sqlValue(@(self.fileModel.status)),bg_sqlKey(@"speedSize"),bg_sqlValue(@(0)),bg_sqlKey(@"backSeconds"),bg_sqlValue(@(0)),bg_sqlKey(@"fileId"),bg_sqlValue(@(self.fileModel.fileId)),bg_sqlKey(@"srcKey"),bg_sqlValue(self.fileModel.srcKey)]];
   
    
    if (self.fileModel.fileOptionType == 1) { // 上传
        if (self.fileModel.status == 2) { // 开始上传
            
            if (!self.fileModel.fileData || self.fileModel.fileData.length == 0) {
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSString *sql  = [NSString stringWithFormat:@"select %@ from %@ where %@=%@ and %@=%@",bg_sqlKey(@"fileData"),FILE_STATUS_TABNAME,bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(self.fileModel.srcKey)];
                    
                    NSArray *results = bg_executeSql(sql, FILE_STATUS_TABNAME,[FileData class]);
                    if (results && results.count > 0) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            FileData *resultModel = results[0];
                            if (!resultModel.fileData || resultModel.fileData.length == 0) {
                                
                            } else {
                                self.fileModel.fileData = resultModel.fileData;
                                [self deUploadFile];
                            }
                           
                        });
                    }
                    
                });
            } else {
                [self deUploadFile];
            }
        } else { // 取消上传
            [self cancelUploadFile];
        }
    } else { // 下载
        if (self.fileModel.status == 2) { // 开始下载
            [self deDownFile];
        } else { // 取消下载
            [self cancelFileDown];
        }
    }
     */
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void) updateSelectShow:(BOOL) isShow
{
    if (isShow) {
        _leftContraintW.constant = 54;
    } else {
        _leftContraintW.constant = 16;
    }
}

- (void) setPhotoFileModel:(PNFileModel *) model isSelect:(BOOL) isSelect
{
    self.fileM = model;
    if (isSelect) {
        _selectImgView.image = [UIImage imageNamed:@"icon_selectmsg"];
    } else {
        _selectImgView.image = [UIImage imageNamed:@"icon_unselectmsg"];
    }
   
    _lblTitle.text = model.Fname;
    _lblSize.text = [SystemUtil transformedValue:model.Size];
    _iconImgView.image = [UIImage imageNamed:@"icon_upload_small_gray"];
    
    if (model.uploadStatus == 1) {
        if (self.fileM.progressV > 0) {
            NSInteger downSize = self.fileM.Size*self.fileM.progressV;
            NSInteger secons = [NSDate getTimestampFromDate:[NSDate date]] - self.fileM.LastModify;
            _lblProgess.text = [[SystemUtil transformedZSValue:downSize/secons] stringByAppendingString:@"/s"];
        } else {
            _lblProgess.text = @"0 KB/s";
        }
        
        [_optionBtn setImage:[UIImage imageNamed:@"noun_pause_a"] forState:UIControlStateNormal];
    } else {
        _lblProgess.text = @"";
        [_optionBtn setImage:[UIImage imageNamed:@"noun_play_b"] forState:UIControlStateNormal];
    }
   
    NSString *fileTypeImgName = @"";
    switch (model.Type) {
        case 1:
            fileTypeImgName = @"jpg";
            break;
        case 4:
            fileTypeImgName = @"mp4";
            break;
        default:
            fileTypeImgName = @"other";
            break;
    }
    _fileImgView.image = [UIImage imageNamed:fileTypeImgName];
    _progess.progress = model.progressV;
}








- (void) setFileModel:(FileData *) model isSelect:(BOOL)isSelect
{
    self.fileModel = model;
    if (isSelect) {
        _selectImgView.image = [UIImage imageNamed:@"icon_selectmsg"];
    } else {
        _selectImgView.image = [UIImage imageNamed:@"icon_unselectmsg"];
    }
    if (model.status == 2) {
        [_optionBtn setImage:[UIImage imageNamed:@"icon_stop_gray"] forState:UIControlStateNormal];
        if (model.speedSize == 0) {
            _lblProgess.text = @"0 KB/s";
        } else {
            _lblProgess.text = [[SystemUtil transformedZSValue:model.speedSize] stringByAppendingString:@"/s"];
        }
        if (![SystemUtil isSocketConnect]) {
            if (model.didStart == 0) {
                _optionBtn.hidden = YES;
            } else {
                _optionBtn.hidden = NO;
            }
        }
        
        
    } else {
        [_optionBtn setImage:[UIImage imageNamed:@"icon_continue_gray"] forState:UIControlStateNormal];
        _lblProgess.text = @"0 KB/s";
       // _optionBtn.userInteractionEnabled = YES;
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

- (void) uploadNodeWithFloderId:(NSInteger) floderId
{
    NSString *fileName = self.fileM.Fname;
    if (!self.fileM.fileData) {
    
        NSString *sql  = [NSString stringWithFormat:@"select %@ from %@ where %@=%@",bg_sqlKey(@"fileData"),EN_FILE_TABNAME,bg_sqlKey(@"fId"),bg_sqlValue(@(self.fileM.fId))];
        NSArray *results = bg_executeSql(sql, EN_FILE_TABNAME,[PNFileModel class]);
    
        if (results && results.count > 0) {
            PNFileModel *fileModel = results[0];
            self.fileM.fileData = fileModel.fileData;
        
        }
    }
    NSData *fileData = self.fileM.fileData;
    int fileType = (int)self.fileM.Type;
    
    if ([SystemUtil isSocketConnect]) { // socket
        SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
        dataUtil.srcKey = self.fileM.FKey;
        dataUtil.fileid = [NSString stringWithFormat:@"%ld",(long)self.fileM.fId];
        dataUtil.isPhoto = YES;
        dataUtil.floderId = floderId;
        NSString *fileNameInfo = @"";
        if (self.fileM.Finfo.length > 0) {
            fileNameInfo = [NSString stringWithFormat:@"%@,%@",fileName,self.fileM.Finfo];
        } else {
            fileNameInfo = fileName;
        }
        [dataUtil sendFileId:@"" fileName:fileNameInfo fileData:fileData fileid:self.fileM.fId fileType:fileType messageid:@"" srcKey:self.fileM.FKey dstKey:@"" isGroup:NO];
        [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
                   
    }
    _optionBtn.userInteractionEnabled = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
