//
//  PNRecevieQLCAddressView.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/18.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNRecevieQLCAddressView.h"

@implementation PNRecevieQLCAddressView
- (IBAction)backAction:(id)sender {
    [self hidePNRecevieQLCAddressView];
}
- (IBAction)editAction:(UIButton *)sender {
    if (_editBlock) {
        _backV.constant = -220;
        [self layoutIfNeeded];
        [self removeFromSuperview];
        _editBlock(sender.tag);
    }
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(_backView.bounds)) byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(16,16)];//圆角大小
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(_backView.bounds));//_backView.bounds;
    maskLayer.path = maskPath.CGPath;
    _backView.layer.mask = maskLayer;
}

+ (instancetype) loadPNRecevieQLCAddressView
{
    PNRecevieQLCAddressView *view = [[[NSBundle mainBundle] loadNibNamed:@"PNRecevieQLCAddressView" owner:self options:nil] lastObject];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    view.backV.constant = -220;
    [view layoutIfNeeded];
    return view;
}
- (void) showPNRecevieQLCAddressView
{
    [AppD.window addSubview:self];
    _backV.constant = 0;
       @weakify_self
       [UIView animateWithDuration:0.3 animations:^{
           [weakSelf layoutIfNeeded];
       }];
}
- (void) hidePNRecevieQLCAddressView
{
    _backV.constant = -220;
    @weakify_self
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
        if (weakSelf.closeBlock) {
            weakSelf.closeBlock();
        }
    }];
}
@end
