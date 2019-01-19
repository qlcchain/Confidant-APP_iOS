//
//  LoginDeviceViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "ModifyActivateCodeViewController.h"

@interface ModifyActivateCodeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *activationCodeTF;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;


@end

@implementation ModifyActivateCodeViewController

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetUserIdcodeSuccessNoti:) name:ResetUserIdcode_SUCCESS_NOTI object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = MAIN_WHITE_COLOR;
    [self addObserve];
    [self renderView];
}

#pragma mark - Operation
- (void)renderView {
    [_updateBtn setRoundedCorners:UIRectCornerAllCorners radius:4];
}

- (void)sendResetUserIdcode {
    NSString *RouterId = _RouterId?:@"";
    NSString *UserSn = _UserSn?:@"";
    NSString *OldCode = _IdentifyCode?:@"";
    NSString *NewCode = _activationCodeTF.text?:@"";
    [SendRequestUtil sendResetUserIdcodeWithRouterId:RouterId UserSn:UserSn OldCode:OldCode NewCode:NewCode showHud:YES];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)updateAction:(id)sender {
    if (_activationCodeTF.text == nil || _activationCodeTF.text.length != 8) {
        [AppD.window showHint:@"Your activation code must include 8 charactors."];
        return;
    }
    
    [self sendResetUserIdcode];
}

#pragma mark - Noti
- (void)resetUserIdcodeSuccessNoti:(NSNotification *)noti {
    [AppD.window showHint:@"Successful"];
}

@end
