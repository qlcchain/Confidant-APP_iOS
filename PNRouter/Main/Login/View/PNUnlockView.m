//
//  PNUnlockView.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/2/26.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNUnlockView.h"
#import "FingetprintVerificationUtil.h"

@interface PNUnlockView ()

@property (weak, nonatomic) IBOutlet UIButton *unlockBtn;
@property (nonatomic, strong) FingetprintVerificationUtil *fingerprintUtil;

@end

@implementation PNUnlockView

+ (instancetype)getInstance {
    PNUnlockView *view = [[[NSBundle mainBundle] loadNibNamed:@"PNUnlockView" owner:self options:nil] lastObject];
    [view viewInit];
    return view;
}

#pragma mark - Operation
- (void)viewInit {
    _unlockBtn.layer.cornerRadius = 4;
    _unlockBtn.layer.masksToBounds = YES;
    _unlockBtn.hidden = YES;
}

- (void)show {
    [AppD.window addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(AppD.window).offset(0);
    }];
    
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    [self showFingetprintVerification];
}

- (void)hide {
    [_fingerprintUtil hide];
    [self removeFromSuperview];
}

- (void)showFingetprintVerification {
    @weakify_self
    _fingerprintUtil = [[FingetprintVerificationUtil alloc] init];
    [_fingerprintUtil backShowWithComplete:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            [weakSelf hide];
        } else {
            weakSelf.unlockBtn.hidden = NO;
        }
    }];
}

#pragma mark - Action

- (IBAction)unlockAction:(id)sender {
    _unlockBtn.hidden = YES;
    [self showFingetprintVerification];
}

@end
