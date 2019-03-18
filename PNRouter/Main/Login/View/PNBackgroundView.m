//
//  PNBackgroundView.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/4.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBackgroundView.h"
#import "CSLogMacro.h"

@interface PNBackgroundView ()

@end

@implementation PNBackgroundView

+ (instancetype)getInstance {
    PNBackgroundView *view = [[[NSBundle mainBundle] loadNibNamed:@"PNBackgroundView" owner:self options:nil] lastObject];
    view.isShow = NO;
    
    UITapGestureRecognizer *tapCancel = [[UITapGestureRecognizer alloc] init];
    [view addGestureRecognizer:tapCancel];
    [tapCancel addTarget:view action:@selector(tapCancelAction:)];
    
    return view;
}

- (void)show {
    if (!AppD.inLogin) {
        CSLOG_TEST_DDLOG(@"**********************锁屏界面打开失败");
        return;
    }
    
    [AppD.window addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(AppD.window).offset(0);
    }];
    
    CSLOG_TEST_DDLOG(@"**********************锁屏界面打开成功");
    _isShow = YES;
    self.alpha = 0;
    @weakify_self
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)hide {
    if (!_isShow) {
        CSLOG_TEST_DDLOG(@"**********************锁屏界面关闭失败");
        return;
    }
    
    CSLOG_TEST_DDLOG(@"**********************锁屏界面关闭成功");
    self.isShow = NO;
    self.alpha = 1;
    @weakify_self
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
//        [weakSelf removeFromSuperview];
    }];
}

- (void)tapCancelAction:(UITapGestureRecognizer *)gr {
    [self hide];
}

@end
