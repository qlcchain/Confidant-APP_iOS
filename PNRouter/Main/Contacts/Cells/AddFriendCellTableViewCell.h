//
//  AddFriendCellTableViewCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/13.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

@class FriendModel;
static NSString *AddFriendCellReuse = @"AddFriendCellTableViewCell";
#define AddFriendCellHeight 58

typedef void(^ClickRightBlock)(NSInteger tag,NSInteger row);

@interface AddFriendCellTableViewCell : UITableViewCell
//@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (nonatomic , copy) ClickRightBlock rightBlcok;
@property (weak, nonatomic) IBOutlet UILabel *lblMsg;
- (void) setFriendModel:(FriendModel *) model;
@property (weak, nonatomic) IBOutlet UIView *rightBackView;
@end
