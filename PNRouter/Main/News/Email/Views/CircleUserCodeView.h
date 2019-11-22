//
//  CircleUserCodeView.h
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/15.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface CircleUserCodeView : UIView

@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UILabel *lblRouterName;
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImgView;
@property (weak, nonatomic) IBOutlet UIImageView *userCodeImgView;
@property (weak, nonatomic) IBOutlet UIView *userCodeBackView;

+ (instancetype) loadCircleUserCodeView;
- (UIImage *) getCircleImage;

@end

NS_ASSUME_NONNULL_END
