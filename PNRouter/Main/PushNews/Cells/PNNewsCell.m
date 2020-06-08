//
//  PNNewsCell.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/14.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNNewsCell.h"

@implementation PNNewsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(descTapGesture:)];
    _lblDesc.userInteractionEnabled = YES;
    [_lblDesc addGestureRecognizer:tapGesture];
}

- (void) descTapGesture:(UITapGestureRecognizer *) gesture
{
    if (_descBlock) {
        _descBlock(_row);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
