//
//  PNFeedbackStatusCell.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/6/2.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define PNFeedbackStatusCellHeight 100
static NSString *PNFeedbackStatusCellResue = @"PNFeedbackStatusCell";

@interface PNFeedbackStatusCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIView *backV;

@end

NS_ASSUME_NONNULL_END
