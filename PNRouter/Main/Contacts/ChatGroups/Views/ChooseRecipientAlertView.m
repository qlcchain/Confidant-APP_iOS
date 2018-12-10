//
//  ChooseRecipientAlertView.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/25.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ChooseRecipientAlertView.h"

@implementation ChooseRecipientAlertView
+ (instancetype) loadChooseRecipientAlertView
{
    ChooseRecipientAlertView *sockView =[[[NSBundle mainBundle] loadNibNamed:@"ChooseRecipientAlertView" owner:self options:nil] lastObject];
    sockView.frame = [UIScreen mainScreen].bounds;
    return sockView;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    _backView.layer.masksToBounds = YES;
    _backView.layer.cornerRadius = 5.0f;
}
- (IBAction)cancelAction:(id)sender {
     [self hideAlertView];
}
- (IBAction)sendAction:(id)sender {
     [self hideAlertView];
}
- (void) showAlertView
{
    [AppD.window addSubview:self];
    self.alpha = 0.0f;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}
- (void) hideAlertView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
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
