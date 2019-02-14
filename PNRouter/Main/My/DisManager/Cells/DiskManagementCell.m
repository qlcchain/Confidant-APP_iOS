//
//  DiskManagementCell.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/28.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "DiskManagementCell.h"
#import "GetDiskTotalInfoModel.h"

@implementation DiskManagementCell

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
    _diskLab.text = [model.Slot integerValue] == 0?@"A":@"B";
    _temperatureKeyLab.textColor = [model.Status integerValue] == 2?UIColorFromRGB(0x2B2B2B):UIColorFromRGB(0x808080);
    _temperatureValLab.textColor = [model.Status integerValue] == 2?UIColorFromRGB(0x2B2B2B):UIColorFromRGB(0x808080);
    _temperatureValLab.text = [NSString stringWithFormat:@"%@℃",model.Temperature];
    _usagetimeKeyLab.textColor = [model.Status integerValue] == 2?UIColorFromRGB(0x2B2B2B):UIColorFromRGB(0x808080);
    _usagetimeValLab.textColor = [model.Status integerValue] == 2?UIColorFromRGB(0x2B2B2B):UIColorFromRGB(0x808080);
    _usagetimeValLab.text = [NSString stringWithFormat:@"%@ H",model.PowerOn];
    _deviceKeyLab.textColor = [model.Status integerValue] == 2?UIColorFromRGB(0x2B2B2B):UIColorFromRGB(0x808080);
    _deviceValLab.textColor = [model.Status integerValue] == 2?UIColorFromRGB(0x2B2B2B):UIColorFromRGB(0x808080);
    _deviceValLab.text = model.Device;
    _serialKeyLab.textColor = [model.Status integerValue] == 2?UIColorFromRGB(0x2B2B2B):UIColorFromRGB(0x808080);
    _serialValLab.textColor = [model.Status integerValue] == 2?UIColorFromRGB(0x2B2B2B):UIColorFromRGB(0x808080);
    _serialValLab.text = model.Serial;
    _capacityKeyLab.textColor = [model.Status integerValue] == 2?UIColorFromRGB(0x2B2B2B):UIColorFromRGB(0x808080);
    _capacityValLab.textColor = [model.Status integerValue] == 2?UIColorFromRGB(0x2B2B2B):UIColorFromRGB(0x808080);
    _serialValLab.text = model.Capacity;
    _statusImg.image = [model.Status integerValue] == 2?nil:[model.Status integerValue] == 1?[UIImage imageNamed:@"icon_disk_not_configured"]:[UIImage imageNamed:@"icon_disk_not_found"];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
//    _backView;
//    _frontView;
    _diskLab.text = nil;
//    _temperatureKeyLab;
    _temperatureValLab.text = nil;
//    _usagetimeKeyLab;
    _usagetimeValLab.text = nil;
//    _deviceKeyLab;
    _deviceValLab.text = nil;
//    _serialKeyLab;
    _serialValLab.text = nil;
//    _capacityKeyLab;
    _capacityValLab.text = nil;
    _statusImg.image = nil;
}

@end
