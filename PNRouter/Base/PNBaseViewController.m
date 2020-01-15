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
#import "RouterConfig.h"
#import "MyConfidant-Swift.h"
#import "AESCipher.h"
#import "OCTManagerConfiguration.h"
#import "OCTManagerFactory.h"
#import "OCTManager.h"
#import "OCTSubmanagerBootstrap.h"
#import "LoginDeviceViewController.h"
#import "UserModel.h"
#import "NSString+Base64.h"
#import "NSString+RegexCategory.h"
#import "SystemUtil.h"



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
    if (@available(iOS 13.0, *)) {
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDarkContent;
       // AppD.window.overrideUserInterfaceStyle = UIUserInterfaceStyleDark;
    } else {
        // Fallback on earlier versions
         [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    }
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
    navController.modalPresentationStyle = UIModalPresentationFullScreen;
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

// 保留第一个和最后一个
- (void) moveAllNavgationViewController
{
    NSMutableArray *marr = [[NSMutableArray alloc]initWithArray:self.navigationController.viewControllers];
    if (marr.count > 1) {
        NSArray *navArr = @[[marr firstObject],[marr lastObject]];
        self.navigationController.viewControllers = navArr;
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
    [RouterConfig getRouterConfig].currentRouterMAC = @"";
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

- (void) scanSuccessfulWithIsInvite:(NSArray *) values
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

#pragma mark------------默认pow码解析 --------------------
- (void) parsePowTempCode
{
    NSArray *codeValues = [powStr componentsSeparatedByString:@","];
    NSString *result = aesDecryptString(codeValues[1],AES_KEY);
    result = [result stringByReplacingOccurrencesOfString:@"\0" withString:@""];
    
    NSString *toxid = [result substringWithRange:NSMakeRange(6, 76)];
    NSString *sn = [result substringWithRange:NSMakeRange(result.length-32, 32)];
   
    
    [RouterConfig getRouterConfig].currentRouterToxid = toxid;
    [RouterConfig getRouterConfig].currentRouterSn = sn;
    [RouterConfig getRouterConfig].currentRouterIp = @"";
    
    [self parsePowTempCodeBlock];
}
- (void)parsePowTempCodeBlock
{
}

#pragma mark - Transition
- (void)jumpToQR {
    [RouterConfig getRouterConfig].currentRouterMAC = @"";
    @weakify_self
    QRViewController *vc = [[QRViewController alloc] initWithCodeQRCompleteBlock:^(NSString *codeValue) {
        if (codeValue != nil && codeValue.length > 0) {
            if (codeValue.length == 12) {
                NSString *macAdress = @"";
                for (int i = 0; i<12; i+=2) {
                   NSString *macIndex = [codeValue substringWithRange:NSMakeRange(i, 2)];
                    macAdress = [macAdress stringByAppendingString:macIndex];
                    if (i < 10) {
                        macAdress = [macAdress stringByAppendingString:@":"];
                    }
                }
                if ([macAdress isMacAddress]) {
                    AppD.isScaner = YES;
                    [RouterConfig getRouterConfig].currentRouterMAC = macAdress;
                    [weakSelf scanSuccessfulWithIsMacd:YES];
                    return ;
                }
            }
            NSArray *codeValues = [codeValue componentsSeparatedByString:@","];
            NSString *type = codeValues[0];
            
            if ([[NSString getNotNullValue:type] isEqualToString:@"type_1"]) {
                // router 码
                NSString *result = aesDecryptString(codeValues[1],AES_KEY);
                result = [result stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                if (result && result.length == 114) {
                    
                    NSString *toxid = [result substringWithRange:NSMakeRange(6, 76)];
                    NSString *sn = [result substringWithRange:NSMakeRange(result.length-32, 32)];
                    NSLog(@"%@",[RouterConfig getRouterConfig].currentRouterSn);
                 
                    AppD.isScaner = YES;
                    [RouterConfig getRouterConfig].currentRouterToxid = toxid;
                    [RouterConfig getRouterConfig].currentRouterSn = sn;
                    [RouterConfig getRouterConfig].currentRouterIp = @"";
                    
                    [weakSelf scanSuccessfulWithIsMacd:NO];
                } else {
                    [weakSelf.view showHint:@"format error!"];
                }
            } else if ([[NSString getNotNullValue:type] isEqualToString:@"type_2"]) {
                    // mac 码
                    NSString *result = aesDecryptString(codeValues[1],AES_KEY);
                    result = [result stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                    AppD.isScaner = YES;
                    [RouterConfig getRouterConfig].currentRouterMAC = result;
                    [weakSelf scanSuccessfulWithIsMacd:YES];
                
            } else if ([[NSString getNotNullValue:type] isEqualToString:@"type_3"]) {
                    // 帐户码
                [weakSelf scanSuccessfulWithIsAccount:codeValues];
            }  else if ([[NSString getNotNullValue:type] isEqualToString:@"type_4"]) {
                // 邀请码
                NSString *circleCode = [codeValues lastObject];
                circleCode = aesDecryptString(circleCode,AES_KEY);
                
                if (circleCode && circleCode.length == 114) {
                    
                    NSString *toxid = [circleCode substringWithRange:NSMakeRange(6, 76)];
                    NSString *sn = [circleCode substringWithRange:NSMakeRange(circleCode.length-32, 32)];
                    NSLog(@"%@",[RouterConfig getRouterConfig].currentRouterSn);
                    
                    AppD.isScaner = YES;
                    [RouterConfig getRouterConfig].currentRouterToxid = toxid;
                    [RouterConfig getRouterConfig].currentRouterSn = sn;
                    [RouterConfig getRouterConfig].currentRouterIp = @"";
                    [weakSelf scanSuccessfulWithIsInvite:codeValues];
                    
                    
                } else {
                     [weakSelf.view showHint:@"format error!"];
                }
               
            } else {
                [weakSelf.view showHint:@"format error!"];
            }
        }
    }];
    [self presentModalVC:vc animated:YES];
}

#pragma mark - Transition
- (void)jumpToCircleQR {
    
    [RouterConfig getRouterConfig].currentRouterMAC = @"";
    @weakify_self
    QRViewController *vc = [[QRViewController alloc] initWithCodeQRCompleteBlock:^(NSString *codeValue) {
        if (codeValue != nil && codeValue.length > 0) {
            if (codeValue.length == 12) {
                NSString *macAdress = @"";
                for (int i = 0; i<12; i+=2) {
                    NSString *macIndex = [codeValue substringWithRange:NSMakeRange(i, 2)];
                    macAdress = [macAdress stringByAppendingString:macIndex];
                    if (i < 10) {
                        macAdress = [macAdress stringByAppendingString:@":"];
                    }
                }
                if ([macAdress isMacAddress]) {
                    AppD.isScaner = YES;
                    [RouterConfig getRouterConfig].currentRouterMAC = macAdress;
                    [weakSelf scanSuccessfulWithIsMacd:YES];
                    return ;
                }
            }
            NSArray *codeValues = [codeValue componentsSeparatedByString:@","];
            NSString *type = codeValues[0];
            
            if ([[NSString getNotNullValue:type] isEqualToString:@"type_1"]) {
                // router 码
                NSString *result = aesDecryptString(codeValues[1],AES_KEY);
                result = [result stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                if (result && result.length == 114) {
                    
                    NSString *toxid = [result substringWithRange:NSMakeRange(6, 76)];
                    NSString *sn = [result substringWithRange:NSMakeRange(result.length-32, 32)];
                    NSLog(@"%@",[RouterConfig getRouterConfig].currentRouterSn);
                    
                    AppD.isScaner = YES;
                    [RouterConfig getRouterConfig].currentRouterToxid = toxid;
                    [RouterConfig getRouterConfig].currentRouterSn = sn;
                    [RouterConfig getRouterConfig].currentRouterIp = @"";
                    
                    [weakSelf scanSuccessfulWithIsMacd:NO];
                } else {
                    [weakSelf.view showHint:@"format error!"];
                }
            } else {
                [weakSelf.view showHint:@"format error!"];
            }
        }
    }];
    [self presentModalVC:vc animated:YES];
}

- (void)jumpToLoginDevice {
    LoginDeviceViewController *vc = [[LoginDeviceViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    //[self presentModalVC:vc animated:YES];
   // PNNavViewController *nav = [[PNNavViewController alloc] initWithRootViewController:vc];
   // [self presentViewController:nav animated:YES completion:nil];
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
