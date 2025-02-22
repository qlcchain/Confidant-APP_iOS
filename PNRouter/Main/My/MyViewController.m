//
//  MyViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "MyViewController.h"
#import "MyHeadView.h"
#import "MyCell.h"
#import "MyDetailViewController.h"
#import "UserModel.h"
#import "KeyCUtil.h"
#import "FriendModel.h"
#import "SocketMessageUtil.h"
#import <WZLBadge/WZLBadgeImport.h>
#import "MyConfidant-Swift.h"
#import "RouterManagerViewController.h"
#import "SystemUtil.h"
#import "OCTSubmanagerUser.h"
#import "PersonCodeViewController.h"
#import "RMDownloadIndicator.h"

//#import <toxcore/crypto_core.h>
#import "crypto_core.h"
#import <libsodium/crypto_box.h>

#import "SettingViewController.h"
#import "PTBPerformanceCenter.h"
#import "WebViewController.h"
#import "PNFeedbackListViewController.h"

static NSString *Management_Circle_Str = @"Manage Circles";
//static NSString *My_QRCode_Str = @"Share with Friends";
static NSString *Help_Center = @"Help Center";
static NSString *Settings_Str = @"Settings";
static NSString *Feed_back = @"Feedback";

@interface MyViewController ()<UITableViewDelegate,UITableViewDataSource> {
}

@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic , strong) NSMutableArray *dataArray;
@property (nonatomic , strong) MyHeadView *myHeadView;
@property (nonatomic , assign) CGFloat downloadedBytes;
@property (strong, nonatomic) RMDownloadIndicator *filedIndicator_left;
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;

@end

@implementation MyViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
   // [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    self.myHeadView.lblName.text = [UserModel getUserModel].username;
    NSString *userKey = [EntryModel getShareObject].signPublicKey;
    [self.myHeadView setUserNameFirstWithName:[StringUtil getUserNameFirstWithName:[UserModel getUserModel].username] userKey:userKey];
    
    UserModel *userM = [UserModel getUserModel];
    [SocketMessageUtil sendUserIsOnLine:userM.userId?:@""];
    [self updateOnlineStatus:NO];
    [_tableV reloadSections:[NSIndexSet indexSetWithIndex:self.dataArray.count-1] withRowAnimation:UITableViewRowAnimationNone];
    [super viewDidAppear:animated];
}

#pragma mark - Observe
- (void)observe {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userHeadChangeNoti:) name:USER_HEAD_CHANGE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ownerOnLine:) name:OWNER_ONLINE_NOTI object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Lazy
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithObjects:@[Management_Circle_Str],@[Help_Center,Feed_back],@[Settings_Str], nil];
        //_dataArray = [NSMutableArray arrayWithObjects:@[Management_Circle_Str],@[Help_Center],@[Settings_Str], nil];
    }
    return _dataArray;
}

- (MyHeadView *)myHeadView {
    if (!_myHeadView) {
        _myHeadView = [MyHeadView loadMyHeadView];
        _myHeadView.lblName.text = [UserModel getUserModel].username;
        _myHeadView.isMyHead = YES;
        NSString *userKey = [EntryModel getShareObject].signPublicKey;
        [_myHeadView setUserNameFirstWithName:[StringUtil getUserNameFirstWithName:[UserModel getUserModel].username] userKey:userKey];
//        _myHeadView.lblContent.text = @"Add to my status";
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpDetailvc)];
        
        _myHeadView.userInteractionEnabled = YES;
        [_myHeadView addGestureRecognizer:gesture];
    }
    return _myHeadView;
}


- (void)updateView:(CGFloat)val {
    self.downloadedBytes+=val;
    [self.filedIndicator_left updateWithTotalBytes:100 downloadedBytes:self.downloadedBytes];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    //[self updateView:10.0f];

}

- (void)viewDidLoad {
    [super viewDidLoad];
     self.view.backgroundColor = MAIN_GRAY_COLOR;
    [self observe];
    
//    _lblVersion.hidden = YES;
    _lblVersion.text = [NSString stringWithFormat:@"V:%@ (Build %@)",APP_Version,APP_Build];
    
    _tableV.delegate = self;
    _tableV.dataSource = self;
    UIView *headBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 96)];
    [headBackView addSubview:self.myHeadView];
    _tableV.tableHeaderView = headBackView;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableV registerNib:[UINib nibWithNibName:MyCellReuse bundle:nil] forCellReuseIdentifier:MyCellReuse];
    
     [self.view addSubview:self.filedIndicator_left];
    
}

- (void)updateOnlineStatus:(BOOL)onLine {
//    [self.myHeadView.lblName showBadge];
//    self.myHeadView.lblName.badgeBgColor = onLine?[UIColor greenColor]:RGB(230, 230, 230);
}

#pragma mark - Action

- (IBAction)rightAction:(UIButton *)sender {
    sender.selected = !sender.selected;
    if (sender.selected) {
        // 性能监控
        [[PTBPerformanceCenter defaultCenter] enable];
    } else {
        [[PTBPerformanceCenter defaultCenter] disable];
    }
}

#pragma mark - Transition
- (void) jumpDetailvc {
    MyDetailViewController *vc = [[MyDetailViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToRouterManagement {
    RouterManagerViewController *vc = [[RouterManagerViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rowArray = self.dataArray[section];
    return rowArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MyCellReuse_Height;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 16;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCellReuse];
     NSArray *rowArray = self.dataArray[indexPath.section];
    NSString *titleStr = rowArray[indexPath.row];
    cell.lblContent.text = titleStr;
    NSString *iconStr = @"";
    if ([titleStr isEqualToString:Management_Circle_Str]) {
        iconStr = @"icon_management_circle";
    }  else if ([titleStr isEqualToString:Settings_Str]) {
        iconStr = @"Settings";
    } else if ([titleStr isEqualToString:Help_Center]) {
        iconStr = @"ic_verified";
    } else if ([titleStr isEqualToString:Feed_back]) {
           iconStr = @"me_feedback";
    }
    cell.iconImageView.image = [UIImage imageNamed:iconStr];
    cell.lblSubContent.hidden = YES;
    if (indexPath.section == self.dataArray.count-1) {
        cell.lblSubContent.hidden = YES;
//        if ([SystemUtil isSocketConnect]) {
//            if ([SocketUtil.shareInstance getSocketConnectStatus] == socketConnectStatusConnected) {
//                cell.lblSubContent.text = @"OnLine";
//            } else {
//                cell.lblSubContent.text = @"OffLine";
//            }
//        } else {
//           OCTToxConnectionStatus connectStatus = [AppD.manager.user connectionStatus];
//            if (connectStatus > 0) {
//                cell.lblSubContent.text = @"OnLine";
//            } else {
//                cell.lblSubContent.text = @"OffLine";
//            }
//        }
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self jumpToRouterManagement];
        } else if (indexPath.row == 1) {
            
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            WebViewController *vc = [[WebViewController alloc] init];
            vc.fromType = WebFromTypeHelpCenter;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
             PNFeedbackListViewController *vc = [[PNFeedbackListViewController alloc] init];
             [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
//    if (indexPath.section == 2) {
//
//        WebViewController *vc = [[WebViewController alloc] init];
//        vc.fromType = WebFromTypeShareFriend;
//        [self.navigationController pushViewController:vc animated:YES];
//
//    }
    
    if (indexPath.section == self.dataArray.count-1) {
        SettingViewController *vc = [[SettingViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 通知
- (void) userHeadChangeNoti:(NSNotification *) noti
{
    NSString *userKey = [EntryModel getShareObject].signPublicKey;
    [_myHeadView setUserNameFirstWithName:[StringUtil getUserNameFirstWithName:[UserModel getUserModel].username] userKey:userKey];
}

- (void)ownerOnLine:(NSNotification *)noti {
    // 0：离线 1：在线 2：隐身 3：忙碌
    NSInteger status = [noti.object integerValue];
    BOOL online = NO;
    if (status == 1) {
        online = YES;
    }
    [self updateOnlineStatus:online];
}

@end
