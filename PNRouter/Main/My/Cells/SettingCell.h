//
//  SettingCell.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/25.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *SettingCellReuse = @"SettingCell";
#define SettingCell_Height 47

@interface SettingCell : UITableViewCell
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftContraintV;

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UISwitch *switc;

@end

NS_ASSUME_NONNULL_END
