//
//  PNFeedbackImgAlertView.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/27.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ClickImgShowBlock)(NSArray *imgs,NSInteger selRow);

@interface PNFeedbackImgAlertView : UIView
@property (weak, nonatomic) IBOutlet UICollectionView *imgCollectionView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomV;
@property (nonatomic, copy) ClickImgShowBlock clickImgBlock;

+ (instancetype) loadPNFeedbackImgAlertView;
- (void) showPNFeedbackImgAlertViewWithArray:(NSArray *) imgs;
- (void) hidePNFeedbackImgAlertView;

@end

NS_ASSUME_NONNULL_END
