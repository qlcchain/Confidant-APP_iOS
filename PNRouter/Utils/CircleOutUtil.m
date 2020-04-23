//
//  CircleOutUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/4/8.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "CircleOutUtil.h"

#import "NSString+Base64.h"
#import "RouterModel.h"
#import "ChooseCircleCell.h"
#import "HeartBeatUtil.h"
#import "SystemUtil.h"
#import "RouterConfig.h"
#import "MyConfidant-Swift.h"
#import "SocketManageUtil.h"
#import "FileDownUtil.h"
#import "ChatListDataUtil.h"
#import "SendCacheChatUtil.h"
#import "ReviceRadio.h"
#import "UserModel.h"
#import "UserHeadUtil.h"
#import "UserConfig.h"
#import "ConnectView.h"
#import "OCTSubmanagerUser.h"
#import "OCTSubmanagerFriends.h"

#import "OCTManagerConfiguration.h"
#import "OCTManagerFactory.h"
#import "OCTManager.h"
#import "OCTSubmanagerBootstrap.h"

@interface CircleOutUtil()<OCTSubmanagerUserDelegate>
{
    int toxSuccessCount;
    BOOL isFindRequest;
    BOOL isLoginRequest;
    BOOL isRegisterRequest;
    BOOL isSwitchCircle;
    int socketDisCount;
    NSString *currentURL;
    NSString *friendID;
    int requstTime;
}
@property (nonatomic ,strong) ConnectView *connectView;
@end

@implementation CircleOutUtil

+ (instancetype) getCircleOutUtilShare
{
    static CircleOutUtil *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
        [shareObject addSwitchCircleNoti];
    });
    return shareObject;
}

- (void) addSwitchCircleNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gbFinashNoti:) name:GB_FINASH_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnConnect:) name:SOCKET_ON_CONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnDisconnect:) name:SOCKET_ON_DISCONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recivceUserFind:) name:USER_FIND_RECEVIE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:SOCKET_LOGIN_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toxAddRoterSuccess:) name:TOX_ADD_ROUTER_SUCCESS_NOTI object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userRegisterSuccess:) name:USER_REGISTER_RECEVIE_NOTI object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerPushNoti:) name:REGISTER_PUSH_NOTI object:nil];
}

#pragma mark ---更新头像
- (void)updateUserHead {
    NSString *Fid = [UserModel getUserModel].userId?:@"";
    NSString *Md5 = @"0";
    [[UserHeadUtil getUserHeadUtilShare] sendUpdateAvatarWithFid:Fid md5:Md5 showHud:NO];
    
}

- (void) circleOutProcessingWithRid:(NSString *)rid friendid:(nonnull NSString *)friendId
                     //circleOutBlock:(nonnull CircleOutBlock)circleOutBlock
{
    
//    if (circleOutBlock) {
//        self.circleOutBlock = circleOutBlock;
//    }
    
    [AppD.window showHudInView:AppD.window hint:Switch_Cricle];
    friendID = friendId;
    isSwitchCircle = YES;
    // 发送退出请求
    [SendRequestUtil sendLogOut];
    // 停止当前心目跳
    [HeartBeatUtil stop];
    AppD.isLogOut = YES;
    AppD.inLogin = NO;
    socketDisCount = 0;
    
    if ([SystemUtil isSocketConnect]) {
        currentURL = [SystemUtil connectUrl];
        AppD.isSwitch = YES;
        // 取消当前socket 连接
        [[SocketUtil shareInstance] disconnect];
        // 停止缓存发送
        [[SendCacheChatUtil getSendCacheChatUtilShare] stop];
        // 清除所有正在发送文件
        [[SocketManageUtil getShareObject] clearAllConnectSocket];
        // 清除所有正在下载文件
        [[FileDownUtil getShareObject] removeAllTask];
        
    } else {
        AppD.isConnect = NO;
        AppD.currentRouterNumber = -1;
        [[NSNotificationCenter defaultCenter] postNotificationName:TOX_CONNECT_STATUS_NOTI object:nil];
    }
    [[ChatListDataUtil getShareObject].dataArray removeAllObjects];
    [RouterConfig getRouterConfig].currentRouterIp = @"";
    [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:rid];
}

#pragma mark -连接socket_tox
- (void) connectSocketWithIsShowHud:(BOOL) isShow
{
    // 当前是在局域网
    if (![[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterIp] isEmptyString])
    {
        requstTime = 10;
        //AppD.manager = nil; //tox_stop
        AppD.currentRouterNumber = -1;
        NSString *connectURL = [SystemUtil connectUrl];
        [SocketUtil.shareInstance connectWithUrl:connectURL];
        
    } else {
        requstTime = 15;
        if (AppD.manager) {
            [self addRouterFriend];
        } else {
            [self loginToxWithShowHud:NO];
        }
    }
}

#pragma ToxLogin
- (void) loginToxWithShowHud:(BOOL)showHud
{
    AppD.manager = nil;
    AppD.currentRouterNumber = -1;
    if (showHud) {
        [AppD.window showHudInView:AppD.window hint:@"Connect P2P..."];
    }
    
    OCTManagerConfiguration *configuration = [OCTManagerConfiguration defaultConfiguration];
    configuration.options.udpEnabled = YES;
    configuration.options.proxyType = OCTToxProxyTypeNone;
    configuration.options.holePunchingEnabled = YES;
    configuration.options.localDiscoveryEnabled = YES;
    configuration.options.ipv6Enabled = YES;
    @weakify_self
    [OCTManagerFactory managerWithConfiguration:configuration encryptPassword:TOX_DATA_PASS successBlock:^(id < OCTManager > manager) {
        
        if (showHud) {
            [AppD.window hideHud];
        }
        [manager.bootstrap addPredefinedNodes];
        [manager.bootstrap bootstrap];
        
        if (![SystemUtil isSocketConnect]) {
            //AppD.manager = nil; tox_stop
            AppD.manager = manager;
             [weakSelf toxLoginSuccessWithManager:manager];
        }
        
    } failureBlock:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (showHud) {
                [AppD.window hideHud];
            } else {
                [weakSelf toxLoginSuccessWithManager:nil];
            }
            [AppD.window showHint:Connect_Failed];
        });
        
    }];
}


// 添加tox好友
- (void) addRouterFriend
{
    if (![AppD.manager.friends friendIsExitWithFriend:[RouterConfig getRouterConfig].currentRouterToxid]) {
        // 隐藏连接圈子提示
        [AppD.window hideHud];
        // 显示p2p连接
        [self showConnectServerLoad];
        // 添加好友
        BOOL result = [AppD.manager.friends sendFriendRequestToAddress:[RouterConfig getRouterConfig].currentRouterToxid message:@"" error:nil];
        if (!result) { // 添加好友失败
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideConnectServerLoad];
                [self switchCircleFaieldWithHintString:Connect_Failed];
                
               // [self loginToxWithShowHud:NO];
            });
        }
        
    } else { // 好友已存在并且在线
        if ([AppD.manager.friends getFriendConnectStatuWithFriendNumber:AppD.currentRouterNumber] > 0) {
            // 走 find 请求
            [self toxConnectSuccessSendFindRequest];
            
        } else {
            // 隐藏连接圈子提示
            [AppD.window hideHud];
            [self showConnectServerLoad];
        }
    }
}
// tox 连接成功后 调用find 请求
- (void) toxConnectSuccessSendFindRequest
{
    toxSuccessCount +=1;
    if (toxSuccessCount == 1) {
        [AppD.window showHudInView:AppD.window hint:Connect_Cricle];
        isFindRequest = NO;
        [SendRequestUtil sendUserFindWithToxid:[RouterConfig getRouterConfig].currentRouterToxid usesn:[RouterConfig getRouterConfig].currentRouterSn showHud:NO];
        [self performSelector:@selector(checkFindRequstOutTime) withObject:self afterDelay:requstTime];
    }
    
}
// 显示连接p2p提示层
- (void) showConnectServerLoad
{
    if (!_connectView) {
        _connectView = [ConnectView loadConnectView];
        @weakify_self
        [_connectView setClickCancelBlock:^{
            [weakSelf switchCircleFaieldWithHintString:@"Circle connection failed."];
        }];
    }
    [_connectView showConnectView];
}
- (void) hideConnectServerLoad
{
    [_connectView hiddenConnectView];
}

#pragma mark -tox 登陆成功
- (void) toxLoginSuccessWithManager:(id<OCTManager>)manager
{
    if (manager) {
        [self addRouterFriend];
    } else {
        [self switchCircleFaieldWithHintString:@"Circle connection failed."];
    }
    
}


#pragma mark -- 切换失败
- (void) switchCircleFaieldWithHintString:(NSString *) hitStr
{
    AppD.currentRouterNumber = -1;
    isSwitchCircle = NO;
    [AppD.window hideHud];
    AppD.isSwitch = NO;
    [RouterConfig getRouterConfig].currentRouterIp = @"";
    
    [AppD.window showFaieldHudInView:AppD.window hint:Switch_Cricle_Failed];
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [AppD setRootLoginWithType:RouterType];
    });
    
//    [AppD setRootLoginWithType:RouterType];
//    [AppD.window showHint:hitStr];
}
#pragma mark- --切换成功
- (void) switchCircleSuccess
{
    
    if (friendID && friendID.length > 0) {
        [SendRequestUtil sendAutoAddFriendWithFriendId:friendID email:@"" type:1 showHud:NO];
    }
    
    if (![SystemUtil isSocketConnect]) {
        if (AppD.currentRouterNumber < 0) {
            return;
        }
    }
    [AppD.window showSuccessHudInView:AppD.window hint:@"Switched"];
    
    isSwitchCircle = NO;
    AppD.isLogOut = NO;
    AppD.inLogin = YES;
    AppD.isSwitch = NO;
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
       [AppD setRootTabbarWithManager:AppD.manager];
    });
    
    
}
// 检测find请求10秒内是否有返回
- (void) checkFindRequstOutTime
{
    if (!isFindRequest) {
        if (toxSuccessCount == 2) {
            isFindRequest = NO;
            [SendRequestUtil sendUserFindWithToxid:[RouterConfig getRouterConfig].currentRouterToxid usesn:[RouterConfig getRouterConfig].currentRouterSn showHud:NO];
            [self performSelector:@selector(checkFindRequstOutTime) withObject:self afterDelay:requstTime];
        } else {
            [AppD.window hideHud];
            [self switchCircleFaieldWithHintString:@"Circle connection failed."];
        }
    }
}
// 检测登录请求10秒内是否有返回
- (void) checkLoginRequstOutTime
{
    if (!isLoginRequest) {
        [AppD.window hideHud];
        [self switchCircleFaieldWithHintString:@"Circle connection failed."];
    }
}
- (void) checkRegisetRequstOutTime
{
    if (!isRegisterRequest) {
        [AppD.window hideHud];
        [self switchCircleFaieldWithHintString:@"Circle connection failed."];
    }
}

#pragma mark ---通知回调
- (void) gbFinashNoti:(NSNotification *) noti
{
    if (isSwitchCircle) {
        if (![[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterMAC] isEmptyString]) {
            isSwitchCircle = NO;
            [AppD.window hideHud];
            if ([[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterIp] isEmptyString]) {
                [AppD.window showHint:@"Failed to connect to the server."];
            } else {
                [AppD setRootTabbarLonginDev];
            }
        } else {
            [self connectSocketWithIsShowHud:NO];
        }
    }
    
   
}
- (void)socketOnConnect:(NSNotification *)noti {
    if (isSwitchCircle) {
        // 走find5
        isFindRequest = NO;
        [SendRequestUtil sendUserFindWithToxid:[RouterConfig getRouterConfig].currentRouterToxid usesn:[RouterConfig getRouterConfig].currentRouterSn showHud:NO];
        [self performSelector:@selector(checkFindRequstOutTime) withObject:self afterDelay:requstTime];
    }
    
}

- (void)socketOnDisconnect:(NSNotification *)noti {
    
    if (isSwitchCircle) {
//        socketDisCount +=1;
//        if (socketDisCount ==1) {
//            return;
//        }
        NSString *url = noti.object;
        if ([url isEqualToString:currentURL]) {
            return;
        }
        [AppD.window hideHud];
        [self switchCircleFaieldWithHintString:@"Circle connection failed."];
    }
}
// find5 通知回调
- (void) recivceUserFind:(NSNotification *) noti
{
    if (isSwitchCircle) {
        isFindRequest = YES;
        NSDictionary *receiveDic = (NSDictionary *)noti.object;
        if (receiveDic) {
            NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
            NSString *routherid = receiveDic[@"params"][@"RouteId"];
            NSString *usesn = receiveDic[@"params"][@"UserSn"];
            NSString *userid = receiveDic[@"params"][@"UserId"];
            // NSString *userName = receiveDic[@"params"][@"NickName"];
            
            if (![[NSString getNotNullValue:routherid] isEmptyString]) {
                [RouterConfig getRouterConfig].currentRouterToxid = routherid;
            }
            if (![[NSString getNotNullValue:usesn] isEmptyString]) {
                [RouterConfig getRouterConfig].currentRouterSn = usesn;
            }
            
            if (retCode == 0) { //已激活
                [AppD.window showHudInView:AppD.window hint:@"Login..."];
                isLoginRequest = NO;
                [SendRequestUtil sendUserLoginWithPass:usesn userid:userid showHud:NO];
                [self performSelector:@selector(checkLoginRequstOutTime) withObject:self afterDelay:requstTime];
            } else { // 未激活 或者日临时帐户
                [AppD.window showHudInView:AppD.window hint:@"Register..."];
                isRegisterRequest = NO;
                NSString *userName = [[UserModel getUserModel].username base64EncodedString];
                [SendRequestUtil sendUserRegisterWithUserPass:@"" username:userName code:@"" showHUD:NO];
                [self performSelector:@selector(checkRegisetRequstOutTime) withObject:self afterDelay:requstTime];
                
            }
        }
    }
    
}

#pragma mark -注册成功
- (void) userRegisterSuccess:(NSNotification *) noti
{
    if (isSwitchCircle) {
        isRegisterRequest = YES;
        [AppD.window hideHud];
        
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
            
            [self switchCircleSuccess];
        } else {
            if (retCode == 1) {
                [self switchCircleFaieldWithHintString:@"Router id error."];
            } else if (retCode == 2) {
                [self switchCircleFaieldWithHintString:@"The qr code has been activated by other users."];
            } else if (retCode == 3) {
                [self switchCircleFaieldWithHintString:@"Error verification coder."];
            }else{
                [self switchCircleFaieldWithHintString:@"Other error."];
            }
            
        }
    }
    
}


#pragma mark -登陆成功
- (void) loginSuccess:(NSNotification *) noti
{
    if (isSwitchCircle) {
        isLoginRequest = YES;
        [AppD.window hideHud];
        NSInteger retCode = [noti.object integerValue];
        if (retCode == 0) {
            [self switchCircleSuccess];
        } else if (retCode == 2) { // routeid不对
            [self switchCircleFaieldWithHintString:@"Routeid wrong."];
        } else if (retCode == 1) { //需要验证
            [self switchCircleFaieldWithHintString:@"Need to verify."];
        } else if (retCode == 3) { //uid错误
            [self switchCircleFaieldWithHintString:@"uid wrong."];
        } else if (retCode == 4) { //登陆密码错误
            [self switchCircleFaieldWithHintString:@"Login failed, verification failed."];
        } else if (retCode == 5) { //验证码错误
            [self switchCircleFaieldWithHintString:@"Verification code error."];
        } else { // 其它错误
            [self switchCircleFaieldWithHintString:@"Login failed Other error."];
        }
    }
    
}

#pragma mark --- 注册推送
- (void) registerPushNoti:(NSNotification *) noti
{
    if (isSwitchCircle) {
         [SendRequestUtil sendRegidReqeust];
    }
}

#pragma mark -加router好友成功
- (void) toxAddRoterSuccess:(NSNotification *) noti
{
    if (isSwitchCircle) {
        NSLog(@"thread = %@",[NSThread currentThread]);
        NSLog(@"加router好友成功----switch circle");
        [self hideConnectServerLoad];
        [self toxConnectSuccessSendFindRequest];
    }
}

@end
