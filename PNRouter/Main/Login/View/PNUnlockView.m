//
//  PNUnlockView.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/2/26.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNUnlockView.h"
#import "FingerprintVerificationUtil.h"

#define UnlockAnimateTime 0.6

@interface PNUnlockView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgCenterY; // -40
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnOffsetBottom; // 44+32
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UIButton *unlockBtn;
@property (nonatomic, strong) FingerprintVerificationUtil *fingerprintUtil;
@property (nonatomic, copy) UnlockOKBlock okBlock;

@end

@implementation PNUnlockView

+ (instancetype)getInstance {
    PNUnlockView *view = [[[NSBundle mainBundle] loadNibNamed:@"PNUnlockView" owner:self options:nil] lastObject];
    view.isShow = NO;
    [view viewInit];
    return view;
}

#pragma mark - Operation
- (void)viewInit {
    _unlockBtn.layer.cornerRadius = 4;
    _unlockBtn.layer.masksToBounds = YES;
    _btnOffsetBottom.constant = -44;
    _unlockBtn.hidden = YES;
}

- (void)showWithUnlockOK:(UnlockOKBlock)block {
    _okBlock = block;
    [AppD.window addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(AppD.window).offset(0);
    }];
    
     _isShow = YES;
    
//    self.imgCenterY.constant = -40;
    @weakify_self
    [UIView animateWithDuration:UnlockAnimateTime animations:^{
        weakSelf.imgCenterY.constant = -(SCREEN_HEIGHT/4.0);
        
        [weakSelf.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [weakSelf showFingetprintVerification];
    }];
}

- (void)hide {
    [self removeFromSuperview];
    _isShow = NO;
    if (_okBlock) {
        _okBlock();
    }
}

- (void)hideAnimate {
    [_fingerprintUtil hide];
    @weakify_self
//    self.btnOffsetBottom.constant = 32;
    [UIView animateWithDuration:UnlockAnimateTime animations:^{
        weakSelf.imgCenterY.constant = -40;
        weakSelf.btnOffsetBottom.constant = -44;
        
        [weakSelf.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [weakSelf hide];
    }];
}

- (void)showUnlockBtn {
    _unlockBtn.hidden = NO;
    @weakify_self
    self.btnOffsetBottom.constant = -44;
    [UIView animateWithDuration:UnlockAnimateTime animations:^{
        weakSelf.btnOffsetBottom.constant = 32;
        weakSelf.imgCenterY.constant = -40;
        
        [weakSelf.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideUnlockBtn {
    @weakify_self
//    self.btnOffsetBottom.constant = -44;
    [UIView animateWithDuration:.4 animations:^{
        weakSelf.btnOffsetBottom.constant = -44;
        weakSelf.imgCenterY.constant = -(SCREEN_HEIGHT/4.0);
        
        [weakSelf.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        [weakSelf showFingetprintVerification];
    }];
}

- (void)showFingetprintVerification {
    @weakify_self
    _fingerprintUtil = [[FingerprintVerificationUtil alloc] init];
    [_fingerprintUtil backShowWithComplete:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            [weakSelf hideAnimate];
        } else {
            [weakSelf showUnlockBtn];
        }
    }];
}

#pragma mark - Action

- (IBAction)unlockAction:(id)sender {
    [self hideUnlockBtn];
}

@end
