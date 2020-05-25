//
//  PNBindQLCAddressView.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/14.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ClickCloseBlock)(void);

@interface PNBindQLCAddressView : UIView<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *neoTF;
@property (weak, nonatomic) IBOutlet UIButton *bindBtn;
@property (weak, nonatomic) IBOutlet UIView *bindBackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomV;
@property (weak, nonatomic) IBOutlet UIView *neoBackView;
@property (weak, nonatomic) IBOutlet UIView *qlcBackView;
@property (weak, nonatomic) IBOutlet UITextField *qlcTF;



@property (copy, nonatomic) ClickCloseBlock closeBlock;

+ (instancetype) loadPNBindQLCAddressView;
- (void) showPNBindQLCAddressView:(UIView *) supView;
- (void) hidePNBindQLCAddressView;

@end

NS_ASSUME_NONNULL_END
