//
//  NewsViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsCell.h"
#import "ChatViewController.h"
#import "KeyCUtil.h"
#import "UserModel.h"
#import "FriendModel.h"
#import "SocketMessageUtil.h"
#import "QRViewController.h"
#import "ChatListModel.h"
#import "ChatListDataUtil.h"
#import "PNRouter-Swift.h"
#import "SystemUtil.h"
#import "SocketCountUtil.h"
#import "NSString+Base64.h"

@interface NewsViewController ()<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UIView *connectBackView;
@property (weak, nonatomic) IBOutlet UIButton *switchRoutherBtn;
@property (weak, nonatomic) IBOutlet UIButton *reloadBtn;
@end

@implementation NewsViewController
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)switchRouther:(id)sender {
}
- (IBAction)reload:(id)sender {
    
    _connectBackView.hidden = YES;
    [SocketCountUtil getShareObject].reConnectCount = 0;
    [AppD.window showHudInView:AppD.window hint:@"connection..."];
    NSString *connectURL = [SystemUtil connectUrl];
    [SocketUtil.shareInstance connectWithUrl:connectURL];
//    [UIView animateWithDuration:0.3 animations:^{
//        self->_connectBackView.alpha = 0.0f;
//    } completion:^(BOOL finished) {
//
//    }];
}

- (IBAction)rightAction:(id)sender {
    
    @weakify_self
    QRViewController *vc = [[QRViewController alloc] initWithCodeQRCompleteBlock:^(NSString *codeValue) {
        if (codeValue != nil && codeValue.length > 0) {
            if ([codeValue isEqualToString:[UserModel getUserModel].userId]) {
                [AppD.window showHint:@"You cannot add yourself as a friend."];
            } else if (codeValue.length != 76) {
                [AppD.window showHint:@"The two-dimensional code format is wrong."];
            } else if ([SystemUtil isFriendWithFriendid:codeValue]) {
                [AppD.window showHint:@"The other person is already your best friend."];
            } else {
                [weakSelf addFriendRequest:codeValue];
            }
        }
    }];
     [self presentModalVC:vc animated:YES];
}
#pragma mark -Operation-
- (void)addFriendRequest:(NSString *)friendId {
    [SendRequestUtil sendAddFriendWithFriendId:friendId];
}

#pragma mark -layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
#pragma textfeild delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn");
    return YES;
}
- (void) addNoti
{
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatMessageChangeNoti:) name:ADD_MESSAGE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSecketFaieldNoti:) name:RELOAD_SOCKET_FAILD_NOTI object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _searchBackView.layer.cornerRadius = 3.0f;
    _searchBackView.layer.masksToBounds = YES;
    _switchRoutherBtn.layer.cornerRadius = 5.0f;
    _reloadBtn.layer.cornerRadius = 5.0f;
    _searchTF.delegate = self;
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableV registerNib:[UINib nibWithNibName:NewsCellResue bundle:nil] forCellReuseIdentifier:NewsCellResue];
    
   
    NSLog(@"userid = %@",[UserModel getUserModel].userId);
    [self chatMessageChangeNoti:nil];
    [self showSocketStatu];
    [self addNoti];
}
- (void) showSocketStatu
{
    if (![SystemUtil isSocketConnect]) {
        _connectBackView.hidden = YES;
    } else {
        NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
        if (connectStatu == socketConnectStatusConnected) {
            _connectBackView.hidden = YES;
        }
    }
}

#pragma mark - tableviewDataSourceDelegate

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NewsCellHeight;
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:NewsCellResue];
    ChatListModel *model = self.dataArray[indexPath.row];
    [cell setModeWithChatListModel:model];
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:65.f];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        FriendModel *model = [[FriendModel alloc] init];
        ChatListModel *chatModel = self.dataArray[indexPath.row];
        model.userId = chatModel.friendID;
        model.username = chatModel.friendName;
        model.publicKey = chatModel.publicKey;
        
        if (chatModel.isHD) {
            chatModel.isHD = NO;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_CHATS_HD_NOTI object:nil];
        }
        
        ChatViewController *vc = [[ChatViewController alloc] initWihtFriendMode:model];
        [self.navigationController pushViewController:vc animated:YES];
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
    switch (index) {
        case 0:
        {
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
                                                 icon:[UIImage imageNamed:@"icon_up"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     MAIN_PURPLE_COLOR
                                                 icon:[UIImage imageNamed:@"icon_delete"]];
    
    return rightUtilityButtons;
}

#pragma mark - noti
- (void) chatMessageChangeNoti:(NSNotification *) noti
{
    if (self.dataArray.count >0) {
        [self.dataArray removeAllObjects];
    }
    [self.dataArray addObjectsFromArray:[ChatListDataUtil getShareObject].dataArray];
    if ([ChatListDataUtil getShareObject].dataArray) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_CHATS_HD_NOTI object:nil];
    }
    [_tableV reloadData];
}
- (void) reloadSecketFaieldNoti:(NSNotification *) noti
{
    NSString *result = noti.object;
    if ([result integerValue] == 0) {
        _connectBackView.hidden = NO;
    } else {
        _connectBackView.hidden = YES;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
