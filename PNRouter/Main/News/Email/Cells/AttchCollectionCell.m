//
//  AttchCollectionCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/15.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "AttchCollectionCell.h"

@implementation AttchCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _backV.layer.borderColor = MAIN_GRAY_COLOR.CGColor;
    _backV.layer.borderWidth = 1.0f;
    _backV.layer.cornerRadius = 8.0f;
    _backV.layer.masksToBounds = YES;
    _closeBtn.hidden = YES;
}
- (IBAction)clickCloseBtn:(id)sender {
    if (_closeBlock) {
        _closeBlock(self.tag);
    }
}
    
@end
