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
#import "MyConfidant-Swift.h"
#import "OCTSubmanagerUser.h"
#import "AccountCodeViewController.h"
#import "LogOutCell.h"
#import "RouterModel.h"
#import "TermsViewController.h"
#define Screen_Lock_Str @"Screen Lock"
#define Terms_Policy @"Terms & Privacy Policy"
#define Log_Out_Str @"Log Out"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *myTableV;
@property (nonatomic , strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UIView *clearDataBackView;

@end

@implementation SettingViewController

#pragma mark - Layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithObjects:Screen_Lock_Str,Terms_Policy,Log_Out_Str,nil];
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
    
    UITapGestureRecognizer *tapGeture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clearAppAllData)];
    tapGeture.numberOfTapsRequired = 3;
    _clearDataBackView.userInteractionEnabled = YES;
    [_clearDataBackView addGestureRecognizer:tapGeture];
}
// 清除app所有信息
- (void) clearAppAllData
{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:@"Clear all data and exit the app?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SystemUtil clearAppAllData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            exit(0);
        });
    }];
    [alert1 setValue:UIColorFromRGB(0x2C2C2C) forKey:@"_titleTextColor"];
    [alertC addAction:alert1];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:alertCancel];
    
    [self presentViewController:alertC animated:YES completion:nil];
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
        // 保存登陆状态
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:Login_Statu_Key];
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
    } else if ([title isEqualToString:Terms_Policy]){
        MyCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCellReuse];
        cell.iconWidth.constant = 0;
        cell.iconleftV.constant = 0;
        cell.subBtn.hidden = YES;
        cell.lblContent.text = title;
        return cell;
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = self.dataArray[indexPath.row];
    if ([title isEqualToString:Terms_Policy]) {
        TermsViewController *vc = [[TermsViewController alloc] init];
        [self presentModalVC:vc animated:YES];
    }
}

@end
