//
//  PNFileOptionView.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/26.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNFileOptionView.h"

@implementation PNFileOptionView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(_backV.bounds)) byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(15,15)];//圆角大小
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(_backV.bounds));//_backView.bounds;
    maskLayer.path = maskPath.CGPath;
    _backV.layer.mask = maskLayer;
}

+ (instancetype) loadPNFileOptionView
{
    PNFileOptionView *view = [[[NSBundle mainBundle] loadNibNamed:@"PNFileOptionView" owner:self options:nil] lastObject];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    view.backContraintV.constant = -156;
    [view layoutIfNeeded];
    return view;
}

- (IBAction)ClickBackBtn:(id)sender {
    [self hideOptionEnumView];
}
- (IBAction)clickDeleteBtn:(id)sender {
    if (_clickMenuBlock) {
        _clickMenuBlock(20);
    }
    [self hideOptionEnumView];
}
- (IBAction)clickBackUpBtn:(id)sender {
    if (_clickMenuBlock) {
        _clickMenuBlock(10);
    }
    [self hideOptionEnumView];
}

- (void) showOptionEnumView
{
    [AppD.window addSubview:self];
    _backContraintV.constant = 0;
    @weakify_self
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf layoutIfNeeded];
    }];
}

- (void) hideOptionEnumView
{
    _backContraintV.constant = -156;
    @weakify_self
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
