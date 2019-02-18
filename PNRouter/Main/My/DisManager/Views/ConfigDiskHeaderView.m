//
//  UploadFilesHeaderView.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "ConfigDiskHeaderView.h"
#import "ConfigDiskViewController.h"

@interface ConfigDiskHeaderView ()

@end

@implementation ConfigDiskHeaderView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        
    }
    
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _titleLab.text = nil;
    _detailLab.text = nil;
    _arrowImg.image = nil;
    
}

- (void)configHeaderWithModel:(ConfigDiskShowModel *)model {
    _titleLab.text = model.title;
    _detailLab.text = model.detail;
    _arrowImg.hidden = !model.showArrow;
    _arrowImg.image = model.showCell?[UIImage imageNamed:@"icon_arrow_down_gray"]:[UIImage imageNamed:@"icon_arrow_up_gray"];
    _selectBtn.selected = model.isSelect;
    _selectImg.hidden = !_selectBtn.selected;
}

- (IBAction)selectAction:(UIButton *)sender {
    if (_selectB) {
        _selectB(_headerSection);
    }
}

- (IBAction)showCellAction:(UIButton *)sender {
    if (_showCellB) {
        _showCellB();
    }
}


@end
