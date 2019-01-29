//
//  UploadAlertView.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "FileMoreAlertView.h"

@interface FileMoreAlertView ()

@property (weak, nonatomic) IBOutlet UILabel *fileNameLab;
@property (weak, nonatomic) IBOutlet UIImageView *icon;

@end

@implementation FileMoreAlertView

+ (instancetype)getInstance {
    FileMoreAlertView *view = [[[NSBundle mainBundle] loadNibNamed:@"FileMoreAlertView" owner:self options:nil] lastObject];
    return view;
}

#pragma mark - Operation
- (void)showWithFileName:(NSString *)fileName fileType:(NSNumber *)fileType {
    self.fileNameLab.text = fileName;
    NSString *fileImgStr = @"";
    if ([fileType integerValue] == 1) { // 图片
        fileImgStr = @"icon_picture_small_gray";
    } else if ([fileType integerValue] == 4) { // 视频
        fileImgStr = @"icon_video_small_gray";
    } else if ([fileType integerValue] == 5) { // 文档
        fileImgStr = @"icon_document_small_gray";
    } else if ([fileType integerValue] == 6) { // 其他
        fileImgStr = @"icon_other_small_gray";
    }
    _icon.image = [UIImage imageNamed:fileImgStr];
    
    [AppD.window addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(AppD.window).offset(0);
    }];
    
    self.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
    }];
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
