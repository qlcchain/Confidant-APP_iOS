//
//  GroupCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "GroupCell.h"

@implementation GroupCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _hdBackView.layer.cornerRadius = 6.0f;
    _hdBackView.backgroundColor = RGB(44, 44, 44);
    _hdBackView.hidden = YES;
    
    _detailText.text = @"";
    _detailText.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
