//
//  LoginDeviceViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "ModifyRouterPWViewController.h"

@interface ModifyRouterPWViewController ()

@property (weak, nonatomic) IBOutlet UITextField *pwOldTF;
@property (weak, nonatomic) IBOutlet UITextField *pwNewTF;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;

@end

@implementation ModifyRouterPWViewController

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetRouterKeySuccessNoti:) name:ResetRouterKey_SUCCESS_NOTI object:nil];
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

- (void)sendResetRouterKey {
    NSString *RouterId = _RouterId?:@"";
    NSString *OldKey = _pwOldTF.text?:@"";
    NSString *NewKey = _pwNewTF.text?:@"";
    [SendRequestUtil sendResetRouterKeyWithRouterId:RouterId OldKey:OldKey NewKey:NewKey showHud:YES];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)updateAction:(id)sender {
    if (_pwOldTF.text == nil) {
        [AppD.window showHint:@"Old password is empty"];
        return;
    }
    if ([_pwOldTF.text isEqualToString:_RouterPW]) {
        [AppD.window showHint:@"Old password is wrong"];
        return;
    }
    
    if (_pwNewTF.text == nil) {
        [AppD.window showHint:@"New password is empty"];
        return;
    }
    
    [self sendResetRouterKey];
}

#pragma mark - Noti
- (void)resetRouterKeySuccessNoti:(NSNotification *)noti {
    [AppD.window showHint:@"Successful"];
}


@end
