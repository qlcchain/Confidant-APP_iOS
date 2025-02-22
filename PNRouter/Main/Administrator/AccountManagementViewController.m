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
#import "RouterConfig.h"
#import "MyConfidant-Swift.h"
#import "SendRequestUtil.h"
#import "SystemUtil.h"
#import "RouterModel.h"
#import "UserModel.h"
#import "LoginViewController.h"
#import "RouterAliasViewController.h"
#import "NSString+Base64.h"
#import "UserConfig.h"
#import "UserHeadUtil.h"

@interface AccountManagementViewController ()
{
    BOOL isAccountManagementViewController;
}

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerLab;
@property (weak, nonatomic) IBOutlet UIImageView *qrImgV;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UILabel *aliasLab;

@end

@implementation AccountManagementViewController
#pragma mark - Observe
- (void)addObserve {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnConnect:) name:SOCKET_ON_CONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnDisconnect:) name:SOCKET_ON_DISCONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recivceUserFind:) name:USER_FIND_RECEVIE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userIdcodeSuccessNoti:) name:@"UserIdcodeSuccessNoti" object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:SOCKET_LOGIN_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRegisterSuccess:) name:USER_REGISTER_RECEVIE_NOTI object:nil];
    
}

- (void) userIdcodeSuccessNoti:(NSNotification *) noti
{
    _IdentifyCode = noti.object;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [super viewDidAppear:animated];
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
    _headerView.layer.cornerRadius = _headerView.width/2.0;
    _headerView.layer.masksToBounds = YES;
    _headerView.layer.magnificationFilter = kCAFilterNearest;
    _headerView.layer.contentsScale = [[UIScreen mainScreen] scale];
    _headerLab.layer.cornerRadius = _headerLab.width/2.0;
    _headerLab.layer.masksToBounds = YES;
    _headerLab.layer.magnificationFilter = kCAFilterNearest;
    _headerLab.layer.contentsScale = [[UIScreen mainScreen] scale];
    
    _nextBtn.layer.cornerRadius = 4;
    _nextBtn.layer.masksToBounds = YES;
    
    _aliasLab.text = _routerAlias;
    
    @weakify_self
    [HMScanner qrImageWithString:_Qrcode?:@"" avatar:nil completion:^(UIImage *image) {
        weakSelf.qrImgV.image = image;
    }];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
  //  [self leftNavBarItemPressedWithPop:YES];
}
//
//- (IBAction)loginAction:(id)sender {
//    RouterModel *routherM = [RouterModel checkRoutherWithSn:_UserSn];
//    if (routherM) {
//        [RouterModel updateRouterConnectStatusWithSn:_UserSn];
//        AppD.isLoginMac = NO;
//        [RoutherConfig getRouterConfig].currentRouterMAC = @"";
//        [AppD setRootLogin];
//    } else {
//        NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
//        if (connectStatu == socketConnectStatusConnected) {
//            [self sendfindRouterRequest];
//        } else {
//            [self connectSocket];
//        }
//
//    }
//}

- (void) sendfindRouterRequest
{
    [RouterConfig getRouterConfig].currentRouterToxid = _RouterId;
    [RouterConfig getRouterConfig].currentRouterSn = _UserSn;
    [SendRequestUtil sendUserFindWithToxid:_RouterId?:@"" usesn:_UserSn?:@""];
    
   // [AppD setRootLoginWithType:MacType];
}

//- (IBAction)activitionCodeAction:(id)sender {
//    [self jumpToModifyActivateCode];
//}

- (IBAction)routerPWAction:(id)sender {
    [self jumpToModifyRouterPW];
}

- (IBAction)routerAliasAction:(id)sender {
    [self jumpToRouterAlias];
}

- (IBAction)nextAction:(id)sender {
//    RouterModel *routherM = [RouterModel checkRoutherWithSn:_UserSn];
//    if (routherM) {
//        [RouterModel updateRouterConnectStatusWithSn:_UserSn];
//        AppD.isLoginMac = NO;
//        [RouterConfig getRouterConfig].currentRouterMAC = @"";
//        [AppD setRootLoginWithType:RouterType];
//    } else {
//        NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
//        if (connectStatu == socketConnectStatusConnected) {
//            [self sendfindRouterRequest];
//        } else {
//            [self connectSocket];
//        }
//    }
    [RouterConfig getRouterConfig].currentRouterMAC = @"";
    NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
    if (connectStatu == socketConnectStatusConnected) {
        [self sendfindRouterRequest];
    } else {
        [self connectSocket];
    }

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

- (void)jumpToRouterAlias {
    RouterAliasViewController *vc = [[RouterAliasViewController alloc] init];
    vc.inputRouterAlias = _routerAlias;
    vc.finishBack = YES;
    @weakify_self
    vc.finishB = ^(NSString * _Nonnull alias) {
        weakSelf.routerAlias = alias;
        weakSelf.aliasLab.text = weakSelf.routerAlias;
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -连接socket
- (void) connectSocket {
    NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
    if (connectStatu == socketConnectStatusConnected) {
        [[SocketUtil shareInstance] disconnect];
    }    // 连接
    [AppD.window showHudInView:AppD.window hint:Connect_Cricle];
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
    [AppD.window showHint:Connect_Failed];
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
        
        if (![[NSString getNotNullValue:routherid] isEmptyString]) {
            [RouterConfig getRouterConfig].currentRouterToxid = routherid;
        }
        if (![[NSString getNotNullValue:usesn] isEmptyString]) {
            [RouterConfig getRouterConfig].currentRouterSn = usesn;
        }
        
        if (retCode == 0) { //已激活
             [self sendLoginRequestWithUserid:userid usersn:usesn];
        } else { // 未激活 或者日临时帐户
             [self sendRegisterRequestWithShowHud:YES];
        }
    }
}


- (void) sendLoginRequestWithUserid:(NSString *) userid usersn:(NSString *) usersn
{
    
    [SendRequestUtil sendUserLoginWithPass:usersn userid:userid showHud:YES];
}

- (void) sendRegisterRequestWithShowHud:(BOOL) isShow
{
    NSString *userName = [[UserModel getUserModel].username base64EncodedString];
    [SendRequestUtil sendUserRegisterWithUserPass:@"" username:userName code:@"" showHUD:YES];
    
}


#pragma mark -登陆成功
- (void) loginSuccess:(NSNotification *) noti
{
    NSInteger retCode = [noti.object integerValue];
    if (retCode == 0) {
        [self updateUserHead];
        [AppD setRootTabbarWithManager:nil];
    } else {
        
        [AppD setRootLoginWithType:MacType];
        
        if (retCode == 2) { // routeid不对
            [AppD.window showHint:@"Wrong Routeid!"];
        } else if (retCode == 1) { //需要验证
            [AppD.window showHint:@"Need to verify"];
        } else if (retCode == 3) { //uid错误
            [AppD.window showHint:@"uid wrong."];
        } else if (retCode == 4) { //登陆密码错误
            [AppD.window showHint:@"Wrong log-in password!"];
        } else if (retCode == 5) { //验证码错误
            [AppD.window showHint:@"Verification code error"];
        } else if (retCode == 7) { //无效帐户
            [AppD.window showHint:@"This account is no longer valid."];
        } else { // 其它错误
            [AppD.window showHint:@"Failed to log in"];
            
        }
    }
}

#pragma mark -注册成功
- (void) userRegisterSuccess:(NSNotification *) noti
{
    
    NSDictionary *receiveDic = (NSDictionary *)noti.object;
     NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    if (retCode == 0) {
        [self updateUserHead];
        [AppD setRootTabbarWithManager:nil];
    } else {
         [AppD setRootLoginWithType:MacType];
    }
}


- (void)updateUserHead {
    //    if (_loginType == ImportType) {
    NSString *Fid = [UserModel getUserModel].userId?:@"";
    NSString *Md5 = @"0";
    [[UserHeadUtil getUserHeadUtilShare] sendUpdateAvatarWithFid:Fid md5:Md5 showHud:NO];
    //    }
}

@end
