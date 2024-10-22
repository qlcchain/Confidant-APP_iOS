//
//  RouterManagementCell.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/27.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "RouterManagementCell.h"
#import "RouterModel.h"
#import "PNDefaultHeaderView.h"

@implementation RouterManagementCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)configWithModel:(RouterModel *)model {
    _nameLab.text = model.name;
    NSString *userKey = @"";
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:_nameLab.text]];
    _icon.image = defaultImg;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    _nameLab.text = nil;
}

@end
