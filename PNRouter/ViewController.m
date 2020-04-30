//
//  ViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/4.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ViewController.h"
#import "MyConfidant-Swift.h"
#import "SocketMessageUtil.h"
#import "RouterModel.h"
#import "ReviceRadio.h"
#import "RouterConfig.h"
#import "SystemUtil.h"
#import "UserHeadUtil.h"
#import "UserModel.h"
#import "LoginViewController.h"
#import "PNNavViewController.h"

@interface ViewController ()
{
    int logId;
}

@property (nonatomic, strong) RouterModel *selectRouther;
@end

@implementation ViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark------------注册通知
- (void) registerNoti {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnConnect:) name:SOCKET_ON_CONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnDisconnect:) name:SOCKET_ON_DISCONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gbFinashNoti:) name:GB_FINASH_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:SOCKET_LOGIN_SUCCESS_NOTI object:nil];
}
- (void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 发送组播
    [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:self.selectRouther.toxid];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self registerNoti];
    
    self.selectRouther = [RouterModel getConnectRouter];
    [RouterConfig getRouterConfig].currentRouterToxid = self.selectRouther.toxid;
    [RouterConfig getRouterConfig].currentRouterSn = self.selectRouther.userSn;
    [RouterConfig getRouterConfig].currentRouterIp = self.selectRouther.routeIp;
    [RouterConfig getRouterConfig].currentRouterPort = self.selectRouther.routePort;
    
}

/**
 更新头像
 */
- (void)updateUserHead {

    NSString *Fid = [UserModel getUserModel].userId?:@"";
    NSString *Md5 = @"0";
    [[UserHeadUtil getUserHeadUtilShare] sendUpdateAvatarWithFid:Fid md5:Md5 showHud:NO];

}

- (void)setRootLoginWithType:(LoginType) type {
    [AppD addTransitionAnimation];
    AppD.isLoginMac = NO;

    LoginViewController *vc = [[LoginViewController alloc] initWithLoginType:type];
    AppD.window.rootViewController = [[PNNavViewController alloc] initWithRootViewController:vc];

}

#pragma mark -组播成功通知
- (void) gbFinashNoti:(NSNotification *) noti
{
    
    if ([[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterIp] isEmptyString]) {
        [AppD.window showHint:@"Failed to connect to the server."];
        [self setRootLoginWithType:RouterType];
    } else {
        // 连接socket
         NSString *connectURL = [SystemUtil connectUrl];
         [SocketUtil.shareInstance connectWithUrl:connectURL];
    }
    
}

#pragma socket边接成功通知
- (void)socketOnConnect:(NSNotification *)noti {
    logId = [SendRequestUtil sendLogRequestWtihAction:LOGIN logid:0 type:0 result:0 info:@"start_login"];
    [SendRequestUtil sendUserLoginWithPass:@"" userid:self.selectRouther.userid showHud:NO];
}
#pragma mark --socket连接失败通知
- (void)socketOnDisconnect:(NSNotification *)noti {
    
    [AppD.window showHint:Connect_Failed];
    [self setRootLoginWithType:RouterType];
}

#pragma mark -登陆成功通知
- (void) loginSuccess:(NSNotification *) noti
{
    int retCode = [noti.object intValue];
    if (retCode == 0) {
       // 上传日志
        [SendRequestUtil sendLogRequestWtihAction:LOGIN logid:logId type:100 result:retCode info:@"login_success"];
        // 保存登陆状态
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:Login_Statu_Key];
        [self updateUserHead];
        AppD.isAutoLogin = YES;
        [AppD setRootTabbarWithManager:nil];
        
    } else {
        
        // 保存登陆状态
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:Login_Statu_Key];
        // 上传日志
        [SendRequestUtil sendLogRequestWtihAction:LOGIN logid:logId type:0xFF result:retCode info:@"login_failed"];
        [AppD.window showHint:@"Failed to log in"];
        [self setRootLoginWithType:RouterType];
        
    }
}
@end
