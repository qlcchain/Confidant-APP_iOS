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
    _lblName.text = [model.friendName base64DecodedString]?:model.friendName;
    _lblNameJX.text = [StringUtil getUserNameFirstWithName:_lblName.text];
    _lblContent.text = model.lastMessage?:@"";
    _lblTime.text = [model.chatTime formattedTime];
}


@end
