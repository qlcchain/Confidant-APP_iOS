//
//  PNEmailPassDefaultView.h
//  MyConfidant
//
//  Created by 旷自辉 on 2019/10/29.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClickDecryptPassBlock)(NSString * _Nullable pass);

NS_ASSUME_NONNULL_BEGIN

@interface PNEmailPassDefaultView : UIView
@property (weak, nonatomic) IBOutlet UITextField *passTF;
@property (weak, nonatomic) IBOutlet UILabel *lblPassHint;
@property (weak, nonatomic) IBOutlet UIButton *decyBtn;
@property (weak, nonatomic) IBOutlet UIView *tfBackView;
@property (nonatomic, copy) ClickDecryptPassBlock clickDecryptPassB;
@property (weak, nonatomic) IBOutlet UIButton *ywBtn;
+ (instancetype) loadPNEmailPassDefaultView;
- (void) showEmailPassDefaultView:(UIView *) supView frameY:(CGFloat) frameY;
- (void) hideEmailPassDefaultView;
@end

NS_ASSUME_NONNULL_END
