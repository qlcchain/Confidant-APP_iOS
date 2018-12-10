//
//  LoginViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/14.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "LoginViewController.h"
#import "RouterModel.h"
#import "RoutherConfig.h"
#import "RegiterViewController.h"
#import "UserModel.h"
#import "PNRouter-Swift.h"
#import "KeyCUtil.h"
#import "NSString+SHA256.h"
#import "ReviceRadio.h"
#import "RSAUtil.h"
#import "SystemUtil.h"
#import "OCTSubmanagerUser.h"
#import "OCTSubmanagerFriends.h"
#import "ConnectView.h"

@interface LoginViewController ()<OCTSubmanagerUserDelegate>
{
    BOOL isLogin;
    BOOL isFind;
}
@property (weak, nonatomic) IBOutlet UIView *loginBackView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *passTF;
@property (weak, nonatomic) IBOutlet UILabel *lblRoutherName;
@property (nonatomic , strong) NSMutableArray *showRouterArr;
@property (nonatomic ,strong) ConnectView *connectView;

@property (nonatomic , strong) RouterModel *selectRouther;

@end

@implementation LoginViewController
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)loginAction:(id)sender {
    
    if ([[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterIp] isEmptyString]) {
        isLogin = YES;
        [self connectSocketWithIsShowHud:YES];
        return;
    }
    
    if (_passTF.text.trim.length < 6 ) {
        [self.view showHint:@"The password must be greater than or equal to 6 digits"];
        return;
    }
     NSString *shaPass = [_passTF.text.trim SHA256];
    /*
    if (![[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterIp] isEmptyString]) { // 走socket
         // 判断socket是否连接
        
        NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
        if (connectStatu == socketConnectStatusConnected) {
            // 发送登陆请求
             [SendRequestUtil sendUserLoginWithPass:shaPass];
        } else {
            isLogin = YES;
            [AppD.window showHudInView:AppD.window hint:@"Connect Routher..."];
            NSString *connectURL = [SystemUtil connectUrl];
            AppD.currentSoketUrl = connectURL;
            [SocketUtil.shareInstance connectWithUrl:connectURL];
        }
        // 连接
        
    }  else { // 走tox
        
    }*/
    
    NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
    if (connectStatu == socketConnectStatusConnected) {
        // 发送登陆请求
        [SendRequestUtil sendUserLoginWithPass:shaPass userid:self.selectRouther.userid];
    } else {
        isLogin = YES;
        [AppD.window showHudInView:AppD.window hint:@"Connect Routher..."];
        NSString *connectURL = [SystemUtil connectUrl];
        AppD.currentSoketUrl = connectURL;
        [SocketUtil.shareInstance connectWithUrl:connectURL];
    }
}
- (IBAction)rightAction:(id)sender {
    isLogin = NO;
    isFind = NO;
    [self jumpToQR];
}
- (IBAction)routherSelect:(id)sender {
    [self showRouter];
}
// 扫码成功重新开启组播
- (void)scanSuccessful
{
   RouterModel *routherM = [RouterModel checkRoutherWithSn:[RoutherConfig getRoutherConfig].currentRouterSn];
    if (routherM) {
        AppD.isScaner = NO;
        self.selectRouther = routherM;
        [RoutherConfig getRoutherConfig].currentRouterIp = @"";
        [RoutherConfig getRoutherConfig].currentRouterToxid = routherM.toxid;
        [RoutherConfig getRoutherConfig].currentRouterSn = routherM.userSn;
        
        [self loadHudView];
        [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RoutherConfig getRoutherConfig].currentRouterToxid];
        _lblRoutherName.text = self.selectRouther.name;
        _passTF.text = self.selectRouther.userPass?:@"";
    } else {
        [self loadHudView];
        [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RoutherConfig getRoutherConfig].currentRouterToxid];
    }
    
}
#pragma mark -连接socket_tox
- (void) connectSocketWithIsShowHud:(BOOL) isShow
{
    // 当前是在局域网
    if (![[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterIp] isEmptyString])
    {
        AppD.manager = nil;
        NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
        if (connectStatu == socketConnectStatusConnected) {
            [[SocketUtil shareInstance] disconnect];
        }    // 连接
        if (isShow) {
            [AppD.window showHudInView:AppD.window hint:@"Connect Routher..."];
        }
        
        NSString *connectURL = [SystemUtil connectUrl];
        AppD.currentSoketUrl = connectURL;
        [SocketUtil.shareInstance connectWithUrl:connectURL];
        
    } else {
        NSLog(@"manager = %@",AppD.manager.user.userAddress);
        if (AppD.manager) {
            [self addRouterFriend];
        } else {
            [self loginTox];
        }
    }
}

- (void) findOrLogin
{
    if (isFind) {
        isFind = NO;
        [SendRequestUtil sendUserFindWithToxid:[RoutherConfig getRoutherConfig].currentRouterToxid usesn:[RoutherConfig getRoutherConfig].currentRouterSn];
        
    } else if (isLogin) {
        isLogin = NO;
        NSString *shaPass = [_passTF.text.trim SHA256];
        [SendRequestUtil sendUserLoginWithPass:shaPass userid:self.selectRouther.userid];
    }
}

#pragma mark -tox 登陆成功
- (void) toxLoginSuccessWithManager:(id<OCTManager>)manager
{
  
    [self addRouterFriend];
    NSLog(@"toxid = %@",manager.user.userAddress);
    
}

- (void) addRouterFriend
{
    
   // [RoutherConfig getRoutherConfig].currentRouterToxid = @"A1DA6FFE24611BDE1D14B55B02F180961A3DFB8C9C9B2A572EB274896B7EAC30B4CDCDCE68B8";
    
    if (![AppD.manager.friends friendIsExitWithFriend:[RoutherConfig getRoutherConfig].currentRouterToxid]) {
        // 添加好友
        [self showConnectServerLoad];
        BOOL result = [AppD.manager.friends sendFriendRequestToAddress:[RoutherConfig getRoutherConfig].currentRouterToxid message:@"" error:nil];
        if (!result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideConnectServerLoad];
                [AppD.window showHint:@"Failed to connect to the server"];
            });
        }
        
    } else { // 好友已存在并且在线
        if ([AppD.manager.friends getFriendConnectStatuWithFriendNumber:AppD.currentRouterNumber] > 0) {
             [self findOrLogin];
        } else {
            [self showConnectServerLoad];
        }
    }
}

- (void) showConnectServerLoad
{
    if (!_connectView) {
         _connectView = [ConnectView loadConnectView];
    }
    [_connectView showConnectView];
}
- (void) hideConnectServerLoad
{
    [_connectView hiddenConnectView];
}



- (void)socketOnConnect:(NSNotification *)noti {
    [AppD.window hideHud];
    if (isLogin) {  // 登陆
        NSString *shaPass = [_passTF.text.trim SHA256];
        [SendRequestUtil sendUserLoginWithPass:shaPass userid:self.selectRouther.userid];
        isLogin = NO;
    } else if (isFind) {
        [SendRequestUtil sendUserFindWithToxid:[RoutherConfig getRoutherConfig].currentRouterToxid usesn:[RoutherConfig getRoutherConfig].currentRouterSn];
        isFind = NO;
    }
   
}

- (void)socketOnDisconnect:(NSNotification *)noti {
    [AppD.window hideHud];
    [AppD.window showHint:@"The connection fails"];
}
- (void) loadHudView
{
    [AppD.window showHudInView:AppD.window hint:@"Check Router..."];
}
- (void) sendGB
{
    [self loadHudView];
    RouterModel *routerModel = [RouterModel getConnectRouter];
    [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:routerModel.toxid];
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    if ([[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterIp] isEmptyString] && !AppD.manager) {
       [self performSelector:@selector(sendGB) withObject:self afterDelay:.1];
    }
    self.selectRouther = [RouterModel getConnectRouter];
    if (self.selectRouther) {
        [RoutherConfig getRoutherConfig].currentRouterSn = self.selectRouther.userSn;
        [RoutherConfig getRoutherConfig].currentRouterToxid = self.selectRouther.toxid;
        _lblRoutherName.text = self.selectRouther.name;
        _passTF.text = self.selectRouther.userPass?:@"";
    }
    _loginBackView.layer.borderWidth = 1.5;
    _loginBackView.layer.cornerRadius = 5;
    [_passTF setValue:RGB(128, 128, 128) forKeyPath:@"_placeholderLabel.textColor"];
    [self changeLogintStatu];
    [self addTargetMethod];
    _showRouterArr = [NSMutableArray array];
    NSArray *routeArr = [RouterModel getLocalRouter];
    
    [_showRouterArr addObjectsFromArray:routeArr];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnConnect:) name:SOCKET_ON_CONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnDisconnect:) name:SOCKET_ON_DISCONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gbFinashNoti:) name:GB_FINASH_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:SOCKET_LOGIN_SUCCESS_NOTI object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recivceUserFind:) name:USER_FIND_RECEVIE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toxAddRoterSuccess:) name:TOX_ADD_ROUTER_SUCCESS_NOTI object:nil];
    
    
}
#pragma 第一次 广播完回调。验证是否走socket 还是 tox
- (void) checkConnectStyle
{
    NSLog(@"ip = %@",[RoutherConfig getRoutherConfig].currentRouterIp);
    if (![[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterIp] isEmptyString]) {
            [self connectSocketWithIsShowHud:YES];
    } else {
       //[self connectTox];
    }
    [self changeLogintStatu];
}

- (void) changeLogintStatu
{
    if ([_passTF.text.trim isEmptyString]) {
        _loginBtn.selected = NO;
    } else {
        _loginBtn.selected = YES;
    }
    if (_loginBtn.selected) {
         _loginBackView.layer.borderColor = [UIColor whiteColor].CGColor;
    } else {
        _loginBackView.layer.borderColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1].CGColor;
    }
}
#pragma mark -切换routher 刷新方法
- (void)refreshSelectRouter:(RouterModel *)routeM {
    
    isLogin = NO;
    isFind = NO;
    
    if ([[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterSn] isEqualToString:routeM.userSn]) {
        return;
    }
    self.selectRouther = routeM;
    
    [RoutherConfig getRoutherConfig].currentRouterIp = @"";
    [RoutherConfig getRoutherConfig].currentRouterToxid = routeM.toxid;
    [RoutherConfig getRoutherConfig].currentRouterSn = routeM.userSn;
    
    [self loadHudView];
    [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RoutherConfig getRoutherConfig].currentRouterToxid];
    _lblRoutherName.text = self.selectRouther.name;
    _passTF.text = self.selectRouther.userPass?:@"";
}


- (void)showRouter {
    @weakify_self
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [_showRouterArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RouterModel *model = obj;
        UIAlertAction *alert = [UIAlertAction actionWithTitle:model.name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf refreshSelectRouter:model];
        }];
        [alertC addAction:alert];
    }];
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:alertCancel];
    [self presentViewController:alertC animated:YES completion:nil];
}

#pragma mark - 直接添加监听方法
-(void)addTargetMethod{
    [_passTF addTarget:self action:@selector(textField1TextChange:) forControlEvents:UIControlEventEditingChanged];
}
-(void)textField1TextChange:(UITextField *)textField{
    if (textField.text.trim.length > 0) {
        if (!_loginBtn.selected) {
            _loginBtn.selected = YES;
            [self changeLogintStatu];
        }
    } else {
        if (_loginBtn.selected) {
            _loginBtn.selected = NO;
            [self changeLogintStatu];
        }
    }
}

#pragma mark - 通知回调
// 加router好友成功
- (void) toxAddRoterSuccess:(NSNotification *) noti
{
    NSLog(@"thread = %@",[NSThread currentThread]);
    NSLog(@"加router好友成功");
    [self hideConnectServerLoad];
   // [AppD.window showHint:@"Server connection successful."];
    [self findOrLogin];
}
- (void) gbFinashNoti:(NSNotification *) noti
{
//    if ([[RoutherConfig getRoutherConfig].currentRouterIp isEmptyString])
//    {
//        [AppD.window showHint:@"当前不在局域网内."];
//    }
    
    RouterModel *routerModel = [RouterModel checkRoutherWithSn:[RoutherConfig getRoutherConfig].currentRouterSn];
    if (routerModel) {
        self.selectRouther = routerModel;
        _lblRoutherName.text = self.selectRouther.name;
        _passTF.text = self.selectRouther.userPass;
        _loginBtn.selected = YES;
        [self connectSocketWithIsShowHud:NO];
        [self changeLogintStatu];
    } else { // 走find 5
        isFind = YES;
        [self connectSocketWithIsShowHud:YES];
    }
    
//    if (!AppD.isScaner) {
//        [self checkConnectStyle];
//    } else {
//        // 当前是在局域网
//        if (![[RoutherConfig getRoutherConfig].currentRouterIp isEmptyString])
//        {
//            RouterModel *routerModel = [RouterModel checkRoutherWithSn:[RoutherConfig getRoutherConfig].currentRouterSn];
//            if (routerModel) {
//                self.selectRouther = routerModel;
//                _lblRoutherName.text = self.selectRouther.name;
//                _passTF.text = self.selectRouther.userPass;
//                _loginBtn.selected = YES;
//                [self connectSocketWithIsShowHud:NO];
//                [self changeLogintStatu];
//            } else { // 走find 5
//                isFind = YES;
//                [self connectSocketWithIsShowHud:YES];
//            }
//        } else { // 走tox
//            //[self connectTox];
//        }
//    }
    AppD.isScaner = NO;
}
- (void) loginSuccess:(NSNotification *) noti
{
    [RouterModel updateRouterPassWithSn:[RoutherConfig getRoutherConfig].currentRouterSn pass:_passTF.text.trim];
    [UserModel updateUserLocalWithPass:_passTF.text.trim];
    [AppD setRootTabbarWithManager:nil];
    [AppD.window showHint:@"Login Success"];
    
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
        
        NSString *userType = [usesn substringWithRange:NSMakeRange(0, 2)];
        AccountType type = AccountSupper;
        if ([userType isEqualToString:@"02"]) {
            type = AccountOrdinary;
        } else if ([userType isEqualToString:@"03"]){
            type = AccountTemp;
        }
        
        if (retCode == 0) { //已激活
            [RouterModel addRouterWithToxid:routherid usesn:usesn userid:userid];
            [RouterModel updateRouterConnectStatusWithSn:usesn];
            [UserModel createUserLocalWithName:userName userid:userid version:0 filePay:@"" userpass:@""];
            LoginViewController *vc = [[LoginViewController alloc] init];
            [self setRootVCWithVC:vc];
        } else { // 未激活 或者日临时帐户
            RegiterViewController *vc = [[RegiterViewController alloc] initWithAccountType:type];
            [self setRootVCWithVC:vc];
        }
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
