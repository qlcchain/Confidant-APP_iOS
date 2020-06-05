//
//  PNFeedbackHeadCell.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/6/2.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define PNFeedbackHeadCellHeight 60
static NSString *PNFeedbackHeadCellResue = @"PNFeedbackHeadCell";

@interface PNFeedbackHeadCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblNo;

@end

NS_ASSUME_NONNULL_END
