//
//  FileCell.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "FileCell.h"
#import "OperationRecordModel.h"

@implementation FileCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _timeLab.text = nil;
    _nameLab.text = nil;
    _fileNameLab.text = nil;
}

- (void)configCellWithModel:(OperationRecordModel *)model {
    _timeLab.text = model.operationTime;
    _nameLab.text = model.operationFrom;
    _fileNameLab.text = model.fileName;
    NSString *operationImgStr = @"";
    if ([model.operationType integerValue] == 0) { // 上传
        operationImgStr = @"icon_upload_small_gray";
    } else if ([model.operationType integerValue] == 1) { // 下载
        operationImgStr = @"icon_download_small_gray";
    } else if ([model.operationType integerValue] == 2) { // 删除
        operationImgStr = @"icon_delete_small_gray";
    }
    _operationIcon.image = [UIImage imageNamed:operationImgStr];
    
    NSString *fileImgStr = @"";
    if ([model.fileType integerValue] == 1) { // 图片
        fileImgStr = @"icon_picture_small_gray";
    } else if ([model.fileType integerValue] == 2) {
        fileImgStr = @"icon_video_small_gray";
    }
    _icon.image = [UIImage imageNamed:fileImgStr];
}

- (IBAction)moreAction:(id)sender {
    if (_fileMoreB) {
        _fileMoreB();
    }
}


@end
