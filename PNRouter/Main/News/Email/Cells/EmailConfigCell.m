//
//  EmailConfigCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/8/14.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EmailConfigCell.h"

@implementation EmailConfigCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _backView.layer.masksToBounds = YES;
    _backView.layer.cornerRadius = 8.0f;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
