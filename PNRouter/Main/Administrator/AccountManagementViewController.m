//
//  AccountManagementViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "AccountManagementViewController.h"
#import "HMScanner.h"
#import "ModifyRouterPWViewController.h"
#import "ModifyActivateCodeViewController.h"

@interface AccountManagementViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *qrImgV;
@property (weak, nonatomic) IBOutlet UILabel *activitionCodeLab;


@end

@implementation AccountManagementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor = MAIN_WHITE_COLOR;
    
    [self viewInit];
}

#pragma mark - Operation

- (void)viewInit {
    @weakify_self
    [HMScanner qrImageWithString:_Qrcode?:@"" avatar:nil completion:^(UIImage *image) {
        weakSelf.qrImgV.image = image;
    }];
    
    _activitionCodeLab.text = _RouterPW?:@"";
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loginAction:(id)sender {
    
}

- (IBAction)activitionCodeAction:(id)sender {
    [self jumpToModifyActivateCode];
}

- (IBAction)routerPWAction:(id)sender {
    [self jumpToModifyRouterPW];
}

#pragma mark - Transition
- (void)jumpToModifyRouterPW {
    ModifyRouterPWViewController *vc = [[ModifyRouterPWViewController alloc] init];
    vc.RouterId = _RouterId;
    vc.RouterPW = _RouterPW;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToModifyActivateCode {
    ModifyActivateCodeViewController *vc = [[ModifyActivateCodeViewController alloc] init];
    vc.RouterId = _RouterId;
    vc.IdentifyCode = _IdentifyCode;
    vc.UserSn = _UserSn;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
