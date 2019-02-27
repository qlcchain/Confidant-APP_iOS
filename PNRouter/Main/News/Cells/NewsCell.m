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

@interface NewsCell ()

@property (nonatomic, strong) ChatListModel *chatListM;
@property (weak, nonatomic) IBOutlet UIView *backView;


@end

@implementation NewsCell

- (void)awakeFromNib {
    [super awakeFromNib];
//    _lblUnCount.layer.cornerRadius = 6.0f;
//    _lblUnCount.layer.masksToBounds = YES;
    // Initialization code
    
    _backView.badgeBgColor = UIColorFromRGB(0xF74C31);
    _backView.badgeTextColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setModeWithChatListModel:(ChatListModel *) model
{
    _chatListM = model;
//    _lblUnCount.hidden = YES;
//    if (model.isHD) {
//        _lblUnCount.hidden = NO;
//    }
    //
    if (model.isHD) {
        CGFloat offset = SCREEN_WIDTH - _backView.width;
        _backView.badgeCenterOffset = CGPointMake(-30+offset, 45);
        [_backView showBadgeWithStyle:WBadgeStyleNumber value:8 animationType:WBadgeAnimTypeNone];
    } else {
        [_backView clearBadge];
    }
    
    _lblNameJX.text = [StringUtil getUserNameFirstWithName:_lblName.text];
    if (model.isDraft) {
        NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[草稿] %@",model.draftMessage?:@""]];
        NSRange redRange = NSMakeRange([[noteStr string] rangeOfString:@"[草稿]"].location, [[noteStr string] rangeOfString:@"[草稿]"].length);
        //需要设置的位置
        [noteStr addAttribute:NSForegroundColorAttributeName value:RGB(239, 59, 48) range:redRange];
        //设置颜色
        [_lblContent setAttributedText:noteStr];
    } else {
        _lblContent.text = model.lastMessage?:@"";
    }
   
    _lblTime.text = [model.chatTime minuteDescription];
    
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
//    _lblName.text =  model.friendName;
}

@end
