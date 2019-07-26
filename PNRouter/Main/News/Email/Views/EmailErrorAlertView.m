//
//  EmailErrorAlertView.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/26.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EmailErrorAlertView.h"

@implementation EmailErrorAlertView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
+ (instancetype)loadEmailErrorAlertView
{
    EmailErrorAlertView *view = [[[NSBundle mainBundle] loadNibNamed:@"EmailErrorAlertView" owner:self options:nil] lastObject];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    view.backView.layer.cornerRadius = 8;
    view.backView.layer.masksToBounds = YES;
    
    view.bottomH.constant = SCREEN_HEIGHT/2+ 108;
    [view layoutIfNeeded];
    
    return view;
}
- (IBAction)clickCloseBtn:(id)sender {
    [self hideEmailAttchSelView];
}

- (void) showEmailAttchSelView
{
    [AppD.window addSubview:self];
    _bottomH.constant = -20;
    @weakify_self
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf layoutIfNeeded];
    }];
}

- (void) hideEmailAttchSelView
{
    _bottomH.constant = SCREEN_HEIGHT/2+ 108;
    @weakify_self
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

@end
