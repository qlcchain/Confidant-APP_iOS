//
//  EmailNameCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/9.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EmailNameCell.h"

@implementation EmailNameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _lblCount.layer.borderColor = [UIColor whiteColor].CGColor;
    _lblCount.layer.borderWidth = 1.0f;
    _lblCount.layer.cornerRadius = 8;
    _lblCount.layer.masksToBounds = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
