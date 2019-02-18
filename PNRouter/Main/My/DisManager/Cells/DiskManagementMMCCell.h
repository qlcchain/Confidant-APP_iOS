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

static NSString *DiskManagementMMCCellReuse = @"DiskManagementMMCCell";
#define DiskManagementMMCCell_Height 93

@interface DiskManagementMMCCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIView *frontView;
@property (weak, nonatomic) IBOutlet UILabel *diskLab;
@property (weak, nonatomic) IBOutlet UILabel *capacityKeyLab;
@property (weak, nonatomic) IBOutlet UILabel *capacityValLab;
@property (weak, nonatomic) IBOutlet UIImageView *statusImg;

- (void)configCellWithModel:(GetDiskTotalInfo *)model;

@end

NS_ASSUME_NONNULL_END
