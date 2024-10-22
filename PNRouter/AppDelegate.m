//
//  AppDelegate.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/4.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "AppDelegate.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "PNNavViewController.h"
#import "CDChatList.h"
#import <objc/runtime.h>
#import "KeyCUtil.h"
#import "FriendModel.h"
#import "SystemUtil.h"
#import "MyConfidant-Swift.h"
#import "GuidePageViewController.h"
#import "ViewController.h"
#import "ReviceRadio.h"
#import "RouterModel.h"
#import "RouterConfig.h"
#import <Bugly/Bugly.h>
#import "RunInBackground.h"
#import "RSAModel.h"
#import "OperationRecordModel.h"
#import "CreateAccountViewController.h"
#import "UserModel.h"
#import "NSDate+Category.h"
#import "FingerprintVerificationUtil.h"
#import "PNUnlockView.h"
#import "SendCacheChatUtil.h"
#import "SocketMessageUtil.h"
#import "PNBackgroundView.h"
#import "ChatModel.h"
#import "CSLogger.h"
#import "CSLogMacro.h"
#import "HeartBeatUtil.h"
#import "SocketManageUtil.h"
#import "FileDownUtil.h"
#import "ChatListDataUtil.h"
#import "LoginDeviceViewController.h"
#import "UserConfig.h"
#import "ChatListModel.h"
#import "LeftViewController.h"
#import "UserPrivateKeyUtil.h"
#import "PNSendSelectViewController.h"
#import "PNNewsViewController.h"

// 引入 JPush 功能所需头文件
#import "JPUSHService.h"
// iOS10 注册 APNs 所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>

// google
#import <GoogleSignIn/GoogleSignIn.h>
#import "GoogleUserModel.h"
#import "EmailAccountModel.h"
//#import <GoogleAnalytics/GAI.h>
//#import <GoogleAnalytics/GAIDictionaryBuilder.h>
//#import <GoogleAnalytics/GAIFields.h>

#endif

@interface AppDelegate () <BuglyDelegate,JPUSHRegisterDelegate,GIDSignInDelegate> 
{
    BOOL isBackendRun;
    BOOL isFingerprintOn;
}
//@property (nonatomic, assign) NSThread *thread;
@property (nonatomic, strong) PNUnlockView *unlockView;
@property (nonatomic, strong) PNBackgroundView *backgroundView;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // apn 内容获取：
   // NSDictionary *remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    
    AppD.currentRouterNumber = -1;
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    // 去除icon 角标
//    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
//         [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//         [JPUSHService setBadge:0];
//    }
    

   //  [KeyCUtil deleteWithKey:@"emailKey_arr"];
  //   [KeyCUtil deleteAllKey];
    
    // 配置google认证
    [GIDSignIn sharedInstance].clientID = CLIENT_ID;
    [GIDSignIn sharedInstance].delegate = self;
    
    // 配置埋点
    [FIRApp configure];
    // 配置Bugly
    [self configBugly];
    // 配置推送
    [self configMiPush:launchOptions];
    // 配置DDLog
   // [self configDDLog];
    // 配置IQKeyboardManager
    [self keyboardManagerConfig];
    
    // 异步执行耗时操作
    @weakify_self
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        // 得到签名，加密 公私钥对
        NSString *modelJson = [KeyCUtil getKeyValueWithKey:libkey];
        EntryModel *model = [LibsodiumUtil getPrivatekeyAndPublickeyWithModelJson:modelJson];
        [UserPrivateKeyUtil changeUserPrivateKeyWithPrivateKey:model.signPrivateKey];
        // 配置聊天
        [weakSelf configChat];
        // 打开时改变文件上传下载状态
        [SystemUtil appFirstOpen];
        // 清除发送失败已经不存在图片
        [[SendCacheChatUtil getSendCacheChatUtilShare] deleteCacheFileNollData];
    });
    
    // 检查显示UI
    [self checkGuidenPage];
    
    if (@available(iOS 13.0, *)) {
        self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    } else {
        // Fallback on earlier versions
    }
    
    //设置UIBarButtonItem和UINavigationBar的默认文字颜色
    [[UIBarButtonItem appearance] setTintColor:MAIN_PURPLE_COLOR];
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = MAIN_PURPLE_COLOR;
    [[UINavigationBar appearance] setTitleTextAttributes:attrs];
    
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
  
//    CSLOG_TEST_DDLOG(@"当前执行方法------%@",NSStringFromSelector(_cmd));
    [self.backgroundView show];
    if (self.backgroundView.isShow && _unlockView.isShow) {
        [self.window insertSubview:self.backgroundView belowSubview:self.unlockView];
    }
    
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    // 播放无声音乐
//    if ([SystemUtil isSocketConnect]) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            self->isBackendRun = YES;
//            [[RunInBackground sharedBg] startRunInbackGround];
//            [[NSRunLoop currentRunLoop] run];
//        });
 //   }
    
    // 更新app通知count
    NSInteger appCount = [self getUnReadMessageCount];
    // 重新设置 icon 角标
    [UIApplication sharedApplication].applicationIconBadgeNumber = appCount+self.campaignUnReadCount;
    [JPUSHService setBadge:appCount];
    
    NSInteger seconds =  [NSDate getTimestampFromDate:[NSDate date]] ;
    [HWUserdefault updateObject:@(seconds) withKey:BACK_TIME];
    
    // 发送心跳
    UserModel *userM = [UserModel getUserModel];
    if (userM.userId && userM.userId.length >0 && _inLogin) {
        NSDictionary *params = @{@"Action":@"HeartBeat",@"UserId":userM.userId?:@"",@"Active":@"1"};
        [SocketMessageUtil sendVersion1WithParams:params];
    }
    
   
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    // 去除icon 角标
//    if ([UIApplication sharedApplication].applicationIconBadgeNumber > 0) {
//        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//        [JPUSHService setBadge:0];
//    }
    
    // 发送心跳
    UserModel *userM = [UserModel getUserModel];
    if (userM.userId && userM.userId.length >0 && _inLogin) {
        NSDictionary *params = @{@"Action":@"HeartBeat",@"UserId":userM.userId?:@"",@"Active":@"0"};
        [SocketMessageUtil sendVersion1WithParams:params];
    }
    NSInteger seconds = [[HWUserdefault getObjectWithKey:BACK_TIME] integerValue];
    if (seconds == 0) {
        return;
    }
    NSDate *backDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSInteger minues = [backDate minutesAfterDate:[NSDate date]];
    if (_inLogin && labs(minues) >= 2) {
        [HWUserdefault updateObject:@(0) withKey:BACK_TIME];
        
        if (!_unlockView) {
            @weakify_self
            [self.window endEditing:YES];
            [self.unlockView showWithUnlockOK:^{
                weakSelf.unlockView = nil;
            }];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    // 播放无声音乐
//    if (isBackendRun) {
//        [[RunInBackground sharedBg] stopAudioPlay];
//    }
//    CSLOG_TEST_DDLOG(@"当前执行方法------%@",NSStringFromSelector(_cmd));
    [self.backgroundView hide];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
//    CSLOG_TEST_DDLOG(@"\n\n\n\n");
    
    NSInteger appCount = [self getUnReadMessageCount];
    // 重新设置 icon 角标
    [UIApplication sharedApplication].applicationIconBadgeNumber = appCount;
    [JPUSHService setBadge:appCount];
    
    [SystemUtil configureAPPTerminate];
    [[SendCacheChatUtil getSendCacheChatUtilShare] stop];
}

- (void)setRootCreateAccount {
    CreateAccountViewController *vc = [[CreateAccountViewController alloc] init];
    [AppD addTransitionAnimation];
    AppD.window.rootViewController = [[PNNavViewController alloc] initWithRootViewController:vc];
}

- (void)setRootLoginWithType:(LoginType) type {
    [AppD addTransitionAnimation];
    AppD.isLoginMac = NO;

    LoginViewController *vc = [[LoginViewController alloc] initWithLoginType:type];
    AppD.window.rootViewController = [[PNNavViewController alloc] initWithRootViewController:vc];
    

}

- (void)addTransitionAnimation {
    // 我们要把系统windown的rootViewController替换掉
    CATransition *animation = [CATransition animation];
    //动画时间
    animation.duration = 0.4f;
    //过滤效果
    if (self.isAutoLogin) {
        self.isAutoLogin = NO;
        animation.type = kCATransitionFade;
    } else {
        animation.type = kCATransitionReveal;
    }
    
    //枚举值:
    // kCATransitionPush 推入效果
    //  kCATransitionMoveIn 移入效果
    //  kCATransitionReveal 截开效果
    //  kCATransitionFade 渐入渐出效果
    //动画执行完毕时是否被移除
    animation.removedOnCompletion = YES;
    //设置方向-该属性从下往上弹出
    animation.subtype = kCATransitionFromRight;
    // 枚举值:
    //  kCATransitionFromRight//右侧弹出
    //  kCATransitionFromLeft//左侧弹出
    //kCATransitionFromTop//顶部弹出
    // kCATransitionFromBottom//底部弹出
    [AppD.window.layer addAnimation:animation forKey:nil];
}

#pragma mark - 是否需要显示引导页
- (void)checkGuidenPage {
    NSString *version = [HWUserdefault getObjectWithKey:VERSION_KEY];
    if (!version || ![version isEqualToString:APP_Version]) {
        [HWUserdefault updateObject:APP_Version withKey:VERSION_KEY];
        GuidePageViewController *pageVC = [[GuidePageViewController alloc] init];
        self.window.rootViewController = pageVC;
    } else {
        [self judgeLogin];
    }
}

- (void)judgeLogin {
    if ([UserModel existLocalNick]) { // 本地有私钥和昵称
       BOOL isDidLogin = [[NSUserDefaults standardUserDefaults] boolForKey:Login_Statu_Key];
        if (isDidLogin) {
            ViewController *vc = [[ViewController alloc] init];
            AppD.window.rootViewController = vc;
        } else {
            [self setRootLoginWithType:RouterType];
        }
       
    } else { // 本地无私钥和昵称
        [self setRootCreateAccount];
    }
}

- (void) setRootTabbarLonginDev {
    
    LoginDeviceViewController *vc = [[LoginDeviceViewController alloc] init];
    PNNavViewController *tabbvc = [[PNNavViewController alloc] initWithRootViewController:vc];
    [AppD addTransitionAnimation];
    AppD.window.rootViewController = tabbvc;
}

- (void) setRootTabbarWithManager:(id<OCTManager>) manager {
    [KeyCUtil saveStringToKeyWithString:@"1" key:LOGIN_KEY];
    AppD.isLogOut = NO;
    AppD.isLoginMac = NO;
    if ([SystemUtil isSocketConnect]) {
       // AppD.manager = nil; tox_stop
        AppD.currentRouterNumber = -1;
    }
    // 我们要把系统windown的rootViewController替换掉
    
    PNTabbarViewController  *tabbarC = [[PNTabbarViewController alloc] initWithManager:manager];
    LeftViewController *leftMenuViewController = [[LeftViewController alloc] init];
    _sideMenuViewController = [[YJSideMenu alloc] initWithContentViewController:tabbarC leftMenuViewController:leftMenuViewController];
    _sideMenuViewController.panGestureEnabled = NO;
    _sideMenuViewController.panFromEdge = NO;
    [AppD addTransitionAnimation];
    AppD.window.rootViewController = _sideMenuViewController;
    AppD.inLogin = YES;
}

- (void)logOutApp {
    [HeartBeatUtil stop];
    AppD.inLogin = NO;
    AppD.showNewFriendAddRequestRedDot = NO;
    AppD.showNewGroupAddRequestRedDot = NO;
    
    if ([SystemUtil isSocketConnect]) {
        [RouterConfig getRouterConfig].currentRouterIp = @"";
        [[SocketUtil shareInstance] disconnect];
        // 清除所有正在发送文件
        [[SocketManageUtil getShareObject] clearAllConnectSocket];
        // 清除所有正在下载文件
        [[FileDownUtil getShareObject] removeAllTask];
    } else {
        AppD.isConnect = NO;
        AppD.currentRouterNumber = -1;
        // [self logOutTox];
        [[NSNotificationCenter defaultCenter] postNotificationName:TOX_CONNECT_STATUS_NOTI object:nil];
    }
    [[ChatListDataUtil getShareObject].dataArray removeAllObjects];
    AppD.isLogOut = YES;
    [AppD setRootLoginWithType:RouterType];
}

#pragma mark - 配置DDLog
- (void)configDDLog {
    //分开logger不同的flag
    [DDLog addLogger:[CSLoggerAssembler createCSFileLogger:CS_Test_1000]];
    //配置DDLog
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
       // [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7; // 7
    [DDLog addLogger:fileLogger];
}

#pragma mark - 配置Bugly
- (void)configBugly {
    BuglyConfig * config = [[BuglyConfig alloc] init];
    // 设置自定义日志上报的级别，默认不上报自定义日志
    //    config.reportLogLevel = BuglyLogLevelWarn;
    config.delegate = self;
    [Bugly startWithAppId:Bugly_AppID config:config];
}
- (void) configMiPush:(NSDictionary *) launchOptions
{
    //Required
    //notice: 3.0.0 及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    if (@available(iOS 12.0, *)) {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
    } else {
        // Fallback on earlier versions
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义 categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    NSString *appKey = @"590fe4b2a75e8f169cab50fd";
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:@"App Store"
                 apsForProduction:isDis
            advertisingIdentifier:nil];
}

#pragma mark - BuglyDelegate
/**
 *  发生异常时回调
 *
 *  @param exception 异常信息
 *
 *  @return 返回需上报记录，随异常上报一起上报
 */
- (NSString *)attachmentForException:(NSException *)exception  {
    [SystemUtil configureAPPTerminate];
    return nil;
}

#pragma mark - 设置IQKeyboardManager
- (void) keyboardManagerConfig {
    IQKeyboardManager *keyboardManager = [IQKeyboardManager sharedManager]; // 获取类库的单例变量
    keyboardManager.enable = YES; // 控制整个功能是否启用
    keyboardManager.shouldResignOnTouchOutside = YES; // 控制点击背景是否收起键盘
    keyboardManager.shouldToolbarUsesTextFieldTintColor = NO; // 控制键盘上的工具条文字颜色是否用户自定义
    keyboardManager.toolbarDoneBarButtonItemText = @"Done";
    keyboardManager.toolbarManageBehaviour = IQAutoToolbarBySubviews; // 有多个输入框时，可以通过点击Toolbar 上的“前一个”“后一个”按钮来实现移动到不同的输入框
   
    
    keyboardManager.enableAutoToolbar = YES; // 控制是否显示键盘上的工具条
    keyboardManager.shouldShowToolbarPlaceholder = YES; // 是否显示占位文字
    keyboardManager.placeholderFont = [UIFont boldSystemFontOfSize:15]; // 设置占位文字的字体
    keyboardManager.keyboardDistanceFromTextField = 10.0f; // 输入框距离键盘的距离
    
  
    
}

#pragma mark - 配置聊天
- (void) configChat
{
    // 配置聊天列表环境
    ChatHelpr.share.config.environment = 1;

    // 聊天页面图片资源配置
    NSMutableDictionary *dic;
    
    /// 表情bundle地址
    NSString *emojiBundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Expression.bundle"];
    /// 表情键值对
    NSDictionary<NSString *, id> *temp = [[NSDictionary alloc] initWithContentsOfFile:[emojiBundlePath stringByAppendingPathComponent:@"files/expressionImage_custom.plist"]];
    NSArray<NSString *> *chineses = [[NSArray alloc] initWithContentsOfFile:[emojiBundlePath stringByAppendingPathComponent:@"files/expression_CH.plist"]];
    CTinputHelper.share.emojEnDic = [[NSDictionary alloc] initWithContentsOfFile:[emojiBundlePath stringByAppendingPathComponent:@"files/expression_EN.plist"]];
    
    /// 表情图片bundle
    NSBundle *bundle = [NSBundle bundleWithPath:emojiBundlePath];
    dic = [NSMutableDictionary dictionary];
    for (NSString *imagName in temp.allKeys) {
        UIImage *img = [UIImage imageNamed:temp[imagName] inBundle:bundle compatibleWithTraitCollection:nil];
        [dic setValue:img forKey:imagName];//
    }
    /// 设置聊天界面的表情资源
    CTHelper.share.emojDic = dic;
        
    /// 设置除表情的图片资源
    NSString *resouceBundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"InputViewBundle.bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resouceBundlePath];
    
    
    NSMutableDictionary *resDic = [NSMutableDictionary dictionaryWithDictionary:ChatHelpr.share.imageDic];
    [resDic setObject:[UIImage imageNamed:@"voice_left_1" inBundle:resourceBundle compatibleWithTraitCollection:nil] forKey:@"voice_left_1"];
    [resDic setObject:[UIImage imageNamed:@"voice_left_2" inBundle:resourceBundle compatibleWithTraitCollection:nil] forKey:@"voice_left_2"];
    [resDic setObject:[UIImage imageNamed:@"voice_left_3" inBundle:resourceBundle compatibleWithTraitCollection:nil] forKey:@"voice_left_3"];
    [resDic setObject:[UIImage imageNamed:@"voice_right_1" inBundle:resourceBundle compatibleWithTraitCollection:nil] forKey:@"voice_right_1"];
    [resDic setObject:[UIImage imageNamed:@"voice_right_2" inBundle:resourceBundle compatibleWithTraitCollection:nil] forKey:@"voice_right_2"];
    [resDic setObject:[UIImage imageNamed:@"voice_right_3" inBundle:resourceBundle compatibleWithTraitCollection:nil] forKey:@"voice_right_3"];
    
    
    NSDictionary *drawImages = [ChatImageDrawer defaultImageDic];
    for (NSString *imageName in drawImages) {
        resDic[imageName] = drawImages[imageName];
    }
    ChatHelpr.share.imageDic = resDic;
    // 设置输入框的表情资源
    CTinputHelper.share.emojDic = dic;
    CTinputHelper.share.emojiNameArr = @[chineses];
  //  CTinputHelper.share.emojiNameArrTitles = @[@"hhe",@"haha"];
    UIImage *photo = [UIImage imageNamed:@"Private document1"];
    UIImage *camcer = [UIImage imageNamed:@"Private document2"];
    UIImage *news = [UIImage imageNamed:@"Private document"];
    UIImage *video = [UIImage imageNamed:@"Private document3"];
    // 配置 ‘’更多‘’  功能;
    [CTinputHelper.share.config addExtra:@{@"Album": photo,
                                           @"Camera":camcer,
                                           @"File": news,
                                           @"Short Video":video
                                           }];
    [CTinputHelper.share.config addEmoji];
    [CTinputHelper.share.config addVoice];
    
    NSDictionary *origin = CTinputHelper.share.imageDic;
    
    
    NSMutableDictionary *newDic = [NSMutableDictionary dictionaryWithDictionary:origin];
    [newDic setObject:[UIImage imageNamed:@"keyboard" inBundle:resourceBundle compatibleWithTraitCollection:nil]
               forKey:@"keyboard"];
    [newDic setObject:[UIImage imageNamed:@"voice" inBundle:resourceBundle compatibleWithTraitCollection:nil]
               forKey:@"voice"];
    [newDic setObject:[UIImage imageNamed:@"micro" inBundle:resourceBundle compatibleWithTraitCollection:nil]
               forKey:@"voice_microphone_alert"];
    [newDic setObject:[UIImage imageNamed:@"redo" inBundle:resourceBundle compatibleWithTraitCollection:nil]
               forKey:@"voice_revocation_alert"];
    [newDic setObject:[UIImage imageNamed:@"emojiDelete" inBundle:resourceBundle compatibleWithTraitCollection:nil]
               forKey:@"emojiDelete"];
    [newDic setObject:[UIImage imageNamed:@"voice" inBundle:resourceBundle compatibleWithTraitCollection:nil]
               forKey:@"voice"];
    /// 设置除表情的图片资源
    CTinputHelper.share.imageDic = newDic;
}

#pragma mark - 配置FMDB
- (void) configureFMDB {
    /**
     想测试更多功能,打开注释掉的代码即可.
     */
    bg_setDebug(NO);//打开调试模式,打印输出调试信息.
    
    /**
     如果频繁操作数据库时,建议进行此设置(即在操作过程不关闭数据库);
     */
    bg_setDisableCloseDB(YES);
    
    /**
     自定义数据库名称，否则默认为BGFMDB
     */
    bg_setSqliteName(@"PPChat_DataBase");
    // 判断表名是否存在
//    if (![[BGDB shareManager] bg_isExistWithTableName:VPNREGISTER_TABNAME]) {
//        [VPNOperationUtil keyChainDataToDB];
//    }
//    [DBManageUtil updateDBversion];
}

#pragma mark -文件分享走的方法
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url options:(nonnull NSDictionary<NSString *,id> *)options
{
    // 判断传过来的url是否为文件类型
    if ([url.scheme isEqualToString:@"file"]) {
        if ([_window.rootViewController isKindOfClass:[YJSideMenu class]]) {
            PNSendSelectViewController *vc = [[PNSendSelectViewController alloc] init];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            vc.fileURL = url;
            [[SystemUtil getCurrentVC] presentViewController:vc animated:YES completion:nil];
        } else {
            self.fileUrl = url;
        }
    } else {
        // google 登陆回调
        [[GIDSignIn sharedInstance] handleURL:url sourceApplication:@"" annotation:nil];
        
//        // Analytics 分析
//        NSString *urlString = [url absoluteString];
//
//        id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:@"confident-d6fd8"
//                                                             trackingId:@"227420399"];
//        // setCampaignParametersFromUrl: parses Google Analytics campaign ("UTM")
//        // parameters from a string url into a Map that can be set on a Tracker.
//        GAIDictionaryBuilder *hitParams = [[GAIDictionaryBuilder alloc] init];
//
//        // Set campaign data on the map, not the tracker directly because it only
//        // needs to be sent once.
//        [hitParams setCampaignParametersFromUrl:urlString];
//
//        // Campaign source is the only required campaign field. If previous call
//        // did not set a campaign source, use the hostname as a referrer instead.
//        if(![hitParams get:kGAICampaignSource] && [url host].length !=0) {
//          // Set campaign data on the map, not the tracker.
//          [hitParams set:@"referrer" forKey:kGAICampaignMedium];
//          [hitParams set:[url host] forKey:kGAICampaignSource];
//        }
//
//        NSDictionary *hitParamsDict = [hitParams build];
//
//        // A screen name is required for a screen view.
//        [tracker set:kGAIScreenName value:@"screen name"];
//
//        // Previous V3 SDK versions.
//        // [tracker send:[[[GAIDictionaryBuilder createAppView] setAll:hitParamsDict] build]];
//
//        // SDK Version 3.08 and up.
//        [tracker send:[[[GAIDictionaryBuilder createScreenView] setAll:hitParamsDict] build]];
    }
    
    return YES;
}


#pragma mark UIApplicationDelegate
- (void)application:(UIApplication *)app
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];

}

- (void)application:(UIApplication *)app
didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    // 注册APNS失败
    // 自行处理
    //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", err);
}


#pragma mark- JPUSHRegisterDelegate

// iOS 12 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification{
    if (notification && [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //从通知界面直接进入应用
    }else{
        //从通知设置界面进入应用
    }
    
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSLog(@"-----------收到推送1");
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
    
    // app在前台时收到推送时走的方法
   
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler {
    // Required
    NSLog(@"-----------收到推送2");
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    NSString *activities = [userInfo valueForKey:@"attachinfo"]?:@"";
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        
        // 通过推送打开app逻辑写这里
        if (activities.length >0) {
            if ([_window.rootViewController isKindOfClass:[YJSideMenu class]]) {
                UIViewController *baseVC = [SystemUtil getCurrentVC];
                if (![baseVC isKindOfClass:[PNNewsViewController class]]) {
                    PNNewsViewController *vc = [[PNNewsViewController alloc] init];
                    vc.modalPresentationStyle = UIModalPresentationFullScreen;
                    [baseVC presentViewController:vc animated:YES completion:nil];
                }
                
            } else {
               AppD.campaignDic = [activities mj_JSONObject];
            }
        }
    }
    completionHandler();  // 系统要求执行这个方法
    
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}


#pragma mark - Lazy
- (PNUnlockView *)unlockView {
    if (!_unlockView) {
        _unlockView = [PNUnlockView getInstance];
    }
    
    return _unlockView;
}

- (PNBackgroundView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [PNBackgroundView getInstance];
    }
    return _backgroundView;
}

// 计算未读消息数
- (NSInteger) getUnReadMessageCount
{
    NSInteger messageCount = 0;
    NSArray *finfAlls = [ChatListModel bg_find:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"myID"),bg_sqlValue([UserConfig getShareObject].usersn)]];
    if (finfAlls && finfAlls.count > 0) {
        for (int i = 0; i<finfAlls.count; i++) {
            ChatListModel *model = finfAlls[i];
            NSInteger count = 0;
            if (model.unReadNum) {
                count = [model.unReadNum integerValue];
            }
            messageCount = messageCount + count;
        }
    }
    return messageCount;
}


#pragma singin delegate----------------------------

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    
    if (error != nil) {
        if (error.code == kGIDSignInErrorCodeHasNoAuthInKeychain) {
            [AppD.window showHint:@"The user has not signed in or their accounts do not exist."];
        } else {
            [AppD.window showHint:([NSString stringWithFormat:@"%@", error.localizedDescription])];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:GOOGLE_EMAIL_SIGN_FAIELD_NOTI object:nil];
        return;
    }
    
    if (![[user.profile.email lowercaseString] containsString:@"@gmail"]) {
        [AppD.window showHint:@"Only Gmail.com is supported."];
        return;
    }
    
    // Perform any operations on signed in user here.
    GoogleUserModel *userM = [[GoogleUserModel alloc] init];
    userM.userId = user.userID;                  // For client-side use only!
    userM.idToken = user.authentication.idToken; // Safe to send to the server
    userM.fullName = user.profile.name;
    userM.givenName = user.profile.givenName;
    userM.familyName = user.profile.familyName;
    userM.email = user.profile.email;
    
    EmailAccountModel *accountModel = [[EmailAccountModel alloc] init];
    accountModel.User = userM.email;
    if (![EmailAccountModel isEixtEmailAccount:accountModel]) {
        // 上传到服务器
        [GoogleUserModel addGoogleUserWithUser:userM];
        [SendRequestUtil sendEmailConfigWithEmailAddress:userM.email type:@(4) caller:@(1) configJson:@"" ShowHud:YES];
        
    } else {
        AppD.isGoogleSign = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:GOOGLE_EMAIL_SIGN_SUCCESS_NOTI object:nil];
    }
    
    // ...
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user

     withError:(NSError *)error {
    NSLog(@"error = %@",error);
}


@end
