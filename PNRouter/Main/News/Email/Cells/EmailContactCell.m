//
//  EmailContactCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EmailContactCell.h"
#import "EmailContactModel.h"
#import "PNDefaultHeaderView.h"

@implementation EmailContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setEmailContactModel:(EmailContactModel *) model
{
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:@"" Name:[StringUtil getUserNameFirstWithName:model.userName]];
    _headImgV.image = defaultImg;
    
    if (model.isSel) {
        _selImgView.image = [UIImage imageNamed:@"radio_selected"];
    } else {
        _selImgView.image = [UIImage imageNamed:@"radio_normat"];
    }
    
    _lblContent.text = model.userName;
    _lblSubContent.text = model.userAddress;
}

@end
