//
//  AttchImgageCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/15.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
static NSString *AttchImgageCellResue = @"AttchImgageCell";

@interface AttchImgageCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIView *backV;
@property (weak, nonatomic) IBOutlet UIImageView *headImgV;
@property (weak, nonatomic) IBOutlet UILabel *lblCount;
@property (weak, nonatomic) IBOutlet UIImageView *backImgView;

@end

NS_ASSUME_NONNULL_END
