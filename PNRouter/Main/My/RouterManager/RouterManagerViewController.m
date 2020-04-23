//
//  RouterManagerViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/27.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "RouterManagerViewController.h"
#import "RouterManagementCell.h"
#import "QRViewController.h"
#import "RouterModel.h"
#import "RouterDetailViewController.h"
#import "MyConfidant-Swift.h"
#import "SocketCountUtil.h"
#import "SystemUtil.h"
#import "PNDefaultHeaderView.h"
#import "UsedSpaceTableViewCell.h"
#import "SettingCell.h"
#import "UserManagerViewController.h"
#import "EditTextViewController.h"
#import "CircleLoginCodeViewController.h"
#import "ChooseCircleViewController.h"
#import "DiskManagerViewController.h"
#import "GetDiskTotalInfoModel.h"
#import "UnitUtil.h"
#import "AddNewMemberViewController.h"
#import "UserConfig.h"
#import "InvitationQRCodeViewController.h"

typedef enum : NSUInteger {
    RouterConnectStatusWait,
    RouterConnectStatusConnecting,
    RouterConnectStatusSuccess,
    RouterConnectStatusFail,
} RouterConnectStatus;

#define Circle_Members_Str @"Circle Members"
#define Circle_Code_Str @"Circle QR Code"
#define Circle_Name_Str @"Circle Name"
#define Add_Circle_Member @"Add a New Member "
#define Circle_QR_Code_Str @"My Private Code"
#define Used_Space_Str @"Used Space"
#define Manage_Disks_Str @"Manage Disks"
#define Run_QLC_Chain_Str @"Run as QLC Chain Node"
#define Enable_Auto_Login_Str @"Enable Auto Login"
#define Circle_Alias_Str @"Circle Alias"
#define Reboot_Circle @"Reboot Circle"

@interface RouterManagerViewController () <UITableViewDelegate, UITableViewDataSource>
{
    BOOL isAdmin;
    NSInteger qlcNodeStatus;
}

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navContraintV;

@property (weak, nonatomic) IBOutlet UILabel *routerNameLab;

@property (weak, nonatomic) IBOutlet UIImageView *currentCircleIcon;

@property (weak, nonatomic) IBOutlet UITableView *routerTable;
@property (nonatomic, strong) NSMutableArray *routerArr;
@property (nonatomic) RouterConnectStatus connectStatus;

@property (nonatomic, strong) RouterModel *connectRouteM;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;
@property (weak, nonatomic) IBOutlet UIView *quickBackView;
@property (nonatomic, strong) GetDiskTotalInfoModel *getDiskTotalInfoM;

@end

@implementation RouterManagerViewController

- (void)viewDidAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [super viewDidAppear:animated];
}

- (IBAction)quickSwitchAction:(id)sender {
    [self jumpToChooseCircle];
}

#pragma mark - Observe
- (void)observe {
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshStatus) name:RELOAD_SOCKET_FAILD_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDiskTotalInfoSuccessNoti:) name:GetDiskTotalInfo_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rebootSuccessNoti:) name:Reboot_Success_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enableQlcNodeSuccessNoti:) name:ENABLE_QLC_NODE_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chekcQlcNodeSuccessNoti:) name:CHECK_QLC_NODE_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchCircleSuccessNoti:) name:SWITCH_CIRCLE_SUCCESS_NOTI object:nil];
    
    
}

#pragma mark - Life Cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _navContraintV.constant = STATUS_BAR_HEIGHT;
    _quickBackView.layer.cornerRadius = 14.0f;
    _quickBackView.layer.masksToBounds = YES;
    _quickBackView.layer.borderColor = RGB(44, 44, 44).CGColor;
    _quickBackView.layer.borderWidth = .5f;
    
    _codeBtn.hidden = YES;
    [self observe];
    _routerArr = [NSMutableArray array];
    _routerTable.delegate = self;
    _routerTable.dataSource = self;
    
    [_routerTable registerNib:[UINib nibWithNibName:RouterManagementCellReuse bundle:nil] forCellReuseIdentifier:RouterManagementCellReuse];
    [_routerTable registerNib:[UINib nibWithNibName:UsedSpaceTableViewCellReuse bundle:nil] forCellReuseIdentifier:UsedSpaceTableViewCellReuse];
    [_routerTable registerNib:[UINib nibWithNibName:SettingCellReuse bundle:nil] forCellReuseIdentifier:SettingCellReuse];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUI];
    
}

- (void) updateUI {
    
    _currentCircleIcon.layer.cornerRadius = 32.0f;
    
    _currentCircleIcon.layer.masksToBounds = YES;
    
    _currentCircleIcon.layer.borderColor = [UIColor whiteColor].CGColor;
    _currentCircleIcon.layer.borderWidth = 2.0f;
    
    _connectRouteM = [RouterModel getConnectRouter];
    _routerNameLab.text = _connectRouteM.name?:@"";
    NSString *userKey = [UserConfig getShareObject].adminKey?:@"";
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:_routerNameLab.text]];
    _currentCircleIcon.image = defaultImg;
    
    NSString *userType = [_connectRouteM.userSn substringWithRange:NSMakeRange(0, 2)];
    [_routerArr removeAllObjects];
    if ([userType isEqualToString:@"01"]) { // 管理员
        // 查看磁盘
        [self sendGetDiskTotalInfo];
        // 查看节点水状态
        [SendRequestUtil sendCheckNodeWithShowHud:NO];
        
        isAdmin = YES;
        [_routerArr addObjectsFromArray:@[@[Circle_Members_Str,Circle_Code_Str],@[Circle_Name_Str],@[Used_Space_Str,Manage_Disks_Str],@[Run_QLC_Chain_Str],@[Enable_Auto_Login_Str],@[Circle_QR_Code_Str],@[Reboot_Circle]]];
    } else {
        isAdmin = NO;
        [_routerArr addObjectsFromArray:@[@[Circle_Alias_Str,Circle_Code_Str],@[Enable_Auto_Login_Str],@[Circle_QR_Code_Str]]];
    }
    [_routerTable reloadData];
}

#pragma mark - Operation
- (void)refreshStatus {
    
    if ([SystemUtil isSocketConnect]) {
        NSInteger status = [SocketUtil.shareInstance getSocketConnectStatus];
        if (status == socketConnectStatusNone) {
            self.connectStatus = RouterConnectStatusWait;
        } else if (status == socketConnectStatusConnecting) {
            self.connectStatus = RouterConnectStatusConnecting;
        } else if (status == socketConnectStatusConnected) {
            self.connectStatus = RouterConnectStatusSuccess;
        } else if (status == socketConnectStatusDisconnecting) {
            self.connectStatus = RouterConnectStatusFail;
        } else if (status == socketConnectStatusDisconnected) {
            self.connectStatus = RouterConnectStatusFail;
        }
    } else {
        if (AppD.manager) {
            self.connectStatus = RouterConnectStatusSuccess;
        } else {
             self.connectStatus = RouterConnectStatusFail;
        }
    }
    
   
}

- (void)refreshTableData {
    [_routerArr removeAllObjects];
    [_routerArr addObjectsFromArray:[RouterModel getLocalRouters]];
    [_routerTable reloadData];
}

#pragma mark - Action
- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)scanAction:(id)sender {
    @weakify_self
    QRViewController *vc = [[QRViewController alloc] initWithCodeQRCompleteBlock:^(NSString *codeValue) {
        if (codeValue != nil && codeValue.length > 0) {
            
        }
    }];
    [self presentModalVC:vc animated:YES];
}

- (IBAction)clickRouterAction:(id)sender {
    [self jumpToRouterDetail:_connectRouteM];
}

- (IBAction)tryAgainAction:(id)sender {
    if ([SystemUtil isSocketConnect]) {
        [SocketCountUtil getShareObject].reConnectCount = 0;
        [AppD.window showHudInView:AppD.window hint:@"connection..."];
        NSString *connectURL = [SystemUtil connectUrl];
        [SocketUtil.shareInstance connectWithUrl:connectURL];
        [self refreshStatus];
    }
}

#pragma mark - Request
- (void)sendGetDiskTotalInfo {
    [SendRequestUtil sendGetDiskTotalInfoWithShowHud:NO];
}

#pragma mark - Transition
- (void)jumpToRouterDetail:(RouterModel *)model {
    RouterDetailViewController *vc = [[RouterDetailViewController alloc] init];
    vc.routerM = model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return _routerArr.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!isAdmin) {
        if (section == 0) {
            return 0;
        }
    } else {
        if (section == 0) {
            return 1;
        } else if (section == 1) {
            return 0;
        }
//        } else if (section == 3) {
//            return 0;
//        }
    }
    return [_routerArr[section] count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!isAdmin) {
        if (section == 0) {
            return 0;
        }
    } else {
        if (section == 1) {
            return 0;
        }
    }
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [UIView new];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 10);
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *title = _routerArr[indexPath.section][indexPath.row];
    if ([title isEqualToString:Used_Space_Str]) {
        return UsedSpaceTableViewCell_Height;
    }
    return RouterManagementCell_Height;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
   
    if (indexPath.section == 0) {
         RouterManagementCell *cell = [tableView dequeueReusableCellWithIdentifier:RouterManagementCellReuse];
        cell.nameLab.text = _routerArr[indexPath.section][indexPath.row];
        if (isAdmin) {
            if (indexPath.row == 0) {
                cell.icon.hidden = YES;
                cell.lblDesc.text = @"";
            } else {
                cell.icon.hidden = NO;
                cell.lblDesc.text = @"";
            }
           
        } else {
            if (indexPath.row == 0) {
                cell.icon.hidden = YES;
                cell.lblDesc.text = _connectRouteM.aliasName?:@"";
            } else {
                cell.icon.hidden = NO;
                cell.lblDesc.text = @"";
            }
        }
        return cell;
    } else if (indexPath.section == 1) {
        if (isAdmin) {
            RouterManagementCell *cell = [tableView dequeueReusableCellWithIdentifier:RouterManagementCellReuse];
            cell.nameLab.text = _routerArr[indexPath.section][indexPath.row];
            if (indexPath.row == 0) {
                cell.icon.hidden = YES;
                cell.lblDesc.text = _connectRouteM.aliasName?:@"";
            } else {
                cell.icon.hidden = YES;
                cell.lblDesc.text = @"";
            }
            return cell;
        } else {
            SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingCellReuse];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.leftContraintV.constant = 16;
            cell.titleLab.text = _routerArr[indexPath.section][indexPath.row];
            [cell.switc setOn:_connectRouteM.isOpen animated:YES];
            [cell.switc addTarget:self action:@selector(swChange:) forControlEvents:UIControlEventValueChanged];
            return cell;
        }
        
    } else if (indexPath.section == 2) {
        if (isAdmin) {
            if (indexPath.row == 0) {
                UsedSpaceTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UsedSpaceTableViewCellReuse];
                if (_getDiskTotalInfoM) {
                    CGFloat useDigital = [UnitUtil getDigitalOfM:_getDiskTotalInfoM.UsedCapacity];
                    CGFloat totalDigital = [UnitUtil getDigitalOfM:_getDiskTotalInfoM.TotalCapacity];
                    CGFloat usePercent = useDigital/totalDigital;
                    cell.useLab.text = [NSString stringWithFormat:@"%@ / %@ （%.1f%@）",_getDiskTotalInfoM.UsedCapacity?:@"",_getDiskTotalInfoM.TotalCapacity?:@"",usePercent*100,@"%"];
                    cell.useProgressV.progress = usePercent;
                }
                return cell;
            } else {
                RouterManagementCell *cell = [tableView dequeueReusableCellWithIdentifier:RouterManagementCellReuse];
                cell.nameLab.text = _routerArr[indexPath.section][indexPath.row];
                cell.lblDesc.text = @"";
                cell.icon.hidden = YES;
                return cell;
            }
        } else {
            RouterManagementCell *cell = [tableView dequeueReusableCellWithIdentifier:RouterManagementCellReuse];
            cell.nameLab.text = _routerArr[indexPath.section][indexPath.row];
            cell.icon.hidden = YES;
            cell.lblDesc.text = @"";
            return cell;
        }
        
    } else if (indexPath.section == 3 || indexPath.section == 4){
        SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingCellReuse];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.leftContraintV.constant = 16;
        cell.titleLab.text = _routerArr[indexPath.section][indexPath.row];
        if (indexPath.section == 4) {
            [cell.switc setOn:_connectRouteM.isOpen animated:YES];
            [cell.switc addTarget:self action:@selector(swChange:) forControlEvents:UIControlEventValueChanged];
        } else {
            [cell.switc setOn:qlcNodeStatus animated:YES];
            [cell.switc addTarget:self action:@selector(qlcChainChange:) forControlEvents:UIControlEventValueChanged];
        }
       
        return cell;
    } else {
        RouterManagementCell *cell = [tableView dequeueReusableCellWithIdentifier:RouterManagementCellReuse];
        cell.nameLab.text = _routerArr[indexPath.section][indexPath.row];
        cell.icon.hidden = YES;
        cell.lblDesc.text = @"";
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
       
        if (isAdmin) {
            if (indexPath.row == 0) {
                // 圈子人数
                [self jumpToUserManager];
            } else {
                // 添加圈子人员
               // [self jumpAddNewMember];
                
                // 圈子code
                [self jumpToCircleCode];
            }
           
        } else {
            if (indexPath.row == 0) {
               // 圈子别名
                 [self jumpToAliasWithType:EditAlis];
            } else {
               // 圈子code
                 [self jumpToCircleCode];
            }
        }
       
    } else if (indexPath.section == 1) {
        if (isAdmin) {
            if (indexPath.row == 0) {
                // 修改圈子昵称
                [self jumpToAliasWithType:EditCircleName];
            } 
            
        }
        
    } else if (indexPath.section == 2) {
        if (isAdmin) {
            if (indexPath.row == 0) {
                // 圈子磁盘空间和使用量
            } else {
                [self jumpToDiskManagement];
            }
        } else {
            // 圈子code
            [self jumpToRouterCode];
        }
       
    } else if (indexPath.section == 5) {
        // 圈子code
        [self jumpToRouterCode];
    } else if (indexPath.section == 6) {
        // 重启圈子
        [self rebootCircle];
    }
}

#pragma mark ----重启圈子
- (void) rebootCircle
{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:@"Disconnect after circle reboot" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"Reboot" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SendRequestUtil sendRebootWithShowHud:YES];
    }];
    [alert1 setValue:UIColorFromRGB(0x2C2C2C) forKey:@"_titleTextColor"];
    [alertC addAction:alert1];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:alertCancel];
    
    [self presentViewController:alertC animated:YES completion:nil];
}

#pragma mark - Transition
- (void)jumpToAliasWithType:(EditType) editType {
    EditTextViewController *vc = [[EditTextViewController alloc] initWithType:editType];
    vc.routerM = _connectRouteM;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToRouterCode {
    CircleLoginCodeViewController *vc = [[CircleLoginCodeViewController alloc] init];
    vc.routerM = _connectRouteM;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToChooseCircle {
    ChooseCircleViewController *vc = [[ChooseCircleViewController alloc] init];
    [self presentModalVC:vc animated:YES];
}

- (void)jumpToDiskManagement {
    DiskManagerViewController *vc = [DiskManagerViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void) jumpAddNewMember
{
    AddNewMemberViewController *vc = [[AddNewMemberViewController alloc] initWithRid:_connectRouteM.toxid];
    [self presentModalVC:vc animated:YES];
}

- (void)jumpToUserManager {
    // 磁盘管理
    UserManagerViewController *vc = [[UserManagerViewController alloc] initWithRid:_connectRouteM.toxid];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToCircleCode {
    InvitationQRCodeViewController *vc = [[InvitationQRCodeViewController alloc] init];
    vc.routerM = _connectRouteM;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - switch开关change
- (void) swChange:(UISwitch *) sender
{
    [RouterModel updateRouterLoginSwitchWithSn:_connectRouteM.userSn isOpen:sender.isOn];
}
- (void) qlcChainChange:(UISwitch *) sender
{
    int openTag = sender.isOn;
    [SendRequestUtil sendQLCNodeWithEnable:@(openTag) seed:@"" showHud:YES];
}

#pragma mark - Noti
- (void)getDiskTotalInfoSuccessNoti:(NSNotification *)noti {
    NSDictionary *receiveDic = noti.object;
    NSDictionary *paramsDic = receiveDic[@"params"];
    _getDiskTotalInfoM = [GetDiskTotalInfoModel getObjectWithKeyValues:paramsDic];
    DDLogDebug(@"---%@",_getDiskTotalInfoM);
    [_routerTable reloadData];
}
- (void) rebootSuccessNoti:(NSNotification *) noti
{
    [AppD.window showHint:@"Reboot successful"];
}
- (void)enableQlcNodeSuccessNoti:(NSNotification *) noti
{
    NSInteger retCode = [noti.object integerValue];
    if (retCode == 0) {
        if (qlcNodeStatus == 0) {
            qlcNodeStatus = 1;
        } else {
            qlcNodeStatus = 0;
        }
    }
    [_routerTable reloadData];
}
- (void)chekcQlcNodeSuccessNoti:(NSNotification *) noti
{
    NSDictionary *resultDic = noti.object;
    qlcNodeStatus = [resultDic[@"Status"] integerValue];
    [_routerTable reloadData];
}
- (void) switchCircleSuccessNoti:(NSNotification *) noti
{
    [self updateUI];
}
#pragma mark - Lazy
//- (void)setConnectStatus:(RouterConnectStatus)connectStatus {
//    _connectStatus = connectStatus;
//    if (_connectStatus == RouterConnectStatusWait) {
//        _connectBtnHeight.constant = 43;
//        [_connectBtn setTitle:@"Connect" forState:UIControlStateNormal];
//        _connectTipBackHeight.constant = 0;
//    } else if (_connectStatus == RouterConnectStatusConnecting) {
//        _connectBtnHeight.constant = 0;
//        _connectTipBackHeight.constant = 30;
//        _connectTipLab.text = @"Connection...";
//        _connectTipIcon.image = [UIImage imageNamed:@"icon_loading"];
//    } else if (_connectStatus == RouterConnectStatusSuccess) {
//        _connectBtnHeight.constant = 0;
//        _connectTipBackHeight.constant = 30;
//        _connectTipLab.text = @"Successful connection";
//        _connectTipIcon.image = [UIImage imageNamed:@"icon_connected"];
//    } else if (_connectStatus == RouterConnectStatusFail) {
//        _connectBtnHeight.constant = 43;
//        [_connectBtn setTitle:@"Try again" forState:UIControlStateNormal];
//        _connectTipBackHeight.constant = 30;
//        _connectTipLab.text = @"Failed to connect";
//        _connectTipIcon.image = nil;
//    }
//}

@end
