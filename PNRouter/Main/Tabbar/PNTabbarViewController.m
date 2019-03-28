//
//  QNTabbarViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "PNTabbarViewController.h"
#import "MyViewController.h"
#import "PNNavViewController.h"
#import "FileViewController.h"
#import "ContactViewController.h"
#import "NewsViewController.h"
#import "SystemUtil.h"
#import "PNRouter-Swift.h"
#import "SocketAlertView.h"
#import "SocketCountUtil.h"
#import "SocketMessageUtil.h"
#import "ChatListDataUtil.h"
#import "ChatListModel.h"
#import "FriendModel.h"
#import "UserModel.h"
#import "RouterModel.h"
#import "WZLBadgeImport.h"
#import "NSString+SHA256.h"
#import "UserConfig.h"
#import "HeartBeatUtil.h"
#import "RouterConfig.h"
#import "LibsodiumUtil.h"
#import <AFNetworking/AFNetworking.h>
#import "AFHTTPClientV2.h"
#import "ReviceRadio.h"
#import "SocketManageUtil.h"
#import "FileDownUtil.h"
#import "SendCacheChatUtil.h"

@interface PNTabbarViewController ()<UITabBarControllerDelegate>
@property (nonatomic ,strong) SocketAlertView *alertView;
@property (nonatomic ,strong) id<OCTManager> manager;
@end

@implementation PNTabbarViewController

- (instancetype)initWithManager:(id<OCTManager>) manager
{
    if (self = [super init]) {
        self.manager = manager;
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (SocketAlertView *)alertView
{
    if (!_alertView) {
        _alertView = [SocketAlertView loadSocketAlertView];
    }
    return _alertView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置tintColor -> 统一设置tabBar的选中颜色
    // 越早设置越好，一般放到AppDelegate中
    // 或者：设置图片渲染模式、设置tabBar文字
    //[[UITabBar appearance] setTintColor:[UIColor clearColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setShadowImage:[UIImage imageWithColor:UIColorFromRGB(0xf5f5f5) size:CGSizeMake(SCREEN_WIDTH,0.5)]];
//    [[UITabBar appearance] setShadowImage:[UIImage new]];
    [UITabBar appearance].translucent = NO;
//    [[UITabBar appearance] setBackgroundImage:[UIImage new]];
    // 添加阴影
//    self.tabBar.layer.shadowColor = SHADOW_COLOR.CGColor;
//    self.tabBar.layer.shadowOffset = CGSizeMake(0, -1);
//    self.tabBar.layer.shadowOpacity = 0.3;
    // 添加渐变背景
    //    [self.tabBar addQGradient];
    self.delegate = self;
    
    [self addChildViewController:[[NewsViewController alloc] initWithManager:self.manager] text:@"Chats" imageName:@"btn_news"];
    [self addChildViewController:[[FileViewController alloc] initWithManager:self.manager] text:@"Files" imageName:@"btn_file"];
    [self addChildViewController:[[ContactViewController alloc] initWithManager:self.manager] text:@"Contacts" imageName:@"btn_contacts"];
    [self addChildViewController:[[MyViewController alloc] initWithManager:self.manager] text:@"My" imageName:@"btn_my"];
    
    [self sendFriendAndGroupList];
     // socket 断开连接通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketDisconnectNoti:) name:SOCKET_DISCONNECT_NOTI object:nil];
    // socket 连接的通知
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnconnectNoti:) name:SOCKET_ON_CONNECT_NOTI object:nil];
    // 获取好友列表通知
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFriendListNoti:) name:GET_FRIEND_LIST_NOTI object:nil];
    // 好友申请红点通知
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactHDShow) name:TABBAR_CONTACT_HD_NOTI object:nil];
    // chats红点通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatsHDShow:) name:TABBAR_CHATS_HD_NOTI object:nil];
    // tox重连成功通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toxReConnectSuccessNoti:) name:TOX_RECONNECT_SUCCESS_NOTI object:nil];
    // app口强制退出通知
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appLogoutNoti:) name:REVER_APP_LOGOUT_NOTI object:nil];
    // 广播成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gbFinashNoti:) name:GB_FINASH_NOTI object:nil];
    // 群组列表查询通知
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullGroupSucess:) name:PULL_GROUP_SUCCESS_NOTI object:nil];
    // 得新拉取好友和群组列表消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendFriendAndGroupList) name:GET_FRIEND_GROUP_LIST_NOTI object:nil];
    
}

- (void) sendFriendAndGroupList
{
    // 获取好友列表
    [self sendGetFriendNoti];
    // 获取群组列表
    [SendRequestUtil sendPullGroupListWithShowHud:NO];
}

- (void) addChildViewController:(UIViewController *) childController text:(NSString *) text imageName:(NSString *) imageName {
    // 设置item图片不渲染
    childController.tabBarItem.image = [[UIImage imageNamed:[imageName stringByAppendingString:@"_normal"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childController.tabBarItem.selectedImage = [[UIImage imageNamed:[imageName stringByAppendingString:@"_highlight"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    // 设置标题的属性
    [childController.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:TABBARTEXT_DEFAULT_COLOR} forState:UIControlStateNormal];
    [childController.tabBarItem setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10],NSForegroundColorAttributeName:TABBARTEXT_SELECT_COLOR} forState:UIControlStateSelected];
    PNNavViewController *nav = [[PNNavViewController alloc] initWithRootViewController:childController];
    
    // 设置item的标题
    childController.tabBarItem.title = text;
    childController.navigationItem.title = text;
    childController.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -3);
    
    [self addChildViewController:nav];
}

#pragma mark - UITabBarControllerDelegate-
//- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
//    if ([((QlinkNavViewController *)viewController).topViewController isKindOfClass:[WalletViewController class]]){
//
//    }
//    return YES;
//}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    
}

- (void) logout {
    
    [[SendCacheChatUtil getSendCacheChatUtilShare] stop];
    [SendRequestUtil sendLogOut];
    AppD.inLogin = NO;
    [HeartBeatUtil stop];
    if ([SystemUtil isSocketConnect]) {
        [RouterConfig getRouterConfig].currentRouterIp = @"";
        [[SocketUtil shareInstance] disconnect];
        // 清除所有正在发送文件
        [[SocketManageUtil getShareObject] clearAllConnectSocket];
        // 清除所有正在下载文件
        [[FileDownUtil getShareObject] removeAllTask];
    } else {
        AppD.isConnect = NO;
        // [self logOutTox];
        [[NSNotificationCenter defaultCenter] postNotificationName:TOX_CONNECT_STATUS_NOTI object:nil];
    }
    [[ChatListDataUtil getShareObject].dataArray removeAllObjects];
    AppD.isLogOut = YES;
    [AppD setRootLoginWithType:RouterType];
}

#pragma mark - noti
- (void) appLogoutNoti:(NSNotification *) noti
{
    [self logout];
}

- (void) toxReConnectSuccessNoti:(NSNotification *) noti
{
    // 重新登录
    AppD.isDisConnectLogin = YES;
    UserConfig *userM = [UserConfig getShareObject];
    [SendRequestUtil sendUserLoginWithPass:@"" userid:userM.userId showHud:NO];
}
- (void) socketOnconnectNoti:(NSNotification *) noti
{
    if (AppD.isSwitch) {
        return;
    }
    [HeartBeatUtil stop];
    AppD.isDisConnectLogin = YES;
    UserConfig *userM = [UserConfig getShareObject];
    [SendRequestUtil sendUserLoginWithPass:@"" userid:userM.userId showHud:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_SOCKET_FAILD_NOTI object:@"1"];
}
- (void) socketDisconnectNoti:(NSNotification *) noti
{
    if (AppD.isSwitch) {
        return;
    }
     [[SendCacheChatUtil getSendCacheChatUtilShare] stop];
     [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_SOCKET_FAILD_NOTI object:@"0"];
    if ([SystemUtil isSocketConnect]) {
        
        AFNetworkReachabilityManager  *man=[AFNetworkReachabilityManager sharedManager];
        
        // AFNetworkReachabilityStatusUnknown          = -1,
        // AFNetworkReachabilityStatusNotReachable     = 0,
        // AFNetworkReachabilityStatusReachableViaWWAN = 1,
        // AFNetworkReachabilityStatusReachableViaWiFi = 2,
        
        //开始监听
        [man startMonitoring];
        @weakify_self
        [man setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            
            switch (status) {
            
                case AFNetworkReachabilityStatusReachableViaWiFi:
                    [weakSelf sendHtppRequestWithIs4g:YES];
                    break;
                    
                case AFNetworkReachabilityStatusReachableViaWWAN:
                    [weakSelf sendHtppRequestWithIs4g:YES];
                    break;
                    
                default:
                     [weakSelf sendHtppRequestWithIs4g:NO];
                    break;
            }
            
        }];
    }
}

- (void) sendHtppRequestWithIs4g:(BOOL) is4g
{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    if (AppD.isWifiConnect && is4g) {
         [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RouterConfig getRouterConfig].currentRouterToxid];
    } else {
        [self performSelector:@selector(connectSocket) withObject:nil afterDelay:1.0f];
    }
}

- (void) connectSocket {
    [SocketCountUtil getShareObject].reConnectCount += 1;
    NSString *connectURL = [SystemUtil connectUrl];
    if (connectURL && ![connectURL isEmptyString]) {
        [SocketUtil.shareInstance connectWithUrl:connectURL];
    }
}
#pragma mark -广播完成
- (void) gbFinashNoti:(NSNotification *) noti
{
    [self connectSocket];
}

//- (void) sendRequestWithRid:(NSString *) rid
//{
//    NSString *url = [NSString stringWithFormat:@"https://pprouter.online:9001/v1/pprmap/Check?rid=%@",rid];
//    @weakify_self
//    [AFHTTPClientV2 requestWithBaseURLStr:url params:@{} httpMethod:HttpMethodGet successBlock:^(NSURLSessionDataTask *dataTask, id responseObject) {
//
//        NSInteger retCode = [responseObject[@"RetCode"] integerValue];
//        NSInteger connStatus = [responseObject[@"ConnStatus"] integerValue];
//        if (retCode == 0 && connStatus == 1) {
//            NSString *routerIp = responseObject[@"ServerHost"];
//            NSString *routerPort = [NSString stringWithFormat:@"%@",responseObject[@"ServerPort"]];
//            NSString *routerId = [NSString stringWithFormat:@"%@",responseObject[@"Rid"]];
//            [RoutherConfig getRouterConfig].currentRouterPort = routerPort;
//            [[RoutherConfig getRouterConfig] addRoutherWithArray:@[routerIp?:@"",routerId?:@""]];
//            [RoutherConfig getRouterConfig].currentRouterIp = routerIp;
//            [RoutherConfig getRouterConfig].currentRouterToxid = routerId;
//
//            [weakSelf connectSocket];
//        }
//
//    } failedBlock:^(NSURLSessionDataTask *dataTask, NSError *error) {
//        [weakSelf connectSocket];
//    }];
//
//}

#pragma mark - 获取好友列表
- (void) sendGetFriendNoti
{
    [SocketMessageUtil sendFriendListRequest];
}
// 获取群列表
- (void) pullGroupSucess:(NSNotification *) noti
{
    NSArray *groups = noti.object;
    if ([ChatListDataUtil getShareObject].groupArray.count>0 > 0) {
        [[ChatListDataUtil getShareObject].groupArray removeAllObjects];
    }
    [[ChatListDataUtil getShareObject].groupArray addObjectsFromArray:groups];
}
- (void) getFriendListNoti:(NSNotification *) noti {
    
    NSString *jsonModel =(NSString *)noti.object;
    NSArray *modelArr = [jsonModel mj_JSONObject];
    if ([ChatListDataUtil getShareObject].friendArray.count>0) {
        [[ChatListDataUtil getShareObject].friendArray removeAllObjects];
    }
    if (modelArr) {
        NSArray *friendArr = [FriendModel mj_objectArrayWithKeyValuesArray:modelArr];
        [friendArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FriendModel *model = obj;
            if (model.remarks && ![model.remarks isEmptyString]) {
                model.username = model.remarks;
            }
            model.publicKey = [LibsodiumUtil getFriendEnPublickkeyWithFriendSignPublicKey:model.signPublicKey];
        }];
        [[ChatListDataUtil getShareObject].friendArray addObjectsFromArray:friendArr];
    }
}

- (void) contactHDShow
{
    UITabBarItem *item1 = self.tabBar.items[2];
    if (AppD.showNewFriendAddRequestRedDot || AppD.showNewGroupAddRequestRedDot) {
        item1.badgeBgColor = TABBAR_RED_COLOR;
        [item1 showBadge];
    } else {
        [item1 clearBadge];
    }
}
- (void) chatsHDShow:(NSNotification *) noti
{
   
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSMutableArray *chats = noti.object;
        __block BOOL isShow = NO;
        [chats enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChatListModel *model = (ChatListModel *)obj;
            if (model.isHD) {
                isShow = YES;
                *stop = YES;
            }
        }];
        
        UITabBarItem *item1 = [self.tabBar.items firstObject];
        if (isShow) {
            item1.badgeBgColor = TABBAR_RED_COLOR;
            [item1 showBadge];
        } else {
            [item1 clearBadge];
        }
    });
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
