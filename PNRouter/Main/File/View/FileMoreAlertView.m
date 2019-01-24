//
//  UploadAlertView.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "FileMoreAlertView.h"

@implementation FileMoreAlertView

+ (instancetype)getInstance {
    FileMoreAlertView *view = [[[NSBundle mainBundle] loadNibNamed:@"FileMoreAlertView" owner:self options:nil] lastObject];
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
- (IBAction)sendAction:(id)sender {
    if (_sendB) {
        _sendB();
    }
    [self hide];
}

- (IBAction)downloadAction:(id)sender {
    if (_downloadB) {
        _downloadB();
    }
    [self hide];
}

- (IBAction)otherApplicationOpenAction:(id)sender {
    if (_otherApplicationOpenB) {
        _otherApplicationOpenB();
    }
    [self hide];
}

- (IBAction)detailInformationAction:(id)sender {
    if (_detailInformationB) {
        _detailInformationB();
    }
    [self hide];
}

- (IBAction)renameAction:(id)sender {
    if (_renameB) {
        _renameB();
    }
    [self hide];
}

- (IBAction)deleteAction:(id)sender {
    if (_deleteB) {
        _deleteB();
    }
    [self hide];
}

- (IBAction)cancelAction:(id)sender {
    [self hide];
}


@end
