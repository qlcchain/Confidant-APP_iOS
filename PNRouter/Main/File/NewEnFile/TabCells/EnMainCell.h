//
//  EnMainCell.h
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/20.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *EnMainCellResue = @"EnMainCell";
#define EnMainCellHeight 152.0f

@interface EnMainCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet UIImageView *enImgView;

@end

NS_ASSUME_NONNULL_END
