//
//  PNFeedbackListCell.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/20.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PNFeedbackMoel;

NS_ASSUME_NONNULL_BEGIN

#define PNFeedbackListCellHeight 132
static NSString *PNFeedbackListCellResue = @"PNFeedbackListCell";

@interface PNFeedbackListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblSuject;
@property (weak, nonatomic) IBOutlet UILabel *lblType;
@property (weak, nonatomic) IBOutlet UILabel *lblNo;
@property (weak, nonatomic) IBOutlet UILabel *lblStatus;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIView *backV;

- (void) setFeedbackModel:(PNFeedbackMoel *) model;

@end

NS_ASSUME_NONNULL_END
