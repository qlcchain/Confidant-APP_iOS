//
//  UploadAlertView.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "ArrangeAlertView.h"

@interface ArrangeAlertView ()

@property (weak, nonatomic) IBOutlet UIImageView *nameSelect;
@property (weak, nonatomic) IBOutlet UIImageView *timeSelect;
@property (weak, nonatomic) IBOutlet UIImageView *sizeSelect;
@property (nonatomic) ArrangeType arrangeType;

@end

@implementation ArrangeAlertView

+ (instancetype)getInstance {
    ArrangeAlertView *view = [[[NSBundle mainBundle] loadNibNamed:@"ArrangeAlertView" owner:self options:nil] lastObject];
    return view;
}

#pragma mark - Operation
- (void)showWithArrange:(ArrangeType)type {
    _arrangeType = type;
    [self refreshSelect];
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

- (void)refreshSelect {
    _nameSelect.hidden = _arrangeType == ArrangeTypeByName?NO:YES;
    _timeSelect.hidden = _arrangeType == ArrangeTypeByTime?NO:YES;
    _sizeSelect.hidden = _arrangeType == ArrangeTypeBySize?NO:YES;
}

#pragma mark - Action

- (IBAction)arrangeByNameAction:(id)sender {
    _arrangeType = ArrangeTypeByName;
    [self refreshSelect];
    if (_clickB) {
        _clickB(_arrangeType);
    }
    [self hide];
}

- (IBAction)arrangeByTimeAction:(id)sender {
    _arrangeType = ArrangeTypeByTime;
    [self refreshSelect];
    if (_clickB) {
        _clickB(_arrangeType);
    }
    [self hide];
}

- (IBAction)arrangeBySizeAction:(id)sender {
    _arrangeType = ArrangeTypeBySize;
    [self refreshSelect];
    if (_clickB) {
        _clickB(_arrangeType);
    }
    [self hide];
}

- (IBAction)cancelAction:(id)sender {
    [self hide];
}


@end
