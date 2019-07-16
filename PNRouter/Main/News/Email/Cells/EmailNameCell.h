//
//  EmailNameCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/9.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *EmailNameCellResue = @"EmailNameCell";
#define EmailNameCellHeight 88

@interface EmailNameCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblFirstName;
@property (weak, nonatomic) IBOutlet UILabel *lblCount;
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIView *topLineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countContraintW;
@property (weak, nonatomic) IBOutlet UIImageView *connectImgView;

@end

NS_ASSUME_NONNULL_END
