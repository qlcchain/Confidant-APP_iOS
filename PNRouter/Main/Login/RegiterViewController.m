//
//  RegiterViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/13.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "RegiterViewController.h"
#import "AESCipher.h"
#import "NSString+SHA256.h"
#import "NSString+Base64.h"
#import "SendRequestUtil.h"
#import "RouterConfig.h"
#import "LoginViewController.h"
#import "RouterModel.h"
#import "UserModel.h"
#import "ReviceRadio.h"
#import "PNRouter-Swift.h"
#import "SystemUtil.h"
#import "OCTSubmanagerUser.h"
#import "OCTSubmanagerFriends.h"
#import "ConnectView.h"
#import "UserConfig.h"

@interface RegiterViewController ()<UITextFieldDelegate>
{
    BOOL isLogin;
    BOOL isFind;
}
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *password2TF;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *codeContraintH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *codeContraintV;
@property (nonatomic ,strong) ConnectView *connectView;

@end

@implementation RegiterViewController

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype) initWithAccountType:(AccountType) type
{
    if (self = [super init]) {
        self.accountType = type;
    }
    return self;
}

- (IBAction)registerAction:(id)sender {
    
    if ([_userNameTF.text.trim isEmptyString]) {
        [self.view showHint:@"Nicknames cannot be empty"];
        return;
    }
    if (_accountType != AccountTemp) {
        if ([_codeTF.text.trim isEmptyString]) {
            [self.view showHint:@"Invitation code cannot be empty"];
            return;
        }
    }
    
    if ([_passwordTF.text.trim isEmptyString]) {
        [self.view showHint:@"Password cannot be empty"];
        return;
    }
    if (_passwordTF.text.trim.length < 6 ) {
        [self.view showHint:@"The password must be greater than or equal to 6 digits"];
        return;
    }
    if ([_password2TF.text.trim isEmptyString] || ![_passwordTF.text.trim isEqualToString:_password2TF.text.trim]) {
        [self.view showHint:@"The passwords do not match"];
        return;
    }
    
    if (![[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterIp] isEmptyString])
    {
        NSString *shaPass = [_passwordTF.text.trim SHA256];
        NSString *userName = [_userNameTF.text.trim base64EncodedString];
        
        NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
        if (connectStatu == socketConnectStatusConnected) {
            // 发送注册请求
            [SendRequestUtil sendUserRegisterWithUserPass:shaPass username:userName code:_codeTF.text.trim?:@""];
        } else {
            isLogin = YES;
            [AppD.window showHudInView:AppD.window hint:Connect_Cricle];
            NSString *connectURL = [SystemUtil connectUrl];
            [SocketUtil.shareInstance connectWithUrl:connectURL];
        }
        
    } else {
        isLogin = YES;
        [self connectSocketWithIsShowHud:YES];
    }
}


- (IBAction)rightAction:(id)sender {
    isLogin = NO;
    isFind = NO;
    [self jumpToQR];
}
- (void) scanSuccessfulWithIsMacd:(BOOL)isMac
{
    [AppD.window showHudInView:AppD.window hint:Connect_Cricle];
    if (isMac) {
        [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RouterConfig getRouterConfig].currentRouterMAC];
    } else {
        [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RouterConfig getRouterConfig].currentRouterToxid];
    }
    
}
- (void) addNoti {
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRegisterSuccess:) name:USER_REGISTER_RECEVIE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnConnect:) name:SOCKET_ON_CONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnDisconnect:) name:SOCKET_ON_DISCONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gbFinashNoti:) name:GB_FINASH_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recivceUserFind:) name:USER_FIND_RECEVIE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toxAddRoterSuccess:) name:TOX_ADD_ROUTER_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerPushNoti:) name:REGISTER_PUSH_NOTI object:nil];
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
   self.view.backgroundColor = MAIN_PURPLE_COLOR;
    _registerBtn.layer.cornerRadius = 5.0f;
    _userNameTF.delegate = self;
    _codeTF.delegate = self;
    _passwordTF.delegate = self;
    _password2TF.delegate = self;
    
    if (_accountType == AccountTemp) {
        _codeContraintH.constant = 0;
        _codeContraintV.constant = 0;
    }
    
    [self addNoti];
}
- (void) reloadAcctionType
{
    if (_accountType == AccountTemp) {
        _codeContraintH.constant = 0;
        _codeContraintV.constant = 0;
    } else {
        _codeContraintH.constant = 44;
        _codeContraintV.constant = 5;
    }
}
#pragma mark - textfielddeleate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == _codeTF) {
        //这里的if时候为了获取删除操作,如果没有次if会造成当达到字数限制后删除键也不能使用的后果.
        if (range.length == 1 && string.length == 0) {
            return YES;
        }
        //so easy
        else if (_codeTF.text.length >= 8) {
            _userNameTF.text = [textField.text substringToIndex:8];
            return NO;
        }
    }
    return YES;
}

#pragma mark -连接socket
- (void) connectSocketWithIsShowHud:(BOOL) isShow
{
    // 当前是在局域网
    if (![[RouterConfig getRouterConfig].currentRouterIp isEmptyString])
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
        if (AppD.manager) {
            [self addRouterFriend];
        } else {
            [self loginToxWithShowHud:YES];
        }
    }
}

#pragma mark -tox 登陆成功
- (void) toxLoginSuccessWithManager:(id<OCTManager>)manager
{
    [self addRouterFriend];
}

- (void) addRouterFriend
{
    if (![AppD.manager.friends friendIsExitWithFriend:[RouterConfig getRouterConfig].currentRouterToxid]) {
        // 添加好友
        [self showConnectServerLoad];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            BOOL result = [AppD.manager.friends sendFriendRequestToAddress:[RouterConfig getRouterConfig].currentRouterToxid message:@"" error:nil];
            if (!result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideConnectServerLoad];
                    [AppD.window showHint:@"Failed to connect to the server"];
                });
            }
        });
        
    } else { // 好友已存在并且在线
        if ([AppD.manager.friends getFriendConnectStatuWithFriendNumber:AppD.currentRouterNumber] > 0) {
            [self findOrLogin];
        } else {
            [self showConnectServerLoad];
        }
    }
}

- (void) findOrLogin
{
    if (isLogin) {
        isLogin = NO;
        NSString *shaPass = [_passwordTF.text.trim SHA256];
        NSString *userName = [_userNameTF.text.trim base64EncodedString];
        // 发送注册请求
        [SendRequestUtil sendUserRegisterWithUserPass:shaPass username:userName code:_codeTF.text.trim?:@""];
    } else if (isFind) {
        isFind = NO;
        [SendRequestUtil sendUserFindWithToxid:[RouterConfig getRouterConfig].currentRouterToxid usesn:[RouterConfig getRouterConfig].currentRouterSn];
    }
}

#pragma mark - NOTI

#pragma mark - 通知回调
// 注册推送
- (void) registerPushNoti:(NSNotification *) noti
{
    [SendRequestUtil sendRegidReqeust];
}
// 加router好友成功
- (void) toxAddRoterSuccess:(NSNotification *) noti
{
   // [AppD.window showHint:@"Server connection successful."];
    [self hideConnectServerLoad];
    [AppD.window hideHud];
    [self findOrLogin];
}

- (void) userRegisterSuccess:(NSNotification *) noti
{
    [AppD.window showHint:@"Registered successfully"];
    NSDictionary *receiveDic = (NSDictionary *)noti.object;
    NSString *userid = receiveDic[@"params"][@"UserId"];
    NSString *userSn = receiveDic[@"params"][@"UserSn"];
     NSString *hashid = receiveDic[@"params"][@"Index"];
    NSInteger dataFileVersion = [receiveDic[@"params"][@"DataFileVersion"] integerValue];
    NSString *dataFilePay = receiveDic[@"params"][@"DataFilePay"];
     NSString *shaPass = _passwordTF.text.trim;
    // 保存路由
    [RouterModel addRouterWithToxid:[RouterConfig getRouterConfig].currentRouterToxid usesn:[RouterConfig getRouterConfig].currentRouterSn userid:userid];
    [RouterModel updateRouterPassWithSn:[RouterConfig getRouterConfig].currentRouterSn pass:shaPass];
    // 保存用户
    [UserModel createUserLocalWithName:[_userNameTF.text.trim base64EncodedString] userid:userid version:dataFileVersion filePay:dataFilePay userpass:shaPass userSn:userSn hashid:hashid];
    
    [UserConfig getShareObject].userId = userid;
    [UserConfig getShareObject].userName = _userNameTF.text.trim;
    [UserConfig getShareObject].usersn = userSn;
    [UserConfig getShareObject].passWord = shaPass;
    [UserConfig getShareObject].dataFilePay = dataFilePay;
    [UserConfig getShareObject].dataFileVersion = dataFileVersion;
    
    
    [AppD setRootTabbarWithManager:nil];
}

- (void)socketOnConnect:(NSNotification *)noti {
    
    if (AppD.isLoginMac) {
        return;
    }
    
    [AppD.window hideHud];
    if (isLogin) {
        isLogin = NO;
        NSString *shaPass = [_passwordTF.text.trim SHA256];
        NSString *userName = [_userNameTF.text.trim base64EncodedString];
        // 发送注册请求
        [SendRequestUtil sendUserRegisterWithUserPass:shaPass username:userName code:_codeTF.text.trim?:@""];
    } else {
         [SendRequestUtil sendUserFindWithToxid:[RouterConfig getRouterConfig].currentRouterToxid usesn:[RouterConfig getRouterConfig].currentRouterSn];
    }
   
}

- (void)socketOnDisconnect:(NSNotification *)noti {
    
    if (AppD.isLoginMac) {
        return;
    }
    
    [AppD.window hideHud];
    [AppD.window showHint:@"The connection fails"];
}

- (void) recivceUserFind:(NSNotification *) noti
{
    if (AppD.isLoginMac) {
        return;
    }
    
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
        
        //[RouterModel addRouterWithToxid:routherid usesn:usesn];
        if (retCode == 0) { //已激活
            [RouterModel addRouterWithToxid:routherid usesn:usesn userid:userid];
            [RouterModel updateRouterConnectStatusWithSn:usesn];
            [RouterModel updateRouterConnectStatusWithSn:usesn];
            LoginViewController *vc = [[LoginViewController alloc] init];
            [self setRootVCWithVC:vc];
        } else { // 未激活 或者日临时帐户
            [self reloadAcctionType];
        }
    }
}
- (void) gbFinashNoti:(NSNotification *) noti
{
    if (![[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterMAC] isEmptyString]) {
        if ([[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterIp] isEmptyString]) {
            [self.view showHint:@"Unable to connect to server."];
        } else {
            [self jumpToLoginDevice];
        }
    } else {
        isFind = YES;
        [self connectSocketWithIsShowHud:YES];
    }
}

@end
