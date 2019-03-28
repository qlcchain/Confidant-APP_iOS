//
//  SettingViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/2/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "SettingViewController.h"
#import "MyCell.h"
#import "SettingCell.h"
#import "SystemUtil.h"
#import "PNRouter-Swift.h"
#import "OCTSubmanagerUser.h"
#import "AccountCodeViewController.h"
#import "LogOutCell.h"
#import "RouterModel.h"

#define Screen_Lock_Str @"Screen Lock"
#define Log_Out_Str @"Log Out"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *myTableV;
@property (nonatomic , strong) NSMutableArray *dataArray;

@end

@implementation SettingViewController

#pragma mark - Layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithObjects:@"Configuration QR Code",@"Status",Screen_Lock_Str,Log_Out_Str, nil];
    }
    return _dataArray;
}

- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _myTableV.delegate = self;
    _myTableV.dataSource = self;
    _myTableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _myTableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_myTableV registerNib:[UINib nibWithNibName:MyCellReuse bundle:nil] forCellReuseIdentifier:MyCellReuse];
    [_myTableV registerNib:[UINib nibWithNibName:SettingCellReuse bundle:nil] forCellReuseIdentifier:SettingCellReuse];
    [_myTableV registerNib:[UINib nibWithNibName:LogOutCellReuse bundle:nil] forCellReuseIdentifier:LogOutCellReuse];
    
    
}

#pragma mark - Operation
- (void)screenLockAction:(UISwitch *)swit {
    [HWUserdefault updateObject:@(swit.on) withKey:Screen_Lock_Local];
    [_myTableV reloadData];
}

- (void)logoutAction {
    
   
    RouterModel *connectRouter = [RouterModel getConnectRouter];
    if (connectRouter.isConnected) {
        [SendRequestUtil sendLogOut];
        [AppD performSelector:@selector(logOutApp) withObject:nil afterDelay:0.5f];
    }
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = self.dataArray[indexPath.row];
    if ([title isEqualToString:Screen_Lock_Str]) {
        return SettingCell_Height;
    } else if ([title isEqualToString:Log_Out_Str]) {
        return LogOutCell_Height;
    }
    return MyCellReuse_Height;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSString *title = self.dataArray[indexPath.row];
    if ([title isEqualToString:Screen_Lock_Str]) { // 屏幕锁
        SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:SettingCellReuse];
        cell.titleLab.text = title;
        NSNumber *screenLock = [HWUserdefault getObjectWithKey:Screen_Lock_Local]?:@(NO);
        cell.switc.on = [screenLock boolValue];
        [cell.switc addTarget:self action:@selector(screenLockAction:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    } if ([title isEqualToString:Log_Out_Str]) { // 退出登录
        LogOutCell *cell = [tableView dequeueReusableCellWithIdentifier:LogOutCellReuse];
        @weakify_self
        cell.logOutB = ^{
            [weakSelf logoutAction];
        };
        
        return cell;
    } else {
        MyCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCellReuse];
        cell.iconWidth.constant = 0;
        cell.lblContent.text = title;
        if (indexPath.row == 0) {
            cell.lblSubContent.hidden = YES;
            cell.subBtn.hidden = NO;
            [cell.subBtn setImage:[UIImage imageNamed:@"icon_code"] forState:UIControlStateNormal];
        } else if (indexPath.row == 1) {
            cell.lblSubContent.hidden = NO;
            cell.subBtn.hidden = YES;
            if ([SystemUtil isSocketConnect]) {
                if ([SocketUtil.shareInstance getSocketConnectStatus] == socketConnectStatusConnected) {
                    cell.lblSubContent.text = @"OnLine";
                } else {
                    cell.lblSubContent.text = @"OffLine";
                }
            } else {
                OCTToxConnectionStatus connectStatus = [AppD.manager.user connectionStatus];
                if (connectStatus > 0) {
                    cell.lblSubContent.text = @"OnLine";
                } else {
                    cell.lblSubContent.text = @"OffLine";
                }
            }
        }
        
        return cell;
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        AccountCodeViewController *vc = [[AccountCodeViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
