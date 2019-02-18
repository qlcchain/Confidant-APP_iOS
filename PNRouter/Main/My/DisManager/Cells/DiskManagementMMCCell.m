//
//  DiskManagementCell.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/28.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "DiskManagementMMCCell.h"
#import "GetDiskTotalInfoModel.h"

@implementation DiskManagementMMCCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configCellWithModel:(GetDiskTotalInfo *)model {
    
    _backView.layer.borderColor = [model.Status integerValue] == 2?UIColorFromRGB(0x3091F2).CGColor:UIColorFromRGB(0xA4A4A4).CGColor;
    _backView.layer.borderWidth = 1;
    _frontView.backgroundColor = [model.Status integerValue] == 2?UIColorFromRGB(0xA0CCF9):UIColorFromRGB(0xBFBFBF);
//    _diskLab.text = [model.Slot integerValue] == 0?@"A":@"B";
    _capacityKeyLab.textColor = [model.Status integerValue] == 2?UIColorFromRGB(0x2B2B2B):UIColorFromRGB(0x808080);
    _capacityValLab.textColor = [model.Status integerValue] == 2?UIColorFromRGB(0x2B2B2B):UIColorFromRGB(0x808080);
    _capacityValLab.text = model.Capacity;
    _statusImg.hidden = [model.Status integerValue] == 2?YES:NO;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
//    _backView;
//    _frontView;
    _diskLab.text = nil;
//    _temperatureKeyLab;
    _capacityValLab.text = nil;
    
}

@end
