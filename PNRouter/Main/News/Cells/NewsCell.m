//
//  NewsCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "NewsCell.h"
#import "ChatListModel.h"
#import "NSDate+Category.h"
#import "NSString+Base64.h"
#import <WZLBadge/WZLBadgeImport.h>
#import "PNDefaultHeaderView.h"

@interface NewsCell ()

@property (nonatomic, strong) ChatListModel *chatListM;
@property (weak, nonatomic) IBOutlet UIView *backView;


@end

@implementation NewsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _backView.badgeBgColor = UIColorFromRGB(0xF7625F);
    _backView.badgeTextColor = [UIColor whiteColor];
    
    _headImgView.layer.cornerRadius = _headImgView.width/2.0;
    _headImgView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModeWithChatListModel:(ChatListModel *)model {
    _chatListM = model;
    if (model.isHD) {
        CGFloat offset = SCREEN_WIDTH - _backView.width;
        _backView.badgeCenterOffset = CGPointMake(-30+offset, 45);
        [_backView showBadgeWithStyle:WBadgeStyleNumber value:[model.unReadNum integerValue] animationType:WBadgeAnimTypeNone];
        if (!model.unReadNum || [model.unReadNum integerValue] == 0) {
            [_backView clearBadge];
        }
    } else {
        [_backView clearBadge];
    }
    if (model.isGroup) {
        _headImgView.image = [UIImage imageNamed:@"icon_group_head"];
    } else {
        NSString *userKey = model.signPublicKey;
        UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:model.friendName]];
        _headImgView.image = defaultImg;
    }
    
    if (model.isDraft) {
        NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[Drafts] %@",model.draftMessage?:@""]];
        NSRange redRange = NSMakeRange([[noteStr string] rangeOfString:@"[Drafts]"].location, [[noteStr string] rangeOfString:@"[Drafts]"].length);
        //需要设置的位置
        [noteStr addAttribute:NSForegroundColorAttributeName value:RGB(239, 59, 48) range:redRange];
        //设置颜色
        [_lblContent setAttributedText:noteStr];
    } else {
        _lblContent.text = model.lastMessage?:@"";
    }
   
    _lblTime.text = [model.chatTime minuteDescription];
    if (model.isGroup) {
        _lblName.text =  model.groupName;
    } else {
        NSString *friendName = model.friendName;
        NSString *joinStr = @" - ";
        NSString *routerName = model.routerName?:@"";
        NSString *str = [[friendName stringByAppendingString:joinStr] stringByAppendingString:routerName];
        if (routerName.length <= 0) {
            str = friendName;
        }
        NSMutableAttributedString *strAtt = [[NSMutableAttributedString alloc] initWithString:str];
        [strAtt setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:UIColorFromRGB(0x2B2B2B)} range:NSMakeRange(0, str.length)];
        [strAtt setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16],NSForegroundColorAttributeName:UIColorFromRGB(0x2B2B2B)} range:NSMakeRange(0, friendName.length)];
        _lblName.attributedText = strAtt;
    }
}

@end
