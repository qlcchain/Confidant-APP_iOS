//
//  PNSetEmailPassView.h
//  MyConfidant
//
//  Created by 旷自辉 on 2019/10/28.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmailPassModel.h"

typedef void(^ClickSetPassBlock)(BOOL isSet);

NS_ASSUME_NONNULL_BEGIN

@interface PNSetEmailPassView : UIView
@property (weak, nonatomic) IBOutlet UIView *pasView;
@property (weak, nonatomic) IBOutlet UIView *depassView;
@property (weak, nonatomic) IBOutlet UIView *hintView;


@property (weak, nonatomic) IBOutlet UITextField *passTF;
@property (weak, nonatomic) IBOutlet UITextField *depassTF;
@property (weak, nonatomic) IBOutlet UITextField *hitTF;
@property (weak, nonatomic) IBOutlet UIImageView *hitImgView;
@property (weak, nonatomic) IBOutlet UIButton *setPassBtn;
@property (weak, nonatomic) IBOutlet UIButton *removeBtn;
@property (weak, nonatomic) IBOutlet UIButton *msetPassBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *downContraintV;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (nonatomic, strong) EmailPassModel *passM;
@property (nonatomic, copy) ClickSetPassBlock clickSetPassB;
+ (instancetype) loadPNSetEmailPassView;
- (void) showEmailSetPassView:(UIView *) supView;
@end

NS_ASSUME_NONNULL_END
