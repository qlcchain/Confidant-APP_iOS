//
//  MyCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "MyCell.h"

@implementation MyCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _subBtn.hidden = YES;
    _lblSubContent.hidden = YES;
    _subBtn.layer.cornerRadius = 15;
    _subBtn.layer.masksToBounds = YES;
    _subBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
