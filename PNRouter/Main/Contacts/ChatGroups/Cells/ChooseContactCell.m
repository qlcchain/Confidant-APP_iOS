//
//  ChooseContactCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/25.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ChooseContactCell.h"
#import "NSString+Base64.h"
#import "PNDefaultHeaderView.h"

@implementation ChooseContactCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void) setModeWithModel:(FriendModel *) model withLeftContraintV:(CGFloat)leftV
{
    _lblContent.text = [model.username base64DecodedString]?:model.username;
    NSString *userKey = model.signPublicKey;
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:_lblContent.text]];
    _headerImgV.image = defaultImg;
//    _lblName.text =[StringUtil getUserNameFirstWithName:_lblContent.text];
    _leftContraintV.constant = leftV;
    if (model.isSelect) {
        _selectImgView.image = [UIImage imageNamed:@"icon_selectmsg"];
    } else {
        _selectImgView.image = [UIImage imageNamed:@"icon_unselectmsg"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
