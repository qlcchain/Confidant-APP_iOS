//
//  TaskCompletedCell.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "TaskCompletedCell.h"
#import "FileData.h"
#import "PNFileModel.h"

@implementation TaskCompletedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)selectAction:(id)sender {
    
    if (_selectBlock) {
        _selectBlock(@[_srcKey,@(_fileId),@(1)]);
    }
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
    self.srcKey = model.FKey;
    self.fileId = model.fId;
    
    if (isSelect) {
        _selectImgView.image = [UIImage imageNamed:@"icon_selectmsg"];
    } else {
        _selectImgView.image = [UIImage imageNamed:@"icon_unselectmsg"];
    }
    
    _lblTitle.text = model.Fname;
    _lblDesc.text = @"Upload to: Router";
    _iconImgView.image = [UIImage imageNamed:@"icon_upload_small_gray"];
    
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
}




- (void) setFileModel:(FileData *) model isSelect:(BOOL)isSelect
{
    self.srcKey = model.srcKey;
    self.fileId = model.fileId;
    
    if (isSelect) {
        _selectImgView.image = [UIImage imageNamed:@"icon_selectmsg"];
    } else {
        _selectImgView.image = [UIImage imageNamed:@"icon_unselectmsg"];
    }
    
    _lblTitle.text = model.fileName;
    if (model.fileOptionType == 1) {
        _lblDesc.text = @"Upload to: Router";
        _iconImgView.image = [UIImage imageNamed:@"icon_upload_small_gray"];
    } else {
        _lblDesc.text = @"Download to: Local";
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
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
