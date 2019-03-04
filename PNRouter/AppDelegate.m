//
//  AppDelegate.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/4.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "AppDelegate.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
//#import "LoginViewController.h"
#import "PNNavViewController.h"
#import "CDChatList.h"
#import <objc/runtime.h>
#import "KeyCUtil.h"
#import "FriendModel.h"
#import "SystemUtil.h"
#import "PNRouter-Swift.h"
#import "GuidePageViewController.h"
#import "ViewController.h"
#import "VPNFileInputView.h"
#import "ReviceRadio.h"
#import "RouterModel.h"
#import "RoutherConfig.h"
#import <Bugly/Bugly.h>
#import "MiPushSDK.h"
#import "RunInBackground.h"
#import "RSAModel.h"
#import "LibsodiumUtil.h"
#import "OperationRecordModel.h"
#import "CreateAccountViewController.h"
#import "UserModel.h"
#import "EntryModel.h"
#import "NSDate+Category.h"
#import "FingetprintVerificationUtil.h"
#import "PNUnlockView.h"
#import "SendCacheChatUtil.h"
#import "SocketMessageUtil.h"
#import "PNBackgroundView.h"

@interface AppDelegate () <BuglyDelegate,MiPushSDKDelegate,UNUserNotificationCenterDelegate>
{
    BOOL isBackendRun;
}
//@property (nonatomic, assign) NSThread *thread;
@property (nonatomic, strong) PNUnlockView *unlockView;
@property (nonatomic, strong) PNBackgroundView *backgroundView;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    NSString *clearDataResult = [KeyCUtil getKeyValueWithKey:CLEAR_DATA];
    if (![[NSString getNotNullValue:clearDataResult] isEqualToString:@"2"]) {
        [KeyCUtil deleteAllKey];
        [FriendModel bg_drop:FRIEND_LIST_TABNAME];
        [FriendModel bg_drop:FRIEND_REQUEST_TABNAME];
        [OperationRecordModel bg_drop:OperationRecord_Table];
        [KeyCUtil saveStringToKeyWithString:@"2" key:CLEAR_DATA];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    // 配置Bugly
    [self configBugly];
    // 配置小米推送
    [self configMiPush];
    // 配置IQKeyboardManager
    [self keyboardManagerConfig];
    // 配置DDLog
    [self configDDLog];
    // 配置聊天
    [self configChat];
    // 打开时改变文件上传下载状态
    [SystemUtil appFirstOpen];
    [self checkGuidenPage];
  //  [RSAModel getRSAModel];
    // 得到签名，加密 公私钥对
   EntryModel *model = [LibsodiumUtil getPrivatekeyAndPublickey];
    [LibsodiumUtil changeUserPrivater:model.signPrivateKey];
    [self.window makeKeyAndVisible];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    
    [self.backgroundView show];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    // 播放无声音乐
//    if ([SystemUtil isSocketConnect]) {
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            self->isBackendRun = YES;
//            [[RunInBackground sharedBg] startRunInbackGround];
//            [[NSRunLoop currentRunLoop] run];
//        });
 //   }
    
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
    
    NSInteger seconds = [[HWUserdefault getObjectWithKey:BACK_TIME] integerValue];
    if (seconds == 0) {
        return;
    }
    NSDate *backDate = [NSDate dateWithTimeIntervalSince1970:seconds];
    NSInteger minues = [backDate minutesAfterDate:[NSDate date]];
    if (_inLogin && labs(minues) >= 2) {
        [HWUserdefault updateObject:@(0) withKey:BACK_TIME];
        
        if (_unlockView) {
        } else {
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
    
    [self.backgroundView hide];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
    LoginViewController *vc = [[LoginViewController alloc] initWithLoginType:type];
    AppD.window.rootViewController = [[PNNavViewController alloc] initWithRootViewController:vc];
}

- (void)addTransitionAnimation {
    // 我们要把系统windown的rootViewController替换掉
    CATransition *animation = [CATransition animation];
    //动画时间
    animation.duration = 0.4f;
    //过滤效果
    animation.type = kCATransitionReveal;
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
        _showTouch = YES;
        [self judgeLogin];
    }
    
//    NSString *version = [KeyCUtil getKeyValueWithKey:LOGIN_KEY];
//    if (![[NSString getNotNullValue:version] isEqualToString:@"1"]) {
//        GuidePageViewController *pageVC = [[GuidePageViewController alloc] init];
//        self.window.rootViewController = pageVC;
//    } else {
//        _showTouch = YES;
//        LoginViewController  *vc = [[LoginViewController alloc] init];
//        AppD.window.rootViewController = vc;
//    }
}

- (void)judgeLogin {
    if ([UserModel existLocalNick]) { // 本地有私钥和昵称
        [self setRootLoginWithType:RouterType];
    } else { // 本地无私钥和昵称
        [self setRootCreateAccount];
    }
}

- (void)setRootTabbarWithManager:(id<OCTManager>) manager {
    [KeyCUtil saveStringToKeyWithString:@"1" key:LOGIN_KEY];
    AppD.isLogOut = NO;
    if ([SystemUtil isSocketConnect]) {
        AppD.manager = nil;
    }
    // 设置当前路由
   // [RouterModel updateRouterConnectStatusWithSn:[RoutherConfig getRoutherConfig].currentRouterSn];
    // 我们要把系统windown的rootViewController替换掉
    PNTabbarViewController  *tabbarC = [[PNTabbarViewController alloc] initWithManager:manager];
    [AppD addTransitionAnimation];
    AppD.window.rootViewController = tabbarC;
    AppD.inLogin = YES;
}

#pragma mark - 配置DDLog
- (void)configDDLog {
    //开启DDLog 颜色
    //    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    //    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor blueColor] backgroundColor:nil forFlag:DDLogFlagVerbose];
    
    //配置DDLog
    [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
       // [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7; // 7
    [DDLog addLogger:fileLogger];
    
    //针对单个文件配置DDLog打印级别，尚未测试
    //    [DDLog setLevel:DDLogLevelAll forClass:nil];
    
    //    DDLogVerbose(@"Verbose");
    //    DDLogDebug(@"Debug");
    //    DDLogInfo(@"Info");
    //    DDLogWarn(@"Warn");
    //    DDLogError(@"Error");
}

#pragma mark - 配置Bugly
- (void)configBugly {
    BuglyConfig * config = [[BuglyConfig alloc] init];
    // 设置自定义日志上报的级别，默认不上报自定义日志
    //    config.reportLogLevel = BuglyLogLevelWarn;
    config.delegate = self;
    [Bugly startWithAppId:Bugly_AppID config:config];
}
- (void) configMiPush
{
    // 同时启用APNs跟应用内长连接
    [MiPushSDK registerMiPush:self type:0 connect:YES];
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
    CTinputHelper.share.emojiNameArr = @[temp.allKeys,temp.allKeys];
  //  CTinputHelper.share.emojiNameArrTitles = @[@"hhe",@"haha"];
    UIImage *photo = [UIImage imageNamed:@"Private document1"];
    UIImage *news = [UIImage imageNamed:@"Private document"];
    UIImage *video = [UIImage imageNamed:@"Private document3"];
    // 配置 ‘’更多‘’  功能;
    [CTinputHelper.share.config addExtra:@{@"Album": photo,
                                           @"Private\ndocument": news,
                                           @"Short video":video
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
        if ([_window.rootViewController isKindOfClass:[PNTabbarViewController class]]) {
            [self performSelector:@selector(showVPNFileView:) withObject:url afterDelay:.5f];
        } else {
            [self performSelector:@selector(showVPNFileView:) withObject:url afterDelay:1.0f];
        }
    }
    
    return YES;
}

- (void) showVPNFileView:(NSURL *) url {
    NSString *fileURL = url.absoluteString;
    NSArray *array = [fileURL componentsSeparatedByString:@"."];
    NSString *fileSuffix = [array lastObject];
  
    array = [fileURL componentsSeparatedByString:@"/"];
    NSString *fileName = [[array lastObject] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    VPNFileInputView *fileView = [VPNFileInputView loadVPNFileInputView];
    fileView.fileSuffix = fileSuffix;
    fileView.txtFileName.text = fileName;
    fileView.vpnURL = url;
    UIWindow *win = [UIApplication sharedApplication].keyWindow;
    [fileView showVPNFileInputView:win];
    
}

#pragma mark UIApplicationDelegate
- (void)application:(UIApplication *)app
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // 注册APNS成功, 注册deviceToken
    [MiPushSDK bindDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)app
didFailToRegisterForRemoteNotificationsWithError:(NSError *)err
{
    // 注册APNS失败
    // 自行处理
}

//- ( void )application:( UIApplication *)application didReceiveRemoteNotification:( NSDictionary *)userInfo
//{
//    [ MiPushSDK handleReceiveRemoteNotification :userInfo];
//    // 使用此方法后，所有消息会进行去重，然后通过miPushReceiveNotification:回调返回给App
//}

#pragma mark MiPushSDKDelegate
- (void)miPushRequestSuccWithSelector:(NSString *)selector data:(NSDictionary *)data
{
    // 请求成功
    // 可在此获取regId
    if ([selector isEqualToString:@"bindDeviceToken:"]) {
        NSLog(@"regid == %@", data[@"regid"]);
        self.regId = data[@"regid"];
    }
}

- (void)miPushRequestErrWithSelector:(NSString *)selector error:(int)error data:(NSDictionary *)data
{
    // 请求失败
}

// iOS10新加入的回调方法
// 应用在前台收到通知
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [MiPushSDK handleReceiveRemoteNotification:userInfo];
    }
    //completionHandler(UNNotificationPresentationOptionAlert);
}

// 点击通知进入应用
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [MiPushSDK handleReceiveRemoteNotification:userInfo];
    }
    completionHandler();
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

@end
