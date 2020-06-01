//
//  PNFeedbackImgAlertView.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/27.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNFeedbackImgAlertView : UIView
@property (weak, nonatomic) IBOutlet UICollectionView *imgCollectionView;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomV;

+ (instancetype) loadPNFeedbackImgAlertView;
- (void) showPNFeedbackImgAlertView;
- (void) hidePNFeedbackImgAlertView;

@end

NS_ASSUME_NONNULL_END
