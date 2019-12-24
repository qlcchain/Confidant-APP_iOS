//
//  UploadFileCell.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "UploadFileCell.h"
#import "PNFileModel.h"
#import "SystemUtil.h"
#import "NSDate+Category.h"
#import "MyConfidant-Swift.h"
#import "UIImage+Resize.h"

@implementation UploadFileCell
- (IBAction)clickOptionAction:(id)sender {
    if (_optionBlock) {
        _optionBlock(self.fileModel,self.tag);
    }
}
- (void) setFileM:(PNFileModel *) fileModel isLocal:(BOOL)isLocal floderId:(NSInteger)floderId
{
    self.fileModel = fileModel;
    _lblDesc.text = [NSString stringWithFormat:@"%@, %@",[NSDate formattedUploadFileTimeFromTimeInterval:fileModel.LastModify],[SystemUtil transformedValue:fileModel.Size]];
    if (fileModel.Type == 1) {
        if (isLocal) {
            if (fileModel.smallData) {
                _typeImgView.image = [UIImage imageWithData:fileModel.smallData];
            } else {
                _typeImgView.image = [UIImage imageNamed:@"jpg"];
            }
        } else {
            NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileModel.Fname];
            NSString *lastTypeStr = [[fileName componentsSeparatedByString:@"."] lastObject];
            NSString *deFilePath = [SystemUtil getPhotoTempDeFloderId:[NSString stringWithFormat:@"%ld",floderId] fid:[NSString stringWithFormat:@"%ld.%@",fileModel.fId,lastTypeStr]];
            
            if ([SystemUtil filePathisExist:deFilePath] && !fileModel.smallData) {
                @weakify_self
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSData *fileData = [NSData dataWithContentsOfFile:deFilePath];
                    UIImage *fileImg = [UIImage imageWithData:fileData];
                    fileData = [fileImg compressWithMaxLength:10*1024];
                    if (fileData) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            fileModel.smallData = fileData;
                            weakSelf.typeImgView.image = [UIImage imageWithData:fileData];
                        });
                    }
                });
            } else if (fileModel.smallData) {
                 _typeImgView.image = [UIImage imageWithData:fileModel.smallData];
            }else {
                _typeImgView.image = [UIImage imageNamed:@"jpg"];
            }
        }
        
    } else if (fileModel.Type == 4) {
        if (isLocal) {
            if (fileModel.smallData) {
                _typeImgView.image = [UIImage imageWithData:fileModel.smallData];
            } else {
                _typeImgView.image = [UIImage imageNamed:@"mp4"];
            }
        } else {
            
            NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileModel.Fname];
            NSString *lastTypeStr = [[fileName componentsSeparatedByString:@"."] lastObject];
            NSString *deFilePath = [SystemUtil getPhotoTempDeFloderId:[NSString stringWithFormat:@"%ld",floderId] fid:[NSString stringWithFormat:@"%ld.%@",fileModel.fId,lastTypeStr]];
            
            if ([SystemUtil filePathisExist:deFilePath] && !fileModel.smallData) {
                @weakify_self
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    NSData *fileData = [NSData dataWithContentsOfFile:deFilePath];
                    UIImage *fileImg = [SystemUtil thumbnailImageForVideo:[NSURL fileURLWithPath:deFilePath]];
                    fileData = [fileImg compressWithMaxLength:10*1024];
                    if (fileImg) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            fileModel.smallData = fileData;
                            weakSelf.typeImgView.image = [UIImage imageWithData:fileData];
                        });
                    }
                });
            } else if (fileModel.smallData) {
                 _typeImgView.image = [UIImage imageWithData:fileModel.smallData];
            }else {
                _typeImgView.image = [UIImage imageNamed:@"mp4"];
            }
        }
        
    } else {
        NSString *fileType = [[fileModel.Fname componentsSeparatedByString:@"."] lastObject];
        UIImage *typeImg = [UIImage imageNamed:[fileType lowercaseString]];
        if (typeImg) {
            _typeImgView.image = typeImg;
        } else {
            _typeImgView.image = [UIImage imageNamed:@"other"];
        }
        
    }
    _nodeImgView.hidden = YES;
    _optionBtn.enabled = YES;
    if (isLocal) {
        _lblName.text = fileModel.Fname;
        if (fileModel.uploadStatus == 2) {
            _nodeImgView.hidden = NO;
        }
        if (fileModel.uploadStatus == 1) {
            _progress.progress = fileModel.progressV;
            _optionBtn.enabled = NO;
            [_optionBtn setImage:[UIImage imageNamed:@"noun_pause_a"] forState:UIControlStateNormal];
        } else {
            _progress.progress = 0;
            [_optionBtn setImage:[UIImage imageNamed:@"statusbar_hedo"] forState:UIControlStateNormal];
        }
    } else {
        _lblName.text = [Base58Util Base58DecodeWithCodeName:fileModel.Fname];
        [_optionBtn setImage:[UIImage imageNamed:@"statusbar_hedo"] forState:UIControlStateNormal];
        _progress.progress = 0;
    }
    
}

/**
 if (fileModel.uploadStatus <= 0) {
          _progress.progress = 0;
          [_optionBtn setImage:[UIImage imageNamed:@"statusbar_hedo"] forState:UIControlStateNormal];
      } else
 */

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
