//
//  UploadAlertView.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "UploadAlertView.h"

@interface UploadAlertView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *otherHeight;

@end

@implementation UploadAlertView

+ (instancetype)getInstance {
    UploadAlertView *view = [[[NSBundle mainBundle] loadNibNamed:@"UploadAlertView" owner:self options:nil] lastObject];
    view.otherHeight.constant = 0;
    return view;
}
- (IBAction)backBtnAction:(id)sender {
    [self hide];
}

#pragma mark - Operation
- (void)show {
    [AppD.window addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(AppD.window).offset(0);
    }];
    
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
//    self.bottomViewBottom.constant = -276;
//    [UIView animateWithDuration:0.5 animations:^{
//        self.bottomViewBottom.constant = 0;
//        [self layoutIfNeeded];
//    }];
}

- (void)hide {
    self.alpha = 1;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
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
