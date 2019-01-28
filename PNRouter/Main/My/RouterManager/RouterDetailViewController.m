//
//  RouterDetailViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/27.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "RouterDetailViewController.h"
#import "EditTextViewController.h"
#import "RouterCodeViewController.h"
#import "RouterModel.h"
#import "PNRouter-Swift.h"
#import "SystemUtil.h"
#import "ChatListDataUtil.h"
#import "UserManagerViewController.h"
#import "HeartBeatUtil.h"
#import "RoutherConfig.h"
#import "DiskManagerViewController.h"

@interface RouterDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *nameValLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoutHeight; // 48
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *userManagerContraintH;
@property (weak, nonatomic) IBOutlet UIButton *logOutBtn;

@end

@implementation RouterDetailViewController

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logOutSuccess:) name:REVER_LOGOUT_SUCCESS_NOTI object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshView];
}

#pragma mark - Operation
- (void)refreshView {
    //_logoutHeight.constant = _routerM.isConnected?48:0;
    NSString *logTtile = _routerM.isConnected?@"Log Out":@"Delete";
    [_logOutBtn setTitle:logTtile forState:UIControlStateNormal];
    
     NSString *userType = [_routerM.userSn substringWithRange:NSMakeRange(0, 2)];
    
    if (![userType isEqualToString:@"01"]) {
        _userManagerContraintH.constant = 0;
    } else {
       RouterModel *model = [RouterModel getConnectRouter];
        if (![model.userSn isEqualToString:_routerM.userSn]) {
            _userManagerContraintH.constant = 0;
        }
    }
    _titleLab.text = _routerM.name?:@"";
    _nameValLab.text = _routerM.name?:@"";
}

- (void)logout {
    
    if ( _routerM.isConnected) {
         [SendRequestUtil sendLogOut];
       
         [self performSelector:@selector(logOutApp) withObject:self afterDelay:0.5f];
    } else { //删除router
        [RouterModel deleteRouterWithUsersn:_routerM.userSn];
        [self leftNavBarItemPressedWithPop:YES];
    }
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)switchRouterAction:(id)sender {
    @weakify_self
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    NSArray *routerArr = [RouterModel getLocalRouter];
    [routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        RouterModel *model = obj;
        UIAlertAction *alert = [UIAlertAction actionWithTitle:model.name style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            weakSelf.routerM = model;
            [weakSelf refreshView];
        }];
        [alertC addAction:alert];
    }];
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:alertCancel];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (IBAction)aliasAction:(id)sender {
    [self jumpToAlias];
}

- (IBAction)qrcodeAction:(id)sender {
    [self jumpToRouterCode];
}
- (IBAction)userManagementAction:(id)sender {
    UserManagerViewController *vc = [[UserManagerViewController alloc] initWithRid:_routerM.toxid];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)logoutAction:(id)sender {
    
    
    NSString *alertMsg = _routerM.isConnected?@"Confirm to log out the router? Please be aware that your chatting history, files and contacts will be erased.":@"Determine whether to remove the current router.";
    
    @weakify_self
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:alertMsg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:alert1];
    UIAlertAction *alert2 = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf logout];
    }];
    [alertC addAction:alert2];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (IBAction)diskManagementAction:(id)sender {
    [self jumpToDiskManagement];
}


#pragma mark - Transition
- (void)jumpToAlias {
    EditTextViewController *vc = [[EditTextViewController alloc] initWithType:EditAlis];
    vc.routerM = _routerM;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToRouterCode {
    RouterCodeViewController *vc = [[RouterCodeViewController alloc] init];
    vc.routerM = _routerM;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToDiskManagement {
    DiskManagerViewController *vc = [DiskManagerViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) logOutApp
{
    [HeartBeatUtil stop];
    if ([SystemUtil isSocketConnect]) {
        [RoutherConfig getRoutherConfig].currentRouterIp = @"";
        [[SocketUtil shareInstance] disconnect];
    } else {
        AppD.isConnect = NO;
        //[self logOutTox];
    }
    [[ChatListDataUtil getShareObject].dataArray removeAllObjects];
    AppD.isLogOut = YES;
    [AppD setRootLogin];
}
#pragma mark -通知回调
- (void) logOutSuccess:(NSNotification *) noti
{
    
}
@end
