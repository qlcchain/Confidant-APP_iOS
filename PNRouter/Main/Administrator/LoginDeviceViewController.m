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
#import "RoutherConfig.h"
#import "PNRouter-Swift.h"
#import "SystemUtil.h"

@interface LoginDeviceViewController ()

@property (weak, nonatomic) IBOutlet UITextField *devicePWTF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation LoginDeviceViewController

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceLoginSuccessNoti:) name:DEVICE_LOGIN_SUCCESS_NOTI object:nil];
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
    [_loginBtn setRoundedCorners:UIRectCornerAllCorners radius:4];
}

- (void)sendLogin {
    NSString *mac = [RoutherConfig getRoutherConfig].currentRouterMAC?:@"";
    NSString *loginKey = [_devicePWTF.text.trim SHA256];
    [SendRequestUtil sendRouterLoginWithMac:mac loginKey:loginKey showHud:YES];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)loginAction:(id)sender {
    NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
    if (connectStatu == socketConnectStatusConnected) {
        [self sendLogin];
    } else {
        [self connectSocket];
    }
}

#pragma mark - Transition
- (void)jumpToAccountManagement:(NSDictionary *)receiveDic {
    NSString *RouterId = receiveDic[@"params"][@"RouterId"];
    NSString *Qrcode = receiveDic[@"params"][@"Qrcode"];
    NSString *IdentifyCode = receiveDic[@"params"][@"IdentifyCode"];
    NSString *UserSn = receiveDic[@"params"][@"UserSn"];
    AccountManagementViewController *vc = [[AccountManagementViewController alloc] init];
    vc.RouterId = RouterId;
    vc.Qrcode = Qrcode;
    vc.IdentifyCode = IdentifyCode;
    vc.UserSn = UserSn;
    vc.RouterPW = _devicePWTF.text?:@"";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Noti
- (void)deviceLoginSuccessNoti:(NSNotification *)noti {
    NSDictionary *dic = [noti object];
    [self jumpToAccountManagement:dic];
}

#pragma mark -连接socket
- (void) connectSocket {
    NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
    if (connectStatu == socketConnectStatusConnected) {
        [[SocketUtil shareInstance] disconnect];
    }    // 连接
    [AppD.window showHudInView:AppD.window hint:@"Connect Router..."];
    NSString *connectURL = [SystemUtil connectUrl];
    [SocketUtil.shareInstance connectWithUrl:connectURL];
}

#pragma mark -通知回调
- (void)socketOnConnect:(NSNotification *)noti {
    [AppD.window hideHud];
    [self sendLogin];
}

- (void)socketOnDisconnect:(NSNotification *)noti {
    [AppD.window hideHud];
    [AppD.window showHint:@"The connection fails"];
}

@end
