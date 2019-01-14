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
#import "UserConfig.h"
#import "FriendRequestViewController.h"

@interface NewsViewController ()<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate,UITextFieldDelegate>
{
    BOOL isSearch;
}
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) NSMutableArray *searchDataArray;
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
            
            NSArray *codeValues = [codeValue componentsSeparatedByString:@","];
            codeValue = codeValues[0];
            
            if ([codeValue isEqualToString:[UserConfig getShareObject].userId]) {
                [AppD.window showHint:@"You cannot add yourself as a friend."];
            } else if (codeValue.length != 76) {
                [AppD.window showHint:@"The two-dimensional code format is wrong."];
            } else {
                NSString *nickName = @"";
                if (codeValues.count>1) {
                    nickName = codeValues[1];
                }
                [weakSelf addFriendRequest:codeValue nickName:nickName];
            }
        }
    }];
     [self presentModalVC:vc animated:YES];
}
#pragma mark -Operation-
- (void)addFriendRequest:(NSString *)friendId nickName:(NSString *) nickName{
    FriendRequestViewController *vc = [[FriendRequestViewController alloc] initWithNickname:nickName userId:friendId];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -layz
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
#pragma textfeild delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
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
    _searchTF.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    _searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addTargetMethod];
    
    [UserConfig getShareObject].userId = [UserModel getUserModel].userId;
    [UserConfig getShareObject].userName = [UserModel getUserModel].username;
    [UserConfig getShareObject].passWord = [UserModel getUserModel].pass;
    
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
            ChatListModel *model = obj;
            NSString *userName = [model.friendName lowercaseString];
            if ([userName containsString:[tf.text.trim lowercaseString]]) {
                [weakSelf.searchDataArray addObject:model];
            }
        }];
    }
    [_tableV reloadData];
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
    return isSearch?self.searchDataArray.count : self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NewsCellHeight;
}


- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:NewsCellResue];
    ChatListModel *model = isSearch? self.searchDataArray[indexPath.row] : self.dataArray[indexPath.row];
    [cell setModeWithChatListModel:model];
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:65.f];
    cell.delegate = self;
    cell.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        FriendModel *model = [[FriendModel alloc] init];
        ChatListModel *chatModel = isSearch? self.searchDataArray[indexPath.row] : self.dataArray[indexPath.row];
        model.userId = chatModel.friendID;
        model.username = chatModel.friendName;
        model.publicKey = chatModel.publicKey;
        
        if (chatModel.isHD) {
            chatModel.isHD = NO;
            
//            NSArray *finfAlls = [ChatListModel bg_find:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"friendID"),bg_sqlValue(chatModel.friendID)]];
//            if (finfAlls && finfAlls.count > 0) {
//               ChatListModel *findModel = [finfAlls firstObject];
//                findModel.isHD = NO;
//                [findModel bg_saveOrUpdate];
//            }
            
            [chatModel bg_saveOrUpdate];
            
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
           // 删除
             ChatListModel *chatModel = isSearch? self.searchDataArray[cell.tag] : self.dataArray[cell.tag];
            [_tableV beginUpdates];
            isSearch? [self.searchDataArray removeObject:chatModel] : [self.dataArray removeObject:chatModel];
            // 删除本地聊天记录
            [[ChatListDataUtil getShareObject] removeChatModelWithFriendID:chatModel.friendID?:@""];
            //[ChatListModel bg_delete:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"friendID"),bg_sqlValue(chatModel.friendID?:@"")]];
            [_tableV deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [_tableV endUpdates];
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
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     MAIN_PURPLE_COLOR
//                                                 icon:[UIImage imageNamed:@"icon_up"]];
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
    
    NSArray *finfAlls = [ChatListModel bg_find:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"myID"),bg_sqlValue([UserConfig getShareObject].userId)]];
    NSMutableArray *tempArr = [NSMutableArray array];
    if (finfAlls && finfAlls.count > 0) {
        [tempArr addObjectsFromArray:finfAlls];
        tempArr = [self sortWith:tempArr];
    }
    @weakify_self
    [tempArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChatListModel *model = obj;
        __block BOOL isexit = NO;
        [weakSelf.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChatListModel *model1 = obj;
            if ([model.friendID isEqualToString:model1.friendID]) {
                isexit = YES;
                *stop = YES;
            }
        }];
        if (!isexit) {
            [weakSelf.dataArray addObject:model];
        }
    }];
     [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_CHATS_HD_NOTI object:self.dataArray];
    [_tableV reloadData];
    /*
    if (finfAlls && finfAlls.count > 0) {
        [self.dataArray addObjectsFromArray:finfAlls];
        @weakify_self
        [[ChatListDataUtil getShareObject].dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChatListModel *model = obj;

           __block BOOL isExit = NO;
            [finfAlls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ChatListModel *model1 = obj;
                if ([model.friendID isEqualToString:model1.friendID]) {
                    model1.lastMessage = model.lastMessage;
                    model1.friendName = model.friendName;
                    model1.chatTime = model.chatTime;
                    model1.isHD = model.isHD;
                    isExit = YES;
                    [model1 bg_saveOrUpdate];
                    *stop = YES;
                }
            }];
            if (!isExit) {
                model.bg_tableName = FRIEND_CHAT_TABNAME;
                if (model.publicKey && ![model.publicKey isEmptyString]) {
                    [model bg_save];
                    [weakSelf.dataArray addObject:model];
                }
            }
        }];
    } else {
        @weakify_self
        [[ChatListDataUtil getShareObject].dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChatListModel *model = obj;
            model.bg_tableName = FRIEND_CHAT_TABNAME;
            [model bg_save];
            [weakSelf.dataArray addObject:model];
        }];
    }*/
    
}

//根据时间排序
- (NSMutableArray *) sortWith:(NSMutableArray *)array{
    [array sortUsingComparator:^NSComparisonResult(ChatListModel *node1, ChatListModel *node2) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy/MM/dd HH:mm:ss"];
        if (node1.chatTime == [node1.chatTime earlierDate: node2.chatTime]) { //不使用intValue比较无效
            return NSOrderedDescending;//降序
        }else if (node1.chatTime == [node1.chatTime laterDate: node2.chatTime]) {
            return NSOrderedAscending;//升序
        }else{
            return NSOrderedSame;//相等
        }
    }];
    return array;
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
