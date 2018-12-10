//
//  BottonCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "BottonCell.h"

@implementation BottonCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _sendMessageBtn.layer.cornerRadius = RADIUS;
    _sendMessageBtn.layer.masksToBounds = YES;
    
    _delegateBtn.layer.cornerRadius = RADIUS;
    _delegateBtn.layer.masksToBounds = YES;
}

- (IBAction)bottonAction:(UIButton *)sender {
    NSInteger tag = sender.tag;
    if (tag == 10) {
        if (_deleteContactB) {
            _deleteContactB();
        }
    } else if (tag == 20) {
        if (_sendMessageB) {
            _sendMessageB();
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
