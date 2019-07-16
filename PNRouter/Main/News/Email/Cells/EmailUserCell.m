//
//  EmailUserCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EmailUserCell.h"
#import "EmailUserModel.h"

@implementation EmailUserCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setUserModel:(EmailUserModel *) model
{
    if (model.userType == UserNo) {
        _lblType.text = @"";
    } else if (model.userType == UserTo) {
        _lblType.text = @"To";
    } else if (model.userType == UserFrom) {
        _lblType.text = @"From";
    } else if (model.userType == UserCc) {
        _lblType.text = @"Cc";
    } else if (model.userType == UserBcc) {
        _lblType.text = @"Bcc";
    }
    
    _lblName.text = model.userName;
    _lblAddress.text = model.userAddress;
}

@end
