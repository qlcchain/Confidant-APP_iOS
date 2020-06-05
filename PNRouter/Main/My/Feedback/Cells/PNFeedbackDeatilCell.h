//
//  PNFeedbackDeatilCell.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/26.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ClickImgBlock)(NSArray *imgs);

#define PNFeedbackDeatilCellHeight 132
static NSString *PNFeedbackDeatilCellResue = @"PNFeedbackDeatilCell";
@interface PNFeedbackDeatilCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (weak, nonatomic) IBOutlet UIView *imgBackView;
@property (weak, nonatomic) IBOutlet UILabel *lblImgCount;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIView *leftBackV;
@property (weak, nonatomic) IBOutlet UIView *backV;
@property (weak, nonatomic) IBOutlet UIButton *imgBtn;
@property (nonatomic, copy) ClickImgBlock clickImgBlock;

- (void) setFeedReplyModel:(id) model;
@end

NS_ASSUME_NONNULL_END
