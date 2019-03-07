//
//  ContactsCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <SWTableViewCell/SWTableViewCell.h>
@class FriendModel;
@class RouterUserModel;

static NSString *ContactsCellReuse = @"ContactsCell";
#define ContactsCellHeight 55
@interface ContactsCell : SWTableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descContraintW;
- (void) setModeWithModel:(FriendModel *) model;
- (void) setModeWithRoutherUserModel:(RouterUserModel *) model;

//@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@end
