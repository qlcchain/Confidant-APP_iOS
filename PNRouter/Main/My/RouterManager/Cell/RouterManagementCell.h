//
//  RouterManagementCell.h
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/27.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RouterModel;

static NSString *RouterManagementCellReuse = @"RouterManagementCell";
#define RouterManagementCell_Height 56

@interface RouterManagementCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;

- (void)configWithModel:(RouterModel *)model;

@end

NS_ASSUME_NONNULL_END
