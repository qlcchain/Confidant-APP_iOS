//
//  ConnectView.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/12/6.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "ConnectView.h"

@implementation ConnectView

- (void)awakeFromNib
{
    _backView.layer.cornerRadius = 8.0f;
    [super awakeFromNib];
}

+ (instancetype) loadConnectView
{
    ConnectView *connectView = [[[NSBundle mainBundle] loadNibNamed:@"ConnectView" owner:self options:nil] lastObject];
    connectView.frame = CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT);
    return connectView;

}

- (IBAction)cacelAction:(id)sender {
    AppD.currentRouterNumber = -1;
    [self hiddenConnectView];
}

- (void) showConnectView
{
    [AppD.window addSubview:self];
    self.alpha = 0.0f;
    [self.activeView startAnimating];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0f;
    }];
    
}
- (void) hiddenConnectView
{
    [UIView animateWithDuration:0.3f animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.activeView stopAnimating];
        [self removeFromSuperview];
    }];
}

@end
