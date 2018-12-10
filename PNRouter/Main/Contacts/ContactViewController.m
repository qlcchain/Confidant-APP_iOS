//
//  ContactViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ContactViewController.h"
#import "ContactsCell.h"
#import "GroupCell.h"
#import "ContactsHeadView.h"
#import "FriendDetailViewController.h"
#import "UserModel.h"
#import "SocketMessageUtil.h"
#import "QRViewController.h"
#import "FriendModel.h"
#import "AddFriendViewController.h"
#import "RSAModel.h"
#import "ChatListDataUtil.h"
#import "NSString+Base64.h"


@interface ContactViewController ()<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) NSArray *groupArray;
@property (nonatomic) NSInteger deleteIndex;

@end

@implementation ContactViewController

#pragma mark - Observe
- (void)observe {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendListChangeNoti:) name:FRIEND_LIST_CHANGE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendGetFriendNoti) name:FRIEND_DELETE_MY_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFriendListNoti:) name:GET_FRIEND_LIST_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestAddFriendNoti:) name:REQEUST_ADD_FRIEND_NOTI object:nil];
}

- (IBAction)rightQRAction:(id)sender {
    @weakify_self
    QRViewController *vc = [[QRViewController alloc] initWithCodeQRCompleteBlock:^(NSString *codeValue) {
        if (codeValue != nil && codeValue.length > 0) {
            if ([codeValue isEqualToString:[UserModel getUserModel].userId]) {
                [AppD.window showHint:@"You cannot add yourself as a friend."];
            } else {
                [weakSelf addFriendRequest:codeValue];
            }
        }
    }];
    [self presentModalVC:vc animated:YES];
}

#pragma mark -layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (NSArray *)groupArray
{
    if (!_groupArray) {
        _groupArray = @[@"Add Contact",@"Create a Group Chat"];
    }
    return _groupArray;
}
#pragma textfeild delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn");
    return YES;
}

#pragma mark - Cycle Life
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
  // NSString *destr = [RSAUtil privateKeyDecryptValue:@"tcsjsh7tFBKt+dYHbGqWmxx+K+3Sd/Sw5ANEccQ4gQak8psGaZFAxD8qir7uoBlFP3Z/XmIWXFQk+aGvqwWYLa3/ADokXUQnUotAnpMm+KDCoaLRvACSTkA7JcjOsUEbd8RD2EFpNTihoqucbXZb0jt3PTZ3M03kyxpmHWIF5rU="];
    
    [self observe];
    _searchBackView.layer.cornerRadius = 3.0f;
    _searchBackView.layer.masksToBounds = YES;
    _searchTF.delegate = self;
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableV registerNib:[UINib nibWithNibName:GroupCellReuse bundle:nil] forCellReuseIdentifier:GroupCellReuse];
     [_tableV registerNib:[UINib nibWithNibName:ContactsCellReuse bundle:nil] forCellReuseIdentifier:ContactsCellReuse];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self sendGetFriendNoti];
  
}

- (void) sendGetFriendNoti
{
    [SocketMessageUtil sendFriendListRequest];
}

#pragma mark -Operation-
- (void)addFriendRequest:(NSString *)friendId {
    [SendRequestUtil sendAddFriendWithFriendId:friendId];
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return GroupCellHeight;
    }
    return ContactsCellHeight;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 64;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    backView.backgroundColor = [UIColor clearColor];
    ContactsHeadView *view = [ContactsHeadView loadContactsHeadView];
    view.frame = backView.bounds;
    [backView addSubview:view];
    return backView;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupCellReuse];
        cell.lblName.text = self.groupArray[indexPath.row];
        cell.hdBackView.hidden = YES;
        if (indexPath.row == 0) {
            if (AppD.showHD) {
                cell.hdBackView.hidden = NO;
            }
        }
        return cell;
    }
    ContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactsCellReuse];
    FriendModel *model = self.dataArray[indexPath.row];
    [cell setModeWithModel:model];
    cell.tag = indexPath.row;
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:65.f];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (indexPath.section == 1) {
            FriendModel *model = self.dataArray[indexPath.row];
            FriendDetailViewController *vc = [[FriendDetailViewController alloc] init];
            model.username = [model.username base64DecodedString]?:model.username;
            vc.friendModel = model;
            [self.navigationController pushViewController:vc animated:YES];
        } else if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                if (AppD.showHD) {
                    AppD.showHD = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_CONTACT_HD_NOTI object:nil];
                    [_tableV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                }
                AddFriendViewController *vc = [[AddFriendViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            } else if (indexPath.row == 1 ){
               
            }
        }
    }
    
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            break;
        case 1:
            NSLog(@"left utility buttons open");
            break;
        case 2:
            NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}


- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [cell hideUtilityButtonsAnimated:YES];
    NSInteger friendIndex = [_tableV indexPathForCell:cell].row;
    FriendModel *model = self.dataArray[friendIndex];
    switch (index) {
        case 0:
        {
            NSLog(@"--------%ld",cell.tag);
            NSLog(@"More button was pressed  1");
           
            break;
        }
        case 1:
        {
             NSLog(@"More button was pressed  2");
            break;
        }

        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     MAIN_PURPLE_COLOR
                                                icon:[UIImage imageNamed:@"icon_forward"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     MAIN_PURPLE_COLOR
                                                icon:[UIImage imageNamed:@"icon_writing"]];
    
    return rightUtilityButtons;
}

#pragma mark - NOTI
- (void) friendListChangeNoti:(NSNotification *)noti {
    [self sendGetFriendNoti];
}
// 有人请求加你为好友的红点通知
- (void) requestAddFriendNoti:(NSNotification *) noti
{
    if (![[self.navigationController.viewControllers lastObject] isKindOfClass:[AddFriendViewController class]]) {
        [_tableV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        // 通知tabbar 红点显示通知
    } else {
        AppD.showHD = NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_CONTACT_HD_NOTI object:nil];
    
}
- (void) getFriendListNoti:(NSNotification *) noti {
    
    NSString *jsonModel =(NSString *)noti.object;
    NSArray *modelArr = [jsonModel mj_JSONObject];
    if (self.dataArray.count > 0) {
        [self.dataArray removeAllObjects];
    }
    if (modelArr) {
       [self.dataArray addObjectsFromArray:[FriendModel mj_objectArrayWithKeyValuesArray:modelArr]];
    }
    
    if ([ChatListDataUtil getShareObject].friendArray.count>0) {
        [[ChatListDataUtil getShareObject].friendArray removeAllObjects];
    }
    [[ChatListDataUtil getShareObject].friendArray addObjectsFromArray:[FriendModel mj_objectArrayWithKeyValuesArray:modelArr]];
    
    [_tableV reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];

//    NSArray *finfAlls = [FriendModel bg_findAll:FRIEND_LIST_TABNAME];
//    if (self.dataArray.count > 0) {
//        [self.dataArray removeAllObjects];
//    }
//    if (finfAlls && finfAlls.count > 0) {
//        [self.dataArray addObjectsFromArray:finfAlls];
//    }
//    [_tableV reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -UITableViewDatasource

@end
