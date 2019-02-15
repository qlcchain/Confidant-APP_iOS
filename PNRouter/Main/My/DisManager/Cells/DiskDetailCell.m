//
//  DiskDetailCell.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/28.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "DiskDetailCell.h"

@implementation DiskDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configCellWithKey:(NSString *)key val:(NSString *)val {
    _titleKeyLab.text = key;
    _titleValLab.text = val;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _titleKeyLab.text = nil;
    _titleValLab.text = nil;
}

@end
