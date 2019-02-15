//
//  MnemonicTipView.m
//  Qlink
//
//  Created by Jelly Foo on 2018/10/23.
//  Copyright © 2018 pan. All rights reserved.
//

#import "DiskToastView.h"
#import "UIView+Visuals.h"

@interface DiskToastView ()

@property (weak, nonatomic) IBOutlet UIView *tipBack;
@property (weak, nonatomic) IBOutlet UILabel *tipLab;

@end

@implementation DiskToastView

+ (instancetype)getInstance {
    DiskToastView *view = [[[NSBundle mainBundle] loadNibNamed:@"DiskToastView" owner:self options:nil] lastObject];
    [view.tipBack setRoundedCorners:UIRectCornerAllCorners radius:8];
    return view;
}

- (void)showWithTitle:(NSString *)title {
    _tipLab.text = title;
    self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [AppD.window addSubview:self];
}

- (void)hide {
    [self removeFromSuperview];
}


@end
