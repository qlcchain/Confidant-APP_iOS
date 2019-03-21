//
//  NewRequestsGroupChatsCell1.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/13.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "NewRequestsGroupChatsCell1.h"
#import "NSString+Base64.h"
#import "PNDefaultHeaderView.h"
#import "GroupVerifyModel.h"
#import "UserModel.h"

@implementation NewRequestsGroupChatsCell1

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    _acceptBtn.layer.cornerRadius = 4;
    _acceptBtn.layer.masksToBounds = YES;
    _headImgV.layer.cornerRadius = _headImgV.width/2.0;
    _headImgV.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)configCellWithModel:(GroupVerifyModel *)model {
    _fromNameLab.text = [model.FromName base64DecodedString]?:model.FromName;
    _toNameLab.text = [model.ToName base64DecodedString]?:model.ToName;
    _gNameLab.text = [model.Gname base64DecodedString]?:model.Gname;
    UserModel *userM = [UserModel getUserModel];
    
    _acceptBtn.hidden = YES;
    _statusLab.hidden = YES;
    if (model.status == 0) { // 同意
        if ([userM.userId isEqualToString:model.Aduit]) { // 审核人是自己
            _acceptBtn.hidden = NO;
        }
    } else {
        _statusLab.hidden = NO;
        UIColor *blackC = UIColorFromRGB(0x2C2C2C);
        UIColor *grayC = UIColorFromRGB(0xBDBDBD);
        NSString *status = @"";
        UIColor *statusColor = blackC;
        if (model.status == 1) { // 已同意
            status = @"Accepted";
            statusColor = grayC;
        } else if (model.status == 2) { // 等待
            status = @"Pending";
            statusColor = blackC;
        } else if (model.status == 3) { // 过期
            status = @"Expired";
            statusColor = grayC;
        }
        _statusLab.text = status;
        _statusLab.textColor = statusColor;
    }

    NSString *userKey = model.UserPubKey;
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:_toNameLab.text]];
    _headImgV.image = defaultImg;

}

- (IBAction)acceptAction:(id)sender {
    if (_acceptB) {
        _acceptB(_currentRow);
    }
}


@end
