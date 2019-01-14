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
#import "RoutherConfig.h"

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
    [[UITabBar appearance] setShadowImage:[UIImage new]];
    [UITabBar appearance].translucent = NO;
    //    [[UITabBar appearance] setBackgroundImage:[UIImage new]];
    // 添加阴影
    self.tabBar.layer.shadowColor = SHADOW_COLOR.CGColor;
    self.tabBar.layer.shadowOffset = CGSizeMake(0, -1);
    self.tabBar.layer.shadowOpacity = 0.3;
    // 添加渐变背景
    //    [self.tabBar addQGradient];
    self.delegate = self;
    
    [self addChildViewController:[[NewsViewController alloc] initWithManager:self.manager] text:@"Chats" imageName:@"btn_news"];
   // [self addChildViewController:[[FileViewController alloc] initWithManager:self.manager] text:@"Files" imageName:@"btn_file"];
    [self addChildViewController:[[ContactViewController alloc] initWithManager:self.manager] text:@"Contacts" imageName:@"btn_contacts"];
    [self addChildViewController:[[MyViewController alloc] initWithManager:self.manager] text:@"Me" imageName:@"btn_my"];
    
    // 获取好友列表
    [self sendGetFriendNoti];
    
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

- (void)logout {
    [SendRequestUtil sendLogOut];
    [HeartBeatUtil stop];
    if ([SystemUtil isSocketConnect]) {
        [RoutherConfig getRoutherConfig].currentRouterIp = @"";
        [[SocketUtil shareInstance] disconnect];
    } else {
        AppD.isConnect = NO;
    }
    [[ChatListDataUtil getShareObject].dataArray removeAllObjects];
    AppD.isLogOut = YES;
    [AppD setRootLogin];
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
    [SendRequestUtil sendUserLoginWithPass:[userM.passWord SHA256] userid:userM.userId showHud:NO];
}
- (void) socketOnconnectNoti:(NSNotification *) noti
{
    [HeartBeatUtil stop];
    AppD.isDisConnectLogin = YES;
    UserConfig *userM = [UserConfig getShareObject];
    [SendRequestUtil sendUserLoginWithPass:[userM.passWord SHA256] userid:userM.userId showHud:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_SOCKET_FAILD_NOTI object:@"1"];
}
- (void) socketDisconnectNoti:(NSNotification *) noti
{
//    [AppD.window hideHud];
//    [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_SOCKET_FAILD_NOTI object:@"0"];
//    return;
    
//    NSLog(@"----reConnectCount = %zd ",[SocketCountUtil getShareObject].reConnectCount);
//    if ([SocketCountUtil getShareObject].reConnectCount == 1) {
//        [AppD.window hideHud];
//        [[NSNotificationCenter defaultCenter] postNotificationName:RELOAD_SOCKET_FAILD_NOTI object:@"0"];
//        return;
//    }
    [self performSelector:@selector(connectSocket) withObject:nil afterDelay:1.0f];
}

- (void) connectSocket {
    [SocketCountUtil getShareObject].reConnectCount += 1;
    NSString *connectURL = [SystemUtil connectUrl];
    if (connectURL && ![connectURL isEmptyString]) {
        [SocketUtil.shareInstance connectWithUrl:connectURL];
    }
}


#pragma mark - 获取好友列表
- (void) sendGetFriendNoti
{
    [SocketMessageUtil sendFriendListRequest];
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
        }];
        [[ChatListDataUtil getShareObject].friendArray addObjectsFromArray:friendArr];
    }
}

- (void) contactHDShow
{
    UITabBarItem *item1 = self.tabBar.items[1];
    if (AppD.showHD) {
        item1.badgeBgColor = MAIN_PURPLE_COLOR;
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
            item1.badgeBgColor = MAIN_PURPLE_COLOR;
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
