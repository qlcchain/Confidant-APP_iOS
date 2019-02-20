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
#import "RoutherConfig.h"
#import "PNRouter-Swift.h"
#import "SendRequestUtil.h"
#import "SystemUtil.h"
#import "RouterModel.h"
#import "RegiterViewController.h"
#import "UserModel.h"
#import "LoginViewController.h"

@interface AccountManagementViewController ()
{
    BOOL isAccountManagementViewController;
}

@property (weak, nonatomic) IBOutlet UIImageView *qrImgV;
@property (weak, nonatomic) IBOutlet UILabel *activitionCodeLab;


@end

@implementation AccountManagementViewController
#pragma mark - Observe
- (void)addObserve {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnConnect:) name:SOCKET_ON_CONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnDisconnect:) name:SOCKET_ON_DISCONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recivceUserFind:) name:USER_FIND_RECEVIE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userIdcodeSuccessNoti:) name:@"UserIdcodeSuccessNoti" object:nil];
    
}
- (void) userIdcodeSuccessNoti:(NSNotification *) noti
{
    _IdentifyCode = noti.object;
    _activitionCodeLab.text = _IdentifyCode?:@"";
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    //self.view.backgroundColor = MAIN_WHITE_COLOR;
    [self addObserve];
    [self viewInit];
}

#pragma mark - Operation

- (void)viewInit {
    @weakify_self
    [HMScanner qrImageWithString:_Qrcode?:@"" avatar:nil completion:^(UIImage *image) {
        weakSelf.qrImgV.image = image;
    }];
    _activitionCodeLab.text = _IdentifyCode?:@"";
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
  //  [self leftNavBarItemPressedWithPop:YES];
}

- (IBAction)loginAction:(id)sender {
    RouterModel *routherM = [RouterModel checkRoutherWithSn:_UserSn];
    if (routherM) {
        [RouterModel updateRouterConnectStatusWithSn:_UserSn];
        AppD.isLoginMac = NO;
        [RoutherConfig getRoutherConfig].currentRouterMAC = @"";
        [AppD setRootLogin];
    } else {
        NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
        if (connectStatu == socketConnectStatusConnected) {
            [self sendfindRouterRequest];
        } else {
            [self connectSocket];
        }
       
    }
}
- (void) sendfindRouterRequest
{
    [SendRequestUtil sendUserFindWithToxid:_RouterId?:@"" usesn:_UserSn?:@""];
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
    if (!isAccountManagementViewController) {
        return;
    }
    [AppD.window hideHud];
    [self sendfindRouterRequest];
}

- (void)socketOnDisconnect:(NSNotification *)noti {
    if (!isAccountManagementViewController) {
        return;
    }
    [AppD.window hideHud];
    [AppD.window showHint:@"The connection fails"];
}

- (void) recivceUserFind:(NSNotification *) noti
{
    NSDictionary *receiveDic = (NSDictionary *)noti.object;
    if (receiveDic) {
        NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
        NSString *routherid = receiveDic[@"params"][@"RouteId"];
        NSString *usesn = receiveDic[@"params"][@"UserSn"];
        NSString *userid = receiveDic[@"params"][@"UserId"];
        NSString *userName = receiveDic[@"params"][@"NickName"];
        NSInteger fileVersion = [receiveDic[@"params"][@"DataFileVersion"] integerValue];
        
        NSString *userType = [usesn substringWithRange:NSMakeRange(0, 2)];
        AccountType type = AccountSupper;
        if ([userType isEqualToString:@"02"]) {
            type = AccountOrdinary;
        } else if ([userType isEqualToString:@"03"]){
            type = AccountTemp;
        }
        if (retCode == 0) { //已激活
            [RouterModel addRouterWithToxid:routherid usesn:usesn userid:userid];
            [UserModel createUserLocalWithName:userName userid:userid version:fileVersion filePay:@"" userpass:@"" userSn:usesn hashid:@""];
            [RouterModel updateRouterConnectStatusWithSn:usesn];
            LoginViewController *vc = [[LoginViewController alloc] init];
            [self setRootVCWithVC:vc];
        } else { // 未激活 或者日临时帐户
            RegiterViewController *vc = [[RegiterViewController alloc] initWithAccountType:type];
            [self setRootVCWithVC:vc];
        }
    }
}

@end
