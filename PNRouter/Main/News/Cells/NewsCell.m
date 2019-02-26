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

@interface NewsCell ()

@property (nonatomic, strong) ChatListModel *chatListM;

@end

@implementation NewsCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _lblUnCount.layer.cornerRadius = 6.0f;
    _lblUnCount.layer.masksToBounds = YES;
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) setModeWithChatListModel:(ChatListModel *) model
{
    _chatListM = model;
    _lblUnCount.hidden = YES;;
    if (model.isHD) {
        _lblUnCount.hidden = NO;
    }
    
    _lblNameJX.text = [StringUtil getUserNameFirstWithName:model.friendName];
    
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
