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
#import "MD5Util.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "UserHeadUtil.h"
#import "UserHeaderModel.h"
#import "FriendRequestViewController.h"

@interface FriendDetailViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic ,strong) MyHeadView *myHeadView;
@end

@implementation FriendDetailViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Observe
- (void)observe {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteFriendSuccess:) name:SOCKET_DELETE_FRIEND_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userHeadDownloadSuccess:) name:USER_HEAD_DOWN_SUCCESS_NOTI object:nil];
}

- (IBAction)backAction:(id)sender {
    if (_isBack) {
        [self moveNavgationBackOneViewController];
    }
    [self leftNavBarItemPressedWithPop:YES];
}

#pragma mark -layz
- (MyHeadView *)myHeadView {
    if (!_myHeadView) {
        _myHeadView = [MyHeadView loadMyHeadView];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpDetailvc)];
        
        _myHeadView.lblName.text = self.friendModel.username;
        NSString *userKey = self.friendModel.signPublicKey;
        [_myHeadView setUserNameFirstWithName:[StringUtil getUserNameFirstWithName:self.friendModel.username] userKey:userKey];
        
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
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIView *headBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 96)];
    [headBackView addSubview:self.myHeadView];
    _tableV.tableHeaderView = headBackView;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableV registerNib:[UINib nibWithNibName:GroupCellReuse bundle:nil] forCellReuseIdentifier:GroupCellReuse];
    [_tableV registerNib:[UINib nibWithNibName:UserInfoCellReuse bundle:nil] forCellReuseIdentifier:UserInfoCellReuse];
    [_tableV registerNib:[UINib nibWithNibName:BottonCellResue bundle:nil] forCellReuseIdentifier:BottonCellResue];
    
    [self sendUpdateAvatar];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSString *nickName = self.friendModel.username;
    if (self.friendModel.remarks && self.friendModel.remarks.length > 0) {
        nickName = self.friendModel.remarks;
    }
    [_tableV reloadData];
    [super viewDidAppear:animated];
}

#pragma mark - Operation
- (void)sendUpdateAvatar {
    NSString *Fid = _friendModel.userId?:@"";
    NSString *Md5 = @"0";
    NSString *userHeaderImg64Str = [UserHeaderModel getUserHeaderImg64StrWithKey:_friendModel.signPublicKey];
    if (userHeaderImg64Str) {
        Md5 = [MD5Util md5WithData:[NSData dataWithBase64EncodedString:userHeaderImg64Str]];
    }
    [[UserHeadUtil getUserHeadUtilShare] sendUpdateAvatarWithFid:Fid md5:Md5 showHud:NO];
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
    if (indexPath.section == 0) {
        if (_friendModel.noFriend) {
            if (indexPath.row == 0) {
                return 0;
            }
        }
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
            cell.detailText.text = self.friendModel.remarks;
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
        cell.addFriendBtn.hidden = !_friendModel.noFriend;
        @weakify_self
        cell.deleteContactB = ^{
            [weakSelf deleteFriendRequest];
        };
        cell.sendMessageB = ^{
            [weakSelf jumpToChat];
        };
        cell.addFriendB = ^{
            [weakSelf jumpToAddFriend];
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
    if (_isBack) {
        [self leftNavBarItemPressedWithPop:YES];
    } else if (_isGroup) {
       
        ChatViewController *vc = [[ChatViewController alloc] initWihtFriendMode:self.friendModel];
        [self.navigationController pushViewController:vc animated:YES];
        [self moveAllNavgationViewController];
        
    } else {
        ChatViewController *vc = [[ChatViewController alloc] initWihtFriendMode:self.friendModel];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}
- (void) jumpToAddFriend
{
    FriendRequestViewController *vc = [[FriendRequestViewController alloc] initWithNickname:[_friendModel.username base64EncodedString] userId:_friendModel.userId signpk:_friendModel.signPublicKey toxId:@"" codeType:@"type_0"];
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
    NSString *timeFilePath = [SystemUtil getBaseFileTimePathWithToid:_friendModel.userId];
    [SystemUtil removeDocmentFilePath:filePath];
    [SystemUtil removeDocmentFilePath:timeFilePath];
    // 删除未发送消息表
     [ChatModel bg_delete:CHAT_CACHE_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"fromId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"toId"),bg_sqlValue(_friendModel.userId)]];
   
    
    // 先删除全局好友
    @weakify_self
    [[ChatListDataUtil getShareObject].friendArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        if ([model.userId isEqualToString:weakSelf.friendModel.userId]) {
            [[ChatListDataUtil getShareObject].friendArray removeObject:obj];
            *stop = YES;
        }
    }];
    // 删除好友头像数据库
    __block BOOL haveFriend = NO;
    // 查找是否有好友
    [[ChatListDataUtil getShareObject].friendArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        if ([model.signPublicKey isEqualToString:weakSelf.friendModel.signPublicKey]) {
            haveFriend = YES;
            *stop = YES;
        }
    }];
    if (!haveFriend) { // 没有此好友--调用删除
        [UserHeaderModel bg_delete:UserHeader_Table where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"UserKey"),bg_sqlValue(_friendModel.signPublicKey)]];
    }
    
    // 删除本地聊天记录
    //[ChatListModel bg_delete:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"friendID"),bg_sqlValue(_friendModel.userId?:@"")]];
    // 发送更新chatlist列表通知
   // [[NSNotificationCenter defaultCenter] postNotificationName:ADD_MESSAGE_NOTI object:nil];
    [self backAction:nil];
}

- (void)userHeadDownloadSuccess:(NSNotification *)noti {
    UserHeaderModel *model = noti.object;
    NSString *userKey = model.UserKey;
    [_myHeadView setUserNameFirstWithName:[StringUtil getUserNameFirstWithName:self.friendModel.username] userKey:userKey];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
