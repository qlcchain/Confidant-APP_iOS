//
//  CircleMemberDetailViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/4/17.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "CircleMemberDetailViewController.h"
#import "MyCell.h"
#import "PNDefaultHeaderView.h"
#import "RouterUserModel.h"
#import "LogOutCell.h"
#import "NSDate+Category.h"
#import "UserConfig.h"

@interface CircleMemberDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic , strong) NSMutableArray *dataArray;

@end

@implementation CircleMemberDetailViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        NSString *userName = [NSString getNotNullValue:_routerUserModel.NickName];
        if (_routerUserModel.Active == 1 && ![userName isEqualToString:@"tempUser"]) {
            _dataArray = [NSMutableArray arrayWithArray:@[@[@"Profile Photo",@"Name"],@[@"Joining time"],@[@"Remove"]]];
        } else {
            _dataArray = [NSMutableArray arrayWithArray:@[@[@"Profile Photo",@"Name"],@[@"Joining time"]]];
        }
    }
    return _dataArray;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableV registerNib:[UINib nibWithNibName:MyCellReuse bundle:nil] forCellReuseIdentifier:MyCellReuse];
    [_tableV registerNib:[UINib nibWithNibName:LogOutCellReuse bundle:nil] forCellReuseIdentifier:LogOutCellReuse];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delUserSuccessNoti:) name:DEL_USER_SUCCESS_NOTI object:nil];
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray[section] count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MyCellReuse_Height;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *resultStr = self.dataArray[indexPath.section][indexPath.row];
    if ([resultStr isEqualToString:@"Remove"]) {
        LogOutCell *cell = [tableView dequeueReusableCellWithIdentifier:LogOutCellReuse];
        cell.btnContraintV.constant = 0;
        [cell.logoutBtn setTitle:self.dataArray[indexPath.section][indexPath.row] forState:UIControlStateNormal];
        @weakify_self
        cell.logOutB = ^{
            [weakSelf delCircleUser];
        };
        return cell;
    } else {
        MyCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCellReuse];
        cell.iconleftV.constant = 0;
        cell.iconWidth.constant = 0;
        cell.rightContraintV.constant = 0;
        cell.rightContraintW.constant = 0;
        cell.subContentContraintV.constant = 0;
        cell.lblSubContent.hidden = YES;
        cell.subBtn.hidden = NO;
        cell.lblContent.text = self.dataArray[indexPath.section][indexPath.row];
        if ([resultStr isEqualToString:@"Profile Photo"]) {
            UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:_routerUserModel.UserKey?:@"" Name:[StringUtil getUserNameFirstWithName:_routerUserModel.NickName?:@""]];
            [cell.subBtn setImage:defaultImg forState:UIControlStateNormal];
            
        } else {
            cell.lblSubContent.hidden = NO;
            if (indexPath.section == 0) {
                 cell.lblSubContent.text = _routerUserModel.NickName;
            } else {
                NSString *operationTime = [NSDate getTimeWithTimestamp:[NSString stringWithFormat:@"%@",@(_routerUserModel.CreateTime)] format:@"yyyy-MM-dd HH:mm:ss" isMil:NO];
                cell.lblSubContent.text = operationTime?:@"";
            }
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
        
- (void) delCircleUser
{
    [SendRequestUtil sendDelUserWithFromTid:[UserConfig getShareObject].userId toTid:_routerUserModel.UserId sn:_routerUserModel.UserSN showHud:YES];
}

#pragma mark --noti
- (void) delUserSuccessNoti:(NSNotification *) noti
{
    [self backAction:nil];
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
