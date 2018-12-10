//
//  SocketAlertView.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/14.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "SocketAlertView.h"
#import "PNRouter-Swift.h"
#import "SystemUtil.h"
#import "SocketCountUtil.h"
#import "RoutherConfig.h"

@implementation SocketAlertView
+ (instancetype) loadSocketAlertView
{
    SocketAlertView *sockView =[[[NSBundle mainBundle] loadNibNamed:@"SocketAlertView" owner:self options:nil] lastObject];
    sockView.frame = [UIScreen mainScreen].bounds;
    return sockView;
}
- (void)awakeFromNib
{
    _backView.layer.cornerRadius = 5.0f;
    _backView.layer.masksToBounds = YES;
    [super awakeFromNib];
}
- (IBAction)okAction:(id)sender {
    
    _isShow = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    [SocketCountUtil getShareObject].reConnectCount = 0;
    [AppD.window showHudInView:AppD.window hint:@"connection..."];
    NSString *connectURL = [NSString stringWithFormat:@"https://%@:18006",[RoutherConfig getRoutherConfig].currentRouterIp];
    [SocketUtil.shareInstance connectWithUrl:connectURL];
}

- (void) showAlertView
{
    _isShow = YES;
    [AppD.window addSubview:self];
    self.alpha = 0.0f;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
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
