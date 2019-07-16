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
#import "RouterModel.h"
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
#import "UploadFileManager.h"
#import "FileDownUtil.h"
#import "DebugLogViewController.h"
#import "AddGroupMemberViewController.h"
#import "RouterConfig.h"
#import "AddGroupMenuViewController.h"
#import "GroupInfoModel.h"
#import "GroupChatViewController.h"
#import "OtherFileOpenViewController.h"
#import "UIViewController+YJSideMenu.h"
#import "EmailListCell.h"
#import "EmailManage.h"
#import "FloderModel.h"

#import "NSDate+Category.h"
#import "PNDefaultHeaderView.h"
#import "EmailListInfo.h"
#import "EmailAccountModel.h"
#import "PNEmailDetailViewController.h"
#import "EmailUserModel.h"

#import <MJRefresh/MJRefresh.h>


@interface NewsViewController ()<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate,UITextFieldDelegate,YJSideMenuDelegate,UIScrollViewDelegate,UISearchControllerDelegate,UISearchBarDelegate> {
    BOOL isSearch;
}

@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) NSMutableArray *emailDataArray;
@property (nonatomic ,strong) NSMutableArray *searchDataArray;
@property (strong, nonatomic) UILabel *lblTop;
@property (weak, nonatomic) IBOutlet UIView *topBackView;
@property (weak, nonatomic) IBOutlet UIView *menuBackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineContrintLeft;
@property (weak, nonatomic) IBOutlet UIView *lineView;
@property (nonatomic , strong) UIButton *selectBtn;
@property (nonatomic) BOOL scrollIsManual; // 用户滑动
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollContraintW;
@property (weak, nonatomic) IBOutlet UIScrollView *mianScrollerView;

@property (weak, nonatomic) IBOutlet UITableView *emailTabView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblSubTitle;

@property (nonatomic ,assign) int page;
@property (nonatomic ,assign) int pageCount;
@property (nonatomic , strong) FloderModel *floderModel;
@end

@implementation NewsViewController

- (void)viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    AppD.sideMenuViewController.panGestureEnabled = YES;
    [super viewWillAppear:animated];
}
- (void)viewWillDisappear:(BOOL)animated
{
    AppD.sideMenuViewController.panGestureEnabled = NO;
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 添加通知
 */
- (void) addNoti
{
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatMessageChangeNoti:) name:ADD_MESSAGE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSecketFaieldNoti:) name:RELOAD_SOCKET_FAILD_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupQuitSuccessNoti:) name:GroupQuit_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageListUpdateNoti:) name:MessageList_Update_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatMessageChangeNoti:) name:SWITCH_CIRCLE_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherFileOpenNoti:) name:OTHER_FILE_OPEN_NOTI object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailAccountChangeNoti:) name:EMIAL_ACCOUNT_CHANGE_NOTI object:nil];
    
}
// 搜索
- (IBAction)clickSearchAction:(id)sender {
    
}
// 添加
- (IBAction)clickAddAction:(id)sender {
    [self jumpToAddGroupMenu];
}

// 显示左菜单
- (IBAction)moreAction:(id)sender {
    [self yj_presentLeftMenuViewController:nil];
}
- (IBAction)clickMenuAction:(UIButton *)sender {
    if (!sender.selected) {
        _scrollIsManual = YES;
        self.selectBtn.selected = NO;
        self.selectBtn = sender;
        sender.selected = YES;
        CGFloat lineLeft = SCREEN_WIDTH/2;
        CGFloat scrollW = SCREEN_WIDTH;
        if (sender.tag == 10) {
             lineLeft = 0;
             scrollW = 0;
            AppD.isEmailPage = NO;
        } else {
            AppD.isEmailPage = YES;
             if (!self.floderModel && EmailManage.sharedEmailManage.imapSeeion){
                 [self firstPullEmailList];
             }
        }
        [self updateTopTitle];
        
        _lineContrintLeft.constant = lineLeft;
        @weakify_self
        [UIView animateWithDuration:0.3 animations:^{
            [weakSelf.menuBackView layoutIfNeeded];
            CGPoint offset = CGPointMake(scrollW, 0);
            [weakSelf.mianScrollerView setContentOffset:offset animated:YES];
        }];
    }
}

// 第一次拉取收件箱邮件
- (void) firstPullEmailList
{
    _lblTitle.text = @"Inbox";
    EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
    if (!accountModel) {
         _lblSubTitle.text = @"Not Configured";
    } else {
         _lblSubTitle.text = accountModel.User;
    }
   
    self.floderModel = [[FloderModel alloc] init];
    self.floderModel.path = @"INBOX";
    self.floderModel.name = @"INBOX";
    MCOIMAPFolderInfoOperation * folderInfoOperation = [EmailManage.sharedEmailManage.imapSeeion folderInfoOperation:self.floderModel.path];
    @weakify_self
    [folderInfoOperation start:^(NSError *error, MCOIMAPFolderInfo * info) {
        if (error) {
            [weakSelf.view showHint:@"Failed to pull mail."];
        } else {
            weakSelf.floderModel.count = info.messageCount;
            [weakSelf pullEmailList];
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _page = 0;
    _pageCount = 10;
    
    AppD.sideMenuViewController.delegate = self;
    AppD.isEmailPage = NO;
    
     [UploadFileManager getShareObject];
     [FileDownUtil getShareObject];
    
    _scrollContraintW.constant = SCREEN_WIDTH*2;
    _mianScrollerView.delegate = self;
    _mianScrollerView.bounces = NO;
    
     self.view.backgroundColor = MAIN_GRAY_COLOR;
    _menuBackView.backgroundColor = MAIN_GRAY_COLOR;
    _topBackView.backgroundColor = MAIN_GRAY_COLOR;
    
    self.selectBtn = [_menuBackView viewWithTag:10];
    self.selectBtn.selected = YES;

    [self updateTopTitle];
    
    _searchBackView.layer.cornerRadius = 3.0f;
    _searchBackView.layer.masksToBounds = YES;
  
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
    
    _emailTabView.delegate = self;
    _emailTabView.dataSource = self;
    _emailTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _emailTabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_emailTabView registerNib:[UINib nibWithNibName:EmailListCellResue bundle:nil] forCellReuseIdentifier:EmailListCellResue];
    
    // 上拉刷新
    _emailTabView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        // 增加5条假数据
       
    }];
    // 默认先隐藏footer
   // _emailTabView.mj_footer.hidden = YES;
    
   
    NSLog(@"userid = %@",[UserModel getUserModel].userId);
    [self chatMessageChangeNoti:nil];
    [self addNoti];
    
    
    if (AppD.fileURL) {
        [self performSelector:@selector(jumpOtherFileVC) withObject:self afterDelay:1.0];
    }
}

// 更新头部标题
- (void) updateTopTitle
{
    if (AppD.isEmailPage) {
        _lblTitle.text = self.floderModel.name;
        EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
        _lblSubTitle.text = accountModel.User;
    } else {
        _lblTitle.text = @"Message";
        _lblSubTitle.text = [RouterModel getConnectRouter].name;
    }
}

/**
 外部文件导入跳转
 */
- (void) jumpOtherFileVC
{
    OtherFileOpenViewController *vc = [[OtherFileOpenViewController alloc] initWithFileUrl:AppD.fileURL];
    vc.backVC = self;
    AppD.fileURL = nil;
    [self presentModalVC:vc animated:YES];
}


/**
 添加好友跳转

 @param friendId 好友id
 @param nickName 好友昵称
 @param signpk 好友签名公钥
 */
- (void)addFriendRequest:(NSString *)friendId nickName:(NSString *) nickName singpk:(NSString *) signpk{
    FriendRequestViewController *vc = [[FriendRequestViewController alloc] initWithNickname:nickName userId:friendId signpk:signpk];
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 查询最后一条消息
 */
- (void)updateData {
    if (self.dataArray.count >0) {
        [self.dataArray removeAllObjects];
    }
    
    NSArray *finfAlls = [ChatListModel bg_find:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"myID"),bg_sqlValue([UserConfig getShareObject].userId)]];
    NSMutableArray *tempArr = [NSMutableArray array];
    if (finfAlls && finfAlls.count > 0) {
        [tempArr addObjectsFromArray:finfAlls];
        tempArr = [self sortWith:tempArr];
    }
    [self.dataArray  addObjectsFromArray:tempArr];

    [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_CHATS_HD_NOTI object:self.dataArray];
    [_tableV reloadData];
}

/**
 添加searchtf 监听

 */
-(void)addTargetMethod{
    [_searchTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
}

/**
 seartf 文本改变方法

 @param tf seartf
 */
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
            NSString *userName = model.isGroup?[model.groupShowName lowercaseString]:[model.friendName lowercaseString];
            if ([userName containsString:[tf.text.trim lowercaseString]]) {
                [weakSelf.searchDataArray addObject:model];
            }
        }];
    }
    [_tableV reloadData];
}

#pragma textfeild delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    NSLog(@"textFieldShouldReturn");
    return YES;
}


- (IBAction)reload:(id)sender {
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
    [self jumpToAddGroupMenu];
}

#pragma mark - tableviewDataSourceDelegate

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _tableV) {
        return isSearch?self.searchDataArray.count : self.dataArray.count;
    } else {
        return self.emailDataArray.count;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableV) {
        return NewsCellHeight;
    }
    return EmailListCellHeight;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    if (tableView == _tableV) {
        NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:NewsCellResue];
        ChatListModel *model = isSearch? self.searchDataArray[indexPath.row] : self.dataArray[indexPath.row];
        [cell setModeWithChatListModel:model];
        [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:65.f];
        cell.delegate = self;
        cell.tag = indexPath.row;
        return cell;
    } else {
        EmailListCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailListCellResue];
        
        EmailListInfo *listInfo = self.emailDataArray[indexPath.row];
        cell.lblTtile.text = listInfo.fromName?:@"";
        cell.lblSubTitle.text = listInfo.Subject?:@"";
        cell.lblTime.text = [listInfo.revDate minuteDescription];
        UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:@"" Name:[StringUtil getUserNameFirstWithName:cell.lblTtile.text]];
        cell.headImgView.image = defaultImg;
        cell.lblContent.text = listInfo.content;
        if (listInfo.attachCount == 0) {
            cell.attachImgView.hidden = YES;
            cell.lblAttCount.text = @"";
        } else {
            cell.attachImgView.hidden = NO;
            cell.lblAttCount.text = [NSString stringWithFormat:@"%d",listInfo.attachCount];
        }
        if (listInfo.Read == 0) {
            cell.readView.hidden = NO;
        } else {
            cell.readView.hidden = YES;
        }
        return cell;
    }
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableV) {
        if (!tableView.isEditing) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            ChatListModel *chatModel = isSearch? self.searchDataArray[indexPath.row] : self.dataArray[indexPath.row];
            
            if (chatModel.isHD) {
                chatModel.isHD = NO;
                chatModel.unReadNum = @(0);
                [chatModel bg_saveOrUpdate];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_CHATS_HD_NOTI object:nil];
            }
            if (chatModel.isGroup) {
                GroupInfoModel *model = [[GroupInfoModel alloc] init];
                model.GId = chatModel.groupID;
                model.GName = [chatModel.groupName base64EncodedString];
                model.Remark = [chatModel.groupAlias base64EncodedString];
                model.UserKey = chatModel.groupUserkey;
                
                GroupChatViewController *vc = [[GroupChatViewController alloc] initWihtGroupMode:model];
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                FriendModel *model = [[FriendModel alloc] init];
                model.userId = chatModel.friendID;
                model.owerId = [UserConfig getShareObject].userId;
                model.username = chatModel.friendName;
                model.publicKey = chatModel.publicKey;
                model.signPublicKey = chatModel.signPublicKey;
                
                ChatViewController *vc = [[ChatViewController alloc] initWihtFriendMode:model];
                [self.navigationController pushViewController:vc animated:YES];
            }
            
        }
    } else {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        EmailListInfo *model = self.emailDataArray[indexPath.row];
        model.floderName = self.floderModel.name;
        PNEmailDetailViewController *vc = [[PNEmailDetailViewController alloc] initWithEmailListModer:model];
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


/**
 选择cell菜单回调

 @param cell cell
 @param index index
 */
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
            if (chatModel.isGroup) {
                [[ChatListDataUtil getShareObject] removeGroupChatModelWithGID:chatModel.groupID?:@""];
            } else {
                [[ChatListDataUtil getShareObject] removeChatModelWithFriendID:chatModel.friendID?:@""];
            }
            
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

/**
 设置cell右边button icon

 @return 所有button
 */
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

- (void)jumpToAddGroupMenu {
    AddGroupMenuViewController *vc = [[AddGroupMenuViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 消息发生改变通知
- (void) chatMessageChangeNoti:(NSNotification *) noti
{
    [self updateData];
}

/**
 根据时间排序

 @param array 排序前array
 @return 排序后的array
 */
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

/**
 socket连接失败，显示top通知

 @param noti noti
 */
- (void) reloadSecketFaieldNoti:(NSNotification *) noti
{
    NSString *result = noti.object;
    if (!AppD.inLogin) {
        self.lblTop.hidden = YES;
        AppD.window.windowLevel = UIWindowLevelNormal;
    } else {
        if ([result integerValue] == 0) {
            //_connectBackView.hidden = NO;
            self.lblTop.hidden = NO;
            AppD.window.windowLevel = UIWindowLevelAlert;
        } else {
            self.lblTop.hidden = YES;
            AppD.window.windowLevel = UIWindowLevelNormal;
            // _connectBackView.hidden = YES;
        }
    }
}

#pragma mark -退出群组成功通知
- (void)groupQuitSuccessNoti:(NSNotification *)noti {
    NSString *GId = noti.object;
    // 删除群组下面所有文件
    NSString *gPath = [SystemUtil getBaseFilePath:GId];
    [SystemUtil removeDocmentFilePath:gPath];
    
    // 删除群列表的记录
    [ChatListModel bg_delete:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"groupID"),bg_sqlValue(GId)]];
    [self updateData];
}

- (void)messageListUpdateNoti:(NSNotification *)noti {
    [self updateData];
}

- (void) otherFileOpenNoti:(NSNotification *) noti
{
    NSURL *url = noti.object;
    OtherFileOpenViewController *vc = [[OtherFileOpenViewController alloc] initWithFileUrl:url];
    vc.backVC = self;
    [self presentModalVC:vc animated:YES];
}

- (void) emailAccountChangeNoti:(NSNotification *) noti
{
    [self firstPullEmailList];
}

#pragma mark - Layz
- (UILabel *)lblTop {
    CGFloat y = 0;
    if (IS_iPhoneX) {
        y = 24;
    }
    if (!_lblTop) {
        _lblTop = [[UILabel alloc] initWithFrame:CGRectMake(0,y, SCREEN_WIDTH, 20)];
        _lblTop.textColor = [UIColor whiteColor];
        _lblTop.backgroundColor = RGB(48, 145, 242);
        _lblTop.font = [UIFont systemFontOfSize:11];
        _lblTop.textAlignment = NSTextAlignmentCenter;
        _lblTop.text = @"Connecting you to the circle";
        [AppD.window addSubview:_lblTop];
    }
    return _lblTop;
}
#pragma mark --layz-------------
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
- (NSMutableArray *)emailDataArray
{
    if (!_emailDataArray) {
        _emailDataArray = [NSMutableArray array];
    }
    return _emailDataArray;
}

#pragma mark - YJSideMenuDelegate---------------
- (void)sideMenu:(YJSideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willShowMenuViewController");
}
- (void)sideMenu:(YJSideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    NSLog(@"willHideMenuViewController");
}
- (void)sideMenu:(YJSideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController selectFloderPath:(FloderModel *)floderModel
{
    NSLog(@"flodername = %@",floderModel.name);
    _lblTitle.text = floderModel.name;
    self.floderModel = floderModel;
    
    if (self.emailDataArray.count > 0) {
        [self.emailDataArray removeAllObjects];
        [_emailTabView reloadData];
    }
    
    if (floderModel.count == 0) {
        return;
    }
    
    [self pullEmailList];
    
}
// 拉取邮件列表
- (void) pullEmailList
{
    [self.view showHudInView:self.view hint:@"Loading"];
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    (MCOIMAPMessagesRequestKindHeaders |MCOIMAPMessagesRequestKindStructure |
     
     MCOIMAPMessagesRequestKindInternalDate |MCOIMAPMessagesRequestKindHeaderSubject |
     
     MCOIMAPMessagesRequestKindFlags);
    
    uint64_t locationf = 1;
    uint64_t lengthf = 10;
    if (self.floderModel.count >_pageCount) {
        locationf = self.floderModel.count - _pageCount+1;
    }
    MCOIndexSet *numbers = [MCOIndexSet indexSetWithRange:MCORangeMake(locationf, lengthf)];
    
    MCOIMAPFetchMessagesOperation *imapMessagesFetchOp = [EmailManage.sharedEmailManage.imapSeeion fetchMessagesByNumberOperationWithFolder:self.floderModel.path
                                                                                                                                requestKind:requestKind
                                                                                                                                    numbers:numbers];
    // 异步获取邮件
    @weakify_self
    [imapMessagesFetchOp start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
        
        if (error) {
            [weakSelf.view hideHud];
            [weakSelf.view showHint:@"Failed to pull mail."];
        } else {
            // 倒序
            NSArray *messageArray = [[messages reverseObjectEnumerator] allObjects];
            [weakSelf tranEmailListInfoWithArr:messageArray];
        }
    }];
}
// 转换成 emaillistinfo
- (void) tranEmailListInfoWithArr:(NSArray *) messageArray
{
    NSMutableArray *tempArray = [NSMutableArray array];
    @weakify_self
    [messageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       EmailListInfo *listInfo = [[EmailListInfo alloc] init];
        MCOIMAPMessage *message = obj;
        MCOMessageHeader *headrMessage = message.header;
        MCOAddress *address = headrMessage.from;
        
        // 获取多个收件人
        NSArray *toAddressArray = headrMessage.to;
        if (toAddressArray) {
            listInfo.toUserArray = [NSMutableArray array];
            for (int i =0; i<toAddressArray.count; i++) {
                MCOAddress *toA = toAddressArray[i];
                EmailUserModel *userM = [[EmailUserModel alloc] init];
                if (i == 0) {
                    userM.userType = UserTo;
                }
                userM.userName = toA.displayName?:[[toA.mailbox componentsSeparatedByString:@"@"] firstObject];
                userM.userAddress = toA.mailbox;
                [listInfo.toUserArray addObject:userM];
            }
        }
        
        // 获取多个抄送人
        NSArray *ccAddressArray = headrMessage.cc;
        if (ccAddressArray) {
            listInfo.ccUserArray = [NSMutableArray array];
            for (int i =0; i<ccAddressArray.count; i++) {
                MCOAddress *toA = ccAddressArray[i];
                EmailUserModel *userM = [[EmailUserModel alloc] init];
                if (i == 0) {
                    userM.userType = UserCc;
                }
                userM.userName = toA.displayName?:[[toA.mailbox componentsSeparatedByString:@"@"] firstObject];
                userM.userAddress = toA.mailbox;
                [listInfo.ccUserArray addObject:userM];
            }
        }
        
        // 获取多个密送人
        NSArray *bccAddressArray = headrMessage.bcc;
        if (bccAddressArray) {
            listInfo.bccUserArray = [NSMutableArray array];
            for (int i =0; i<bccAddressArray.count; i++) {
                MCOAddress *toA = bccAddressArray[i];
                EmailUserModel *userM = [[EmailUserModel alloc] init];
                if (i == 0) {
                    userM.userType = UserBcc;
                }
                userM.userName = toA.displayName?:[[toA.mailbox componentsSeparatedByString:@"@"] firstObject];
                userM.userAddress = toA.mailbox;
                [listInfo.bccUserArray addObject:userM];
            }
        }
        
        
        listInfo.uid = message.uid;
        listInfo.Read = message.flags;
        listInfo.messageid = headrMessage.messageID;
        listInfo.fromName = address.displayName?:@"";
        listInfo.From = address.mailbox;
       // listInfo.toName = toAddress.displayName?:@"";
        listInfo.Subject = message.header.subject;
        listInfo.revDate = message.header.receivedDate;
        [tempArray addObject:listInfo];
    }];
    
   __block int endCount = 0;
    for (int i =0; i<tempArray.count; i++) {
        EmailListInfo *info = tempArray[i];
        MCOIMAPFetchContentOperation * fetchContentOp = [EmailManage.sharedEmailManage.imapSeeion fetchMessageOperationWithFolder:self.floderModel.path uid:info.uid];
        [fetchContentOp start:^(NSError * error, NSData * data) {
            
            endCount++;
            
            if ([error code] != MCOErrorNone) {
                NSLog(@"解析邮件失败");
            }
            MCOMessageParser *messageParser = [MCOMessageParser messageParserWithData:data];
            info.attachCount = (int)messageParser.attachments.count;
            NSString *content = [messageParser plainTextBodyRenderingAndStripWhitespace:YES];
            NSString *htmlContent = [messageParser htmlBodyRendering];
            htmlContent =[htmlContent componentsSeparatedByString:@"<hr/>"][0];
            NSArray *attchArray = messageParser.attachments;
            [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                EmailListInfo *listModel = obj;
                if ([messageParser.header.messageID isEqualToString:listModel.messageid]) {
                    listModel.content = content;
                    listModel.htmlContent = htmlContent;
                    listModel.attchArray = [NSMutableArray arrayWithArray:attchArray?:@[]];
                    *stop = YES;
                }
            }];
            // 判断是否完成
            if (endCount == tempArray.count) {
                [weakSelf.view hideHud];
                [weakSelf.emailDataArray addObjectsFromArray:tempArray];
                [weakSelf.emailTabView reloadData];
            }
        }];
    }
}

#pragma mark - UIScrollViewDelegate-------------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _mianScrollerView) {
        if (_scrollIsManual == NO) {
            CGPoint offset = scrollView.contentOffset;
            _lineView.centerX = offset.x/2+SCREEN_WIDTH/4;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _mianScrollerView) {
        CGPoint offset = scrollView.contentOffset;
        if (offset.x >= SCREEN_WIDTH) {
            UIButton *btn = [_menuBackView viewWithTag:20];
            [self clickMenuAction:btn];
        } else {
            UIButton *btn = [_menuBackView viewWithTag:10];
            [self clickMenuAction:btn];
        }
        _scrollIsManual = NO;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == _mianScrollerView) {
        _scrollIsManual = NO;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
