//
//  UsedSpaceTableViewCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/27.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "UsedSpaceTableViewCell.h"

@implementation UsedSpaceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _useLab.text = @"0 G / 0 G （0%）";
    _useProgressV.progress = 0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
}

@end
