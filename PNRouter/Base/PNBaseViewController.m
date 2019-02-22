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
#import "LibsodiumUtil.h"
#import "UserModel.h"
#import "NSString+Base64.h"

@interface PNBaseViewController ()

@property (nonatomic, strong) UIView *emptyView;

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
    self.view.backgroundColor = MAIN_WHITE_COLOR;
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
    [RoutherConfig getRoutherConfig].currentRouterMAC = @"";
    AppD.isLoginMac = NO;
    [AppD addTransitionAnimation];
    AppD.window.rootViewController = vc;
}

- (void) scanSuccessfulWithIsMacd:(BOOL) isMac
{
    
}
- (void) scanSuccessfulWithIsAccount:(NSArray *) values
{
    
}

- (void)showEmptyViewToView:(UIView *)view img:(UIImage *)img title:(NSString *)title {
    if (!_emptyView) {
        _emptyView = [[UIView alloc] init];
        _emptyView.frame = CGRectMake(0, 0, 200, 200);
        _emptyView.backgroundColor = [UIColor whiteColor];
        [view addSubview:_emptyView];
        [_emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.mas_equalTo(view).offset(0);
        }];
        
        UIImageView *imgV = [[UIImageView alloc] init];
        imgV.frame = CGRectMake(0, 0, 80, 80);
        imgV.image = img;
        [_emptyView addSubview:imgV];
        @weakify_self
        [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(weakSelf.emptyView.centerX).offset(0);
            make.centerY.mas_equalTo(weakSelf.emptyView.centerY).offset(0);
            make.width.mas_equalTo(80);
            make.height.mas_equalTo(80);
        }];
        
        UILabel *titleLab = [[UILabel alloc] init];
        titleLab.frame = CGRectMake(0, 0, 100, 44);
        titleLab.numberOfLines = 2;
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.textColor = UIColorFromRGB(0x808080);
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.text = title;
        [_emptyView addSubview:titleLab];
        [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(weakSelf.emptyView.centerX).offset(0);
            make.top.mas_equalTo(imgV.mas_bottom).offset(24);
            make.left.mas_equalTo(weakSelf.emptyView).offset(15);
            make.right.mas_equalTo(weakSelf.emptyView).offset(-15);
        }];
    }
}

- (void)hideEmptyView {
    [_emptyView removeFromSuperview];
    _emptyView = nil;
}

#pragma mark - Transition
- (void)jumpToQR {
    [RoutherConfig getRoutherConfig].currentRouterMAC = @"";
    @weakify_self
    QRViewController *vc = [[QRViewController alloc] initWithCodeQRCompleteBlock:^(NSString *codeValue) {
        if (codeValue != nil && codeValue.length > 0) {
            NSArray *codeValues = [codeValue componentsSeparatedByString:@","];
            NSString *type = codeValues[0];
            
            if ([[NSString getNotNullValue:type] isEqualToString:@"type_1"]) {
                // router 码
                NSString *result = aesDecryptString(codeValues[1],AES_KEY);
                result = [result stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                if (result && result.length == 114) {
                    
                    NSString *toxid = [result substringWithRange:NSMakeRange(6, 76)];
                    NSString *sn = [result substringWithRange:NSMakeRange(result.length-32, 32)];
                    NSLog(@"%@",[RoutherConfig getRoutherConfig].currentRouterSn);
                 
                    AppD.isScaner = YES;
                    [RoutherConfig getRoutherConfig].currentRouterToxid = toxid;
                    [RoutherConfig getRoutherConfig].currentRouterSn = sn;
                    [RoutherConfig getRoutherConfig].currentRouterIp = @"";
                    
                    [weakSelf scanSuccessfulWithIsMacd:NO];
                } else {
                    [weakSelf.view showHint:@"format error!"];
                }
            } else if ([[NSString getNotNullValue:type] isEqualToString:@"type_2"]) {
                    // mac 码
                    NSString *result = aesDecryptString(codeValues[1],AES_KEY);
                    result = [result stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                    AppD.isScaner = YES;
                    [RoutherConfig getRoutherConfig].currentRouterMAC = result;
                    [weakSelf scanSuccessfulWithIsMacd:YES];
            } else if ([[NSString getNotNullValue:type] isEqualToString:@"type_3"]) {
                    // 帐户码
                [LibsodiumUtil changeUserPrivater:codeValues[1]];
                NSString *name = [codeValues[3] base64DecodedString];
                [UserModel createUserLocalWithName:name];
                [weakSelf scanSuccessfulWithIsAccount:codeValues];
            } else {
                [weakSelf.view showHint:@"format error!"];
            }
        }
    }];
    [self presentModalVC:vc animated:YES];
}

- (void)jumpToLoginDevice {
    LoginDeviceViewController *vc = [[LoginDeviceViewController alloc] init];
    PNNavViewController *nav = [[PNNavViewController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
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
