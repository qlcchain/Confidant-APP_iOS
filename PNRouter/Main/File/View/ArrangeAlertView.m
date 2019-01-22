//
//  UploadAlertView.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "ArrangeAlertView.h"

@implementation ArrangeAlertView

+ (instancetype)getInstance {
    ArrangeAlertView *view = [[[NSBundle mainBundle] loadNibNamed:@"ArrangeAlertView" owner:self options:nil] lastObject];
    return view;
}

#pragma mark - Operation
- (void)show {
    [AppD.window addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(AppD.window).offset(0);
    }];
}

- (void)hide {
    [self removeFromSuperview];
}

#pragma mark - Action

- (IBAction)arrangeByNameAction:(id)sender {
    [self hide];
}

- (IBAction)arrangeByTimeAction:(id)sender {
    [self hide];
}

- (IBAction)arrangeBySizeAction:(id)sender {
    [self hide];
}

- (IBAction)cancelAction:(id)sender {
    [self hide];
}


@end
