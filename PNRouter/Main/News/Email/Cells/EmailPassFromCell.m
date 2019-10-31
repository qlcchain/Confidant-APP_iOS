//
//  EmailPassFromCell.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/10/29.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EmailPassFromCell.h"

@implementation EmailPassFromCell

- (IBAction)clickEncodeBtn:(id)sender {
    if (_clickEncodeB) {
        _clickEncodeB();
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _encodeBtn.layer.cornerRadius = 4.0f;
    _encodeBtn.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
