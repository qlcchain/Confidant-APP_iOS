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
#import "CTinputHelper.h"



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

- (void) setSubjectWith:(NSString *) subject unReadCount:(NSInteger) unReadCount
{
    if (unReadCount > 0) {
         CGFloat offset = SCREEN_WIDTH - _backView.width;
        _backView.badgeCenterOffset = CGPointMake(-30+offset, 45);
        [_backView showBadgeWithStyle:WBadgeStyleNumber value:unReadCount animationType:WBadgeAnimTypeNone];
        _backView.badgeBgColor = MAIN_ZS_COLOR;
    } else {
        [_backView clearBadge];
    }
   
    _headImgView.image = [UIImage imageNamed:@"message_push"];
    _lblContent.text = subject?:@"";
    _lblTime.text = @"Official";
    _lblName.text = @"Campaign Updates";
    _lblName.textColor = MAIN_ZS_COLOR;
}

- (void)setModeWithChatListModel:(ChatListModel *)model {
    
    if (!model) {
        
        CGFloat offset = SCREEN_WIDTH - _backView.width;
        _backView.badgeCenterOffset = CGPointMake(-30+offset, 45);
        [_backView showBadgeWithStyle:WBadgeStyleNumber value:3 animationType:WBadgeAnimTypeNone];
        _backView.badgeBgColor = MAIN_ZS_COLOR;
        _headImgView.image = [UIImage imageNamed:@"message_push"];
        _lblContent.text = @"只要好友数量达到5位即可获得奖励，越多…";
        _lblTime.text = @"Official";
        _lblName.text = @"Campaign Updates";
        _lblName.textColor = MAIN_ZS_COLOR;
        return;
    }
    
    _lblName.textColor = RGB(43, 43, 43);
    _chatListM = model;
    if (model.isHD) {
        CGFloat offset = SCREEN_WIDTH - _backView.width;
        _backView.badgeCenterOffset = CGPointMake(-30+offset, 45);
        _backView.badgeBgColor = [UIColor redColor];
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
    
    NSString *showContent = model.lastMessage?:@"";
    if (!model.isAT) {
        if (model.isDraft) {
            showContent = model.draftMessage?:@"";
        }
    }
    
    // 替换中文表情显示
    if (showContent.length > 0) {
        // 处理表情   将所有[呵呵]换成占位字符  并计算图片位置
        NSRegularExpression *regEmoji = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\[\\]]+?\\]"
                                                                                  options:kNilOptions error:NULL];
        //
        NSArray<NSTextCheckingResult *> *emoticonResults = [regEmoji matchesInString:showContent
                                                                             options:kNilOptions
                                                                               range:NSMakeRange(0, showContent.length)];
        if (emoticonResults && emoticonResults.count >0) {
            
            NSMutableArray *emjStrs = [NSMutableArray arrayWithCapacity:emoticonResults.count];
            
            for (NSTextCheckingResult *checkM in emoticonResults) {
                NSString *emjStr = [showContent substringWithRange:checkM.range]?:@"";
                [emjStrs addObject:emjStr];
            }
            for (NSString *enjCH in emjStrs) {
                NSString *emjEnStr = CTinputHelper.share.emojEnDic[enjCH]?:@"";
                if (emjEnStr.length > 0) {
                    showContent = [showContent stringByReplacingOccurrencesOfString:enjCH withString:emjEnStr];
                }
            }
        }
        
    }
   
    if (model.isATYou) {
        NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[You were mentioned] %@:%@",model.friendName?:@"",showContent]];
        NSRange redRange = NSMakeRange([[noteStr string] rangeOfString:@"[You were mentioned]"].location, [[noteStr string] rangeOfString:@"[You were mentioned]"].length);
        //需要设置的位置
        [noteStr addAttribute:NSForegroundColorAttributeName value:RGB(239, 59, 48) range:redRange];
        //设置颜色
        [_lblContent setAttributedText:noteStr];
    } else {
        
        if (model.isDraft) {
            NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"[Drafts] %@",showContent]];
            NSRange redRange = NSMakeRange([[noteStr string] rangeOfString:@"[Drafts]"].location, [[noteStr string] rangeOfString:@"[Drafts]"].length);
            //需要设置的位置
            [noteStr addAttribute:NSForegroundColorAttributeName value:RGB(239, 59, 48) range:redRange];
            //设置颜色
            [_lblContent setAttributedText:noteStr];
        } else {
            if (model.isGroup) {
                if (model.friendName && model.friendName.length>0) {
                    _lblContent.text = [NSString stringWithFormat:@"%@: %@",model.friendName,showContent];
                } else {
                    _lblContent.text = showContent;
                }
            } else {
                _lblContent.text = showContent;
            }
            
        }
    }
    _lblTime.text = [model.chatTime minuteDescription];
    if (model.isGroup) {
//        _lblName.text =  model.groupName;
        _lblName.text = model.groupShowName;
    } else {
        NSString *friendName = model.friendName;
        NSString *joinStr = @" - ";
        NSString *routerName = model.routerName?:@"";
        NSString *str = [[friendName stringByAppendingString:joinStr?:@""] stringByAppendingString:routerName?:@""];
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
