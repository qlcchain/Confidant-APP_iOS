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

@implementation TaskOngoingCell

- (IBAction)optionAction:(id)sender {
    
    [UploadFileManager getShareObject];
    
    [_optionBtn setImage:[UIImage imageNamed:@"icon_continue_gray"] forState:UIControlStateNormal];
    _optionBtn.userInteractionEnabled = NO;
    if (self.fileModel.fileOptionType == 1) { // 上传
        if ([SystemUtil isSocketConnect]) { // 是socket
            SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
            dataUtil.srcKey = self.fileModel.srcKey;
            dataUtil.fileid = [NSString stringWithFormat:@"%d",self.fileModel.fileId];
            [dataUtil sendFileId:@"" fileName:self.fileModel.fileName fileData:self.fileModel.fileData fileid:self.fileModel.fileId fileType:self.fileModel.fileType messageid:@"" srcKey:self.fileModel.srcKey dstKey:@""];
            [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
        } else { // tox
            
        }
    } else { // 下载
         if ([SystemUtil isSocketConnect]) { // 是socket
             [[FileDownUtil getShareObject] deDownFileWithFileModel:self.fileModel progressBlock:^(CGFloat progress) {
             } success:^(NSURLSessionDownloadTask * _Nonnull dataTask, NSString * _Nonnull filePath) {
             } failure:^(NSURLSessionDownloadTask * _Nonnull dataTask, NSError * _Nonnull error) {
             }];
         } else { // tox
             
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
        [_optionBtn setImage:[UIImage imageNamed:@"icon_continue_gray"] forState:UIControlStateNormal];
        _optionBtn.userInteractionEnabled = NO;
    } else {
        [_optionBtn setImage:[UIImage imageNamed:@"icon_suspend_gray"] forState:UIControlStateNormal];
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
