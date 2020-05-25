//
//  PNPushNewsHeadView.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/14.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNPushNewsHeadView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;

+ (instancetype) loadPNPushNewsHeadView;
@end

NS_ASSUME_NONNULL_END
