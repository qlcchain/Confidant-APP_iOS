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
#import "UserConfig.h"
#import "FingetprintVerificationUtil.h"
#import "NSString+Base64.h"
#import "LibsodiumUtil.h"
#import "UserHeadUtil.h"
#import "EntryModel.h"
#import "CSLogMacro.h"

@interface LoginViewController ()<OCTSubmanagerUserDelegate> {
    BOOL isLogin;
    BOOL isFind;
    BOOL isConnectSocket;
    BOOL resultLogin;
    NSInteger sendCount;
}
@property (weak, nonatomic) IBOutlet UIButton *arrowImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet UIView *loginBackView;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblRoutherName;
@property (weak, nonatomic) IBOutlet UIView *circleBack;
@property (weak, nonatomic) IBOutlet UIImageView *circleDefaultImgV;
@property (weak, nonatomic) IBOutlet UILabel *circleDefaultLab;

@property (nonatomic , strong) NSMutableArray *showRouterArr;
@property (nonatomic ,strong) ConnectView *connectView;
@property (nonatomic , strong) RouterModel *selectRouther;

@end

@implementation LoginViewController

- (void)dealloc {
    CSLOG_TEST_DDLOG(@"Login View Controller dealloc***************************************************");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnConnect:) name:SOCKET_ON_CONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnDisconnect:) name:SOCKET_ON_DISCONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gbFinashNoti:) name:GB_FINASH_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:SOCKET_LOGIN_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recivceUserFind:) name:USER_FIND_RECEVIE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toxAddRoterSuccess:) name:TOX_ADD_ROUTER_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerPushNoti:) name:REGISTER_PUSH_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCurrentSelectRouter) name:CANCEL_LOGINMAC_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(touchModifySuccess:) name:TOUCH_MODIFY_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRegisterSuccess:) name:USER_REGISTER_RECEVIE_NOTI object:nil];
}

- (instancetype) initWithLoginType:(LoginType)type {
    if (self = [super init]) {
        self.loginType = type;
        [RoutherConfig getRoutherConfig].currentRouterMAC = @"";
    }
    return self;
}
- (void) appOptionWithLoginType:(LoginType) type
{
    if (type == MacType) {
        isFind = YES;
        [self connectSocketWithIsShowHud:YES];
    }
}

- (IBAction)loginAction:(id)sender {
    if ([[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterToxid] isEmptyString]) {
        [self.view showHint:@"Please select the circle."];
        return;
    }
    sendCount = 0;
    isConnectSocket = YES;
    resultLogin = NO;
    if (![[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterIp] isEmptyString]) {
        
        NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
        if (connectStatu == socketConnectStatusConnected) {
            // 发送登陆请求
            sendCount = 0;
            [self sendLoginRequestWithUserid:self.selectRouther.userid usersn:@""];
        } else {
            isLogin = YES;
            [AppD.window showHudInView:AppD.window hint:Connect_Cricle];
            NSString *connectURL = [SystemUtil connectUrl];
            [SocketUtil.shareInstance connectWithUrl:connectURL];
        }
    } else {
        isLogin = YES;
        [self sendGB];
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
// 导入帐号
- (void)scanSuccessfulWithIsAccount:(NSArray *)values
{
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"" message:@"This operation will overwrite the current account. Do you want to continue?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    @weakify_self
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *signpk = values[1];
        NSString *usersn = values[2];
        if (![signpk isEqualToString:[EntryModel getShareObject].signPrivateKey]) {
            // 更改私钥
            [LibsodiumUtil changeUserPrivater:values[1]];
            NSString *name = [values[3] base64DecodedString];
            [UserModel createUserLocalWithName:name];
            // 删除所有路由
            [RouterModel delegateAllRouter];
            [weakSelf.showRouterArr removeAllObjects];
            weakSelf.selectRouther = nil;
        } else {
            [AppD.window showHint:@""];
             weakSelf.selectRouther = [RouterModel checkRoutherWithSn:usersn];
        }
        [weakSelf changeLogintStatu];
    }];
    
    [vc addAction:cancelAction];
    [vc addAction:confirm];
    
    [self presentViewController:vc animated:YES completion:nil];
    
    
}
// 扫码成功重新开启组播
- (void)scanSuccessfulWithIsMacd:(BOOL)isMac
{
    if (isMac) {
        [self loadHudView];
        [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RoutherConfig getRoutherConfig].currentRouterMAC];
    } else {
        RouterModel *routherM = [RouterModel checkRoutherWithSn:[RoutherConfig getRoutherConfig].currentRouterSn];
        if (routherM) {
            AppD.isScaner = NO;
            self.selectRouther = routherM;
            [RoutherConfig getRoutherConfig].currentRouterIp = @"";
            [RoutherConfig getRoutherConfig].currentRouterToxid = routherM.toxid;
            [RoutherConfig getRoutherConfig].currentRouterSn = routherM.userSn;
            
            //[self loadHudView];
            //[[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RoutherConfig getRoutherConfig].currentRouterToxid];
            _lblRoutherName.text = self.selectRouther.name;
        }
        [self loadHudView];
        [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RoutherConfig getRoutherConfig].currentRouterToxid];
    }
}
#pragma mark -连接socket_tox
- (void) connectSocketWithIsShowHud:(BOOL) isShow
{
    isConnectSocket = YES;
    
    // 当前是在局域网
    if (![[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterIp] isEmptyString])
    {
        AppD.manager = nil;
        NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
        if (connectStatu == socketConnectStatusConnected) {
            [[SocketUtil shareInstance] disconnect];
        }    // 连接
        if (isShow) {
            [AppD.window showHudInView:AppD.window hint:Connect_Cricle];
        }
        
        NSString *connectURL = [SystemUtil connectUrl];
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
        sendCount = 0;
        [self sendLoginRequestWithUserid:self.selectRouther.userid usersn:@""];
    }
}

- (void) sendLoginRequestWithUserid:(NSString *) userid usersn:(NSString *) usersn
{
    BOOL isShow = NO;
    if (sendCount == 0) {
        isShow = YES;
    }
    [SendRequestUtil sendUserLoginWithPass:usersn userid:userid showHud:isShow];
    /*
    sendCount ++;
    if (sendCount == 4) {
        return;
    }
    
    [self performSelector:@selector(sendLoginRequestWithUserid:) withObject:userid afterDelay:5];*/
}

- (void) sendRegisterRequestWithShowHud:(BOOL) isShow
{
     NSString *userName = [[UserModel getUserModel].username base64EncodedString];
     [SendRequestUtil sendUserRegisterWithUserPass:@"" username:userName code:@""];
    
}

#pragma mark -tox 登陆成功
- (void) toxLoginSuccessWithManager:(id<OCTManager>)manager
{
    [self addRouterFriend];
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
    
    if (AppD.isLoginMac && _loginType != MacType) {
        return;
    }
    
    isConnectSocket = NO;
    [AppD.window hideHud];
    if (isLogin) {  // 登陆
        sendCount = 0;
        [self sendLoginRequestWithUserid:self.selectRouther.userid usersn:@""];
        isLogin = NO;
    } else if (isFind) {
        [SendRequestUtil sendUserFindWithToxid:[RoutherConfig getRoutherConfig].currentRouterToxid usesn:[RoutherConfig getRoutherConfig].currentRouterSn];
        isFind = NO;
    }
   
}

- (void)socketOnDisconnect:(NSNotification *)noti {
    
    if (AppD.isLoginMac && _loginType != MacType) {
        return;
    }
    
    [AppD.window hideHud];
    if (isConnectSocket) {
        isConnectSocket = NO;
        [AppD.window showHint:@"The connection fails"];
    }
}
- (void) loadHudView
{
    [AppD.window showHudInView:AppD.window hint:Connect_Cricle];
}
- (void) sendGB
{
    [self loadHudView];
    [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RoutherConfig getRoutherConfig].currentRouterToxid];
}
- (void) getCurrentSelectRouter
{
    if (AppD.showTouch) {
        self.selectRouther = [RouterModel getLoginOpenRouter];
        if (!self.selectRouther) {
            self.selectRouther = [RouterModel getConnectRouter];
        }
    } else {
        self.selectRouther = [RouterModel getConnectRouter];
    }
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CSLOG_TEST_DDLOG(@"Login View Controller alloc***************************************************");
    AppD.inLogin = NO;
    self.view.backgroundColor = MAIN_PURPLE_COLOR;
    _lblTitle.text = [NSString stringWithFormat:@"Hello\n%@\nWelcome back!",[UserModel getUserModel].username];
    _circleBack.layer.cornerRadius = _circleBack.width/2.0;
    _circleBack.layer.masksToBounds = YES;
    _circleBack.layer.magnificationFilter = kCAFilterNearest;
    _circleBack.layer.contentsScale = [[UIScreen mainScreen] scale];
    _circleDefaultImgV.layer.cornerRadius = _circleDefaultImgV.width/2.0;
    _circleDefaultImgV.layer.masksToBounds = YES;
    _circleDefaultImgV.layer.magnificationFilter = kCAFilterNearest;
    _circleDefaultImgV.layer.contentsScale = [[UIScreen mainScreen] scale];
    _circleDefaultLab.layer.cornerRadius = _circleDefaultLab.width/2.0;
    _circleDefaultLab.layer.masksToBounds = YES;
    _circleDefaultLab.layer.magnificationFilter = kCAFilterNearest;
    _circleDefaultLab.layer.contentsScale = [[UIScreen mainScreen] scale];
    
    
    [self getCurrentSelectRouter];

    _loginBtn.layer.cornerRadius = 5;
  
    [self changeLogintStatu];

    _showRouterArr = [NSMutableArray array];
    NSArray *routeArr = [RouterModel getLocalRouter];
    [_showRouterArr addObjectsFromArray:routeArr];
    
    [self addObserve];
    [self appOptionWithLoginType:_loginType];
    
    if (AppD.showTouch) {
         AppD.showTouch = NO;
         [FingetprintVerificationUtil show];
    }
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
    _lblTitle.text = [NSString stringWithFormat:@"Hello\n%@\nWelcome back!",[UserModel getUserModel].username]?:@"";
    if (self.selectRouther) {
        [RoutherConfig getRoutherConfig].currentRouterSn = self.selectRouther.userSn;
        [RoutherConfig getRoutherConfig].currentRouterToxid = self.selectRouther.toxid;
        _lblRoutherName.text = self.selectRouther.name;
    } else {
        [RoutherConfig getRoutherConfig].currentRouterSn = @"";
        [RoutherConfig getRoutherConfig].currentRouterToxid = @"";
    }
    if (self.selectRouther) {
        _loginBtn.enabled = YES;
        _lblRoutherName.textColor = [UIColor whiteColor];
        _loginBtn.backgroundColor = [UIColor whiteColor];
        _lblDesc.text = @"*Select to re-join a circle or scan to join a new one.";
        [_arrowImgView setImage:[UIImage imageNamed:@"icon_arrow_down_gray"] forState:UIControlStateNormal];
        _circleDefaultLab.hidden = NO;
        _circleDefaultImgV.hidden = YES;
    } else {
        _circleDefaultLab.hidden = YES;
        _circleDefaultImgV.hidden = NO;
        _loginBtn.enabled = NO;
        _lblRoutherName.textColor = RGB(178, 178, 178);
        _loginBtn.backgroundColor = [UIColor colorWithRed:128/255.0 green:128/255.0 blue:128/255.0 alpha:1];
         _lblRoutherName.text = @"You haven't joined any circle";
        _lblDesc.text = @"*Scan the invitation QR code to join a Confidant Circle.\n*Scan the QR Code on your Confidant node to launch your Circle.";
        [_arrowImgView setImage:[UIImage imageNamed:@"icon_arrow_gray"] forState:UIControlStateNormal];
    }
}
#pragma mark -切换routher 刷新方法
- (void)refreshSelectRouter:(RouterModel *)routeM {
    
    AppD.manager = nil;
    
    isLogin = NO;
    isFind = NO;
    
    if ([[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterSn] isEqualToString:routeM.userSn]) {
        return;
    }
    self.selectRouther = routeM;
    
    [RoutherConfig getRoutherConfig].currentRouterIp = @"";
    [RoutherConfig getRoutherConfig].currentRouterToxid = routeM.toxid;
    [RoutherConfig getRoutherConfig].currentRouterSn = routeM.userSn;
    
    _lblRoutherName.text = self.selectRouther.name;
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

//#pragma mark - 直接添加监听方法
//-(void)addTargetMethod{
//    [_passTF addTarget:self action:@selector(textField1TextChange:) forControlEvents:UIControlEventEditingChanged];
//}
//-(void)textField1TextChange:(UITextField *)textField{
//    if (textField.text.trim.length > 0) {
//        if (!_loginBtn.selected) {
//            _loginBtn.selected = YES;
//            [self changeLogintStatu];
//        }
//    } else {
//        if (_loginBtn.selected) {
//            _loginBtn.selected = NO;
//            [self changeLogintStatu];
//        }
//    }
//}

- (void)updateUserHead {
//    if (_loginType == ImportType) {
        NSString *Fid = [UserModel getUserModel].userId?:@"";
        NSString *Md5 = @"0";
        [[UserHeadUtil getUserHeadUtilShare] sendUpdateAvatarWithFid:Fid md5:Md5 showHud:NO];
//    }
}

#pragma mark - 通知回调
// touch验证成功
- (void) touchModifySuccess:(NSNotification *) noti
{
    if ([RouterModel getLoginOpenRouter]) {
        [self loginAction:nil];
    }
}
// 注册推送
- (void) registerPushNoti:(NSNotification *) noti
{
    [SendRequestUtil sendRegidReqeust];
}
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
     [AppD.window hideHud];
    if (![[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterMAC] isEmptyString]) {
        if ([[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterIp] isEmptyString]) {
            [self.view showHint:@"Unable to connect to server."];
        } else {
            [self jumpToLoginDevice];
        }
        
    } else {
//        RouterModel *routerModel = [RouterModel checkRoutherWithSn:[RoutherConfig getRoutherConfig].currentRouterSn];
//        if (routerModel) {
//            self.selectRouther = routerModel;
//            _lblRoutherName.text = self.selectRouther.name;
//            _loginBtn.selected = YES;
//            [self connectSocketWithIsShowHud:YES];
//            [self changeLogintStatu];
//        } else { // 走find 5
//            isFind = YES;
//            [self connectSocketWithIsShowHud:YES];
//        }
        
        RouterModel *routerModel = [RouterModel checkRoutherWithSn:[RoutherConfig getRoutherConfig].currentRouterSn];
        if (routerModel) {
            self.selectRouther = routerModel;
            _lblRoutherName.text = self.selectRouther.name;
            _loginBtn.selected = YES;
            [self changeLogintStatu];
        }
            // 走find 5
        isFind = YES;
        [self connectSocketWithIsShowHud:YES];
    }
    
    AppD.isScaner = NO;
}

- (void) recivceUserFind:(NSNotification *) noti
{
    if (AppD.isLoginMac && _loginType != MacType) {
        return;
    }
    [AppD.window hideHud];
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
            sendCount = 0;
            [self sendLoginRequestWithUserid:userid usersn:usesn];
            
//            [RouterModel addRouterWithToxid:routherid usesn:usesn userid:userid];
//            [RouterModel updateRouterConnectStatusWithSn:usesn];
//            [UserModel createUserLocalWithName:userName userid:userid version:0 filePay:@"" userpass:@"" userSn:usesn hashid:@""];
//            [RouterModel updateRouterConnectStatusWithSn:usesn];
//            LoginViewController *vc = [[LoginViewController alloc] init];
//            [self setRootVCWithVC:vc];
        } else { // 未激活 或者日临时帐户
//            RegiterViewController *vc = [[RegiterViewController alloc] initWithAccountType:type];
//            [self setRootVCWithVC:vc];
            [self sendRegisterRequestWithShowHud:YES];
        }
    }
}
#pragma mark -登陆成功
- (void) loginSuccess:(NSNotification *) noti
{
  
    NSInteger retCode = [noti.object integerValue];
    if (retCode == 0) {
        [self updateUserHead];
        [AppD setRootTabbarWithManager:nil];
      //  [AppD.window showHint:@"Login Success"];
    } else if (retCode == 2) { // routeid不对
        [AppD.window showHint:@"Routeid wrong."];
    } else if (retCode == 1) { //需要验证
        [AppD.window showHint:@"Need to verify"];
    } else if (retCode == 3) { //uid错误
        [AppD.window showHint:@"uid wrong."];
    } else if (retCode == 4) { //登陆密码错误
        [AppD.window showHint:@"Login failed, verification failed."];
    } else if (retCode == 5) { //验证码错误
        [AppD.window showHint:@"Verification code error."];
    } else { // 其它错误
        [AppD.window showHint:@"Login failed Other error."];
    }
}

#pragma mark -注册成功
- (void) userRegisterSuccess:(NSNotification *) noti
{
   
    NSDictionary *receiveDic = (NSDictionary *)noti.object;
    NSString *userid = receiveDic[@"params"][@"UserId"];
    NSString *userSn = receiveDic[@"params"][@"UserSn"];
    NSString *hashid = receiveDic[@"params"][@"Index"];
    NSString *routeId = receiveDic[@"params"][@"RouteId"];
    NSString *routerName = receiveDic[@"params"][@"RouterName"];
    NSInteger dataFileVersion = [receiveDic[@"params"][@"DataFileVersion"] integerValue];
    NSString *dataFilePay = receiveDic[@"params"][@"DataFilePay"];
    
    
    // 保存用户
    [UserModel updateHashid:hashid usersn:userSn userid:userid needasysn:0];
    // 保存路由
    [RouterModel addRouterName:routerName routerid:routeId usersn:userSn userid:userid];
    [RouterModel updateRouterConnectStatusWithSn:userSn];
    
    [UserConfig getShareObject].userId = userid;
    [UserConfig getShareObject].userName = [UserModel getUserModel].username;
    [UserConfig getShareObject].usersn = userSn;
    [UserConfig getShareObject].dataFilePay = dataFilePay;
    [UserConfig getShareObject].dataFileVersion = dataFileVersion;
    
    [self updateUserHead];
    
    [AppD setRootTabbarWithManager:nil];
   //  [AppD.window showHint:@"Registered successfully"];
}

#pragma mark - OCTSubmanagerUserDelegate
- (void)submanagerUser:(nonnull id<OCTSubmanagerUser>)submanager connectionStatusUpdate:(OCTToxConnectionStatus)connectionStatus {
    
}

@end
