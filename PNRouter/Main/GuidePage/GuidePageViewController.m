//
//  GuidePageViewController.m
//  Qlink
//
//  Created by 旷自辉 on 2018/6/21.
//  Copyright © 2018年 pan. All rights reserved.
//

#import "GuidePageViewController.h"
#import "GuidePageView1.h"
#import "GuidePageView2.h"
#import "GuidePageView3.h"
#import "QRViewController.h"
#import "RSAUtil.h"
#import "AESCipher.h"
#import "LoginViewController.h"
#import "RegiterViewController.h"
#import "RoutherConfig.h"
#import "PNRouter-Swift.h"
#import "RouterModel.h"
#import "ReviceRadio.h"
#import "UserModel.h"
#import "SystemUtil.h"
#import "OCTSubmanagerFriends.h"
#import "NSString+Base64.h"
#import "OCTSubmanagerUser.h"
#import "ConnectView.h"

@interface GuidePageViewController ()
{
    BOOL isFind;
}
@property (nonatomic ,strong) UIScrollView *mainScrollView;
@property (nonatomic ,strong) ConnectView *connectView;

@end

@implementation GuidePageViewController
- (void) showConnectServerLoad
{
    if (!_connectView) {
        _connectView = [ConnectView loadConnectView];
    }
    [_connectView showConnectView];
}
- (void) hideConnectServerLoad
{
    [_connectView hiddenConnectView];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void) addNotication
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recivceUserFind:) name:USER_FIND_RECEVIE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnConnect:) name:SOCKET_ON_CONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnDisconnect:) name:SOCKET_ON_DISCONNECT_NOTI object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gbFinashNoti:) name:GB_FINASH_NOTI object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toxAddRoterSuccess:) name:TOX_ADD_ROUTER_SUCCESS_NOTI object:nil];
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _mainScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    _mainScrollView.bounces = NO;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.showsVerticalScrollIndicator = NO;
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.backgroundColor = [UIColor clearColor];
    _mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH*3, SCREEN_HEIGHT);
    [self.view addSubview:_mainScrollView];
    [self addGuidePageView];
    [self addNotication];
}

// 添加引导页
- (void) addGuidePageView {
    GuidePageView1 *page1 = [GuidePageView1 loadGuidePageView1];
    page1.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
     [page1.nextBtn addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    
    GuidePageView2 *page2 = [GuidePageView2 loadGuidePageView2];
    page2.frame = CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
     [page2.nextBtn addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    
    GuidePageView3 *page3 = [GuidePageView3 loadGuidePageView3];
    page3.frame = CGRectMake(SCREEN_WIDTH*2, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    [page3.nextBtn addTarget:self action:@selector(nextAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [_mainScrollView addSubview:page1];
    [_mainScrollView addSubview:page2];
    [_mainScrollView addSubview:page3];
}
- (void) nextAction:(UIButton *) sender
{
    if (sender.tag == 2) {
//        UIDocumentPickerViewController *vc = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:@[@"public.content",@"public.text",@"public.source-code",@"public.image",@"public.audiovisual-content",@"com.adobe.pdf",@"com.apple.keynote.key",@"com.microsoft.word.doc",@"com.microsoft.excel.xls",@"com.microsoft.powerpoint.ppt"] inMode:UIDocumentPickerModeOpen];
////        vc.delegate = self;
//        vc.modalPresentationStyle = UIModalPresentationFullScreen;
//        //    vc.allowsMultipleSelection = YES;
//        [self presentViewController:vc animated:YES completion:nil];
//
//        return;
        
         [self jumpToQR];
    } else {
        [_mainScrollView scrollRectToVisible:CGRectMake(SCREEN_WIDTH*(sender.tag+1), 0, SCREEN_WIDTH, SCREEN_HEIGHT) animated:YES];
    }
}

- (void)scanSuccessfulWithIsMacd:(BOOL)isMac
{
    [AppD.window showHudInView:AppD.window hint:@"Check Router..."];
    if (isMac) {
         [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RoutherConfig getRoutherConfig].currentRouterMAC];
    } else {
        [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RoutherConfig getRoutherConfig].currentRouterToxid];
    }
    
}

#pragma mark -连接socket
- (void) connectSocket
{
    NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
    if (connectStatu == socketConnectStatusConnected) {
        [[SocketUtil shareInstance] disconnect];
    }    // 连接
    [AppD.window showHudInView:AppD.window hint:@"Connect Router..."];
    NSString *connectURL = [SystemUtil connectUrl];
    [SocketUtil.shareInstance connectWithUrl:connectURL];
}

#pragma mark -通知回调
- (void)socketOnConnect:(NSNotification *)noti {
    
    if (AppD.isLoginMac) {
        return;
    }
    
    [AppD.window hideHud];
    [SendRequestUtil sendUserFindWithToxid:[RoutherConfig getRoutherConfig].currentRouterToxid usesn:[RoutherConfig getRoutherConfig].currentRouterSn];
}

- (void)socketOnDisconnect:(NSNotification *)noti {
    
    if (AppD.isLoginMac) {
        return;
    }
    
    [AppD.window hideHud];
    [AppD.window showHint:@"The connection fails"];
}

- (void) gbFinashNoti:(NSNotification *) noti
{
    if (![[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterMAC] isEmptyString]) {
        if ([[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterIp] isEmptyString]) {
            [self.view showHint:@"Unable to connect to server."];
        } else {
            [self jumpToLoginDevice];
        }
    } else {
        isFind = YES;
        // 当前是在局域网
        if (![[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterIp] isEmptyString])
        {
            AppD.manager = nil;
            [self connectSocket];
            
        } else { // tox
            if (!AppD.manager) {
                [self loginTox];
            } else {
                [self toxLoginSuccessWithManager:AppD.manager];
            }
            
        }
    }
}

- (void)toxLoginSuccessWithManager:(id<OCTManager>)manager
{
    
  //  [RoutherConfig getRoutherConfig].currentRouterToxid = @"A1DA6FFE24611BDE1D14B55B02F180961A3DFB8C9C9B2A572EB274896B7EAC30B4CDCDCE68B8";
    
    if (![manager.friends friendIsExitWithFriend:[RoutherConfig getRoutherConfig].currentRouterToxid]) {
        // 添加好友
        [self showConnectServerLoad];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            BOOL result = [manager.friends sendFriendRequestToAddress:[RoutherConfig getRoutherConfig].currentRouterToxid message:@"" error:nil];
            if (!result) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self hideConnectServerLoad];
                    [AppD.window showHint:@"Failed to connect to the server"];
                });
            }
        });
       
    } else { // 好友已存在并且在线
        
        if ([AppD.manager.friends getFriendConnectStatuWithFriendNumber:AppD.currentRouterNumber] > 0) {
             [self sendToxFindWithManager:manager];
        } else {
            [self showConnectServerLoad];
        }
        
    }
    
}


- (void) sendToxFindWithManager:(id<OCTManager>)manager
{
    if (isFind) {
        isFind = NO;
        [SendRequestUtil sendUserFindWithToxid:[RoutherConfig getRoutherConfig].currentRouterToxid usesn:[RoutherConfig getRoutherConfig].currentRouterSn];
    }
}

- (void) toxAddRoterSuccess:(NSNotification *) noti
{
    [self hideConnectServerLoad];
    [AppD.window hideHud];
   // [AppD.window showHint:@"Server connection successful."];
    [self sendToxFindWithManager:AppD.manager];
}

- (void) recivceUserFind:(NSNotification *) noti
{
    if (AppD.isLoginMac) {
        return;
    }
    NSDictionary *receiveDic = (NSDictionary *)noti.object;
    if (receiveDic) {
        NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
        NSString *routherid = receiveDic[@"params"][@"RouteId"];
        NSString *usesn = receiveDic[@"params"][@"UserSn"];
        NSString *userid = receiveDic[@"params"][@"UserId"];
        NSString *userName = receiveDic[@"params"][@"NickName"];
        NSInteger fileVersion = [receiveDic[@"params"][@"DataFileVersion"] integerValue];
        
        NSString *userType = [usesn substringWithRange:NSMakeRange(0, 2)];
        AccountType type = AccountSupper;
        if ([userType isEqualToString:@"02"]) {
            type = AccountOrdinary;
        } else if ([userType isEqualToString:@"03"]){
            type = AccountTemp;
        }
        
        //[RouterModel addRouterWithToxid:routherid usesn:usesn];
        
        if (retCode == 0) { //已激活
            [RouterModel addRouterWithToxid:routherid usesn:usesn userid:userid];
            [UserModel createUserLocalWithName:userName userid:userid version:fileVersion filePay:@"" userpass:@"" userSn:usesn hashid:@""];
            [RouterModel updateRouterConnectStatusWithSn:usesn];
            LoginViewController *vc = [[LoginViewController alloc] init];
            [self setRootVCWithVC:vc];
        } else { // 未激活 或者日临时帐户
            RegiterViewController *vc = [[RegiterViewController alloc] initWithAccountType:type];
            [self setRootVCWithVC:vc];
        }
    }
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
