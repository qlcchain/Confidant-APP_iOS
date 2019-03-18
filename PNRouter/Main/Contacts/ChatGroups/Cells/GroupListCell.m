//
//  GroupListCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "GroupListCell.h"
#import "NSString+Base64.h"
#import "GroupInfoModel.h"

@implementation GroupListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setModeWithGroupModel:(GroupInfoModel *) model
{
    _lblName.text = model.GName? [model.GName base64DecodedString]:@"";
}

@end
