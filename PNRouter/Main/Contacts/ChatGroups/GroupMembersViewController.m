//
//  ChooseContactViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/21.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "GroupMembersViewController.h"
#import "ChooseDownView.h"
#import "ChatListDataUtil.h"
#import "ChooseContactShowModel.h"
#import "NSString+Base64.h"
#import "ChooseContactTableCell.h"
#import "GroupMembersHeaderView.h"
#import "FriendModel.h"
#import "GroupMembersModel.h"
#import "RouterConfig.h"
#import "AddGroupMemberViewController.h"
#import "GroupInfoModel.h"
#import "FriendDetailViewController.h"
#import "UserModel.h"

@interface GroupMembersViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (weak, nonatomic) IBOutlet UIButton *addBtn;

@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) NSMutableArray *searchDataArray;

@property (nonatomic) BOOL isSearch;

@end

@implementation GroupMembersViewController

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupUserPullSuccessNoti:) name:GroupUserPull_SUCCESS_NOTI object:nil];
}

#pragma mark - Life Cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObserve];
    
    if (_optionType == RemindType) {
        _addBtn.hidden = YES;
    }
    
    _searchBackView.layer.cornerRadius = 3.0f;
    _searchBackView.layer.masksToBounds = YES;
    
    _searchTF.delegate = self;
    _searchTF.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    _searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addTargetMethod];
    
    _dataArray = [NSMutableArray array];
    
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableV registerNib:[UINib nibWithNibName:ChooseContactTableCellResue bundle:nil] forCellReuseIdentifier:ChooseContactTableCellResue];
    [_tableV registerNib:[UINib nibWithNibName:GroupMembersHeaderViewReuse bundle:nil] forHeaderFooterViewReuseIdentifier:GroupMembersHeaderViewReuse];
    
    [self sendGroupUserPull];
}

#pragma mark - Request
- (void)sendGroupUserPull {
    [SendRequestUtil sendGroupUserPullWithGId:_groupInfoM.GId?:@"" TargetNum:@(0) StartId:@"0" showHud:YES];
}

#pragma mark - Action
- (IBAction)backAction:(id)sender {
    if (_optionType == CheckType) {
        [self leftNavBarItemPressedWithPop:YES];
    } else {
         [[NSNotificationCenter defaultCenter] postNotificationName:REMIND_USER_SUCCESS_NOTI object:nil];
        [self leftNavBarItemPressedWithPop:NO];
    }
    
}

- (IBAction)addAction:(id)sender {
    [self jumpToAddGroupMember];
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return _isSearch? self.searchDataArray.count : self.dataArray.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    NSArray *arr = _isSearch? self.searchDataArray : self.dataArray;
//    ChooseContactShowModel *model = arr[section];
//    if (model.showCell) {
//        return model.routerArr.count;
//    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ChooseContactTableCellHeight;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return GroupMembersHeaderViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    GroupMembersHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:GroupMembersHeaderViewReuse];
    
    NSArray *arr = _isSearch? self.searchDataArray : self.dataArray;
    GroupMembersModel *model = arr[section];
    [view configHeaderWithModel:model];
    
    @weakify_self
    [view setClickBlock:^(GroupMembersModel * _Nonnull model) {
        // 选中@用户
        if (weakSelf.optionType == RemindType) {
            [[NSNotificationCenter defaultCenter] postNotificationName:REMIND_USER_SUCCESS_NOTI object:model];
            [weakSelf leftNavBarItemPressedWithPop:NO];
        } else {
            if (![model.ToxId isEqualToString:[UserModel getUserModel].userId]) {
                FriendModel *fModel = [[ChatListDataUtil getShareObject] getFriendWithUserid:model.ToxId];
                FriendModel *friendModel = [[FriendModel alloc] init];
                if (!fModel) {
                    friendModel.userId = model.ToxId;
                    friendModel.username = [model.Nickname base64DecodedString];
                    friendModel.signPublicKey = model.UserKey;
                    friendModel.noFriend = YES;
                } else {
                    friendModel.userId = fModel.userId;
                    friendModel.username = [fModel.username base64DecodedString]?:fModel.username;
                    friendModel.publicKey = fModel.publicKey;
                    friendModel.remarks = [fModel.remarks base64DecodedString]?:fModel.remarks;
                    friendModel.Index = fModel.Index;
                    friendModel.onLineStatu = fModel.onLineStatu;
                    friendModel.signPublicKey = fModel.signPublicKey;
                    friendModel.RouteId = fModel.RouteId;
                    friendModel.RouteName = fModel.RouteName;
                    friendModel.signPublicKey = fModel.publicKey;
                    
                }
                [weakSelf jumpFriendDetailVC:friendModel];
            }
        }
    }];
    
    return view;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ChooseContactTableCell *cell = [tableView dequeueReusableCellWithIdentifier:ChooseContactTableCellResue];
    
//    ChooseContactShowModel *model = _isSearch? self.searchDataArray[indexPath.section] : self.dataArray[indexPath.section];
//    ChooseContactRouterModel *crModel = model.routerArr[indexPath.row];
//    [cell configCellWithModel:crModel];
//    cell.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}
#pragma mark ---jumpVC
- (void) jumpFriendDetailVC:(FriendModel *) model
{
    FriendDetailViewController *vc = [[FriendDetailViewController alloc] init];
    vc.friendModel = model;
    vc.isGroup = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma mark - UITextFeildDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    return YES;
}

#pragma mark - 直接添加监听方法
-(void)addTargetMethod{
    [_searchTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void) textFieldTextChange:(UITextField *) tf
{
    if ([tf.text.trim isEmptyString]) {
        _isSearch = NO;
    } else {
        _isSearch = YES;
        [self.searchDataArray removeAllObjects];
        @weakify_self
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GroupMembersModel *model = obj;
            NSString *userName = [[model.showName base64DecodedString] lowercaseString];
            if ([userName containsString:[tf.text.trim lowercaseString]]) {
                [weakSelf.searchDataArray addObject:model];
            }
        }];
    }
    [_tableV reloadData];
}

#pragma mark - Transition
- (void)jumpToAddGroupMember {
    NSArray *tempArr = [ChatListDataUtil getShareObject].friendArray;
    // 过滤非当前路由的好友
    NSString *currentToxid = [RouterConfig getRouterConfig].currentRouterToxid;
    NSMutableArray *inputArr = [NSMutableArray array];
    [tempArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        if ([model.RouteId isEqualToString:currentToxid]) {
            [inputArr addObject:model];
        }
    }];
    NSMutableArray *originArr = [NSMutableArray array];
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GroupMembersModel *groupMembersM = obj;
        FriendModel *friendM = [FriendModel new];
        friendM.userId = [NSString stringWithFormat:@"%@",groupMembersM.Id];
        friendM.RouteId = groupMembersM.ToxId;
        friendM.username = groupMembersM.Nickname;
        friendM.signPublicKey = groupMembersM.UserKey;
        [originArr addObject:friendM];
    }];
    AddGroupMemberViewController *vc = [[AddGroupMemberViewController alloc] initWithMemberArr:inputArr originArr:originArr type:AddGroupMemberTypeInGroupDetail];
    vc.groupInfoM = _groupInfoM;
    @weakify_self
    vc.addCompleteB = ^(NSArray *addArr) {
        [weakSelf sendGroupUserPull];
    };
    [self presentModalVC:vc animated:YES];
}

#pragma mark - Noti
- (void)groupUserPullSuccessNoti:(NSNotification *)noti {
    NSArray *arr = noti.object;
    arr = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        GroupMembersModel *model1 = obj1;
        GroupMembersModel *model2 = obj2;
        return [model1.Type compare:model2.Type];
    }];
    [_dataArray removeAllObjects];
    [_dataArray addObjectsFromArray:arr];
    [_tableV reloadData];
}

#pragma mark - Lazy
- (NSMutableArray *)searchDataArray
{
    if (!_searchDataArray) {
        _searchDataArray = [NSMutableArray array];
    }
    return _searchDataArray;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
