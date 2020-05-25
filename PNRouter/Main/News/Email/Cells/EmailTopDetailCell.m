//
//  EmailTopDetailCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EmailTopDetailCell.h"
#import "EmailListInfo.h"
#import "NSDate+Category.h"
#import "EmailAccountModel.h"
#import "PNDefaultHeaderView.h"
#import "EmailUserModel.h"
#import "EmailOptionUtil.h"

@implementation EmailTopDetailCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (IBAction)clickHiddenBtn:(UIButton *)sender {
    if (_hiddenBlock) {
        _hiddenBlock();
    }
}

- (void) setEmialInfoModel:(EmailListInfo *) model
{
    _lblFromName.text = model.Subject;
    _lblFromAlisa.text = model.fromName;
    _lblMonthTime.text =  [model.revDate minuteDescription];
    
    // 获取read 二进制的第三位，1为加星  0 为没有
   
    _lableImgView.hidden = ![EmailOptionUtil checkEmailStar:model.Read];

   EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
    if (![model.From isEqualToString:accountModel.User]) {
        _lblToName.text = @"To me";
    } else {
        if (model.toUserArray && model.toUserArray.count > 0) {
           EmailUserModel *userModel = model.toUserArray[0];
            userModel.userName = [userModel.userName stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            _lblToName.text = [NSString stringWithFormat:@"To %@",userModel.userName?:@""];
        } else {
             _lblToName.text = @"";
        }
    }
    
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:@"" Name:[StringUtil getUserNameFirstWithName:model.fromName]];
    _headImgView.image = defaultImg;
    
}

@end
