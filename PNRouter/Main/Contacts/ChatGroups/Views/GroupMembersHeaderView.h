//
//  UploadFilesHeaderView.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GroupMembersModel;

static NSString *GroupMembersHeaderViewReuse = @"GroupMembersHeaderView";
#define GroupMembersHeaderViewHeight 56


@interface GroupMembersHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UIImageView *headImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;

- (void)configHeaderWithModel:(GroupMembersModel *)model;

@end

NS_ASSUME_NONNULL_END
