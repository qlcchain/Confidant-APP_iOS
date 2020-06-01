//
//  PNImgCollectionCell.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/26.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNImgCollectionCell.h"

@implementation PNImgCollectionCell
- (IBAction)clickCloseAction:(id)sender {
    if (_clickDelBlock) {
        _clickDelBlock(self.tag);
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _imgV.layer.cornerRadius = 4.0f;
    // Initialization code
}

@end
