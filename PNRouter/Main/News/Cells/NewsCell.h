//
//  NewsCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <SWTableViewCell/SWTableViewCell.h>
@class ChatListModel;

static NSString *NewsCellResue = @"NewsCell";
#define NewsCellHeight 64

@interface NewsCell : SWTableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblNameJX;
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblUnCount;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
- (void) setModeWithChatListModel:(ChatListModel *) model;
@end
