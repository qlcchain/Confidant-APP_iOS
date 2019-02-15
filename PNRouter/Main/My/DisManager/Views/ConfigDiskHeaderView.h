//
//  UploadFilesHeaderView.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ConfigDiskShowModel;

static NSString *ConfigDiskHeaderViewReuse = @"ConfigDiskHeaderView";
#define ConfigDiskHeaderViewHeight 56

typedef void(^ConfigDiskSelectBlock)(void);
typedef void(^ConfigDiskShowCellBlock)(void);

@interface ConfigDiskHeaderView : UITableViewHeaderFooterView

@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIButton *showCellBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *detailLab;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImg;
@property (nonatomic, copy) ConfigDiskSelectBlock selectB;
@property (nonatomic, copy) ConfigDiskShowCellBlock showCellB;

- (void)configHeaderWithModel:(ConfigDiskShowModel *)model;

@end

NS_ASSUME_NONNULL_END
