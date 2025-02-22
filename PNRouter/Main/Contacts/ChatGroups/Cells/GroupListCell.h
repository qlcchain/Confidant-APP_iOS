//
//  GroupListCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//



#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@class GroupInfoModel;

static NSString *GroupListCellReuse = @"GroupListCell";
#define GroupListCellHeight 56

@interface GroupListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;

- (void) setModeWithGroupModel:(GroupInfoModel *) model;

@end

NS_ASSUME_NONNULL_END
