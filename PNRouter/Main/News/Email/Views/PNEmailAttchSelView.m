//
//  PNEmailAttchSelView.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/24.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNEmailAttchSelView.h"

@implementation PNEmailAttchSelView

+ (instancetype) loadPNEmailAttchSelView
{
    PNEmailAttchSelView *view = [[[NSBundle mainBundle] loadNibNamed:@"PNEmailAttchSelView" owner:self options:nil] lastObject];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    view.backContraintBottom.constant = -145;
    [view layoutIfNeeded];
    
    return view;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_backV.bounds byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(16,16)];//圆角大小
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];    maskLayer.frame = _backV.bounds;    maskLayer.path = maskPath.CGPath;
    _backV.layer.mask = maskLayer;
    
}

- (IBAction)clickBackAction:(id)sender {
    
    [self hideEmailAttchSelView];
    
}
- (IBAction)clickItemAction:(UIButton *)sender {
    [self hideEmailAttchSelView];
    if (_emumBlock) {
        _emumBlock(sender.tag);
    }
}

- (void) showEmailAttchSelView
{
    [AppD.window addSubview:self];
    _backContraintBottom.constant = 0;
    @weakify_self
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf layoutIfNeeded];
    }];
}

- (void) hideEmailAttchSelView
{
    _backContraintBottom.constant = -145;
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
