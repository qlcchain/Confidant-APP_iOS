//
//  EmailTopDetailCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

static NSString *EmailTopDetailCellResue = @"EmailTopDetailCell";
#define EmailTopDetailCellDefaultHeight 128


typedef void(^ClickHiddenBlock)(void);
@class EmailListInfo;
@interface EmailTopDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblFromName;
@property (weak, nonatomic) IBOutlet UIImageView *lableImgView;
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblFromAlisa;
@property (weak, nonatomic) IBOutlet UILabel *lblToName;
@property (weak, nonatomic) IBOutlet UILabel *lblMonthTime;


@property (nonatomic, copy) ClickHiddenBlock hiddenBlock;
@property (weak, nonatomic) IBOutlet UIButton *hiddenBtn;
@property (weak, nonatomic) IBOutlet UIView *lineView;

- (void) setEmialInfoModel:(EmailListInfo *) model;
@end

NS_ASSUME_NONNULL_END
