//
//  SettingViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/2/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "SettingViewController.h"
#import "MyCell.h"
#import "SystemUtil.h"
#import "PNRouter-Swift.h"
#import "OCTSubmanagerUser.h"
#import "AccountCodeViewController.h"

@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *myTableV;
@property (nonatomic , strong) NSMutableArray *dataArray;

@end

@implementation SettingViewController

#pragma mark - layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithObjects:@"Export configuration QR code",@"Status", nil];
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
    
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MyCellReuse_Height;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCellReuse];
    cell.lblContent.text = self.dataArray[indexPath.row];
    if (indexPath.row == 0) {
        cell.lblSubContent.hidden = YES;
        cell.subBtn.hidden = NO;
         [cell.subBtn setImage:[UIImage imageNamed:@"icon_code"] forState:UIControlStateNormal];
    } else {
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        AccountCodeViewController *vc = [[AccountCodeViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
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
