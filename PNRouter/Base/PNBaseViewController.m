//
//  QBaseViewController.m
//  Qlink
//
//  Created by Jelly Foo on 2018/3/21.
//  Copyright © 2018年 pan. All rights reserved.
//

#import "PNBaseViewController.h"
#import "PNNavViewController.h"
#import "QRViewController.h"
#import "RoutherConfig.h"
#import "PNRouter-Swift.h"
#import "AESCipher.h"
#import "OCTManagerConfiguration.h"
#import "OCTManagerFactory.h"
#import "OCTManager.h"
#import "OCTSubmanagerBootstrap.h"
#import "LoginDeviceViewController.h"

@interface PNBaseViewController ()

@end

@implementation PNBaseViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
//    self.navigationController.navigationBarHidden = YES;
}
    
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    self.navigationController.navigationBarHidden = NO;
}

- (instancetype)initWithManager:(id<OCTManager>)manager
{
    self = [super init];
    
    if (! self) {
        return nil;
    }
    _manager = manager;
    return self;
}

    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = MAIN_PURPLE_COLOR;
//    UIView *tabBackView = [[UIView alloc] initWithFrame:CGRectMake(0,NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT)];
//    tabBackView.backgroundColor = RGB(242, 242, 242);
//    [self.view addSubview:tabBackView];
    
//    self.view.backgroundColor = MAIN_PURPLE_COLOR;
    self.navigationController.navigationBarHidden = !showRightNavBarItem;
    // 设置右边按钮
    if (showRightNavBarItem) {
        self.rightNavBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.rightNavBtn.frame = CGRectMake(0, 0, 60, 30);
        
        self.rightNavBtn.titleLabel.font = [UIFont boldSystemFontOfSize:13];
        [self.rightNavBtn setShowsTouchWhenHighlighted:YES];
        [self.rightNavBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.rightNavBtn setTitle:@"" forState:UIControlStateNormal];
        [self.rightNavBtn addTarget:self action:@selector(rightNavBarItemPressed) forControlEvents:UIControlEventTouchUpInside];
        self.rightNavBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightNavBtn];
    }
    
    [self refreshContent];
}

- (void) initVariables
{
    showRightNavBarItem = NO;
    showNavigationBar = YES;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initVariables];
    }
    return self;
}

- (id)initWithShowCustomNavigationBar:(BOOL)_showNavigationBar
{
    self = [super init];
    if (self) {
        showNavigationBar = _showNavigationBar;
        showRightNavBarItem = NO;
    }
    return self;
    
}
- (void)leftNavBarItemPressedWithPop:(BOOL)isPop
{
     [AppD.window hideHud];
    if (!isPop)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)rightNavBarItemPressed
{
    
}
- (void) toxLoginSuccessWithManager:(id<OCTManager>) manager
{
}

- (void)presentModalVC:(UIViewController *)VC animated:(BOOL)animated
{
    PNNavViewController *navController = [[PNNavViewController alloc] initWithRootViewController:VC] ;
    if([self respondsToSelector:@selector(presentViewController:animated:completion:)]){
        [self presentViewController:navController animated:animated completion:nil];
    }
}
// 移除指定vs
- (void) moveNavgationViewController:(UIViewController *) vs
{
    NSMutableArray *marr = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    for (UIViewController *vc in marr) {
        if ([vc isKindOfClass:[vs class]]) {
            [marr removeObject:vc];
            break;
        }
    }
    self.navigationController.viewControllers = marr;
}
// 移除前二个vs
- (void) moveNavgationBackViewController
{
    NSMutableArray *marr = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    if (marr.count > 1) {
        [marr removeObjectAtIndex:marr.count-2];
        if (marr.count > 1) {
             [marr removeObjectAtIndex:marr.count-2];
        }
        self.navigationController.viewControllers = marr;
    }
   
}
// 移除上一个vs
- (void) moveNavgationBackOneViewController
{
    NSMutableArray *marr = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    if (marr.count > 1) {
        [marr removeObjectAtIndex:marr.count-2];
        self.navigationController.viewControllers = marr;
    }
}

#pragma mark - 子类继承刷新子view
- (void)refreshContent {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setRootVCWithVC:(PNBaseViewController *) vc {
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
    AppD.window.rootViewController = vc;
}

- (void) scanSuccessful
{
    
}

#pragma mark - Transition
- (void)jumpToQR {
    @weakify_self
    QRViewController *vc = [[QRViewController alloc] initWithCodeQRCompleteBlock:^(NSString *codeValue) {
        if (codeValue != nil && codeValue.length > 0) {
            NSString *result = aesDecryptString(codeValue,AES_KEY);
            result = [result stringByReplacingOccurrencesOfString:@"\0" withString:@""];
            if (result && result.length == 114) {
               
                NSString *toxid = [result substringWithRange:NSMakeRange(6, 76)];
                NSString *sn = [result substringWithRange:NSMakeRange(result.length-32, 32)];
                NSLog(@"%@",[RoutherConfig getRoutherConfig].currentRouterSn);
              //  if (![sn isEqualToString:[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterSn]]) {
                    
                    AppD.isScaner = YES;
                    [RoutherConfig getRoutherConfig].currentRouterToxid = toxid;
                    [RoutherConfig getRoutherConfig].currentRouterSn = sn;
                    [RoutherConfig getRoutherConfig].currentRouterIp = @"";
                
                    [weakSelf scanSuccessful];
             //   }
                
                
//                if (![toxid isEqualToString:[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterToxid]]) {
//                    [RoutherConfig getRoutherConfig].currentRouterSn = sn;
//                    [RoutherConfig getRoutherConfig].currentRouterToxid = toxid;
//                    NSArray *dataArr = [[RoutherConfig getRoutherConfig] getCurrentRoutherWithToxid:[RoutherConfig getRoutherConfig].currentRouterToxid];
//                    
//                   NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
//                    if (connectStatu == socketConnectStatusConnected) {
//                        // 取消连接
//                        [SocketUtil.shareInstance disconnect];
//                    }
//                    
//                    if (!dataArr) { // 走tox
//                        
//                    } else {
//                        [RoutherConfig getRoutherConfig].currentRouterIp = dataArr[0];
//                        [AppD.window showHudInView:AppD.window hint:@"Connect..."];
//                        NSString *connectURL =[NSString stringWithFormat:@"https://%@:18006",[RoutherConfig getRoutherConfig].currentRouterIp];
//                        AppD.currentSoketUrl = connectURL;
//                        [SocketUtil.shareInstance connectWithUrl:connectURL];
//                    }
//                }
                
            } else if (result && result.length == 12) { // 管理账户 MAC
                [weakSelf jumpToLoginDevice];
            } else {
                [weakSelf.view showHint:@"format error!"];
            }
        }
    }];
    [self presentModalVC:vc animated:YES];
}

- (void)jumpToLoginDevice {
    LoginDeviceViewController *vc = [[LoginDeviceViewController alloc] init];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma ToxLogin
- (void) loginTox
{
    AppD.manager = nil;
    [AppD.window showHudInView:AppD.window hint:@"Connect P2P..."];
   OCTManagerConfiguration *configuration = [OCTManagerConfiguration defaultConfiguration];
    configuration.options.udpEnabled = YES;
    configuration.options.proxyType = OCTToxProxyTypeNone;
    configuration.options.holePunchingEnabled = YES;
    configuration.options.localDiscoveryEnabled = YES;
    configuration.options.ipv6Enabled = YES;
    @weakify_self
    [OCTManagerFactory managerWithConfiguration:configuration encryptPassword:TOX_DATA_PASS successBlock:^(id < OCTManager > manager) {
       
            [AppD.window hideHud];
            [manager.bootstrap addPredefinedNodes];
            [manager.bootstrap bootstrap];
            AppD.manager = manager;
            [weakSelf toxLoginSuccessWithManager:manager];
        
    } failureBlock:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [AppD.window hideHud];
            [AppD.window showHint:@"Connect faield"];
        });
        
    }];
}

#pragma ToxLogin
- (void) logOutTox
{
    AppD.manager = nil;
    OCTManagerConfiguration *configuration = [OCTManagerConfiguration defaultConfiguration];
    configuration.options.udpEnabled = YES;
    configuration.options.proxyType = OCTToxProxyTypeNone;
    configuration.options.holePunchingEnabled = YES;
    configuration.options.localDiscoveryEnabled = YES;
    configuration.options.ipv6Enabled = YES;
    
    [OCTManagerFactory managerWithConfiguration:configuration encryptPassword:TOX_DATA_PASS successBlock:^(id < OCTManager > manager) {
        
        [manager.bootstrap addPredefinedNodes];
        [manager.bootstrap bootstrap];
        AppD.manager = manager;
 
    } failureBlock:^(NSError * _Nonnull error) {
        dispatch_async(dispatch_get_main_queue(), ^{
           
        });
        
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
