//
//  UploadAlertView.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "UploadAlertView.h"

@implementation UploadAlertView

+ (instancetype)getInstance {
    UploadAlertView *view = [[[NSBundle mainBundle] loadNibNamed:@"UploadAlertView" owner:self options:nil] lastObject];
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

- (IBAction)uploadPhotosAction:(id)sender {
    if (_photoB) {
        _photoB();
    }
    [self hide];
}

- (IBAction)uploadVideoAction:(id)sender {
    if (_videoB) {
        _videoB();
    }
    [self hide];
}

- (IBAction)uploadDocumentAction:(id)sender {
    if (_documentB) {
        _documentB();
    }
    [self hide];
}

- (IBAction)uploadOtherAction:(id)sender {
    if (_otherB) {
        _otherB();
    }
    [self hide];
}

- (IBAction)cancelAction:(id)sender {
    [self hide];
}


@end
