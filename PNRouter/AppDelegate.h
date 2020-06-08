//
//  AppDelegate.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/4.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PNTabbarViewController.h"
#import "LoginViewController.h"
#import "YJSideMenu.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
//@property (nonatomic, strong) NSString *curLoginToxid;
//@property (nonatomic, strong) NSString *curLoginUsername;
@property (nonatomic ,assign) int currentRouterNumber;
@property (nonatomic ,strong) id<OCTManager> manager;
@property (nonatomic ,assign) BOOL showNewFriendAddRequestRedDot; // 加好友请求
@property (nonatomic ,assign) BOOL showNewGroupAddRequestRedDot; // 邀请加群请求
@property (nonatomic ,assign) BOOL isLogOut;
@property (nonatomic ,assign) BOOL isWifiConnect;
@property (nonatomic ,assign) BOOL isConnect; // 记录当前是不是已连接。如果是就不用再管第二次udp
@property (nonatomic ,assign) BOOL isScaner;
@property (nonatomic ,assign) BOOL isRegister;
@property (nonatomic ,assign) BOOL isDisConnectLogin;
@property (nonatomic ,assign) BOOL isLoginMac;
@property (nonatomic ,assign) BOOL isSwitch;
// google signin
@property (nonatomic ,assign) BOOL isGoogleSign;
// 外部文件打开的url
@property (nonatomic ,strong) NSURL *fileUrl;
// 推广活动字典
@property (nonatomic, strong) NSDictionary *campaignDic;
// 推广活动未读
@property (nonatomic, assign) NSInteger campaignUnReadCount;
//@property (nonatomic ,strong) NSData *devToken;
// 左侧左栏
@property (nonatomic ,strong) YJSideMenu *sideMenuViewController;
// 当前是不是emailpage
@property (nonatomic ,assign) BOOL isEmailPage;
// 当前是不是自动登陆
@property (nonatomic ,assign) BOOL isAutoLogin;
/**
 app是否正在进行登录操作
 */
@property (nonatomic ,assign) BOOL inLogin;
// 通讯录授权状态
@property (nonatomic ,assign) NSInteger contactStatus; // 0:没有授权 1: 成功 2:失败 3:没有选择授权直接返回

- (void)setRootTabbarWithManager:(id<OCTManager>) manager;
- (void)setRootLoginWithType:(LoginType) type;
- (void) setRootTabbarLonginDev;
- (void)judgeLogin;
- (void)addTransitionAnimation;
- (void)logOutApp;

@end

