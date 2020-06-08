//
//  PNFeedbackTypeCell.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/26.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define PNFeedbackTypeCellHeight 52
static NSString *PNFeedbackTypeCellResue = @"PNFeedbackTypeCell";

@interface PNFeedbackTypeCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *selectImg;

@end

NS_ASSUME_NONNULL_END
