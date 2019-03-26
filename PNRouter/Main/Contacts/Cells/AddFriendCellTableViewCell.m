//
//  AddFriendCellTableViewCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/13.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "AddFriendCellTableViewCell.h"
#import "FriendModel.h"
#import "NSDate+Category.h"
#import "NSString+Base64.h"
#import "PNDefaultHeaderView.h"
#import "EntryModel.h"

@implementation AddFriendCellTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _headImgView.layer.cornerRadius = _headImgView.width/2.0;
    _headImgView.layer.masksToBounds = YES;
    _acceptBtn.layer.cornerRadius = 4;
    _acceptBtn.layer.masksToBounds = YES;
}

- (void)prepareForReuse {
    [super prepareForReuse];

}

- (IBAction)rightAction:(UIButton *)sender {
    if (self.rightBlcok) {
        self.rightBlcok(sender.tag, self.tag);
    }
}

- (void) setFriendModel:(FriendModel *) model{
    _lblName.text = model.username?:@"";
    _lblStatus.text = @"";
    _acceptBtn.hidden = YES;
    UIColor *blackC = UIColorFromRGB(0x2C2C2C);
    UIColor *grayC = UIColorFromRGB(0xBDBDBD);
    if (model.dealStaus == 1) {
        _lblStatus.text = @"Added";
        _lblStatus.textColor = grayC;
    } else if (model.dealStaus == 2) {
        _lblStatus.text = @"Expired";
        _lblStatus.textColor = grayC;
    } else if (model.dealStaus == 3) {
        _lblStatus.text = @"Pending";
        _lblStatus.textColor = blackC;
    } else {
        NSInteger day = labs([model.requestTime daysAfterDate:[NSDate date]]);
        if (day > 7) {
            model.dealStaus = 2;
            _lblStatus.text = @"Expired";
            _lblStatus.textColor = grayC;
            [model bg_saveOrUpdate];
        } else {
             _acceptBtn.hidden = NO;
        }
    }
    NSString *userKey = model.signPublicKey;
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:model.username]];
    _headImgView.image = defaultImg;
//    _lblTitle.text = [StringUtil getUserNameFirstWithName:model.username];
    NSString *msg = model.msg?:@"";
    if (msg && ![msg isEmptyString]) {
        msg = [msg base64DecodedString];
    }
    _lblMsg.text = msg;
}
@end
