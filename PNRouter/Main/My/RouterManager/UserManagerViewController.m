//
//  UserManagerViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/23.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "UserManagerViewController.h"
#import "SendRequestUtil.h"
#import "GroupCell.h"
#import "RouterUserModel.h"
#import "ContactsHeadView.h"
#import "NSString+Base64.h"
#import "ContactsCell.h"
#import "CreateRouterUserViewController.h"
#import "RouterUserCodeViewController.h"
#import "RouterModel.h"

@interface UserManagerViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger userCount;
    NSInteger tempCount;
}
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) NSString *rid;

@end

@implementation UserManagerViewController
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithRid:(NSString *)rid
{
    if (self = [super init]) {
        self.rid = rid;
    }
    return self;
}

- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
#pragma mark - layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
#pragma add observer
- (void) addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reverPullUserList:) name:USER_PULL_SUCCESS_NOTI object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _searchBackView.layer.cornerRadius = 3.0f;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.delegate = self;
    _tableV.dataSource = self;
    [_tableV registerNib:[UINib nibWithNibName:GroupCellReuse bundle:nil] forCellReuseIdentifier:GroupCellReuse];
    [_tableV registerNib:[UINib nibWithNibName:ContactsCellReuse bundle:nil] forCellReuseIdentifier:ContactsCellReuse];
    //[self.dataArray addObject:@[@"Create user accounts",@"Create temporary accounts"]];
    [self.dataArray addObject:@[@"Create user accounts"]];
    [self addObserver];
    // 拉取用户
    [SendRequestUtil sendPullUserList];
}

#pragma mark -UITableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray[section] count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    if ([self.dataArray[section] count] == 0) {
        return nil;
    }
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 48)];
    backView.backgroundColor = [UIColor clearColor];
    ContactsHeadView *view = [ContactsHeadView loadContactsHeadView];
    view.topContraintH.constant = 0;
    if (section == 1) {
        view.lblTitle.text = [@"User" stringByAppendingString:[NSString stringWithFormat:@" (%zd/%zd)",userCount,[self.dataArray[section] count]]];
    } else {
        view.lblTitle.text = [@"Temporoay" stringByAppendingString:[NSString stringWithFormat:@" (%zd/%zd)",tempCount,[self.dataArray[section] count]]];
    }
    view.frame = backView.bounds;
    [backView addSubview:view];
    return backView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return GroupCellHeight;
    }
    return ContactsCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 16;
    }
    if (section == 1) {
        if ([self.dataArray[2] count] > 0) {
            return 16;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0 || [self.dataArray[section] count] == 0) {
        return 0;
    }
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        GroupCell *myCell = [tableView dequeueReusableCellWithIdentifier:GroupCellReuse];
        myCell.lblName.text = self.dataArray[indexPath.section][indexPath.row];
        return myCell;
    }
    ContactsCell *myCell = [tableView dequeueReusableCellWithIdentifier:ContactsCellReuse];
    RouterUserModel *model = self.dataArray[indexPath.section][indexPath.row];
    [myCell setModeWithRoutherUserModel:model];
    return myCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        CreateRouterUserViewController *vc = [[CreateRouterUserViewController alloc] initWithRid:self.rid];
        vc.userType = indexPath.row;
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        if (indexPath.section == 1) {
            RouterUserModel *model = self.dataArray[indexPath.section][indexPath.row];
            RouterUserCodeViewController *vc = [[RouterUserCodeViewController alloc] init];
            vc.routerUserModel = model;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Temporary accounts" message:@"fixed two-dimensional code sharing out, users scan the two-dimensional code can automatically generate a temporary account, login, temporary account does not support recovery, default to a router to support up to 20 temporary accounts." preferredStyle:UIAlertControllerStyleAlert];
            
            @weakify_self
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                RouterUserModel *model = weakSelf.dataArray[indexPath.section][indexPath.row];
                RouterUserCodeViewController *vc = [[RouterUserCodeViewController alloc] init];
                vc.routerUserModel = model;
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }];
            UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alertVC addAction:okAction];
            [alertVC addAction:alertCancel];
            [self presentViewController:alertVC animated:YES completion:nil];
        }
        
    }
}

#pragma mark - noti
- (void) reverPullUserList:(NSNotification *) noti
{
    NSArray *playod = noti.object;
    if (!playod || playod.count == 0) {
        [self.view showHint:@"The list of users is empty."];
    } else {
       // __block NSMutableArray *supperArray = [NSMutableArray array];
         __block NSMutableArray *ptArray = [NSMutableArray array];
         __block NSMutableArray *tempArray = [NSMutableArray array];
        [playod enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            RouterUserModel *model = obj;
            model.NickName = [model.NickName base64DecodedString]?:[model.Mnemonic base64DecodedString];
            // 1 派生类。2 普通类 3 临时类
            /* if (model.UserType == 1) {
             [supperArray addObject:model];
             } else*/
            if (model.UserType == 2) {
                if (model.Active == 1) {
                    self->userCount ++;
                }
                [ptArray addObject:model];
            } else if (model.UserType == 3){
                if (model.Active == 1) {
                    self->tempCount ++;
                }
                [tempArray addObject:model];
            }
        }];
       // [self.dataArray addObject:supperArray];
        [self.dataArray addObject:ptArray];
        [self.dataArray addObject:tempArray];
        
        [_tableV reloadData];
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
