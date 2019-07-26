//
//  EmailErrorAlertView.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/26.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmailErrorAlertView : UIView
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomH;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;

@property (weak, nonatomic) IBOutlet UIView *backView;
+ (instancetype) loadEmailErrorAlertView;
- (void) showEmailAttchSelView;
@end

NS_ASSUME_NONNULL_END
