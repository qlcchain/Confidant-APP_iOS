//
//  FriendDetailViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "FriendDetailViewController.h"
#import "GroupCell.h"
#import "UserInfoCell.h"
#import "MyHeadView.h"
#import "BottonCell.h"
//#import "MyDetailViewController.h"
#import "UserModel.h"
#import "SocketMessageUtil.h"
#import "FriendModel.h"
#import "ChatViewController.h"
#import "ChatListDataUtil.h"
#import "ChatListModel.h"
#import "PersonCodeViewController.h"
#import "EditTextViewController.h"
#import "UserConfig.h"
#import "SystemUtil.h"
#import "ChatModel.h"

@interface FriendDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic ,strong) MyHeadView *myHeadView;
@end

@implementation FriendDetailViewController

#pragma mark - Observe
- (void)observe {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteFriendSuccess:) name:SOCKET_DELETE_FRIEND_SUCCESS_NOTI object:nil];
}

- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}

#pragma mark -layz
- (MyHeadView *)myHeadView
{
    if (!_myHeadView) {
        _myHeadView = [MyHeadView loadMyHeadView];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpDetailvc)];
        
        _myHeadView.lblName.text = self.friendModel.remarks;
        [_myHeadView setUserNameFirstWithName:[StringUtil getUserNameFirstWithName:self.friendModel.username]];
        
        _myHeadView.userInteractionEnabled = YES;
        [_myHeadView addGestureRecognizer:gesture];
    }
    return _myHeadView;
}

#pragma mark -jumpVC
- (void) jumpDetailvc {
   // MyDetailViewController *vc = [[MyDetailViewController alloc] init];
   // [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self observe];
    _lblNavTitle.text = self.friendModel.username;
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIView *headBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 135)];
    [headBackView addSubview:self.myHeadView];
    _tableV.tableHeaderView = headBackView;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableV registerNib:[UINib nibWithNibName:GroupCellReuse bundle:nil] forCellReuseIdentifier:GroupCellReuse];
    [_tableV registerNib:[UINib nibWithNibName:UserInfoCellReuse bundle:nil] forCellReuseIdentifier:UserInfoCellReuse];
    [_tableV registerNib:[UINib nibWithNibName:BottonCellResue bundle:nil] forCellReuseIdentifier:BottonCellResue];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    _lblNavTitle.text = self.friendModel.username;
    [_tableV reloadData];
    [super viewDidAppear:animated];
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    } else if (section == 1) {
        return 0;
    } else {
        return 1;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2) {
        return BottonCellHeight;
    }
    return GroupCellHeight;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 16;
}
-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 16)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    return headerView;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
   
    if (indexPath.section == 0) {
         GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupCellReuse];
        if (indexPath.row == 0) {
            cell.lblName.text = @"Add Nickname";
            cell.detailText.hidden = NO;
            cell.detailText.text = self.friendModel.username;
        } else {
            cell.lblName.text = @"Share Contact";
            cell.detailText.hidden = YES;
            cell.detailText.text = @"";
        }
        return cell;
    } else if (indexPath.section == 1) {
         UserInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:UserInfoCellReuse];
        if (indexPath.row == 0) {
            cell.lblName.text = @"Company";
        } else if (indexPath.row == 1) {
            cell.lblName.text = @"Position";
        } else {
            cell.lblName.text = @"Location";
        }
        return cell;
    } else {
        BottonCell *cell = [tableView dequeueReusableCellWithIdentifier:BottonCellResue];
        @weakify_self
        cell.deleteContactB = ^{
            [weakSelf deleteFriendRequest];
        };
        cell.sendMessageB = ^{
            [weakSelf jumpToChat];
        };
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 1) { // share code
            PersonCodeViewController *vc = [[PersonCodeViewController alloc] initWithUserId:self.friendModel.userId userNaem:self.friendModel.username signPK:self.friendModel.signPublicKey];
            [self.navigationController pushViewController:vc animated:YES];
        } else { // nickname
            EditTextViewController *vc = [[EditTextViewController alloc] initWithType:EditFriendAlis friendModel:self.friendModel];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - Operation
- (void)deleteFriendRequest {
    UserModel *userM = [UserModel getUserModel];
    NSDictionary *params = @{@"Action":@"DelFriendCmd",@"UserId":userM.userId?:@"",@"FriendId":_friendModel.userId?:@""};
    [self.view showHudInView:self.view hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
    [SocketMessageUtil sendVersion1WithParams:params];
}

#pragma mark - Transition
- (void)jumpToChat {
    ChatViewController *vc = [[ChatViewController alloc] initWihtFriendMode:self.friendModel];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - NOTI
- (void)deleteFriendSuccess:(NSNotification *)noti {
    [self.view hideHud];
    // 删除本地聊天列表
    [[ChatListDataUtil getShareObject] removeChatModelWithFriendID:_friendModel.userId];
    // 删除好友请求表
    [FriendModel bg_delete:FRIEND_REQUEST_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue(_friendModel.userId?:@""),bg_sqlKey(@"owerId"),bg_sqlValue([UserConfig getShareObject].userId?:@"")]];
    // 删除好友表
    [FriendModel bg_delete:FRIEND_LIST_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"userId"),bg_sqlValue(_friendModel.userId?:@"")]];
    // 删除聊天文件
    NSString *filePath = [SystemUtil getBaseFilePath:_friendModel.userId];
    // 删除未发送消息表
     [ChatModel bg_delete:CHAT_CACHE_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"fromId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"toId"),bg_sqlValue(_friendModel.userId)]];
    [SystemUtil removeDocmentFilePath:filePath];
    
    // 删除本地聊天记录
    //[ChatListModel bg_delete:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"friendID"),bg_sqlValue(_friendModel.userId?:@"")]];
    // 发送更新chatlist列表通知
   // [[NSNotificationCenter defaultCenter] postNotificationName:ADD_MESSAGE_NOTI object:nil];
    [self backAction:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
