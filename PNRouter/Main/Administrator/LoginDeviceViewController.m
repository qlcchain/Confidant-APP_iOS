//
//  LoginDeviceViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "LoginDeviceViewController.h"
#import "SendRequestUtil.h"
#import "NSString+SHA256.h"
#import "AccountManagementViewController.h"

@interface LoginDeviceViewController ()

@property (weak, nonatomic) IBOutlet UITextField *devicePWTF;

@end

@implementation LoginDeviceViewController

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceLoginSuccessNoti:) name:DEVICE_LOGIN_SUCCESS_NOTI object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
}

#pragma mark - Operation
- (void)sendLogin {
    NSString *mac = _mac?:@"";
    NSString *loginKey = [_devicePWTF.text.trim SHA256];
    [SendRequestUtil sendRouterLoginWithMac:mac loginKey:loginKey showHud:YES];
}

#pragma mark - Action

- (IBAction)loginAction:(id)sender {
    [self sendLogin];
}

#pragma mark - Transition
- (void)jumpToAccountManagement {
    AccountManagementViewController *vc = [[AccountManagementViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Noti
- (void)deviceLoginSuccessNoti:(NSNotification *)noti {
    [self jumpToAccountManagement];
}

@end
