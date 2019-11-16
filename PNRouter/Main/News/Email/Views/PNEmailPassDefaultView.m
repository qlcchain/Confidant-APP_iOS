//
//  PNEmailPassDefaultView.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/10/29.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNEmailPassDefaultView.h"
#import <LFKit/LFBubbleView.h>
#import <LFKit/LFBubbleViewDefaultConfig.h>
@interface PNEmailPassDefaultView ()
@property (nonatomic ,strong)LFBubbleView *bubbleView;
@end

@implementation PNEmailPassDefaultView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (LFBubbleView *)bubbleView
{
    if (!_bubbleView) {
        
        [LFBubbleViewDefaultConfig sharedInstance].textColor = MAIN_PURPLE_COLOR;
        [LFBubbleViewDefaultConfig sharedInstance].font = [UIFont systemFontOfSize:14];
        [LFBubbleViewDefaultConfig sharedInstance].color = MAIN_WHITE_COLOR;
        [LFBubbleViewDefaultConfig sharedInstance].triangleH = 5;
        [LFBubbleViewDefaultConfig sharedInstance].edgeInsets = UIEdgeInsetsMake(5, 16, 5, 16);
      
        
        _bubbleView  = [[LFBubbleView alloc] initWithFrame:CGRectMake(0, 0, 250, 100)];
        _bubbleView.lbTitle.text = @"The password is set by the sender to encrypt this email.";
        _bubbleView.direction = LFTriangleDirection_Down;
        _bubbleView.triangleXY = _ywBtn.center.x-50;
        
        
    }
    return _bubbleView;
}

+ (instancetype) loadPNEmailPassDefaultView
{
    PNEmailPassDefaultView *view = [[[NSBundle mainBundle] loadNibNamed:@"PNEmailPassDefaultView" owner:self options:nil] lastObject];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    view.backgroundColor = MAIN_GRAY_COLOR;
    view.decyBtn.layer.cornerRadius = 8.0f;
    view.decyBtn.layer.masksToBounds = YES;
    view.tfBackView.layer.cornerRadius = 8.0f;
    view.tfBackView.layer.masksToBounds = YES;
    return view;
}
- (void) showEmailPassDefaultView:(UIView *) supView frameY:(CGFloat)frameY
{
    [supView addSubview:self];
    CGRect rect = self.frame;
    rect.origin.y = frameY;
    self.frame = rect;
//    @weakify_self
//    [UIView animateWithDuration:0.3 animations:^{
//        weakSelf.frame = rect;
//    }];
}
- (IBAction)clickDoubtBtn:(UIButton *)sender {
    if (sender.isSelected == NO) {
        sender.selected = YES;
        [self addSubview:self.bubbleView];
        [self.bubbleView showInPoint:CGPointMake(sender.center.x, sender.center.y - 13)];
        
    } else {
        sender.selected = NO;
        self.bubbleView.dismissAfterSecond = 0.5;
    }
    
}
- (IBAction)clickDecryBtn:(id)sender {
    if (_passTF.text.trim.length >0) {
        if (_clickDecryptPassB) {
            NSString *passkey = @"";
            if (_passTF.text.trim.length > 16) {
                passkey = [_passTF.text.trim substringToIndex:16];
            } else {
                passkey = _passTF.text.trim;
                while (passkey.length < 16) {
                    passkey = [passkey stringByAppendingString:@"0"];
                }
            }
            _clickDecryptPassB(passkey);
        }
    } else {
        [self showHint:@"The password cannot be empty."];
    }
   
}

- (void) hideEmailPassDefaultView
{
    CGRect rect = self.frame;
    rect.origin.y = SCREEN_HEIGHT;
    @weakify_self
    [UIView animateWithDuration:0.3 animations:^{
        weakSelf.frame = rect;
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

@end
