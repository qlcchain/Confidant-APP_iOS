//
//  PNSetEmailPassView.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/10/28.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNSetEmailPassView.h"
#import "NSString+EmptyUtil.h"

@interface PNSetEmailPassView()<UITextFieldDelegate>

@end

@implementation PNSetEmailPassView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (EmailPassModel *)passM
{
    if (!_passM) {
        _passM = [[EmailPassModel alloc] init];
    }
    return _passM;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(_backView.bounds)) byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(16,16)];//圆角大小
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(_backView.bounds));//_backView.bounds;
    maskLayer.path = maskPath.CGPath;
    _backView.layer.mask = maskLayer;
    
    _setPassBtn.layer.cornerRadius = 8.0f;
    _setPassBtn.layer.masksToBounds = YES;
    
    _msetPassBtn.layer.cornerRadius = 8.0f;
    _msetPassBtn.layer.masksToBounds = YES;
    
    _removeBtn.layer.cornerRadius = 8.0f;
    _removeBtn.layer.borderWidth = 1.0f;
    _removeBtn.layer.borderColor = MAIN_PURPLE_COLOR.CGColor;
    _removeBtn.layer.masksToBounds = YES;
    
    _pasView.layer.cornerRadius = 5.0f;
    _pasView.layer.masksToBounds = YES;
    
    _depassView.layer.cornerRadius = 5.0f;
    _depassView.layer.masksToBounds = YES;
    
    _hintView.layer.cornerRadius = 5.0f;
    _hintView.layer.masksToBounds = YES;
    
}

+ (instancetype) loadPNSetEmailPassView
{
    PNSetEmailPassView *view = [[[NSBundle mainBundle] loadNibNamed:@"PNSetEmailPassView" owner:self options:nil] lastObject];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    view.downContraintV.constant = -370;
    view.hitTF.delegate = view;
    view.passTF.delegate = view;
    view.depassTF.delegate = view;
    [view layoutIfNeeded];
    return view;
}

- (void) showEmailSetPassView:(UIView *) supView
{
    if (!self.passM.isSet) {
        _setPassBtn.hidden = NO;
        _removeBtn.hidden = YES;
        _msetPassBtn.hidden = YES;
        
        _passTF.text= @"";
        _depassTF.text = @"";
        _hitTF.text = @"";
        
    } else {
        _setPassBtn.hidden = YES;
        _removeBtn.hidden = NO;
        _msetPassBtn.hidden = NO;
        
        _passTF.text= _passM.passStr?: @"";
        _depassTF.text = _passM.depassStr?: @"";
        _hitTF.text = _passM.hintStr?: @"";
    }
    
    [supView addSubview:self];
    _downContraintV.constant = 0;
    @weakify_self
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf layoutIfNeeded];
    }];
}

- (IBAction)clickRemoveBtn:(id)sender {
    _passTF.text= @"";
    _depassTF.text = @"";
    _hitTF.text = @"";
    self.passM.isSet = NO;
    self.passM.passStr = @"";
    self.passM.depassStr = @"";
    self.passM.hintStr = @"";
    if (_clickSetPassB) {
        _clickSetPassB(NO);
    }
}
- (IBAction)clickMsetPassBtn:(id)sender {
    [self clickSetPassBtn:nil];
}
- (IBAction)clickSetPassBtn:(id)sender {
    
    [self endEditing:YES];
    
    if (self.passM.passStr && self.passM.passStr.length > 0) {
        if ([self.passM.passStr isEqualToString:[NSString getNotNullValue:self.passM.depassStr]]) {
            self.passM.isSet = YES;
            [self hidePNSetEmailPassView];
            if (_clickSetPassB) {
                _clickSetPassB(YES);
            }
        } else {
            [self showHint:@"Inconsistent password"];
        }
    } else {
        [self showHint:@"The password cannot be empty."];
    }
}
- (IBAction)clickCloseBtn:(id)sender {
    [self hidePNSetEmailPassView];
}

- (void) hidePNSetEmailPassView
{
    _downContraintV.constant = -370;
    @weakify_self
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _passTF) {
        self.passM.passStr = textField.text.trim;
    } else if (textField == _depassTF) {
        self.passM.depassStr = textField.text.trim;
    }if (textField == _hitTF) {
        self.passM.hintStr = textField.text.trim;
    }
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _passTF) {
       return  [_depassTF becomeFirstResponder];
    } else if (textField == _depassTF) {
        return  [_hitTF becomeFirstResponder];
    } else {
        [self endEditing:YES];
        return YES;
    }
}
@end
