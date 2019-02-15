//
//  DiskManagementCell.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/28.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class GetDiskTotalInfo;

static NSString *DiskManagementCellReuse = @"DiskManagementCell";
#define DiskManagementCell_Height 136

@interface DiskManagementCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *frontView;
@property (weak, nonatomic) IBOutlet UILabel *diskLab;
@property (weak, nonatomic) IBOutlet UILabel *temperatureKeyLab;
@property (weak, nonatomic) IBOutlet UILabel *temperatureValLab;
@property (weak, nonatomic) IBOutlet UILabel *usagetimeKeyLab;
@property (weak, nonatomic) IBOutlet UILabel *usagetimeValLab;
@property (weak, nonatomic) IBOutlet UILabel *deviceKeyLab;
@property (weak, nonatomic) IBOutlet UILabel *deviceValLab;
@property (weak, nonatomic) IBOutlet UILabel *serialKeyLab;
@property (weak, nonatomic) IBOutlet UILabel *serialValLab;
@property (weak, nonatomic) IBOutlet UILabel *capacityKeyLab;
@property (weak, nonatomic) IBOutlet UILabel *capacityValLab;
@property (weak, nonatomic) IBOutlet UIImageView *statusImg;

- (void)configCellWithModel:(GetDiskTotalInfo *)model;

@end

NS_ASSUME_NONNULL_END
