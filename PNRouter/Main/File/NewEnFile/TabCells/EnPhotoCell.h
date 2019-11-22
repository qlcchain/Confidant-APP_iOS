//
//  EnPhotoCell.h
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *EnPhotoCellResue = @"EnPhotoCell";
#define EnPhotoCellHeight 67.0f

@interface EnPhotoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblNumber;

@end

NS_ASSUME_NONNULL_END
