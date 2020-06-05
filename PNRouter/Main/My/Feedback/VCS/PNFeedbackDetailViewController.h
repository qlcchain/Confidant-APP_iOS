//
//  PNFeedbackDetailViewController.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/20.
//  Copyright © 2020 旷自辉. All rights reserved.
//

@class PNFeedbackMoel;
#import "PNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PNFeedbackDetailViewController : PNBaseViewController
- (instancetype) initWithPNFeedbackModel:(PNFeedbackMoel *) model;
@end

NS_ASSUME_NONNULL_END
