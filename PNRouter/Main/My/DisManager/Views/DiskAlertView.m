//
//  MnemonicTipView.m
//  Qlink
//
//  Created by Jelly Foo on 2018/10/23.
//  Copyright © 2018 pan. All rights reserved.
//

#import "DiskAlertView.h"

@interface DiskAlertView ()

@property (weak, nonatomic) IBOutlet UIView *tipBack;
@property (weak, nonatomic) IBOutlet UILabel *tipLab;

@end

@implementation DiskAlertView

+ (instancetype)getInstance {
    DiskAlertView *view = [[[NSBundle mainBundle] loadNibNamed:@"DiskAlertView" owner:self options:nil] lastObject];
    view.tipBack.layer.cornerRadius = 8;
    view.tipBack.layer.masksToBounds = YES;
    return view;
}

- (void)show {
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [AppD.window addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.left.right.mas_equalTo(AppD.window).offset(0);
    }];
}

- (void)hide {
    [self removeFromSuperview];
}

- (IBAction)okAction:(id)sender {
    if (_okBlock) {
        _okBlock();
    }
    [self hide];
}

@end
