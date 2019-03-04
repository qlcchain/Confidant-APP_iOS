//
//  PNBackgroundView.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/4.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBackgroundView.h"

@interface PNBackgroundView ()

@property (nonatomic) BOOL isShow;

@end

@implementation PNBackgroundView

+ (instancetype)getInstance {
    PNBackgroundView *view = [[[NSBundle mainBundle] loadNibNamed:@"PNBackgroundView" owner:self options:nil] lastObject];
    view.isShow = NO;
    return view;
}

- (void)show {
    if (!AppD.inLogin) {
        return;
    }
    
    [AppD.window addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(AppD.window).offset(0);
    }];
    
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
        return;
    }
    self.alpha = 1;
    @weakify_self
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.alpha = 0;
    } completion:^(BOOL finished) {
        weakSelf.isShow = NO;
//        [weakSelf removeFromSuperview];
    }];
}

@end