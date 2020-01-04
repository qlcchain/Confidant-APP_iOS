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
#import "RouterConfig.h"
#import "MyConfidant-Swift.h"
#import "SystemUtil.h"
#import "RouterAliasViewController.h"
#import "NSString+Base64.h"

@interface LoginDeviceViewController ()<UITextFieldDelegate>
{
    BOOL isLoginDeviceViewController;
    BOOL isClickConnect;
}
@property (weak, nonatomic) IBOutlet UITextField *devicePWTF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@end

@implementation LoginDeviceViewController

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceLoginSuccessNoti:) name:DEVICE_LOGIN_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnConnect:) name:SOCKET_ON_CONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnDisconnect:) name:SOCKET_ON_DISCONNECT_NOTI object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated
{
    isLoginDeviceViewController = YES;
    [super viewDidAppear:animated];
}
- (void) viewDidDisappear:(BOOL)animated
{
    isLoginDeviceViewController = NO;
    [super viewDidDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    AppD.isLoginMac = YES;
    _devicePWTF.delegate = self;
    [self addObserve];
    [self renderView];
}

#pragma mark - Operation
- (void)renderView {
    _loginBtn.layer.cornerRadius = 4;
    _loginBtn.layer.masksToBounds = YES;
//    [_loginBtn setRoundedCorners:UIRectCornerAllCorners radius:4];
}

- (void)sendLogin {
    //AppD.manager = nil;  tox_stop
    AppD.currentRouterNumber = -1;
    NSString *mac = [RouterConfig getRouterConfig].currentRouterMAC?:@"";
    NSString *loginKey = [_devicePWTF.text.trim SHA256];
    [SendRequestUtil sendRouterLoginWithMac:mac loginKey:loginKey showHud:YES];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
   
    AppD.isLoginMac = NO;
    NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
    if (connectStatu == socketConnectStatusConnected) {
        [[SocketUtil shareInstance] disconnect];
    }
    [RouterConfig getRouterConfig].currentRouterIp = @"";
    [RouterConfig getRouterConfig].currentRouterMAC = @"";
    [[NSNotificationCenter defaultCenter] postNotificationName:CANCEL_LOGINMAC_NOTI object:nil];
    if (self.navigationController.viewControllers.count == 1) {
        [AppD setRootLoginWithType:RouterType];
    } else {
        [self leftNavBarItemPressedWithPop:YES];
    }
   
}

- (IBAction)loginAction:(id)sender {
    [self.view endEditing:YES];
    if ([[NSString getNotNullValue:_devicePWTF.text.trim] isEmptyString] || _devicePWTF.text.trim.length !=8) {
        [self.view showHint:@"Your password must include 8 charactors."];
        return;
    }
    isClickConnect = YES;
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
    NSString *RouterName = receiveDic[@"params"][@"RouterName"];

    [RouterConfig getRouterConfig].currentRouterSn = UserSn;

    AccountManagementViewController *vc = [[AccountManagementViewController alloc] init];
    vc.RouterId = RouterId;
    vc.Qrcode = Qrcode;
    vc.IdentifyCode = IdentifyCode;
    vc.UserSn = UserSn;
    vc.RouterPW = _devicePWTF.text?:@"";
    vc.routerAlias = [RouterName base64DecodedString];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToRouterAlias:(NSDictionary *)receiveDic {
    NSString *RouterId = receiveDic[@"params"][@"RouterId"];
    NSString *Qrcode = receiveDic[@"params"][@"Qrcode"];
    NSString *IdentifyCode = receiveDic[@"params"][@"IdentifyCode"];
    NSString *UserSn = receiveDic[@"params"][@"UserSn"];
    
    [RouterConfig getRouterConfig].currentRouterSn = UserSn;
    
    RouterAliasViewController *vc = [[RouterAliasViewController alloc] init];
    vc.RouterId = RouterId;
    vc.Qrcode = Qrcode;
    vc.IdentifyCode = IdentifyCode;
    vc.UserSn = UserSn;
    vc.RouterPW = _devicePWTF.text?:@"";
    vc.finishBack = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Noti
- (void)deviceLoginSuccessNoti:(NSNotification *)noti {
    NSDictionary *receiveDic = [noti object];
    NSString *RouterName = receiveDic[@"params"][@"RouterName"];
    if (!RouterName || RouterName.length <= 0) {
        [self jumpToRouterAlias:receiveDic];
    } else {
        [self jumpToAccountManagement:receiveDic];
    }
}

#pragma mark -codeTF 改变回调
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == _devicePWTF) {
        //这里的if时候为了获取删除操作,如果没有次if会造成当达到字数限制后删除键也不能使用的后果.
        if (range.length == 1 && string.length == 0) {
            return YES;
        }
        //so easy
        else if (_devicePWTF.text.length >= 8) {
            _devicePWTF.text = [textField.text substringToIndex:8];
            return NO;
        }
    }
    return YES;
}
#pragma mark -连接socket
- (void) connectSocket {
    NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
    if (connectStatu == socketConnectStatusConnected) {
        [[SocketUtil shareInstance] disconnect];
    }    // 连接
    [AppD.window showHudInView:AppD.window hint:@"Connect Circle..."];
    NSString *connectURL = [SystemUtil connectUrl];
    [SocketUtil.shareInstance connectWithUrl:connectURL];
}

#pragma mark -通知回调
- (void)socketOnConnect:(NSNotification *)noti {
    if (!isLoginDeviceViewController) {
        return;
    }
    isClickConnect = NO;
    [AppD.window hideHud];
    [self sendLogin];
}

- (void)socketOnDisconnect:(NSNotification *)noti {
    if (!isLoginDeviceViewController || !AppD.isLoginMac || !isClickConnect) {
        return;
    }
    isClickConnect = NO;
    [AppD.window hideHud];
    [AppD.window showHint:@"The connection fails"];
}

@end
