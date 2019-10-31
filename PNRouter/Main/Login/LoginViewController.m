//
//  LoginViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/14.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "LoginViewController.h"
#import "RouterModel.h"
#import "RouterConfig.h"
#import "UserModel.h"
#import "MyConfidant-Swift.h"
#import "KeyCUtil.h"
#import "NSString+SHA256.h"
#import "ReviceRadio.h"
#import "RSAUtil.h"
#import "SystemUtil.h"
#import "OCTSubmanagerUser.h"
#import "OCTSubmanagerFriends.h"
#import "ConnectView.h"
#import "UserConfig.h"
#import "FingerprintVerificationUtil.h"
#import "NSString+Base64.h"
#import "UserHeadUtil.h"
#import "CSLogMacro.h"
#import "NSData+Base64.h"
#import "UserPrivateKeyUtil.h"


@interface LoginViewController ()<OCTSubmanagerUserDelegate> {
    BOOL isLogin;
    BOOL isFind;
    BOOL isConnectSocket;
    BOOL resultLogin;
    NSInteger sendCount;
    BOOL isClickLogin;
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
//    CSLOG_TEST_DDLOG(@"Login View Controller dealloc***************************************************");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 添加通知
 */
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
        [RouterConfig getRouterConfig].currentRouterMAC = @"";
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

/**
 登陆
 @param sender sender
 */
- (IBAction)loginAction:(id)sender {
    
    if ([[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterToxid] isEmptyString]) {
        [self.view showHint:@"Please select the circle."];
        return;
    }
    sendCount = 0;
    isConnectSocket = YES;
    resultLogin = NO;
    isClickLogin = YES;
    
    if (![[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterIp] isEmptyString]) {
        
        NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
        if (connectStatu == socketConnectStatusConnected) {
            [SocketUtil.shareInstance disconnect];
        }
        
        [RouterConfig getRouterConfig].currentRouterIp = @"";
        [RouterConfig getRouterConfig].currentRouterMAC = @"";
        [RouterConfig getRouterConfig].currentRouterSn = self.selectRouther.userSn;
        [RouterConfig getRouterConfig].currentRouterToxid = self.selectRouther.toxid;
        isLogin = YES;
        [self sendGB];
    } else {
        
        if (self.selectRouther) {
            [RouterConfig getRouterConfig].currentRouterSn = self.selectRouther.userSn;
            [RouterConfig getRouterConfig].currentRouterToxid = self.selectRouther.toxid;
            isLogin = YES;
        }
        [RouterConfig getRouterConfig].currentRouterMAC = @"";
        [self sendGB];
    }
}

/**
 扫码操作
 @param sender sender
 */
- (IBAction)rightAction:(id)sender {
    isClickLogin = YES;
    isLogin = NO;
    isFind = NO;
    [self jumpToQR];
}

/**
 选择circle

 @param sender sender
 */
- (IBAction)routherSelect:(id)sender {
    [self showRouter];
}

/**
 导入帐号

 @param values 导入帐号的值
 */
- (void)scanSuccessfulWithIsAccount:(NSArray *)values
{
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"" message:@"This operation will overwrite the current account. Do you want to continue?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    @weakify_self
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *signpk = values[1];
       // NSString *usersn = values[2];
        if (![signpk isEqualToString:[EntryModel getShareObject].signPrivateKey]) {
            
            // 清除所有数据
            [SystemUtil clearAppAllData];
            // 更改私钥
            [UserPrivateKeyUtil changeUserPrivateKeyWithPrivateKey:values[1]];
            NSString *name = [values[3] base64DecodedString];
            [UserModel createUserLocalWithName:name];
            // 删除所有路由
            [RouterModel delegateAllRouter];
            [weakSelf.showRouterArr removeAllObjects];
            weakSelf.selectRouther = nil;
        }
//        else {
//            [AppD.window showHint:@""];
//            weakSelf.selectRouther = [RouterModel checkRoutherWithSn:usersn];
//        }
        [weakSelf changeLogintStatu];
    }];
    
    [vc addAction:cancelAction];
    [vc addAction:confirm];
    
    [self presentViewController:vc animated:YES completion:nil];

}

- (void) parsePowTempCodeBlock
{
    _lblRoutherName.text = @"Default node";
    _loginBtn.enabled = YES;
    _lblRoutherName.textColor = [UIColor whiteColor];
    _loginBtn.backgroundColor = [UIColor whiteColor];
    _lblDesc.text = @"*Select to re-join a circle or scan to join a new one.";
    [_arrowImgView setImage:[UIImage imageNamed:@"icon_arrow_down_gray"] forState:UIControlStateNormal];
    _circleDefaultLab.hidden = NO;
    _circleDefaultImgV.hidden = YES;
}

/**
 扫码成功后回调

 @param isMac 是不是mac帐户
 */
- (void)scanSuccessfulWithIsMacd:(BOOL)isMac
{
    if (isMac) {
        [self loadHudView];
        [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RouterConfig getRouterConfig].currentRouterMAC];
    } else {
        RouterModel *routherM = [RouterModel checkRoutherWithSn:[RouterConfig getRouterConfig].currentRouterSn];
        if (routherM) {
            AppD.isScaner = NO;
            self.selectRouther = routherM;
            [RouterConfig getRouterConfig].currentRouterIp = @"";
            [RouterConfig getRouterConfig].currentRouterToxid = routherM.toxid;
            [RouterConfig getRouterConfig].currentRouterSn = routherM.userSn;
            
            //[self loadHudView];
            //[[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RoutherConfig getRouterConfig].currentRouterToxid];
            _lblRoutherName.text = self.selectRouther.name;
        }
        [self loadHudView];
        [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RouterConfig getRouterConfig].currentRouterToxid];
    }
}


/**
 根据ip,连接socket or tox

 @param isShow 是否显示加载ui
 */
- (void) connectSocketWithIsShowHud:(BOOL) isShow
{
    isConnectSocket = YES;
    
    // 当前是在局域网
    if (![[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterIp] isEmptyString])
    {
        //AppD.manager = nil; tox_stop
        AppD.currentRouterNumber = -1;
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
            [self loginToxWithShowHud:YES];
        }
    }
}

/**
 根据 isfind islogin ,判断当前是find还是login
 */
- (void) findOrLogin
{
    if (isFind) {
        isFind = NO;
        [SendRequestUtil sendUserFindWithToxid:[RouterConfig getRouterConfig].currentRouterToxid usesn:[RouterConfig getRouterConfig].currentRouterSn];
    } else if (isLogin) {
        isLogin = NO;
        sendCount = 0;
        
        [self sendLoginRequestWithUserid:self.selectRouther.userid usersn:@""];
    }
}

/**
 发送登陆请求

 @param userid 用户id
 @param usersn 用户sn
 */
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

/**
 发送注册请求

 @param isShow 是否显示加载ui
 */
- (void) sendRegisterRequestWithShowHud:(BOOL) isShow
{
     NSString *userName = [[UserModel getUserModel].username base64EncodedString];
     [SendRequestUtil sendUserRegisterWithUserPass:@"" username:userName code:@"" showHUD:YES];
    
}


/**
 tox登陆成功回调

 @param manager tox manage
 */
- (void) toxLoginSuccessWithManager:(id<OCTManager>)manager
{
    [self addRouterFriend];
}

/**
 添加circle为好友
 */
- (void) addRouterFriend
{
    
   // [RoutherConfig getRouterConfig].currentRouterToxid = @"A1DA6FFE24611BDE1D14B55B02F180961A3DFB8C9C9B2A572EB274896B7EAC30B4CDCDCE68B8";
    if (![AppD.manager.friends friendIsExitWithFriend:[RouterConfig getRouterConfig].currentRouterToxid]) {
        // 添加好友
        [self showConnectServerLoad];
        BOOL result = [AppD.manager.friends sendFriendRequestToAddress:[RouterConfig getRouterConfig].currentRouterToxid message:@"" error:nil];
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

/**
 显示tox连接中的弹出框
 */
- (void) showConnectServerLoad
{
    if (!_connectView) {
         _connectView = [ConnectView loadConnectView];
    }
    [_connectView showConnectView];
}
/**
 隐藏tox连接中的弹出框
 */
- (void) hideConnectServerLoad
{
    [_connectView hiddenConnectView];
}
#pragma socket边接成功通知
- (void)socketOnConnect:(NSNotification *)noti {
    
    if (AppD.isLoginMac) {
        return;
    }
    isConnectSocket = NO;
    [AppD.window hideHud];
    if (isLogin) {  // 登陆
        sendCount = 0;
        [self sendLoginRequestWithUserid:self.selectRouther.userid usersn:@""];
        isLogin = NO;
    } else if (isFind) {
        [SendRequestUtil sendUserFindWithToxid:[RouterConfig getRouterConfig].currentRouterToxid usesn:[RouterConfig getRouterConfig].currentRouterSn];
        isFind = NO;
    }
   
}
#pragma mark --socket连接失败通知
- (void)socketOnDisconnect:(NSNotification *)noti {
    
    if (AppD.isLoginMac) {
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

/**
 发送组播
 */
- (void) sendGB
{
    [self loadHudView];
    [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RouterConfig getRouterConfig].currentRouterToxid];
}

/**
 得到当前选择的circle
 */
- (void) getCurrentSelectRouter
{
//    if (AppD.showTouch) {
//        self.selectRouther = [RouterModel getLoginOpenRouter];
//        if (!self.selectRouther) {
//            self.selectRouther = [RouterModel getConnectRouter];
//        }
//    } else {
//        self.selectRouther = [RouterModel getConnectRouter];
//    }
    self.selectRouther = [RouterModel getConnectRouter];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    CSLOG_TEST_DDLOG(@"Login View Controller alloc***************************************************");
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
    NSArray *routeArr = [RouterModel getLocalRouters];
    [_showRouterArr addObjectsFromArray:routeArr];
    
    // 默认设置为pow node
//    if (routeArr.count == 0) {
//        [self parsePowTempCode];
//    }
    
    [self addObserve];
    [self appOptionWithLoginType:_loginType];
    
    if (AppD.showTouch && !AppD.isLogOut) {
         AppD.showTouch = NO;
        [FingerprintVerificationUtil show];
    } else {
        if (self.selectRouther.isOpen && !AppD.isLogOut) {
            [self loginAction:nil];
        }
    }
}


/**
 检查当前连接方式
 */
- (void) checkConnectStyle
{
    NSLog(@"ip = %@",[RouterConfig getRouterConfig].currentRouterIp);
    if (![[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterIp] isEmptyString]) {
            [self connectSocketWithIsShowHud:YES];
    } else {
       //[self connectTox];
    }
    [self changeLogintStatu];
}

/**
 更新ui
 */
- (void) changeLogintStatu
{
    
    _lblTitle.text = [NSString stringWithFormat:@"Hello\n%@\nWelcome back!",[UserModel getUserModel].username]?:@"";
    if (self.selectRouther) {
        [RouterConfig getRouterConfig].currentRouterSn = self.selectRouther.userSn;
        [RouterConfig getRouterConfig].currentRouterToxid = self.selectRouther.toxid;
        _lblRoutherName.text = self.selectRouther.name;
    } else {
        [RouterConfig getRouterConfig].currentRouterSn = @"";
        [RouterConfig getRouterConfig].currentRouterToxid = @"";
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
    
    //AppD.manager = nil; tox_stop
    AppD.currentRouterNumber = -1;
    isLogin = NO;
    isFind = NO;
    
    if ([[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterSn] isEqualToString:routeM.userSn]) {
        return;
    }
    self.selectRouther = routeM;
    
    [RouterConfig getRouterConfig].currentRouterIp = @"";
    [RouterConfig getRouterConfig].currentRouterToxid = routeM.toxid;
    [RouterConfig getRouterConfig].currentRouterSn = routeM.userSn;
    
    _lblRoutherName.text = self.selectRouther.name;
}

/**
 显示所有circle
 */
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

/**
 更新头像
 */
- (void)updateUserHead {
//    if (_loginType == ImportType) {
        NSString *Fid = [UserModel getUserModel].userId?:@"";
        NSString *Md5 = @"0";
        [[UserHeadUtil getUserHeadUtilShare] sendUpdateAvatarWithFid:Fid md5:Md5 showHud:NO];
//    }
}


#pragma mark -touch验证成功通知
- (void) touchModifySuccess:(NSNotification *) noti
{
    if (self.selectRouther.isOpen) {
        [self loginAction:nil];
    }
}
#pragma mark -注册推送
- (void) registerPushNoti:(NSNotification *) noti
{
    if (isClickLogin) {
        [SendRequestUtil sendRegidReqeust];
    }
    
}
#pragma mark --tox加圈子为好友成功通知
- (void) toxAddRoterSuccess:(NSNotification *) noti
{
    if (AppD.currentRouterNumber >=0 && isClickLogin) {
        NSLog(@"thread = %@",[NSThread currentThread]);
        NSLog(@"加router好友成功");
        [self hideConnectServerLoad];
        // [AppD.window showHint:@"Server connection successful."];
        [self findOrLogin];
    }
    
}
#pragma mark -组播成功通知
- (void) gbFinashNoti:(NSNotification *) noti
{
    if (!isClickLogin) {
        return;
    }
     [AppD.window hideHud];
    if (![[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterMAC] isEmptyString]) {
        if ([[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterIp] isEmptyString]) {
            isClickLogin = NO;
            [self.view showHint:@"Unable to connect to server."];
        } else {
            isClickLogin = NO;
            [self jumpToLoginDevice];
        }
        
    } else {
        RouterModel *routerModel = [RouterModel checkRoutherWithSn:[RouterConfig getRouterConfig].currentRouterSn];
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
#pragma mark -find接口成功通知
- (void) recivceUserFind:(NSNotification *) noti
{
    if (!isClickLogin) {
        return;
    }
    NSDictionary *receiveDic = (NSDictionary *)noti.object;
    if (receiveDic) {
        NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
        NSString *routherid = receiveDic[@"params"][@"RouteId"];
        NSString *usesn = receiveDic[@"params"][@"UserSn"];
        NSString *userid = receiveDic[@"params"][@"UserId"];
        NSString *userName = receiveDic[@"params"][@"NickName"];
    
        if (![[NSString getNotNullValue:routherid] isEmptyString]) {
            [RouterConfig getRouterConfig].currentRouterToxid = routherid;
        }
        if (![[NSString getNotNullValue:usesn] isEmptyString]) {
            [RouterConfig getRouterConfig].currentRouterSn = usesn;
        }
        
        if (retCode == 0) { //已激活
            sendCount = 0;
            [self sendLoginRequestWithUserid:userid usersn:usesn];

        } else { // 未激活 或者日临时帐户

            [self sendRegisterRequestWithShowHud:YES];
        }
    } else {
        isClickLogin = NO;
    }
}
#pragma mark -登陆成功通知
- (void) loginSuccess:(NSNotification *) noti
{
    if (!isClickLogin) {
        return;
    }
  
    NSInteger retCode = [noti.object integerValue];
    if (retCode == 0) {
        [self updateUserHead];
        [AppD setRootTabbarWithManager:nil];
      //  [AppD.window showHint:@"Login Success"];
    } else {
        isClickLogin = NO;
        if (retCode == 2) { // routeid不对
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
}

#pragma mark -注册成功通知
- (void) userRegisterSuccess:(NSNotification *) noti
{
    if (!isClickLogin) {
        return;
    }
    NSDictionary *receiveDic = (NSDictionary *)noti.object;
    NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
    if (retCode == 0) {
        
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
    } else {
        isClickLogin = NO;
    }

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
//    NSString *devToken = @"Izq2cRDrsOUCzHtqrHpEoKlQgl9heypMieJvHG2WGQU=";
//    NSLog(@"---%@",[devToken base64DecodedData]);
//    
//    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:[AppD.devToken base64EncodedString] preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        UIPasteboard *pBoard = [UIPasteboard generalPasteboard];
//        pBoard.string = [AppD.devToken base64EncodedString];
//    }];
//    [alert1 setValue:UIColorFromRGB(0x2C2C2C) forKey:@"_titleTextColor"];
//    [alertC addAction:alert1];
//   
//    [self presentViewController:alertC animated:YES completion:nil];
    
}

@end
