//
//  ChooseRecipientAlertView.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/25.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseRecipientAlertView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lblSubName;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UITextField *messageTF;
@property (weak, nonatomic) IBOutlet UIView *backView;

- (void) showAlertView;
- (void) hideAlertView;
+ (instancetype) loadChooseRecipientAlertView;
@end
