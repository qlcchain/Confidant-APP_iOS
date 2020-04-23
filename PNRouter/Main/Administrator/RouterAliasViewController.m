//
//  RouterAliasViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/2/20.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "RouterAliasViewController.h"
#import "AccountManagementViewController.h"
#import "SocketMessageUtil.h"
#import "MyConfidant-Swift.h"
#import "SystemUtil.h"
#import "NSString+Trim.h"

@interface RouterAliasViewController ()
{
    BOOL isRouterAliasViewController;
}
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *headerLab;
@property (weak, nonatomic) IBOutlet UITextField *aliasTF;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end

@implementation RouterAliasViewController

- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetRouterNameSuccess:) name:ResetRouterName_Success_Noti object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    isRouterAliasViewController = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    isRouterAliasViewController = NO;
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addObserve];
    [self renderView];
    [self viewInit];
}

#pragma mark - Operation
- (void)viewInit {
    _aliasTF.text = _inputRouterAlias;
}

- (void)renderView {
    _headerView.layer.cornerRadius = _headerView.width/2.0;
    _headerView.layer.masksToBounds = YES;
    _headerLab.layer.cornerRadius = _headerLab.width/2.0;
    _headerLab.layer.masksToBounds = YES;
    _nextBtn.layer.cornerRadius = 4;
    _nextBtn.layer.masksToBounds = YES;
}

- (void)sendResetRouterName {
    
    NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
    if (connectStatu == socketConnectStatusConnected) {
        NSString *aliasName = [NSString trimWhitespaceAndNewline:[NSString getNotNullValue:_aliasTF.text]];
        [SocketMessageUtil sendUpdateRourerNickName:aliasName showHud:YES];
    } else {
        [self connectSocket];
    }
    
}

#pragma mark -连接socket
- (void) connectSocket {
    // 连接
    [AppD.window showHudInView:AppD.window hint:Connect_Cricle];
    NSString *connectURL = [SystemUtil connectUrl];
    [SocketUtil.shareInstance connectWithUrl:connectURL];
}

#pragma mark -通知回调
- (void)socketOnConnect:(NSNotification *)noti {
    if (!isRouterAliasViewController) {
        return;
    }
    [AppD.window hideHud];
    NSString *aliasName = [NSString trimWhitespaceAndNewline:[NSString getNotNullValue:_aliasTF.text]];
    [SocketMessageUtil sendUpdateRourerNickName:aliasName showHud:YES];
}

- (void)socketOnDisconnect:(NSNotification *)noti {
    if (!isRouterAliasViewController) {
        return;
    }
    [AppD.window hideHud];
    [AppD.window showHint:Connect_Failed];
}

#pragma mark - Action
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)nextAction:(id)sender {
    NSString *aliasName = [NSString trimWhitespaceAndNewline:[NSString getNotNullValue:_aliasTF.text]];
    if (!aliasName || aliasName.length == 0) {
        [AppD.window showHint:@"Please enter the Circle Alias"];
        return;
    }
    
    [self sendResetRouterName];
}

#pragma mark - Transition
- (void)jumpToAccountManagement {
    AccountManagementViewController *vc = [[AccountManagementViewController alloc] init];
    vc.RouterId = _RouterId;
    vc.Qrcode = _Qrcode;
    vc.IdentifyCode = _IdentifyCode;
    vc.UserSn = _UserSn;
    vc.RouterPW = _RouterPW;
    vc.routerAlias = _aliasTF.text?:@"";
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Noti
- (void)resetRouterNameSuccess:(NSNotification *)noti {
//    NSDictionary *receiveDic = noti.object;
//    NSDictionary *paramsDic = receiveDic[@"params"];
    if (_finishBack) {
        if (_finishB) {
            NSString *alias = _aliasTF.text?:@"";
            _finishB(alias);
        }
        [self backAction:nil];
    } else {
        [self jumpToAccountManagement];
    }
}

@end
