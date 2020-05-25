//
//  PNBindQLCAddressView.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/14.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNBindQLCAddressView.h"
#import <QLCFramework/QLCWalletManage.h>

@implementation PNBindQLCAddressView

- (IBAction)closeAction:(id)sender {
    [self hidePNBindQLCAddressView];
}
- (IBAction)bindAction:(id)sender {
    [self endEditing:YES];
    NSString *neoStr = [_neoTF.text trim];
    if (neoStr.length == 0) {
        [self showHint:@"Please input a Nep-5 address for receiving QLC rewards"];
        return;
    }
    if (!([neoStr hasPrefix:@"A"] && neoStr.length == 34)) {
        [self showHint:@"This Nep-5 address in invalid"];
        return;
    }
    NSString *qlcStr = [_qlcTF.text trim];
    if (qlcStr.length == 0) {
        [self showHint:@"Please input a QLC Chain address for receiving QGas rewards"];
        return;
    }
    if (![[QLCWalletManage shareInstance] walletAddressIsValid:qlcStr]) {
        [self showHint:@"This QLC Chain address is invalid"];
        return;
    }
    NSString *addresss = [NSString stringWithFormat:@"%@,%@",neoStr,qlcStr];
    [SendRequestUtil sendBakWalletAccountWithWalletType:@"1,2" walletAddress:addresss showHud:YES];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _neoBackView.layer.cornerRadius = 8.0f;
    _qlcBackView.layer.cornerRadius = 8.0f;
    _bindBtn.layer.cornerRadius = 8.0f;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(_bindBackView.bounds)) byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(16,16)];//圆角大小
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(_bindBackView.bounds));//_backView.bounds;
    maskLayer.path = maskPath.CGPath;
    _bindBackView.layer.mask = maskLayer;
    
}

+ (instancetype) loadPNBindQLCAddressView
{
    PNBindQLCAddressView *view = [[[NSBundle mainBundle] loadNibNamed:@"PNBindQLCAddressView" owner:self options:nil] lastObject];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    view.neoTF.delegate = view;
    view.qlcTF.delegate = view;
    view.bottomV.constant = -350;
    [view layoutIfNeeded];
    return view;
}

- (void) showPNBindQLCAddressView:(UIView *) supView
{
    [supView addSubview:self];
    _bottomV.constant = 0;
    @weakify_self
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf layoutIfNeeded];
    }];
}

- (void) hidePNBindQLCAddressView
{
    [self endEditing:YES];
    _bottomV.constant = -350;
    @weakify_self
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
        if (weakSelf.closeBlock) {
            weakSelf.closeBlock();
        }
    }];
}


#pragma mark ---textfeild delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == _neoTF) {
       return [_qlcTF becomeFirstResponder];
    }
    return  [textField resignFirstResponder];
}
@end
