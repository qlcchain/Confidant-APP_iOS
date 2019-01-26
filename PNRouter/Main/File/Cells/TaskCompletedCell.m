//
//  TaskCompletedCell.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "TaskCompletedCell.h"
#import "FileData.h"

@implementation TaskCompletedCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void) setFileModel:(FileData *) model
{
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
