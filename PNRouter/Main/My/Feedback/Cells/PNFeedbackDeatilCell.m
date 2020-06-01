//
//  PNFeedbackDeatilCell.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/26.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNFeedbackDeatilCell.h"

@implementation PNFeedbackDeatilCell
- (IBAction)clickCheckImgAction:(id)sender {
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _backV.layer.cornerRadius = 4.0f;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
