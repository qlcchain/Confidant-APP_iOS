//
//  AttchImgageCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/15.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "AttchImgageCell.h"

@implementation AttchImgageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _backV.layer.borderColor = MAIN_GRAY_COLOR.CGColor;
    _backV.layer.borderWidth = 1.0f;
    _backV.layer.cornerRadius = 8.0f;
    _backV.layer.masksToBounds = YES;
}

@end
