//
//  GroupChatsViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "GroupChatsViewController.h"
#import "AddGroupMenuViewController.h"
#import "GroupInfoModel.h"
#import <MJRefresh/MJRefresh.h>
#import <MJRefresh/MJRefreshStateHeader.h>
#import <MJRefresh/MJRefreshHeader.h>
#import "GroupListCell.h"
#import "NSString+Base64.h"
#import "ChatListDataUtil.h"
#import "RoutherConfig.h"
#import "FriendModel.h"
#import "AddGroupMemberViewController.h"
#import "GroupChatViewController.h"

@interface GroupChatsViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    BOOL isSearch;
}
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (weak, nonatomic) IBOutlet UITableView *mainTab;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) NSMutableArray *searchDataArray;

@end

@implementation GroupChatsViewController
#pragma -mark Action
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)rightAction:(id)sender {
    
    NSArray *tempArr = [ChatListDataUtil getShareObject].friendArray;
    // 过滤非当前路由的好友
    NSString *currentToxid = [RoutherConfig getRoutherConfig].currentRouterToxid;
    NSMutableArray *inputArr = [NSMutableArray array];
    [tempArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        if ([model.RouteId isEqualToString:currentToxid]) {
            [inputArr addObject:model];
        }
    }];
    AddGroupMemberViewController *vc = [[AddGroupMemberViewController alloc] initWithMemberArr:inputArr type:AddGroupMemberTypeToCreate];
    [self presentModalVC:vc animated:YES];
}
#pragma -mark layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (NSMutableArray *)searchDataArray
{
    if (!_searchDataArray) {
        _searchDataArray = [NSMutableArray array];
    }
    return _searchDataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchBackView.layer.cornerRadius = 3.0f;
    _searchBackView.layer.masksToBounds = YES;
    _searchTF.delegate = self;
    _searchTF.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    _searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addTargetMethod];
    
    _mainTab.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _mainTab.delegate = self;
    _mainTab.dataSource = self;
    [_mainTab registerNib:[UINib nibWithNibName:GroupListCellReuse bundle:nil] forCellReuseIdentifier:GroupListCellReuse];
    _mainTab.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullGroupList)];
    // Hide the time
    ((MJRefreshStateHeader *)_mainTab.mj_header).lastUpdatedTimeLabel.hidden = YES;
    // Hide the status
    ((MJRefreshStateHeader *)_mainTab.mj_header).stateLabel.hidden = YES;
    [_mainTab.mj_header beginRefreshing];
    
    [self addNoti];
}
#pragma mark --添加通知
- (void) addNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullGroupSucess:) name:PULL_GROUP_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpGroupChatNoti:) name:CREATE_GROUP_SUCCESS_JUMP_NOTI object:nil];
}
#pragma mark - 拉取群组
- (void) pullGroupList
{
    [SendRequestUtil sendPullGroupListWithShowHud:NO];
}

#pragma mark - tableviewDataSourceDelegate

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return isSearch?self.searchDataArray.count : self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return GroupListCellHeight;
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    GroupListCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupListCellReuse];
    GroupInfoModel *model = isSearch? self.searchDataArray[indexPath.row] : self.dataArray[indexPath.row];
    [cell setModeWithGroupModel:model];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GroupInfoModel *model = isSearch? self.searchDataArray[indexPath.row] : self.dataArray[indexPath.row];
    GroupChatViewController *vc = [[GroupChatViewController alloc] initWihtGroupMode:model];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 直接添加监听方法
-(void)addTargetMethod{
    [_searchTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
}
- (void) textFieldTextChange:(UITextField *) tf
{
    if ([tf.text.trim isEmptyString]) {
        isSearch = NO;
    } else {
        isSearch = YES;
        [self.searchDataArray removeAllObjects];
        @weakify_self
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GroupInfoModel *model = obj;
            NSString *gname = model.GName? [model.GName base64DecodedString]:@"";
            NSString *userName = [gname lowercaseString];
            if ([userName containsString:[tf.text.trim lowercaseString]]) {
                [weakSelf.searchDataArray addObject:model];
            }
        }];
    }
    [_mainTab reloadData];
}

#pragma mark --通知回调
- (void) pullGroupSucess:(NSNotification *) noti
{
    [_mainTab.mj_header endRefreshing];
    NSArray *groups = noti.object;
    if (self.dataArray.count > 0) {
        [self.dataArray removeAllObjects];
    }
    [self.dataArray addObjectsFromArray:groups];
    [_mainTab reloadData];
}

- (void) jumpGroupChatNoti:(NSNotification *) noti
{
    [self pullGroupList];
    GroupInfoModel *model = noti.object;
    GroupChatViewController *vc = [[GroupChatViewController alloc] initWihtGroupMode:model];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma textfeild delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    NSLog(@"textFieldShouldReturn");
    return YES;
}

@end
