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
    _selectLeftWidth.constant = model.showSelect?40:0;
    _selectBtn.selected = model.isSelect;
    _icon.image = [UIImage imageNamed:@"icon_document_small_gray"];
    _titleLab.text = [Base58Util Base58DecodeWithCodeName:model.FileName];
    int fileSize = [model.FileSize intValue]/1024;
    NSString *desTime = [NSDate formattedUploadFileTimeFromTimeInterval:[model.Timestamp  intValue]];
    _detailLab.text = [NSString stringWithFormat:@"%d KB %@",fileSize,desTime];
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
