//
//  FileListCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/4/4.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "FileListCell.h"
#import "FileListModel.h"
#import "PNRouter-Swift.h"
#import "SystemUtil.h"

@implementation FileListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void) setFileModel:(FileListModel *) model
{
    NSString *lastPath = model.FileName?:@"";
    _lblFileName.text = [Base58Util Base58DecodeWithCodeName:lastPath];
    _lblFileSize.text = [SystemUtil transformedValue:[model.FileSize floatValue]];
    
    NSString *fileTypeImgName = @"";
    switch ([model.FileType intValue]) {
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
    _fileIconImgV.image = [UIImage imageNamed:fileTypeImgName];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
