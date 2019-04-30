//
//  MyFilesCell.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "MyFilesCell.h"
#import "FileListModel.h"
#import "PNRouter-Swift.h"
#import "NSDate+Category.h"
#import "NSString+Base64.h"
#import "SystemUtil.h"
#import "UserConfig.h"

@implementation MyFilesCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configCellWithModel:(FileListModel *)model {
    // icon_picture_small_gray 图片
    // icon_video_small_gray 视频
    // icon_document_small_gray 文档
    // icon_other_small_gray 其它
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
    _selectLeftWidth.constant = model.showSelect?40:0;
    _selectBtn.selected = model.isSelect;
    _icon.image = [UIImage imageNamed:fileTypeImgName];
    NSString *fileName = model.FileName?:@"";
    _titleLab.text = [Base58Util Base58DecodeWithCodeName:fileName];
    
    int fileSize = [model.FileSize intValue];
    if (model.FileFrom == 1) {
        _iocn_imgV.image = [UIImage imageNamed:@"icon_file_sent_black"];
        _lblName.text = [model.Sender base64DecodedString];
    } else if (model.FileFrom == 2) {
        _iocn_imgV.image = [UIImage imageNamed:@"icon_file_black"];
        _lblName.text = [model.Sender base64DecodedString];
    } else {
        _iocn_imgV.image = [UIImage imageNamed:@"icon_file_sent_black"];
        _lblName.text = [UserConfig getShareObject].userName;
    }
    
    NSString *desTime = [NSDate formattedUploadFileTimeFromTimeInterval:[model.Timestamp  intValue]];
    _detailLab.text = [NSString stringWithFormat:@"%@ %@",[SystemUtil transformedValue:fileSize],desTime];
}

- (IBAction)moreAction:(id)sender {
    if (_moreB) {
        _moreB();
    }
}


- (void)prepareForReuse {
    [super prepareForReuse];
    
    _icon.image = nil;
    _titleLab.text = nil;
    _detailLab.text = nil;
}

@end
