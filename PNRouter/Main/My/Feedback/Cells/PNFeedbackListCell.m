//
//  PNFeedbackListCell.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/20.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNFeedbackListCell.h"

@implementation PNFeedbackListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _backV.layer.cornerRadius = 8.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
