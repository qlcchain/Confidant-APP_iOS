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
#import "MyConfidant-Swift.h"
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
#import "PNEmailSendViewController.h"
#import "EmailUserModel.h"
#import "EmailAttchModel.h"

#import <MJRefresh/MJRefresh.h>
#import "EmailOptionUtil.h"
#import "NSString+HexStr.h"
#import "EmailDataBaseUtil.h"

#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "EmailNodeModel.h"

#import "NSString+Trim.h"
#import "PNSearchViewController.h"
#import "EmailErrorAlertView.h"
#import "AESCipher.h"
//#import <CocoaSecurity/CocoaSecurity.h>

//#import <QLCFramework/QLCFramework.h>
#import <GoogleSignIn/GoogleSignIn.h>

#import "GoogleUserModel.h"
#import "GoogleServerManage.h"
#import "GoogleMessageModel.h"
#import <GoogleAPIClientForREST/GTLRBase64.h>
#import "NSData+UTF8.h"

#import "MLMenuView.h"
#import "AddNewMemberViewController.h"
#import "NSString+RegexCategory.h"
#import "CircleOutUtil.h"
#import "CodeMsgViewController.h"
#import "UserPrivateKeyUtil.h"
#import "CreateGroupChatViewController.h"
#import "NSString+RegexCategory.h"



@interface NewsViewController ()<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate,UITextFieldDelegate,YJSideMenuDelegate,UIScrollViewDelegate,UISearchControllerDelegate,UISearchBarDelegate,GIDSignInUIDelegate> {
    BOOL isSearch;
    int startId;
    NSInteger selEmailRow;
    NSInteger selMessageRow;
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
@property (nonatomic ,assign) NSInteger currentEmailCount; // 当前邮件总数
@property (nonatomic ,assign) BOOL isRefresh; // 是不是上拉刷新
@property (nonatomic ,assign) BOOL isRequestFloderCount;
// 记录最大uid
@property (nonatomic ,assign) int maxUid;
@property (nonatomic, strong) NSString *nextPageToken;
@property (nonatomic, strong) NSMutableArray *googleTempMessages;
@property (nonatomic, strong) NSArray *googleTempLists;
@property (nonatomic ,assign) int messageCount;

@property (nonatomic, assign) BOOL isSend;
@property (nonatomic, assign) BOOL isFriendSend;
@property (nonatomic, strong) NSString *codeResultValue;
@end

@implementation NewsViewController

#pragma mark ----layz
- (NSMutableArray *)googleTempMessages
{
    if (!_googleTempMessages) {
        _googleTempMessages = [NSMutableArray arrayWithCapacity:10];
    }
    return _googleTempMessages;
}

- (void)viewWillAppear:(BOOL)animated {
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cricleChangeChangeNoti:) name:SWITCH_CIRCLE_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherFileOpenNoti:) name:OTHER_FILE_OPEN_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailAccountChangeNoti:) name:EMIAL_ACCOUNT_CHANGE_NOTI object:nil];
    // 邮件flags 改变通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailFlagsChangeNoti:) name:EMIAL_FLAGS_CHANGE_NOTI object:nil];
    // 拉取节点邮件通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullEmailNoti:) name:EMAIL_PULL_NODE_NOTI object:nil];
    // 搜索界面点击 邮件或消息状态发生改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MessageStatusChangeNoti:) name:SEARCH_MODEL_STATUS_CHANGE_NOTI object:nil];
    // 删除邮箱通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noEmailConfigNoti:) name:EMAIL_NO_CONFIG_NOTI object:nil];
    // 新注册用户默认添加节点管理员到chat
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addOwnerToChatNoti:) name:ADD_OWNER_CHAT_NOTI object:nil];
    // google sign 成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(firstPullEmailList) name:GOOGLE_EMAIL_SIGN_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(googleSigninFaield) name:GOOGLE_EMAIL_SIGN_FAIELD_NOTI object:nil];
    
    
    // menu 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseContactNoti:) name:CHAT_CHOOSE_FRIEND_CREATE_GROUOP_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpGroupChatNoti:) name:CHAT_CREATE_GROUP_SUCCESS_JUMP_NOTI object:nil];
}
// 搜索
- (IBAction)clickSearchAction:(id)sender {
    PNSearchViewController *vc = [[PNSearchViewController alloc] initWithData:AppD.isEmailPage?self.emailDataArray:self.dataArray isMessage:!AppD.isEmailPage floder:self.floderModel];
    @weakify_self
    [vc setClickObjBlock:^(id  _Nonnull object) {
        if ([object isKindOfClass:[ChatListModel class]]) {
            ChatListModel *listM = object;
            [weakSelf.dataArray enumerateObjectsUsingBlock:^(ChatListModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *groupId1 = listM.groupID?:@"";
                NSString *groupId2 = obj.groupID?:@"";
                if ([listM.friendID isEqualToString:obj.friendID] && [groupId1 isEqualToString:groupId2]) {
                    [weakSelf jumpChatDetailOrEmailDetailWithObject:object row:idx];
                    *stop = YES;
                }
            }];
        } else if ([object isKindOfClass:[EmailListInfo class]]) {
            EmailListInfo *listM = object;
            [weakSelf.emailDataArray enumerateObjectsUsingBlock:^(EmailListInfo *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (listM.uid == obj.uid) {
                    [weakSelf jumpChatDetailOrEmailDetailWithObject:object row:idx];
                    *stop = YES;
                }
            }];
        } else {
            GoogleMessageModel *listM = object;
            [weakSelf.emailDataArray enumerateObjectsUsingBlock:^(GoogleMessageModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([listM.messageId isEqualToString:obj.messageId]) {
                    [weakSelf jumpChatDetailOrEmailDetailWithObject:object row:idx];
                    *stop = YES;
                }
            }];
        }
    }];
   // [self.navigationController pushViewController:vc animated:YES];
    [self presentModalVC:vc animated:YES];
}
// 添加
- (IBAction)clickAddAction:(id)sender {
    [self jumpToAddGroupMenu];
}

// 显示左菜单
- (IBAction)moreAction:(id)sender {
    if (AppD.isEmailPage) {
        [self yj_presentLeftMenuViewController:nil];
    }
    
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
             EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
            
            // 如果是google 邮箱 sgin in
            if (accountModel && accountModel.userId && accountModel.userId.length > 0) {
                if (!AppD.isGoogleSign) {
                    [self.view showHudInView:self.view hint:@""];
                    NSArray *currentScopes = @[@"https://mail.google.com/"];
                    [GIDSignIn sharedInstance].scopes = currentScopes;
                    [[GIDSignIn sharedInstance] signIn];
                } else {
                    if (self.emailDataArray.count == 0){
                        [self firstPullEmailList];
                    }
                }
            } else {
                if (!self.floderModel && accountModel){
                    [self firstPullEmailList];
                }
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
    if (self.isSend || self.isFriendSend) {
        if (self.isSend) {
            self.isSend = NO;
            [self jumpNewEmail];
        } else {
            self.isFriendSend = NO;
            [self jumpFriendNewEmail];
        }
        
        return;
    }
    
    self.emailTabView.mj_header.hidden = NO;
    if (self.emailDataArray.count > 0) {
        [self.emailDataArray removeAllObjects];
        [self.emailTabView reloadData];
    }
    
    
    EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
    _page = 1;
    _maxUid = [[HWUserdefault getObjectWithKey:accountModel.User] intValue];
    _nextPageToken = @"";
    
    if(accountModel.userId && accountModel.userId.length > 0)  { // google api
        
        self.floderModel = [[FloderModel alloc] init];
        self.floderModel.path = @"INBOX";
        self.floderModel.name = @"Inbox";
        _lblTitle.text = self.floderModel.name;
        _lblSubTitle.text = accountModel.User;
        
        if (!AppD.isGoogleSign) {
            
            [self.view showHudInView:self.view hint:@""];
            NSArray *currentScopes = @[@"https://mail.google.com/"];
            [GIDSignIn sharedInstance].scopes = currentScopes;
            [[GIDSignIn sharedInstance] signIn];
            
        } else {
            
            [self sendGoogleRequestWithShow:YES];
        }
        
        
        
    } else if (accountModel) {
        
        self.floderModel = [[FloderModel alloc] init];
        self.floderModel.path = @"INBOX";
        self.floderModel.name = @"Inbox";
        
        _lblTitle.text = self.floderModel.name;
        _lblSubTitle.text = accountModel.User;
        
        MCOIMAPFolderInfoOperation * folderInfoOperation = [EmailManage.sharedEmailManage.imapSeeion folderInfoOperation:self.floderModel.path];
        
        //[self.view showHudInView:self.view hint:@"Loading" userInteractionEnabled:NO hideTime:REQEUST_TIME];
        [self.view showHudInView:self.view hint:@"Loading"];
        @weakify_self
        [folderInfoOperation start:^(NSError *error, MCOIMAPFolderInfo * info) {
            if (error) {
                [weakSelf.view hideHud];
                [weakSelf.view showHint:@"Failed to pull mail."];
            } else {
                if (weakSelf.emailDataArray.count == 0) {
                    weakSelf.isRequestFloderCount = YES;
                    weakSelf.floderModel.count = info.messageCount;
                    [weakSelf pullEmailList];
                }
            }
        }];
    } else {
        _lblTitle.text = @"Email";
        _lblSubTitle.text = @"Not Configured";
        _emailTabView.mj_footer.hidden = YES;
        _emailTabView.mj_header.hidden = YES;
    }

}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    

    [GIDSignIn sharedInstance].uiDelegate = self;
    
    _page = 1;
    _pageCount = 20;
    
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
    [UserConfig getShareObject].usersn = [UserModel getUserModel].userSn;
    
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
    _emailTabView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(sendPullNewEmailList)];
    // Hide the time
    ((MJRefreshStateHeader *)_emailTabView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    // Hide the status
    ((MJRefreshStateHeader *)_emailTabView.mj_header).stateLabel.hidden = YES;
  
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    @weakify_self
    _emailTabView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf pullEmailList];
    }];
    MJRefreshAutoNormalFooter *footerView = (MJRefreshAutoNormalFooter *)_emailTabView.mj_footer;
    [footerView setRefreshingTitleHidden:YES];
    [footerView setTitle:@"" forState:MJRefreshStateIdle];
    
    if ([EmailAccountModel getLocalAllEmailAccounts].count == 0) {
        footerView.hidden = YES;
        _emailTabView.mj_header.hidden = YES;
    }
    
    NSLog(@"userid = %@",[UserModel getUserModel].userId);
    [self cricleChangeChangeNoti:nil];
    [self addNoti];
    
    
    if (AppD.fileURL) {
        [self performSelector:@selector(jumpOtherFileVC) withObject:self afterDelay:1.0];
    }

    
}
// 拉取新邮件
- (void) sendPullNewEmailList
{
    if (self.floderModel.path && self.floderModel.path.length > 0) {
        
        self.isRefresh = YES;
        [self pullEmailList];

    }
}

// 更新头部标题
- (void) updateTopTitle
{
    if (AppD.isEmailPage) {
        EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
        if (accountModel) {
            if (!self.floderModel) {
                 _lblTitle.text = @"InBox";
            } else {
                 _lblTitle.text = self.floderModel.name;
            }
           
            _lblSubTitle.text = accountModel.User;
        } else {
            _lblTitle.text = @"Email";
            _lblSubTitle.text = @"Not Configured";
        }
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
 查询最后一条消息
 */
- (void)updateData {
    if (self.dataArray.count >0) {
        [self.dataArray removeAllObjects];
    }
    
    NSArray *finfAlls = [ChatListModel bg_find:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"myID"),bg_sqlValue([UserModel getUserModel].userSn)]];
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
        /*
        MCOIMAPMessage *imapMessage = self.emailDataArray[indexPath.row];
       // 这个方法是自动把文本中的空行之类的去掉了，也有不去掉和可选是否去掉的方法
        MCOIMAPMessageRenderingOperation *messageRenderingOperation = [EmailManage.sharedEmailManage.imapSeeion plainTextBodyRenderingOperationWithMessage:imapMessage folder:self.floderModel.path];
        cell.messageRenderingOperation = messageRenderingOperation;
        
        [cell.messageRenderingOperation start:^(NSString * plainTextBodyString,NSError * error) {
            if (error == nil) {
                cell.lblContent.text = plainTextBodyString?:@"";
            }else{
                NSLog(@"fetch plain text error:%@",error);
            }
        }];
        
        MCOMessageHeader *headrMessage = imapMessage.header;
        MCOAddress *address = headrMessage.from;
        
        cell.lblTtile.text = address.displayName?:@"";
        cell.lblSubTitle.text = headrMessage.subject?:@"";
        cell.lblTime.text = [headrMessage.receivedDate minuteDescription];
        UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:@"" Name:[StringUtil getUserNameFirstWithName:cell.lblTtile.text]];
        cell.headImgView.image = defaultImg;
        
        if (imapMessage.flags %2 == 0 && ![self.floderModel.name isEqualToString:Drafts] && ![self.floderModel.name isEqualToString:Sent]) {
            cell.readView.hidden = NO;
            cell.lblContent.textColor = MAIN_PURPLE_COLOR;
        } else {
            cell.readView.hidden = YES;
            cell.lblContent.textColor = RGB(148, 150, 161);
        }
        // 获取read 二进制的第三位，1为加星  0 为没有
        cell.lableImgView.hidden = ![EmailOptionUtil checkEmailStar:imapMessage.flags];
        
        return cell;
        */
        if ([self.floderModel.name isEqualToString:Drafts]) {
            [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:65.f];
            cell.delegate = self;
            cell.tag = indexPath.row;
        } else {
            if (cell.delegate) {
                [cell setRightUtilityButtons:@[] WithButtonWidth:0];
                cell.delegate = nil;
                cell.tag = indexPath.row;
            }
        }
        
        
        if ([self.emailDataArray[indexPath.row] isKindOfClass:[GoogleMessageModel class]]) {
            
            GoogleMessageModel *messageM = self.emailDataArray[indexPath.row];
            messageM.currentRow = indexPath.row;
            cell.lblContent.text = messageM.snippet?:@"";
            cell.lblTime.text = [[NSDate dateWithTimeIntervalSince1970:messageM.internalDate/1000] minuteDescription];
            cell.lblSubTitle.text = messageM.Subject?:@"";
            
            
            cell.lblTtile.text = messageM.FromName?:@"";
            UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:@"" Name:[StringUtil getUserNameFirstWithName:cell.lblTtile.text]];
            cell.headImgView.image = defaultImg;
            
            if (messageM.attachCount == 0) {
                cell.attachImgView.hidden = YES;
                cell.lblAttCount.text = @"";
            } else {
                cell.attachImgView.hidden = NO;
                cell.lblAttCount.text = [NSString stringWithFormat:@"%d",messageM.attachCount];
            }
            
            // 星标
            
            cell.lableImgView.hidden = !messageM.isStarred;
            cell.starW.constant = cell.lableImgView.hidden? 0:24;
            
            if (((messageM.deKey && messageM.deKey.length > 0) || messageM.passHint.length > 0) && ![self.floderModel.name isEqualToString:Node_backed_up]) {
                cell.lockImgView.hidden = NO;
            } else {
                cell.lockImgView.hidden = YES;
            }
            
            if (!messageM.isRead && ![self.floderModel.name isEqualToString:Drafts] && ![self.floderModel.name isEqualToString:Sent]) {
                cell.readView.hidden = NO;
                cell.lblContent.textColor = MAIN_PURPLE_COLOR;
            } else {
                cell.readView.hidden = YES;
                cell.lblContent.textColor = RGB(148, 150, 161);
            }
            
            
            
            
        } else {
            
            
            EmailListInfo *listInfo = self.emailDataArray[indexPath.row];
            
            listInfo.currentRow = indexPath.row;
            cell.lblTtile.text = listInfo.fromName?:@"";
            cell.lblSubTitle.text = listInfo.Subject?:@"";
            cell.lblTime.text = [listInfo.revDate minuteDescription];
            UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:@"" Name:[StringUtil getUserNameFirstWithName:cell.lblTtile.text]];
            cell.headImgView.image = defaultImg;
            if (listInfo.Read %2 == 0 && ![self.floderModel.name isEqualToString:Drafts] && ![self.floderModel.name isEqualToString:Sent]) {
                cell.readView.hidden = NO;
                cell.lblContent.textColor = MAIN_PURPLE_COLOR;
            } else {
                cell.readView.hidden = YES;
                cell.lblContent.textColor = RGB(148, 150, 161);
            }
            // 获取read 二进制的第三位，1为加星  0 为没有
            cell.lableImgView.hidden = ![EmailOptionUtil checkEmailStar:listInfo.Read];
            cell.starW.constant = cell.lableImgView.hidden? 0:24;
            
            if (((listInfo.deKey && listInfo.deKey.length > 0) || listInfo.passHint.length > 0) && ![self.floderModel.name isEqualToString:Node_backed_up]) {
                cell.lockImgView.hidden = NO;
            } else {
                cell.lockImgView.hidden = YES;
            }
            
            cell.lblContent.text = listInfo.content;
            if (listInfo.attachCount == 0) {
                cell.attachImgView.hidden = YES;
                cell.lblAttCount.text = @"";
            } else {
                cell.attachImgView.hidden = NO;
                cell.lblAttCount.text = [NSString stringWithFormat:@"%d",listInfo.attachCount];
            }
            
            // 解析内容和附件
            if (listInfo.fetchContentOp && !listInfo.isFetch) {
                listInfo.isFetch = YES;
                @weakify_self
                [listInfo.fetchContentOp start:^(NSError * _Nullable error, NSData * _Nullable data) {
                    
                    if ([error code] != MCOErrorNone) {
                        NSLog(@"解析邮件失败");
                    }
                    
                    MCOMessageParser *messageParser = [MCOMessageParser messageParserWithData:data];
                    listInfo.attachCount = (int)messageParser.attachments.count;
                    
//                    NSString *content = [messageParser plainTextBodyRenderingAndStripWhitespace:YES]?:@"";
//
//                    content = [content stringByReplacingOccurrencesOfString:confidantEmialStr withString:@""];
//                    content = [content stringByReplacingOccurrencesOfString:confidantEmialText withString:@""];
//                    content = [NSString trimWhitespace:content];
//
//                    // 去除带有附件名字段
//                    if (listInfo.attachCount > 0) {
//                        NSArray *contentArr = [content componentsSeparatedByString:@" "];
//                        if ([contentArr[0] containsString:@"-"] ) {
//                            content = [contentArr lastObject];
//                        } else {
//                            content = contentArr[0];
//                        }
//                    }
                    
            
                    NSString *htmlContents = [messageParser htmlBodyRendering];
                    // 检查是否包含 confidantcontent
                    NSString *confidantContent = [weakSelf checkConfidantContentWithHtmlContent:htmlContents];
                    
                    if (confidantContent.length > 0) {
                       htmlContents = [confidantContent base64DecodedString];
                    }
                    
                    // 检查是否需要解密
                    NSString *dsKey = [weakSelf deEmailHtmlContentWithContent:htmlContents];
                   
                    
                    // 检查是否带有好友id
                    listInfo.friendId = [weakSelf checkFriendWithHtmlContent:htmlContents];
                    
                    // 检查是否带有密码
                    listInfo.passHint = [weakSelf checkPassWithHtmlContent:htmlContents];
                    
                    // 解密正文
                    if (listInfo.passHint.length > 0) {
                        
                       htmlContents = [weakSelf getHtmlBodyWithHtmlContent:htmlContents emailType:1 isAttch:listInfo.attachCount deKey:@""];
                        
                        
                    } else if (dsKey.length > 0) {
                        
                       
                        NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:dsKey];
                        if (datakey && datakey.length > 0) {
                            datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
                     
                            htmlContents = [weakSelf getHtmlBodyWithHtmlContent:htmlContents emailType:2 isAttch:listInfo.attachCount deKey:datakey];

                            
                            listInfo.deKey = datakey;
                        }
                    } else { // dsKey.length > 0
                        
                        htmlContents = [weakSelf getHtmlBodyWithHtmlContent:htmlContents emailType:0 isAttch:listInfo.attachCount deKey:@""];
                        
                    }
                    // 获取附件
                    NSArray *attchArray = messageParser.attachments;
                    if (attchArray && attchArray.count > 0) {
                        
                        htmlContents = [htmlContents stringByReplacingOccurrencesOfString:@"<hr/>" withString:@""];
                        NSArray *attchs = [htmlContents componentsSeparatedByString:@"<div>-"];
                        if (attchs) {
                            NSArray *attNames =[[attchs lastObject] componentsSeparatedByString:@"</div>"];
                            if (attNames) {
                                NSString *attNameStr = [@"<div>-" stringByAppendingString:attNames[0]];
                                htmlContents = [htmlContents stringByReplacingOccurrencesOfString:attNameStr withString:@""];
                            }
                        }
                        //去除附件
                        /*
                         NSArray *hrs = [htmlContents componentsSeparatedByString:@"<hr/>"];
                         NSString *attHtml =[hrs lastObject];
                         NSRange range = [htmlContents rangeOfString:[@"<hr/>" stringByAppendingString:attHtml]];
                         if (range.location != NSNotFound) {
                         NSString *htmlRangeContents = [htmlContents substringWithRange:NSMakeRange(0, range.location)];
                         if (htmlContents && htmlContents.length > 0) {
                         htmlContents = htmlRangeContents;
                         }
                         }
                         */
                    }
                  
                    NSString *content = [weakSelf filterHTML:htmlContents]?:@"";//content;//[content componentsSeparatedByString:@" "][0];
                    content = [content stringByReplacingOccurrencesOfString:confidantEmialText withString:@""];
                    listInfo.content = content;
                    listInfo.htmlContent = htmlContents;
                    listInfo.parserData = data;
                    
                    // 转换附件类型
                    listInfo.attchArray = [NSMutableArray array];
                    if (attchArray) {
                        [attchArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            MCOAttachment *attInfo = obj;
                            EmailAttchModel *attModel = [[EmailAttchModel alloc] init];
                            attModel.attId = attInfo.uniqueID;
                            attModel.attName = attInfo.filename;
                            attModel.attData = attInfo.data;
                            [listInfo.attchArray addObject:attModel];
                        }];
                    }
                    // [weakSelf.emailTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:listInfo.currentRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    EmailListCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:listInfo.currentRow inSection:0]];
                    if (cell) {
                        
                        if (((listInfo.deKey && listInfo.deKey.length > 0) || listInfo.passHint.length > 0) && ![weakSelf.floderModel.name isEqualToString:Node_backed_up]) {
                            cell.lockImgView.hidden = NO;
                        } else {
                            cell.lockImgView.hidden = YES;
                        }
                        
                        cell.lblContent.text = listInfo.content;
                        if (listInfo.attachCount == 0) {
                            cell.attachImgView.hidden = YES;
                            cell.lblAttCount.text = @"";
                        } else {
                            cell.attachImgView.hidden = NO;
                            cell.lblAttCount.text = [NSString stringWithFormat:@"%d",listInfo.attachCount];
                        }
                        
                    }
                    
                    
                }]; //listInfo.fetchContentOp
            }// listInfo.fetchContentOp
            
            
        }
        
        
        
        return cell;
    }
    
}

#pragma mark ----------得到body内容---------------

/**
 得到body内容

 @param htmlContents htmlcontent
 @param type 1:password 2:userkey 3:不加密邮件
 @return body
 */
- (NSString *) getHtmlBodyWithHtmlContent:(NSString *) htmlContents emailType:(NSInteger) type isAttch:(BOOL) isAttch deKey:(NSString *) dsKey
{
    
    NSString *spanStr = @"";
    // 解密正文
    if (type == 1) {
        
        NSString *bodyStr = [htmlContents componentsSeparatedByString:@"</body>"][0];
        NSArray *bodys = [bodyStr componentsSeparatedByString:@"<body>"];
        NSString *enStr = [bodys lastObject];
        
        if (isAttch) {
            NSString *attchHtml = bodys[0];
            htmlContents = [htmlContents stringByReplacingOccurrencesOfString:attchHtml withString:htmlHead];
        }
    
        NSArray *spanArray = [enStr componentsSeparatedByString:@"<span style='display:none'"];
        if (spanArray && spanArray.count <2) {
            spanStr = [enStr componentsSeparatedByString:@"<span style=\"display:none\""][0];
        } else {
            spanStr = spanArray[0];
        }
        

    } else if (type == 2) {
        
            NSString *bodyStr = [htmlContents componentsSeparatedByString:@"</body>"][0];
            NSArray *bodys = [bodyStr componentsSeparatedByString:@"<body>"];
            NSString *enStr = [bodys lastObject];
            
            if (isAttch) {
                NSString *attchHtml = bodys[0];
                htmlContents = [htmlContents stringByReplacingOccurrencesOfString:attchHtml withString:htmlHead];
            }
            
            
            NSArray *spanArray = [enStr componentsSeparatedByString:@"<span style='display:none'"];
            if (spanArray && spanArray.count <2) {
                spanStr = [enStr componentsSeparatedByString:@"<span style=\"display:none\""][0];
            } else {
                spanStr = spanArray[0];
            }
            NSString *deStr = aesDecryptString(spanStr, dsKey)?:@"";
            spanStr = [deStr stringByAppendingString:confidantHtmlStr];
        
    } else { // dsKey.length > 0
        
        // 替换正文body ，截取掉 span标签
        NSString *bodyStr = [htmlContents componentsSeparatedByString:@"</body>"][0];
        NSArray *bodys = [bodyStr componentsSeparatedByString:@"<body>"];
        bodyStr = [bodys lastObject];
        
        if (isAttch > 0) {
            NSString *attchHtml = bodys[0];
            htmlContents = [htmlContents stringByReplacingOccurrencesOfString:attchHtml withString:htmlHead];
        }
        
        NSArray *spanArray2 = [bodyStr componentsSeparatedByString:@"<span style='display:none'"];
        if (spanArray2 && spanArray2.count <2) {
            spanStr = [bodyStr componentsSeparatedByString:@"<span style=\"display:none\""][0];
        } else {
            spanStr = spanArray2[0];
             spanStr = [spanStr stringByAppendingString:confidantHtmlStr];
        }
        
    }
    return spanStr;
}

#pragma mark---------------解密newconfidantcontent
- (NSString *) checkConfidantContentWithHtmlContent:(NSString *) htmlContents
{
    if (htmlContents && htmlContents.length > 0) {
        
        NSArray *passArr = [htmlContents componentsSeparatedByString:@"newconfidantcontent\n"];
        if (passArr && passArr.count == 1) {
            passArr = [htmlContents componentsSeparatedByString:@"newconfidantcontent"];
        }
        if (passArr && passArr.count == 2) {
            
            NSString *useridLastStr = [passArr lastObject];
            useridLastStr = [useridLastStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            useridLastStr = [useridLastStr stringByReplacingOccurrencesOfString:@"'" withString:@""];
            
            
            NSString *friendid = [useridLastStr componentsSeparatedByString:@"></span>"][0];
            friendid = [friendid stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            friendid = [friendid stringByReplacingOccurrencesOfString:@"'" withString:@""];
            
            return friendid?:@"";
        }
    }
    return @"";
}

#pragma mark --------------解密内容
- (NSString *) deEmailHtmlContentWithContent:(NSString *) htmlContents
{
    // 检查是否需要解密
     EmailAccountModel *accountM =[EmailAccountModel getConnectEmailAccount];
    __block NSString *dsKey = @"";
    if (htmlContents && htmlContents.length > 0) {
        NSArray *arrs1 = [htmlContents componentsSeparatedByString:@"confidantkey=\n"];
        if (arrs1 && arrs1.count == 1) {
            arrs1 = [htmlContents componentsSeparatedByString:@"confidantkey="];
        }
        
        NSArray *arrs2 = [htmlContents componentsSeparatedByString:@"newconfidantkey\n"];
        if (arrs2 && arrs2.count == 1) {
            arrs2 = [htmlContents componentsSeparatedByString:@"newconfidantkey"];
        }
        
        NSArray *arrs = nil;
        if (arrs1.count == 2) {
            arrs = arrs1;
        } else if (arrs2.count == 2) {
            arrs = arrs2;
        }
        
        if (arrs) {
            NSString *confidantLastStr = [arrs lastObject];
            confidantLastStr = [confidantLastStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            confidantLastStr = [confidantLastStr stringByReplacingOccurrencesOfString:@"'" withString:@""];
           
            
            NSString *enStr = [confidantLastStr componentsSeparatedByString:@"></span>"][0];
            enStr = [enStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            enStr = [enStr stringByReplacingOccurrencesOfString:@"'" withString:@""];
            
            NSArray *emailUserkeys = [enStr componentsSeparatedByString:@"##"];
            if (emailUserkeys && emailUserkeys.count > 0) {
                [emailUserkeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *uks = obj;
                    NSArray *userkeys = [uks componentsSeparatedByString:@"&amp;&amp;"];
                    if (userkeys && userkeys.count == 1) {
                        userkeys = [uks componentsSeparatedByString:@"&&"];
                    }
                    if ([accountM.User isEqualToString:[userkeys[0] base64DecodedString]]) {
                        dsKey = userkeys[1];
                    }
                }];
            }
            
        } 
    } //htmlContents && htmlC
    
    return dsKey;
}

// 检查是否带有密码加密
- (NSString *) checkPassWithHtmlContent:(NSString *) htmlContents
{
    if (htmlContents && htmlContents.length > 0) {
        
        NSArray *passArr = [htmlContents componentsSeparatedByString:@"newconfidantpass\n"];
        if (passArr && passArr.count == 1) {
            passArr = [htmlContents componentsSeparatedByString:@"newconfidantpass"];
        }
        if (passArr && passArr.count == 2) {
            
            NSString *useridLastStr = [passArr lastObject];
            useridLastStr = [useridLastStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            useridLastStr = [useridLastStr stringByReplacingOccurrencesOfString:@"'" withString:@""];
            
            
            NSString *friendid = [useridLastStr componentsSeparatedByString:@"></span>"][0];
            friendid = [friendid stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            friendid = [friendid stringByReplacingOccurrencesOfString:@"'" withString:@""];
            
            return friendid?:@"";
        }
    }
    return @"";

}


// 检查是否带有好友 id
- (NSString *) checkFriendWithHtmlContent:(NSString *) htmlContents
{
    if (htmlContents && htmlContents.length > 0) {
        
        NSArray *useridArr1 = [htmlContents componentsSeparatedByString:@"confidantuserid=\n"];
        if (useridArr1 && useridArr1.count == 1) {
            useridArr1 = [htmlContents componentsSeparatedByString:@"confidantuserid="];
        }
        
        NSArray *useridArr2 = [htmlContents componentsSeparatedByString:@"newconfidantuserid\n"];
        if (useridArr2 && useridArr2.count == 1) {
            useridArr2 = [htmlContents componentsSeparatedByString:@"newconfidantuserid"];
        }
        NSArray *useridArr = nil;
        if (useridArr1.count == 2) {
            useridArr = useridArr1;
        } else if (useridArr2.count == 2) {
            useridArr = useridArr2;
        }
        
        if (useridArr) {
            
            NSString *useridLastStr = [useridArr lastObject];
            useridLastStr = [useridLastStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            useridLastStr = [useridLastStr stringByReplacingOccurrencesOfString:@"'" withString:@""];
            
            
            NSString *friendid = [useridLastStr componentsSeparatedByString:@"></span>"][0];
            friendid = [friendid stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            friendid = [friendid stringByReplacingOccurrencesOfString:@"'" withString:@""];
            
            return friendid?:@"";
        }
        return @"";
        
    } else {
        return @"";
    }
   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableV) {
        if (!tableView.isEditing) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self jumpChatDetailOrEmailDetailWithObject:self.dataArray[indexPath.row] row:indexPath.row];
        }
    } else {
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
        [self jumpChatDetailOrEmailDetailWithObject:self.emailDataArray[indexPath.row] row:indexPath.row];
        
    }
        
}

- (void) jumpChatDetailOrEmailDetailWithObject:(id) object row:(NSInteger) row
{
    if ([object isKindOfClass:[ChatListModel class]]) {
        ChatListModel *chatModel = object;
        if (chatModel.isHD) {
            chatModel.isHD = NO;
            chatModel.unReadNum = @(0);
            [chatModel bg_saveOrUpdate];
            [_tableV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
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
    } else if ([object isKindOfClass:[EmailListInfo class]]) {
        
        EmailListInfo *model = object;
        model.floderName = self.floderModel.name;
        model.floderPath = self.floderModel.path;
        selEmailRow = row;
        
        if ([self.floderModel.name isEqualToString:Drafts]) { //草稿箱
            PNEmailSendViewController *vc = [[PNEmailSendViewController alloc] initWithEmailListInfo:model sendType:DraftEmail];
            [self presentModalVC:vc animated:YES];
            
        } else {
            PNEmailDetailViewController *vc = [[PNEmailDetailViewController alloc] initWithEmailListModer:model];
            [self.navigationController pushViewController:vc animated:YES];
            // 设为已读
            if (model.Read == 0) {
                model.Read = 1;
                [_emailTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                // 设为已读
                [EmailOptionUtil setEmailReaded:YES uid:model.uid messageId:@"" folderPath:model.floderPath complete:^(BOOL success) {
                    
                }];
            }
        }
    } else if ([object isKindOfClass:[GoogleMessageModel class]]) {
        
        GoogleMessageModel *model = object;
        EmailListInfo *emailM = [self tranGoogleMessageModelToEmailListInfoWithModel:model];
        emailM.floderName = self.floderModel.name;
        emailM.floderPath = self.floderModel.path;
        selEmailRow = row;
        
        if ([self.floderModel.name isEqualToString:Drafts]) { //草稿箱
            PNEmailSendViewController *vc = [[PNEmailSendViewController alloc] initWithEmailListInfo:emailM sendType:DraftEmail];
            [self presentModalVC:vc animated:YES];
            
        } else {
            PNEmailDetailViewController *vc = [[PNEmailDetailViewController alloc] initWithEmailListModer:emailM];
            [self.navigationController pushViewController:vc animated:YES];
            // 设为已读
            if (emailM.Read == 0) {
                emailM.Read = 1;
                model.isRead = YES;
                [_emailTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                // 设为已读
                [self sendGoogleLableRequestWithMessageModel:model];
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
            if (!AppD.isEmailPage) {
                @weakify_self
                [_tableV performBatchUpdates:^{
                    
                    // 删除
                    ChatListModel *chatModel = self->isSearch? weakSelf.searchDataArray[cell.tag] : weakSelf.dataArray[cell.tag];
                    self->isSearch? [self.searchDataArray removeObject:chatModel] : [weakSelf.dataArray removeObject:chatModel];
                    // 删除本地聊天记录
                    if (chatModel.isGroup) {
                        [[ChatListDataUtil getShareObject] removeGroupChatModelWithGID:chatModel.groupID?:@""];
                    } else {
                        [[ChatListDataUtil getShareObject] removeChatModelWithFriendID:chatModel.friendID?:@""];
                    }
                    
                     [weakSelf.tableV deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    
                }completion:^(BOOL finished){
                    [weakSelf.tableV reloadData];
                }];
                
//                // 删除
//                ChatListModel *chatModel = isSearch? self.searchDataArray[cell.tag] : self.dataArray[cell.tag];
//                [_tableV beginUpdates];
//                isSearch? [self.searchDataArray removeObject:chatModel] : [self.dataArray removeObject:chatModel];
//                // 删除本地聊天记录
//                if (chatModel.isGroup) {
//                    [[ChatListDataUtil getShareObject] removeGroupChatModelWithGID:chatModel.groupID?:@""];
//                } else {
//                    [[ChatListDataUtil getShareObject] removeChatModelWithFriendID:chatModel.friendID?:@""];
//                }
//
//                [_tableV deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
//                [_tableV endUpdates];
            } else {
                
                [self.view showHudInView:self.view hint:@""];
                EmailListInfo *listM = nil;
                if ([self.emailDataArray[cell.tag] isKindOfClass:[GoogleMessageModel class]]) {
                    listM = [self tranGoogleMessageModelToEmailListInfoWithModel:self.emailDataArray[cell.tag]];
                } else {
                    listM = self.emailDataArray[cell.tag];
                }
                 @weakify_self
                [EmailOptionUtil deleteEmailUid:listM.uid messageId:listM.messageid  folderPath:self.floderModel.path folderName:self.floderModel.name complete:^(BOOL success) {
                    
                    [weakSelf.view hideHud];
                    if (success) {
                        [weakSelf.emailTabView performBatchUpdates:^{
                            [weakSelf.emailDataArray removeObjectAtIndex:cell.tag];
                            [weakSelf.emailTabView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                            
                        }completion:^(BOOL finished){
                            [weakSelf.emailTabView reloadData];
                        }];
                        
                    } else {
                        [weakSelf.view showFaieldHudInView:weakSelf.view hint:@"Failure."];
                    }
                }];
            }
            
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
  //  AddGroupMenuViewController *vc = [[AddGroupMenuViewController alloc] init];
  //  [self.navigationController pushViewController:vc animated:YES];
    
    
    NSArray *titles = @[@"New Chat",@"New Email",@"Add Contacts",@"Invite Friends"];
    NSArray *images = @[@"tabbar_circle_selected",@"tabbar_email_selected",@"add_contacts",@"invite friends"];
    
    NSString *currentRouterSn = [RouterConfig getRouterConfig].currentRouterSn;
    NSString *userType = [currentRouterSn substringWithRange:NSMakeRange(0, 2)];
    
    if ([userType isEqualToString:@"01"]) { // 01:admin
        titles = @[@"New Chat",@"New Email",@"Add Contacts",@"Invite Friends",@"Add Members"];
        images = @[@"tabbar_circle_selected",@"tabbar_email_selected",@"add_contacts",@"invite friends",@"add Members"];
    }
    
    MLMenuView *menuView = [[MLMenuView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 180 - 10, 0, 180, 50 * images.count) WithTitles:titles WithImageNames:images WithMenuViewOffsetTop:NAVIGATION_BAR_HEIGHT WithTriangleOffsetLeft:160 triangleColor:RGBP(255, 255, 255, 0.8)];
    menuView.titleColor = MAIN_PURPLE_COLOR;
    menuView.font = [UIFont systemFontOfSize:16];
    menuView.separatorAlpha = 0;
    @weakify_self
    menuView.didSelectBlock = ^(NSInteger index) {
        
        if (index == 0) { // 创建群组
            [weakSelf jumpCreateGroup];
        } else if (index == 1) { // new email
            [weakSelf jumpNewEmail];
        } else if (index == 2) { // add contacts
            [weakSelf jumpScanCoder];
        } else if (index == 3) { // Invite Friends
            [weakSelf jumpFriendNewEmail];
        }  else if (index == 4) { // add members
            [weakSelf jumpAddMembers];
        }
       
    };
    [menuView showMenuEnterAnimation:MLEnterAnimationStyleRight];
}

#pragma mark - 消息发生改变通知
- (void) chatMessageChangeNoti:(NSNotification *) noti
{
     [self updateData];
}
- (void) cricleChangeChangeNoti:(NSNotification *) noti
{
    [self updateData];
    // 更新节点名字
    if (!AppD.isEmailPage) {
        _lblSubTitle.text = [RouterModel getConnectRouter].name;
    }
    // 上传邮箱配置到节点
    NSArray *emails = [EmailAccountModel getLocalAllEmailAccounts];
    [emails enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EmailAccountModel *accountM = obj;
        [SendRequestUtil sendEmailConfigWithEmailAddress:[accountM.User lowercaseString] type:@(accountM.Type) caller:@(0) configJson:@"" ShowHud:NO];
    }];
}
- (void) addOwnerToChatNoti:(NSNotification *) noti
{
    FriendModel *friendM = [ChatListDataUtil getShareObject].friendArray[0];
    ChatListModel *chatM = [[ChatListModel alloc] init];
    chatM.myID = [UserConfig getShareObject].usersn;
    chatM.friendID = friendM.userId;
    chatM.lastMessage = @"";
    chatM.chatTime = [NSDate date];
    [[ChatListDataUtil getShareObject] addFriendModel:chatM];
    
}
- (void) MessageStatusChangeNoti:(NSNotification *) noti
{
    if (AppD.isEmailPage) {
        [_emailTabView reloadData];
    } else {
        [_tableV reloadData];
    }
}
- (void) noEmailConfigNoti:(NSNotification *) noti
{
    _lblTitle.text = @"Email";
    _lblSubTitle.text = @"Not Configured";
    _emailTabView.mj_footer.hidden = YES;
    _emailTabView.mj_header.hidden = YES;
    
    if (self.emailDataArray.count > 0) {
        [self.emailDataArray removeAllObjects];
        [self.emailTabView reloadData];
    }
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

#pragma mark ------------email 通知回调-------------------
// 邮箱帐号改变
- (void) emailAccountChangeNoti:(NSNotification *) noti
{
    _emailTabView.mj_header.hidden = NO;
    [self.view hideHud];
    [self firstPullEmailList];
}
- (void) pullEmailNoti:(NSNotification *) noti
{
    NSDictionary *dic = noti.object;
    NSInteger retCode = [dic[@"RetCode"] integerValue];
    if (retCode == 0) {
        @weakify_self
        NSArray *Payloads = dic[@"Payload"];
        if (Payloads && Payloads.count > 0) {
            if (Payloads.count == 10) {
                 self.emailTabView.mj_footer.hidden = NO;
            } else {
                [_emailTabView.mj_footer endRefreshing];
                self.emailTabView.mj_footer.hidden = YES;
            }
            __block NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:Payloads.count];
            [Payloads enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *payloadDic = obj;
                NSString *dsKey = payloadDic[@"Userkey"]?:@"";
                
                NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:dsKey];
                if (datakey && datakey.length >= 16) {
                    
                    datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
                    
                    NSString *emialJosn = aesDecryptString(payloadDic[@"MailInfo"], datakey);
                    EmailNodeModel *nodeM = [EmailNodeModel getObjectWithKeyValues:[emialJosn mj_JSONObject]];
                    EmailListInfo *emailM = [[EmailListInfo alloc] init];
                    emailM.Read = (int)nodeM.flags;
                    emailM.attachCount = (int)nodeM.attchCount;
                    emailM.Subject = nodeM.subTitle;
                    emailM.fromName = nodeM.fromName;
                    emailM.From = nodeM.fromEmailBox;
                    emailM.content = nodeM.content;
                    emailM.revDate = [NSDate dateWithTimeIntervalSince1970:nodeM.revDate];
                    emailM.EmailPath = payloadDic[@"EmailPath"]?:@"";
                    emailM.uid = [payloadDic[@"Id"] intValue];
                    emailM.deKey = datakey;
                    
                    if (nodeM.toUserJosn && nodeM.toUserJosn.length > 0) {
                        NSArray *tojs = [nodeM.toUserJosn mj_JSONObject];
                        emailM.toUserArray = [EmailUserModel mj_objectArrayWithKeyValuesArray:tojs];
                    }
                    if (nodeM.ccUserJosn && nodeM.ccUserJosn.length > 0) {
                        NSArray *tojs = [nodeM.ccUserJosn mj_JSONObject];
                        emailM.ccUserArray = [EmailUserModel mj_objectArrayWithKeyValuesArray:tojs];
                    }
                    if (nodeM.bccUserJosn && nodeM.bccUserJosn.length > 0) {
                        NSArray *tojs = [nodeM.bccUserJosn mj_JSONObject];
                        emailM.bccUserArray = [EmailUserModel mj_objectArrayWithKeyValuesArray:tojs];
                    }
                    [tempArray addObject:emailM];
                }
            }];
            [self.emailDataArray addObjectsFromArray:tempArray];
            [self.emailTabView reloadData];
        } else {
            [_emailTabView.mj_footer endRefreshing];
            self.emailTabView.mj_footer.hidden = YES;
        }
    } else {
        [self.view showHint:@"pull faield."];
        if (startId > 0) {
            [_emailTabView.mj_footer endRefreshing];
        }
    }
}
    
// 邮件flags改变
- (void) emailFlagsChangeNoti:(NSNotification *) noti
{
    int optionType = [noti.object intValue];
    
    if ([self.emailDataArray[0] isKindOfClass:[GoogleMessageModel class]]) {
        
        if (optionType == 0 || optionType == 1) { // 未读 和 加星
            if (optionType == 0) { // 未读
                GoogleMessageModel *model = self.emailDataArray[selEmailRow];
                model.isRead = NO;
            } else {
                GoogleMessageModel *model = self.emailDataArray[selEmailRow];
                model.isStarred = NO;
            }
           
            [self.emailTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selEmailRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        } else if (optionType == 2 || optionType == 3) { // 移动到  和 删除
            
            [self.emailDataArray removeObjectAtIndex:selEmailRow];
            [self.emailTabView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selEmailRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            //self.floderModel.count--;
            
        } else if (optionType == 4) { // 星标邮件取消星标
            [self.emailDataArray removeObjectAtIndex:selEmailRow];
            [self.emailTabView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selEmailRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            //self.floderModel.count--;
        }
        
    } else {
        
        if (optionType == 0 || optionType == 1) { // 未读 和 加星
            [self.emailTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selEmailRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        } else if (optionType == 2 || optionType == 3) { // 移动到  和 删除
            
            [self.emailDataArray removeObjectAtIndex:selEmailRow];
            [self.emailTabView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selEmailRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            self.floderModel.count--;
        } else if (optionType == 4) { // 星标邮件取消星标
            [self.emailDataArray removeObjectAtIndex:selEmailRow];
            [self.emailTabView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:selEmailRow inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            self.floderModel.count--;
        }
        
    }
    
    
   
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
    [self.view hideHud];
    NSLog(@"flodername = %@---floderpath = %@",floderModel.name,floderModel.path);
    if ([self.floderModel.name isEqualToString:floderModel.name]) {
        return;
    }
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    
    _lblTitle.text = floderModel.name;
    self.floderModel = floderModel;
    _page = 1;
    _maxUid = 0;
    if ([self.floderModel.name isEqualToString:Inbox]) {
        _maxUid = [[HWUserdefault getObjectWithKey:accountM.User] intValue];
    }
    self.nextPageToken = @"";
    
    [_emailTabView.mj_footer endRefreshing];
    [_emailTabView.mj_header endRefreshing];
    _emailTabView.mj_footer.hidden = YES;
    
    _emailTabView.mj_header.hidden = NO;
    if ([self.floderModel.name isEqualToString:Starred] || [self.floderModel.name isEqualToString:Node_backed_up]) {
        _emailTabView.mj_header.hidden = YES;
    }
    
    
    
    
    // googleapi
    if (accountM.userId && accountM.userId.length > 0) {
        
        if (self.emailDataArray.count > 0) {
            [self.emailDataArray removeAllObjects];
            [_emailTabView reloadData];
        }
        
        [self pullEmailList];
        
        return;
    }
    
    
    if (self.floderModel.path.length > 0) {
         [self pullEmailList];
    } else {
        if (self.emailDataArray.count > 0) {
            [self.emailDataArray removeAllObjects];
            [_emailTabView reloadData];
        }
        
        if ([self.floderModel.name isEqualToString:Starred]) {
            
            NSString *whereSql = [NSString stringWithFormat:@"where %@=%@ order by %@ desc",bg_sqlKey(@"emailAddress"),bg_sqlValue(accountM.User),bg_sqlKey(@"uid")];
             [self.view showHudInView:self.view hint:@"Loading"];
            @weakify_self
            [EmailListInfo bg_findAsync:EMAIL_STAR_TABNAME where:whereSql complete:^(NSArray * _Nullable array) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [weakSelf.view hideHud];
                    
                    if (array && array.count > 0) {
                        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            EmailListInfo *infoM = obj;
                            if (infoM.ToJson && infoM.ToJson.length > 0) {
                                NSArray *tojs = [infoM.ToJson mj_JSONObject];
                                infoM.toUserArray = [EmailUserModel mj_objectArrayWithKeyValuesArray:tojs];
                            }
                            if (infoM.ccJsons && infoM.ccJsons.length > 0) {
                                NSArray *tojs = [infoM.ccJsons mj_JSONObject];
                                infoM.ccUserArray = [EmailUserModel mj_objectArrayWithKeyValuesArray:tojs];
                            }
                            if (infoM.bccJsons && infoM.bccJsons.length > 0) {
                                NSArray *tojs = [infoM.bccJsons mj_JSONObject];
                                infoM.bccUserArray = [EmailUserModel mj_objectArrayWithKeyValuesArray:tojs];
                            }
                        }];
                        [weakSelf.emailDataArray addObjectsFromArray:array];
                        [weakSelf.emailTabView reloadData];
                    }
                });
            }];
        } else if ([self.floderModel.name isEqualToString:Node_backed_up]){ // 节点邮件
            [self pullEmailList];
        }
    }
}
// 拉取邮件列表
- (void) pullEmailList
{
    // 拉取节点邮件
    if ([self.floderModel.name isEqualToString:Node_backed_up]) {
        if (self.emailDataArray.count == 0) {
            self.emailTabView.mj_footer.hidden = YES;
            startId = 0;
        } else {
            EmailListInfo *emailM = [self.emailDataArray lastObject];
            startId = emailM.uid;
        }
        if (startId == 0) {
            [SendRequestUtil sendPullEmailWithStarid:@(startId) num:@(10) showHud:YES];
        } else {
            [SendRequestUtil sendPullEmailWithStarid:@(startId) num:@(10) showHud:NO];
        }
        
        return;
    }
    
     EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
    // 如果是 google api 请求
    if (accountModel.userId && accountModel.userId.length > 0) {
        
        if (!AppD.isGoogleSign) {
            if (_isRefresh) {
                _isRefresh = NO;
                [self.emailTabView.mj_header endRefreshing];
            }
            [self.view showHudInView:self.view hint:@""];
            NSArray *currentScopes = @[@"https://mail.google.com/"];
            [GIDSignIn sharedInstance].scopes = currentScopes;
            [[GIDSignIn sharedInstance] signIn];
            
        } else {
            
            BOOL isShow = [self.nextPageToken isEmptyString] && !_isRefresh;
            [self sendGoogleRequestWithShow:isShow];
            
        }
        
       
        return;
    }
    
    if (_isRefresh) { // 上拉
       
        if (self.floderModel.count == 0) {
            
            MCOIMAPFolderInfoOperation * folderInfoOperation = [EmailManage.sharedEmailManage.imapSeeion folderInfoOperation:self.floderModel.path];
            
            @weakify_self
            [folderInfoOperation start:^(NSError *error, MCOIMAPFolderInfo * info) {
                if (error) {
                    weakSelf.floderModel.count = (int) weakSelf.currentEmailCount;
                    weakSelf.isRefresh = NO;
                    [weakSelf.view hideHud];
                    [weakSelf.emailTabView.mj_header endRefreshing];
                    [weakSelf.view showHint:@"Failed to pull mail."];
                } else {
                    if (weakSelf.emailDataArray.count == 0) {
                        weakSelf.isRequestFloderCount = YES;
                        weakSelf.floderModel.count = info.messageCount;
                        if (info.messageCount > 0) {
                            [weakSelf pullEmailList];
                        } else {
                            [weakSelf.view hideHud];
                            weakSelf.isRefresh = NO;
                            [weakSelf.emailTabView.mj_header endRefreshing];
                        }
                        
                    }
                }
            }];
            return;
        }
        
    } else {
        if (_page == 1) {
            self.emailTabView.mj_footer.hidden = YES;
        }
        
        if (self.emailDataArray.count > 0 && _page == 1) {
            [self.emailDataArray removeAllObjects];
            [_emailTabView reloadData];
        }
        
        if (self.floderModel.count == 0) {
            self.emailTabView.mj_footer.hidden = YES;
            if (_isRequestFloderCount) {
                [self.view hideHud];
            }
            return;
        }
        if (_page == 1 && !_isRequestFloderCount) {
            [self.view showHudInView:self.view hint:@"Loading" userInteractionEnabled:NO hideTime:REQEUST_TIME];
        }
        _isRequestFloderCount = NO;
    }
    
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    (MCOIMAPMessagesRequestKindHeaders |MCOIMAPMessagesRequestKindExtraHeaders |MCOIMAPMessagesRequestKindStructure |MCOIMAPMessagesRequestKindInternalDate |MCOIMAPMessagesRequestKindHeaderSubject |MCOIMAPMessagesRequestKindFlags);
    
   __block MCOIMAPFetchMessagesOperation *imapMessagesFetchOp = nil;
    
    uint64_t locationf = 1;
    uint64_t lengthf = 20;
    
    // 第一次拉取
    if (_page == 1 && _maxUid >0 && [_floderModel.name isEqualToString:Inbox]) {
        
        MCOIndexSet *firstNumbers = [MCOIndexSet indexSetWithRange:MCORangeMake(_floderModel.count, 1)];
        imapMessagesFetchOp = [EmailManage.sharedEmailManage.imapSeeion fetchMessagesByNumberOperationWithFolder:self.floderModel.path
        requestKind:requestKind
                                         numbers:firstNumbers];
        // 异步获取邮件
        @weakify_self
        [imapMessagesFetchOp start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
            if (error) {
                [weakSelf emailPullFailShowWithError:error];
            } else {
                if (messages.count == 0) {
                    if (weakSelf.isRefresh) {
                        weakSelf.isRefresh = NO;
                        [weakSelf.emailTabView.mj_header endRefreshing];
                    } else {
                        [weakSelf.view hideHud];
                        [weakSelf.emailTabView.mj_footer endRefreshing];
                    }
                    [weakSelf.view showHint:@"No mail available."];
                } else {
                    
                    MCOIMAPMessage *message = messages[0];
                    int subEmailCount = abs(message.uid - weakSelf.maxUid);
                    // 如果有 10封以上新邮件处理
                    MCOIndexSet *firstNumbers = [MCOIndexSet indexSetWithRange:MCORangeMake(weakSelf.maxUid+1,subEmailCount)];
                    imapMessagesFetchOp = [EmailManage.sharedEmailManage.imapSeeion fetchMessagesByNumberOperationWithFolder:self.floderModel.path
                    requestKind:requestKind
                                                     numbers:firstNumbers];
                     // 拉取所有新邮件
                     [imapMessagesFetchOp start:^(NSError *error, NSArray *messages1, MCOIndexSet *vanishedMessages) {
                         
                         if (error) {
                             [weakSelf emailPullFailShowWithError:error];
                         }  else {
                             
                             if (messages1.count >= 20) {
                                 // 倒序
                                 if (!weakSelf.isRefresh) {
                                      weakSelf.page ++;
                                 }
                                 // 根据uid 排序
                                 NSMutableArray *messageArray = [NSMutableArray arrayWithArray:messages1];
                                 NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:NO];
                                 [messageArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                                 // 转换mode
                                 [weakSelf tranEmailListInfoWithArr:messageArray];
                                 
                             } else {
                                 
                                 int startIndex = 1;
                                 int len = 0;
                                 if (weakSelf.floderModel.count > weakSelf.pageCount) {
                                     startIndex = (weakSelf.floderModel.count - weakSelf.pageCount)+1;
                                     len = weakSelf.pageCount-1;
                                 } else {
                                     len = weakSelf.floderModel.count-1;
                                 }
                                 MCOIndexSet *fNumbers = [MCOIndexSet indexSetWithRange:MCORangeMake(startIndex,len)];
                                 imapMessagesFetchOp = [EmailManage.sharedEmailManage.imapSeeion fetchMessagesByNumberOperationWithFolder:self.floderModel.path
                                 requestKind:requestKind
                                                                  numbers:fNumbers];
                                 
                                 // 拉取所有新邮件
                                 [imapMessagesFetchOp start:^(NSError *error, NSArray *messages2, MCOIndexSet *vanishedMessages) {
                                     if (error) {
                                         [weakSelf emailPullFailShowWithError:error];
                                     }  else {
                                         // 倒序
                                         if (!weakSelf.isRefresh) {
                                              weakSelf.page ++;
                                         }
                                         // 根据uid 排序
                                         NSMutableArray *messageArray = [NSMutableArray arrayWithArray:messages2];
                                         NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:NO];
                                         [messageArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                                         // 转换mode
                                         [weakSelf tranEmailListInfoWithArr:messageArray];
                                     }
                                 }];
                                 
                             }
                         }
                         
                     }];
                    
                } //messcout == 0
            }
        }];
        
        return;
    }
    
    
    
    if (_isRefresh && _maxUid >0) {
        lengthf = _pageCount-1;
        if ([_floderModel.name isEqualToString:Inbox]) {
            lengthf = 100;
        }
        locationf = _maxUid+1;
    } else {
        CGFloat syCount = self.floderModel.count - self.emailDataArray.count;
        if (syCount > _pageCount) {
            locationf = (syCount - _pageCount)+1;
            lengthf = _pageCount-1;
        } else {
            lengthf = syCount-1;
        }
    }
    
    MCOIndexSet *numbers = [MCOIndexSet indexSetWithRange:MCORangeMake(locationf, lengthf)];
    
    if (_isRefresh && _maxUid >0) {
         imapMessagesFetchOp = [EmailManage.sharedEmailManage.imapSeeion fetchMessagesOperationWithFolder:self.floderModel.path requestKind:requestKind uids:numbers];
    } else {
        imapMessagesFetchOp = [EmailManage.sharedEmailManage.imapSeeion fetchMessagesByNumberOperationWithFolder:self.floderModel.path
                                                                        requestKind:requestKind
                                                                                                         numbers:numbers];
    }
    
  
    // 异步获取邮件
    @weakify_self
    [imapMessagesFetchOp start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
        
        if (EmailManage.sharedEmailManage.imapSeeion == nil) {
            [weakSelf.view hideHud];
            weakSelf.isRefresh = NO;
            [weakSelf.emailTabView.mj_header endRefreshing];
            [weakSelf.emailTabView.mj_footer endRefreshing];
            return ;
        }
        
        if (error) {
            [weakSelf emailPullFailShowWithError:error];
        } else {
            
            if (messages.count == 0) {
                if (weakSelf.isRefresh) {
                    weakSelf.isRefresh = NO;
                    [weakSelf.emailTabView.mj_header endRefreshing];
                } else {
                    [weakSelf.view hideHud];
                    [weakSelf.emailTabView.mj_footer endRefreshing];
                }
                return;
            }
            
            // 倒序
            if (!weakSelf.isRefresh) {
                 weakSelf.page ++;
            }
            //NSArray *messageArray = [[messages reverseObjectEnumerator] allObjects];
            // [weakSelf tranEmailListInfoWithArr:messageArray];
            
            // 根据uid 排序
            NSMutableArray *messageArray = [NSMutableArray arrayWithArray:messages];
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:NO];
            [messageArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            // 转换mode
            [weakSelf tranEmailListInfoWithArr:messageArray];
           // [weakSelf.emailDataArray addObjectsFromArray:messageArray];
            
            
            
//            [weakSelf.emailTabView reloadData];
//
//            if (weakSelf.isRefresh) {
//                weakSelf.isRefresh = NO;
//                [weakSelf.emailTabView.mj_header endRefreshing];
//            } else {
//                [weakSelf.view hideHud];
//                [weakSelf.emailTabView.mj_footer endRefreshing];
//            }
        }
    }];
}
// 邮件拉取失败提示
- (void) emailPullFailShowWithError:(NSError *) error
{
    if (self.isRefresh) { // 是上拉刷新
        self.floderModel.count = (int) self.currentEmailCount;
        self.isRefresh = NO;
        [self.emailTabView.mj_header endRefreshing];
    } else {
        if (self.page == 1) {
            [self.view hideHud];
        } else {
            self.emailTabView.mj_footer.hidden = NO;
        }
        [self.emailTabView.mj_footer endRefreshing];
    }
    
    if (error.code == 1) {
        [self.view showHint:@"Unable to connect to email server."];
    } else {
        EmailAccountModel *accoutM = [EmailAccountModel getConnectEmailAccount];
        NSString *errorStr = [NSString stringWithFormat:@"%@ Unsuccessful verification. Please check the password, or the IMAP service is not available.",accoutM.User];
        EmailErrorAlertView *alertView = [EmailErrorAlertView loadEmailErrorAlertView];
        alertView.lblContent.text = errorStr;
        [alertView showEmailAttchSelView];
    }
}
// 转换成 emaillistinfo
- (void) tranEmailListInfoWithArr:(NSArray *) messageArray
{
    
    EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
    
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
                if (toA.mailbox && toA.mailbox.length > 0) {
                    EmailUserModel *userM = [[EmailUserModel alloc] init];
                    if (i == 0) {
                        userM.userType = UserTo;
                    }
                    userM.userName = toA.displayName?:[[toA.mailbox componentsSeparatedByString:@"@"] firstObject];
                    userM.userName = [userM.userName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    userM.userAddress = toA.mailbox;
                    userM.userAddress = [userM.userAddress stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    [listInfo.toUserArray addObject:userM];
                }
                
            }
        }
        // 获取多个抄送人
        NSArray *ccAddressArray = headrMessage.cc;
        if (ccAddressArray) {
            listInfo.ccUserArray = [NSMutableArray array];
            for (int i =0; i<ccAddressArray.count; i++) {
                MCOAddress *toA = ccAddressArray[i];
                if (toA.mailbox && toA.mailbox.length > 0) {
                    EmailUserModel *userM = [[EmailUserModel alloc] init];
                    if (i == 0) {
                        userM.userType = UserCc;
                    }
                    userM.userName = toA.displayName?:[[toA.mailbox componentsSeparatedByString:@"@"] firstObject];
                    userM.userName = [userM.userName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    userM.userAddress = toA.mailbox;
                    userM.userAddress = [userM.userAddress stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    [listInfo.ccUserArray addObject:userM];
                }
                
            }
        }
        
        // 获取多个密送人
        NSArray *bccAddressArray = headrMessage.bcc;
        if (bccAddressArray) {
            listInfo.bccUserArray = [NSMutableArray array];
            for (int i =0; i<bccAddressArray.count; i++) {
                MCOAddress *toA = bccAddressArray[i];
                if (toA.mailbox && toA.mailbox.length > 0) {
                    EmailUserModel *userM = [[EmailUserModel alloc] init];
                    if (i == 0) {
                        userM.userType = UserBcc;
                    }
                    userM.userName = toA.displayName?:[[toA.mailbox componentsSeparatedByString:@"@"] firstObject];
                    userM.userName = [userM.userName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    userM.userAddress = toA.mailbox;
                    userM.userAddress = [userM.userAddress stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    [listInfo.bccUserArray addObject:userM];
                }
                
            }
        }
        
   
        listInfo.uid = message.uid;
        if (listInfo.uid >weakSelf.maxUid) { // 取到最大uid
            weakSelf.maxUid = listInfo.uid;
            NSLog(@"---maxUid = %d",weakSelf.maxUid);
            if ([weakSelf.floderModel.name isEqualToString:Inbox]) {
                [HWUserdefault updateObject:@(weakSelf.maxUid) withKey:accountModel.User];
            }
        }
        listInfo.Read = message.flags;
        listInfo.messageid = headrMessage.messageID;
       // NSLog(@"-----messageid------%@",listInfo.messageid);
        listInfo.fromName = address.displayName?:@"";
        listInfo.fromName = [listInfo.fromName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        listInfo.From = address.mailbox;
        listInfo.From = [listInfo.From stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        if (listInfo.fromName.length == 0) {
            listInfo.fromName = [address.mailbox componentsSeparatedByString:@"@"][0];
        }
        listInfo.Subject = message.header.subject;
        listInfo.revDate = message.header.receivedDate;
        [tempArray addObject:listInfo];
        
        if (![self.floderModel.name isEqualToString:Spam]) {
             [EmailDataBaseUtil insertDataWithUser:accountModel.User userName:listInfo.fromName userAddress:listInfo.From date:listInfo.revDate];
        }
        
        MCOIMAPFetchContentOperation * fetchContentOp = [EmailManage.sharedEmailManage.imapSeeion fetchMessageOperationWithFolder:self.floderModel.path uid:listInfo.uid];
        listInfo.fetchContentOp = fetchContentOp;
        
    }];
    
    if (self.isRefresh) {
        [self.emailDataArray insertObjects:tempArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tempArray.count)]];
    } else {
        [self.emailDataArray addObjectsFromArray:tempArray];
    }
    
    [self.emailTabView reloadData];
    
    if (weakSelf.isRefresh) {
        weakSelf.isRefresh = NO;
        [weakSelf.emailTabView.mj_header endRefreshing];
    } else {
        [weakSelf.view hideHud];
        [weakSelf.emailTabView.mj_footer endRefreshing];
        if (messageArray.count == weakSelf.pageCount) {
            weakSelf.emailTabView.mj_footer.hidden = NO;
        } else {
            weakSelf.emailTabView.mj_footer.hidden = YES;
        }
    }
    
    
    return;
    
    
    __block int endCount = 0;
    for (int i =0; i<tempArray.count; i++) {
        EmailListInfo *info = tempArray[i];
        MCOIMAPFetchContentOperation * fetchContentOp = [EmailManage.sharedEmailManage.imapSeeion fetchMessageOperationWithFolder:self.floderModel.path uid:info.uid];
        info.fetchContentOp = fetchContentOp;
        [info.fetchContentOp start:^(NSError * error, NSData * data) {
            
            endCount++;
            
            if ([error code] != MCOErrorNone) {
                NSLog(@"解析邮件失败");
            }
            MCOMessageParser *messageParser = [MCOMessageParser messageParserWithData:data];
            info.attachCount = (int)messageParser.attachments.count;
            NSString *content = [messageParser plainTextBodyRenderingAndStripWhitespace:YES]?:@"";
            // 去除带有附件名字段
            if (info.attachCount > 0) {
                NSArray *contentArr = [content componentsSeparatedByString:@" "];
                if ([contentArr[0] containsString:@"-"] ) {
                    content = [contentArr lastObject];
                } else {
                    content = contentArr[0];
                }
            }
            
            NSString *htmlContents = [messageParser htmlBodyRendering];
            
            // 检查是否需要解密
            __block NSString *dsKey = @"";
            if (htmlContents && htmlContents.length > 0) {
                NSArray *arrs = [htmlContents componentsSeparatedByString:@"confidantkey=\n'"];
                if (arrs && arrs.count == 2) {
                    
                    EmailAccountModel *accountM =[EmailAccountModel getConnectEmailAccount];
                    
                    NSString *enStr = [[arrs lastObject] componentsSeparatedByString:@"'></span>"][0];
                    NSArray *emailUserkeys = [enStr componentsSeparatedByString:@"##"];
                    if (emailUserkeys && emailUserkeys.count > 0) {
                        [emailUserkeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            NSString *uks = obj;
                            NSArray *userkeys = [uks componentsSeparatedByString:@"&amp;&amp;"];
                            if ([accountM.User isEqualToString:[userkeys[0] base64DecodedString]]) {
                                dsKey = userkeys[1];
                            }
                        }];
                    }
                }
            }
           
            
            if (dsKey.length > 0) {
                NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:dsKey];
                if (datakey && datakey.length >= 16) {
                    datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
                    NSString *bodyStr = [htmlContents componentsSeparatedByString:@"</body>"][0];
                    NSString *enStr = [[bodyStr componentsSeparatedByString:@"<body>"] lastObject];
                    NSString *spanStr = [enStr componentsSeparatedByString:@"<span style='display:none'"][0];
                    NSString *deStr = aesDecryptString(spanStr, datakey)?:@"";
                    if (deStr.length > 0) {
                        htmlContents = [htmlContents stringByReplacingOccurrencesOfString:enStr withString:[deStr stringByAppendingString:confidantHtmlStr]];
                    }
                    content = [content stringByReplacingOccurrencesOfString:confidantEmialStr withString:@""];
                    content = [content stringByReplacingOccurrencesOfString:confidantEmialText withString:@""];
                    content = aesDecryptString([content componentsSeparatedByString:@" "][0], datakey)?:content;
                    content = [self filterHTML:content];
                    info.deKey = datakey;
                }
                //fileData = aesDecryptData(fileData, [datakey dataUsingEncoding:NSUTF8StringEncoding]);
            }
            
            NSArray *attchArray = messageParser.attachments;
            if (attchArray && attchArray.count > 0) {
                 //去除附件
                NSString *attHtml =[[htmlContents componentsSeparatedByString:@"<hr/>"] lastObject];
                NSRange range = [htmlContents rangeOfString:[@"<hr/>" stringByAppendingString:attHtml]];
                if (range.location != NSNotFound) {
                    NSString *htmlRangeContents = [htmlContents substringWithRange:NSMakeRange(0, range.location)];
                    if (htmlContents && htmlContents.length > 0) {
                        htmlContents = htmlRangeContents;
                    }
                }
            }
            info.content = [content componentsSeparatedByString:@" "][0];
            info.htmlContent = htmlContents;
            info.parserData = data;
            
            // 转换附件类型
            info.attchArray = [NSMutableArray array];
            if (attchArray) {
                [attchArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    MCOAttachment *attInfo = obj;
                    EmailAttchModel *attModel = [[EmailAttchModel alloc] init];
                    attModel.attId = attInfo.uniqueID;
                    attModel.attName = attInfo.filename;
                    attModel.attData = attInfo.data;
                    [info.attchArray addObject:attModel];
                }];
            }
            
            
//            [tempArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                EmailListInfo *listModel = obj;
//               NSLog(@"-----uid------%@",messageParser.header.messageID);
//                if ([messageParser.header.messageID isEqualToString:listModel.messageid]) {
//                    
//                    // NSLog(@"-----uid------%@",messageParser.header.messageID);
//                    
//                    listModel.content = content;
//                    listModel.htmlContent = htmlContents;
//                    listModel.parserData = data;
//                    // 转换附件类型
//                    listModel.attchArray = [NSMutableArray array];                    if (attchArray) {
//                        [attchArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                            MCOAttachment *attInfo = obj;
//                            EmailAttchModel *attModel = [[EmailAttchModel alloc] init];
//                            attModel.attId = attInfo.uniqueID;
//                            attModel.attName = attInfo.filename;
//                            attModel.attData = attInfo.data;
//                            [listModel.attchArray addObject:attModel];
//                        }];
//                    }
//                    *stop = YES;
//                }
//            }];
            // 判断是否完成
            if (endCount == tempArray.count) {
                
                if (weakSelf.isRefresh) {
                    [weakSelf.emailDataArray insertObjects:tempArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, tempArray.count)]];
                } else {
                     [weakSelf.emailDataArray addObjectsFromArray:tempArray];
                }
               
                [weakSelf.emailTabView reloadData];
                
                if (weakSelf.isRefresh) {
                    weakSelf.isRefresh = NO;
                    [weakSelf.emailTabView.mj_header endRefreshing];
                } else {
                    [weakSelf.view hideHud];
                    [weakSelf.emailTabView.mj_footer endRefreshing];
                }
               
            }
        }];
    }
}
///获取HTML标签中的信息
- (NSString *)filterHTML:(NSString *)html{
    if (!html || html.length == 0) {
        return @"";
    }
    
//    NSDictionary *dic = @{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType};
//    NSData *data = [html dataUsingEncoding:NSUnicodeStringEncoding];
//    NSAttributedString *attriStr = [[NSAttributedString alloc] initWithData:data options:dic documentAttributes:nil error:nil];
//    NSString *str = attriStr.string;
//    str = [NSString trimWhitespace:str];
//    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
//    return str;
    return [html getHtmlText];
    
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


- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController
{
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentModalVC:viewController animated:YES];
    
}
- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

//- (IBAction)didTapDisconnect:(id)sender {
//    [[GIDSignIn sharedInstance] disconnect];
//}


#pragma mark -----------------google api reqeuest----------------

- (void) sendGoogleRequestWithShow:(BOOL) isShowHud
{
    EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
    NSString *nextToken = self.nextPageToken?:@"";
    NSInteger num = 15;
    if (_isRefresh) {
        nextToken = @"";
        if (self.emailDataArray.count > 0) {
            num = 15;
        }
    }
    NSString *labelId = @"INBOX";
    if ([self.floderModel.name isEqualToString:Starred]) {
        labelId = @"STARRED";
    } else if ([self.floderModel.name isEqualToString:Drafts]) {
        labelId = @"DRAFT";
    } else if ([self.floderModel.name isEqualToString:Sent]) {
        labelId = @"SENT";
    } else if ([self.floderModel.name isEqualToString:Spam]) {
        labelId = @"SPAM";
    } else if ([self.floderModel.name isEqualToString:Trash]) {
        labelId = @"TRASH";
    }
    
    GTLRGmailQuery_UsersMessagesList *messageList =  [GTLRGmailQuery_UsersMessagesList queryWithUserId:accountModel.userId num:num nextPage:nextToken labelIds:labelId];
    if (isShowHud) {
        [self.view hideHud];
        [self.view showHudInView:self.view hint:@""];
    }
     
    @weakify_self
    [[GoogleServerManage getGoogleServerManageShare].gmailService executeQuery:messageList completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        if (callbackError) { // 获取邮件失败
            if (isShowHud) {
                [weakSelf.view hideHud];
                [weakSelf.view showHint:@"Failed to pull mail."];
            }
            weakSelf.isRefresh = NO;
        } else {
            GTLRObject *gtlM = object;
            NSString *pageToken = gtlM.JSON[@"nextPageToken"]?:@"";
            weakSelf.googleTempLists = gtlM.JSON[@"messages"]?:@[];
            
            // 没有邮件
            if (weakSelf.googleTempLists.count == 0) {
                if (weakSelf.isRefresh) {
                    weakSelf.isRefresh = NO;
                    [weakSelf.emailTabView.mj_header endRefreshing];
                } else {
                    [weakSelf.emailTabView.mj_footer endRefreshing];
                    weakSelf.emailTabView.mj_footer.hidden = YES;
                }
                
                if (isShowHud) {
                    [weakSelf.view hideHud];
                }
                return ;
            }
            
            // 没有新邮件
            if (weakSelf.isRefresh) {
                if (weakSelf.emailDataArray.count > 0) {
                    GoogleMessageModel *messageM = weakSelf.emailDataArray[0];
                    if ([messageM.messageId isEqualToString:weakSelf.googleTempLists[0][@"id"]]) {
                        weakSelf.isRefresh = NO;
                        [weakSelf.emailTabView.mj_header endRefreshing];
                        return;
                    }
                }
            }
            
            weakSelf.messageCount = 0;
            [weakSelf.googleTempLists enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *messageDic = obj;
                [weakSelf sendGoogleMessageGetWithMessageId:messageDic[@"id"] nextPageToken:pageToken];
                
            }];
        }
    }];
}

/**
 根据 Id 得到邮件详情

 @param messageId id
 @param pageToken page
 */
- (void) sendGoogleMessageGetWithMessageId:(NSString *) messageId nextPageToken:(NSString *) pageToken
{
    EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
    GTLRGmailQuery_UsersMessagesGet *messageGet = [GTLRGmailQuery_UsersMessagesGet queryWithUserId:accountModel.userId identifier:messageId];
    @weakify_self
    [[GoogleServerManage getGoogleServerManageShare].gmailService executeQuery:messageGet completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        
        weakSelf.messageCount++;
        if (callbackError) {
            
        } else {
            GTLRObject *gtlM = object;
            GoogleMessageModel *messageM = [GoogleMessageModel getObjectWithKeyValues:gtlM.JSON];
            if (messageM.labelIds && ![messageM.labelIds containsObject:@"UNREAD"]) {
                messageM.isRead = YES;
            }
            if (messageM.labelIds && [messageM.labelIds containsObject:@"STARRED"]) {
                messageM.isStarred = YES;
            }
            // 是否有附件
            NSArray *attArray = messageM.payload[@"parts"]?:@[];
            [attArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *fileName = obj[@"filename"]?:@"";
                if (fileName.length > 0) {
                    
                    NSDictionary *attBodyDic = obj[@"body"]?:@{};
                    NSInteger fileSize = [attBodyDic[@"size"] integerValue];
                    NSString *attid = attBodyDic[@"attachmentId"];
                    
                    EmailAttchModel *attModel = [[EmailAttchModel alloc] init];
                    attModel.attId = attid;
                    attModel.attName = fileName;
                    attModel.attSize = fileSize;
                    
                    __block NSString *cidStr = @"";
                    NSArray *headres = obj[@"headers"]?:@[];
                    [headres enumerateObjectsUsingBlock:^(NSDictionary *obj2, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj2[@"name"] isEqualToString:@"Content-Id"]) {
                            cidStr = obj2[@"value"]?:@"";
                            *stop = YES;
                        }
                    }];
                    
                    if (cidStr.length > 0) {
                        if (!messageM.cidArray) {
                            messageM.cidArray = [NSMutableArray array];
                        }
                        cidStr = [cidStr stringByReplacingOccurrencesOfString:@"<" withString:@""];
                        cidStr = [cidStr stringByReplacingOccurrencesOfString:@">" withString:@""];
                        attModel.cid = cidStr;
                        [messageM.cidArray addObject:attModel];
                    } else {
                        if (!messageM.attArray) {
                            messageM.attArray = [NSMutableArray array];
                        }
                        [messageM.attArray addObject:attModel];
                        messageM.attachCount ++;
                    }
                    
                }
                NSArray *parts = obj[@"parts"]?:@[];
                [parts enumerateObjectsUsingBlock:^(NSDictionary *obj1, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *fileName1 = obj1[@"filename"]?:@"";
                    if (fileName1.length > 0) {
                        
                        NSDictionary *attBodyDic1 = obj1[@"body"]?:@{};
                        NSInteger fileSize1 = [attBodyDic1[@"size"] integerValue];
                        NSString *attid1 = attBodyDic1[@"attachmentId"];
                        
                        EmailAttchModel *attModel1 = [[EmailAttchModel alloc] init];
                        attModel1.attId = attid1;
                        attModel1.attName = fileName1;
                        attModel1.attSize = fileSize1;
                        
                        __block NSString *cidStr1 = @"";
                        NSArray *headres1 = obj1[@"headers"]?:@[];
                        [headres1 enumerateObjectsUsingBlock:^(NSDictionary *headObj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([headObj[@"name"] isEqualToString:@"Content-Id"]) {
                                cidStr1 = headObj[@"value"]?:@"";
                                *stop = YES;
                            }
                            
                        }];
                        
                        if (cidStr1.length > 0) {
                            if (!messageM.cidArray) {
                                messageM.cidArray = [NSMutableArray array];
                            }
                            cidStr1 = [cidStr1 stringByReplacingOccurrencesOfString:@"<" withString:@""];
                            cidStr1 = [cidStr1 stringByReplacingOccurrencesOfString:@">" withString:@""];
                            attModel1.cid = cidStr1;
                            [messageM.cidArray addObject:attModel1];
                        } else {
                            if (!messageM.attArray) {
                                messageM.attArray = [NSMutableArray array];
                            }
                            [messageM.attArray addObject:attModel1];
                            messageM.attachCount ++;
                        }
                        
                    }
                }];
                
            }];
            
            // 取出内容
            __block NSString *htmlContent = @"";
            NSString *mimeType = messageM.payload[@"mimeType"]?:@"";
            if (mimeType.length >0 && ([mimeType isEqualToString:@"text/plain"] || [mimeType isEqualToString:@"text/html"])) {
                // 纯文字没换行 没样式情况
                NSDictionary *bodyDic = messageM.payload[@"body"]?:@{};
                htmlContent = bodyDic[@"data"]?:@"";
                
            }
            
            if (htmlContent.length == 0) {
                // 取 text/html
                [attArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *mutType = obj[@"mimeType"]?:@"";
                    if ([mutType isEqualToString:@"text/html"]) {
                        NSDictionary *bodyDic = obj[@"body"]?:@{};
                        htmlContent = bodyDic[@"data"]?:@"";
                        *stop = YES;
                    } else {
                        NSArray *parts = obj[@"parts"]?:@[];
                        [parts enumerateObjectsUsingBlock:^(NSDictionary *obj1, NSUInteger idx, BOOL * _Nonnull stop) {
                            NSString *mutType = obj1[@"mimeType"]?:@"";
                            if ([mutType isEqualToString:@"text/html"]) {
                                NSDictionary *bodyDic = obj1[@"body"]?:@{};
                                htmlContent = bodyDic[@"data"]?:@"";
                                *stop = YES;
                            }
                        }];
                        if (htmlContent.length > 0) {
                            *stop = YES;
                        }
                    }
                }];
            }
            
            if (htmlContent.length == 0) {
                NSLog(@"----------");
            }
            if (htmlContent.length > 0) {
                
                NSData *contentData = GTLRDecodeWebSafeBase64(htmlContent);
                if (contentData) {
                    
                    NSString *htmlContents = [contentData convertedToUtf8String]?:@"";
                    
                    // 检查是否包含 confidantcontent
                    NSString *confidantContent = [self checkConfidantContentWithHtmlContent:htmlContents];
                    
                    if (confidantContent.length > 0) {
                        htmlContents = [confidantContent base64DecodedString];
                    }
                    
                    // 检查是否需要解密
                    NSString *dsKey = [self deEmailHtmlContentWithContent:htmlContents]?:@"";
                    // 检查是否带有好友id
                    messageM.friendId = [self checkFriendWithHtmlContent:htmlContents];
                    // 检查是否需要密码
                    messageM.passHint = [self checkPassWithHtmlContent:htmlContents]?:@"";
                    
                    if (messageM.passHint.length > 0) {
                        
                        htmlContents = [weakSelf getHtmlBodyWithHtmlContent:htmlContents emailType:1 isAttch:NO deKey:@""];

                        NSString *content = [self filterHTML:htmlContents];
                        content = [NSString trimWhitespace:content];
                        messageM.snippet = content.length > 50? [content substringToIndex:49]:content;
                        
                    } else if (dsKey.length > 0) {
                        
                        NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:dsKey];
                        if (datakey && datakey.length >= 16) {
                            datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
                            
                            htmlContents = [weakSelf getHtmlBodyWithHtmlContent:htmlContents emailType:2 isAttch:NO deKey:datakey];
                            
                            messageM.deKey = datakey;
                            NSString *content = [self filterHTML:htmlContents]?:@"";
                            content = [content stringByReplacingOccurrencesOfString:confidantEmialText withString:@""];
                            content = [NSString trimWhitespace:content];
                            messageM.snippet = content.length > 50? [content substringToIndex:49]:content;
                            
                        }
                       
                    } else {
                        htmlContents = [weakSelf getHtmlBodyWithHtmlContent:htmlContents emailType:0 isAttch:NO deKey:@""];
                    }
                    
                    messageM.htmlContent = htmlContents;
                }
            }
                
                
                NSArray *headArray = messageM.payload[@"headers"]?:@[];
                [headArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if ([obj[@"name"] isEqualToString:@"Subject"]) {
                        messageM.Subject = obj[@"value"];
                    }
                    if ([obj[@"name"] isEqualToString:@"To"]) {
                        messageM.To = obj[@"value"];
                    }
                    if ([obj[@"name"] isEqualToString:@"Cc"]) {
                        messageM.Cc = obj[@"value"];
                    }
                    if ([obj[@"name"] isEqualToString:@"Bcc"]) {
                        messageM.Bcc = obj[@"value"];
                    }
                    if ([obj[@"name"] isEqualToString:@"From"]) {
                        messageM.From = obj[@"value"];
                        
                        messageM.From = [messageM.From stringByReplacingOccurrencesOfString:@"<" withString:@""];
                        messageM.From = [messageM.From stringByReplacingOccurrencesOfString:@">" withString:@""];
                        
                        NSArray *froms = [messageM.From componentsSeparatedByString:@" "];
                        if (froms.count >1) {
                            messageM.FromName = froms[0];
                            messageM.From = [froms lastObject];
                        } else {
                            messageM.FromName = [[messageM.From componentsSeparatedByString:@"@"] firstObject];
                        }
                        
                    }
                }];
                messageM.FromName = [messageM.FromName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                messageM.From = [messageM.From stringByReplacingOccurrencesOfString:@"<" withString:@""];
                messageM.From = [messageM.From stringByReplacingOccurrencesOfString:@">" withString:@""];
                [weakSelf.googleTempMessages addObject:messageM];
                
                // 保存最近联系人
                if (![self.floderModel.name isEqualToString:Spam]) {
                    [EmailDataBaseUtil insertDataWithUser:accountModel.User userName:messageM.FromName userAddress:messageM.From date:[NSDate dateWithTimeIntervalSince1970:messageM.internalDate/1000]];
                }
            
            
            
            
            if (weakSelf.messageCount == weakSelf.googleTempLists.count) { // 请求完成
                
                [weakSelf.view hideHud];
                
                if (weakSelf.googleTempMessages.count == weakSelf.messageCount) { // 全部请求成功
                    
                    weakSelf.nextPageToken = pageToken;
                    if (weakSelf.nextPageToken && weakSelf.nextPageToken.length > 0) {
                        weakSelf.emailTabView.mj_footer.hidden = NO;
                    } else {
                        weakSelf.emailTabView.mj_footer.hidden = YES;
                    }
                    
                    // 根据internalDate 排序
                    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"internalDate" ascending:NO];
                    [weakSelf.googleTempMessages sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                    
                    if (weakSelf.isRefresh && weakSelf.emailDataArray.count > 0) { // 刷新时插入
                        // 排除已存在的
                        GoogleMessageModel *messageM = weakSelf.emailDataArray[0];
                        __block NSMutableArray *insertArray = [NSMutableArray array];
                        [weakSelf.googleTempMessages enumerateObjectsUsingBlock:^(GoogleMessageModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                            if ([messageM.messageId isEqualToString:obj.messageId]) {
                                *stop = YES;
                            }
                            [insertArray addObject:obj];
                        }];
                        
                        [weakSelf.emailDataArray insertObjects:insertArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, insertArray.count)]];
                        
                        //                    NSArray* reversedArray = [[insertArray reverseObjectEnumerator] allObjects]?:@[];
                        //                    [reversedArray enumerateObjectsUsingBlock:^(GoogleMessageModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        //                        [weakSelf.emailDataArray insertObject:obj atIndex:0];
                        //
                        //                    }];
                        
                        
                    } else {
                        [weakSelf.emailDataArray addObjectsFromArray:weakSelf.googleTempMessages];
                    }
                    
                    [weakSelf.emailTabView reloadData];
                    
                } else {
                    [weakSelf.view showHint:@"Failed to pull mail."];
                }
                
                if (weakSelf.isRefresh) {
                    weakSelf.isRefresh = NO;
                    [weakSelf.emailTabView.mj_header endRefreshing];
                } else {
                    [weakSelf.emailTabView.mj_footer endRefreshing];
                }
                [weakSelf.googleTempMessages removeAllObjects];
            }
        }
    }];
}

/**
 修改标签

 @param messageM 模型
 */
- (void) sendGoogleLableRequestWithMessageModel:(GoogleMessageModel *) messageM
{
    EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
    
    GTLRGmail_ModifyMessageRequest *modifyRequest = [[GTLRGmail_ModifyMessageRequest alloc] init];
    modifyRequest.removeLabelIds = @[@"UNREAD"];
    
    GTLRGmailQuery_UsersMessagesModify *usersMessageModify = [GTLRGmailQuery_UsersMessagesModify queryWithObject:modifyRequest userId:accountModel.userId identifier:messageM.messageId];
    
    [[GoogleServerManage getGoogleServerManageShare].gmailService executeQuery:usersMessageModify completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        if (!callbackError) {
            GTLRObject *gtlM = object;
            messageM.labelIds = gtlM.JSON[@"labelIds"];
        }
    }];
    
}

// GoogleMessageModel 转 emailinfolist
- (EmailListInfo *) tranGoogleMessageModelToEmailListInfoWithModel:(GoogleMessageModel *) messageM
{
    EmailListInfo *emailM = [[EmailListInfo alloc] init];
    emailM.Read = messageM.isRead;
    emailM.Subject = messageM.Subject;
    if (messageM.isRead) {
        emailM.Read = 1;
    }
    if (messageM.isStarred) {
        emailM.Read += 4;
    }
    emailM.fromName = messageM.FromName;
    emailM.From = messageM.From;
    emailM.content = messageM.snippet;
    emailM.messageid = messageM.messageId?:@"";
    emailM.attachCount = messageM.attachCount;
    emailM.revDate = [NSDate dateWithTimeIntervalSince1970:messageM.internalDate/1000];
    emailM.htmlContent = messageM.htmlContent?:@"";
    emailM.isGoogleAPI = YES;
    emailM.deKey = messageM.deKey?:@"";
    emailM.friendId = messageM.friendId?:@"";
    emailM.passHint = messageM.passHint?:@"";
    
    if (messageM.attArray) {
        emailM.attchArray = [NSMutableArray array];
        [emailM.attchArray addObjectsFromArray:messageM.attArray];
    }
    
    if (messageM.cidArray) {
        emailM.cidArray = [NSMutableArray array];
        [emailM.cidArray addObjectsFromArray:messageM.cidArray];
    }
    
    // 获取多个收件人
    NSArray *toAddressArray = [messageM.To componentsSeparatedByString:@", "];
    if (toAddressArray) {
        emailM.toUserArray = [NSMutableArray array];
        for (int i =0; i<toAddressArray.count; i++) {
            EmailUserModel *userM = [[EmailUserModel alloc] init];
            if (i == 0) {
                userM.userType = UserTo;
            }
            NSString *name = [toAddressArray[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            
            name = [name stringByReplacingOccurrencesOfString:@"<" withString:@""];
            name = [name stringByReplacingOccurrencesOfString:@">" withString:@""];
            NSArray *nameboxArray = [name componentsSeparatedByString:@" "];
            
            if (nameboxArray && nameboxArray.count >1) {
                userM.userName = nameboxArray[0];
                userM.userAddress = nameboxArray[1];
            } else {
                userM.userName = [[name componentsSeparatedByString:@"@"] firstObject];
                userM.userAddress = name;
            }
            
            [emailM.toUserArray addObject:userM];
        }
    }
    
    // 获取多个抄送人
    if (messageM.Cc && messageM.Cc.length > 0) {
        NSArray *ccAddressArray = [messageM.Cc componentsSeparatedByString:@", "];
        if (ccAddressArray) {
            emailM.ccUserArray = [NSMutableArray array];
            for (int i =0; i<ccAddressArray.count; i++) {
                EmailUserModel *userM = [[EmailUserModel alloc] init];
                if (i == 0) {
                    userM.userType = UserCc;
                }
                NSString *name = [ccAddressArray[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                
                name = [name stringByReplacingOccurrencesOfString:@"<" withString:@""];
                name = [name stringByReplacingOccurrencesOfString:@">" withString:@""];
                NSArray *nameboxArray = [name componentsSeparatedByString:@" "];
                
                if (nameboxArray && nameboxArray.count >1) {
                    userM.userName = nameboxArray[0];
                    userM.userAddress = nameboxArray[1];
                } else {
                    userM.userName = [[name componentsSeparatedByString:@"@"] firstObject];
                    userM.userAddress = name;
                }
                
                [emailM.ccUserArray addObject:userM];
            }
        }
    }
    
    // 获取多个密送人
    if (messageM.Bcc && messageM.Bcc.length > 0) {
        NSArray *bccAddressArray = [messageM.Bcc componentsSeparatedByString:@", "];
        if (bccAddressArray) {
            emailM.bccUserArray = [NSMutableArray array];
            for (int i =0; i<bccAddressArray.count; i++) {
                EmailUserModel *userM = [[EmailUserModel alloc] init];
                if (i == 0) {
                    userM.userType = UserBcc;
                }
                NSString *name = [bccAddressArray[i] stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                
                name = [name stringByReplacingOccurrencesOfString:@"<" withString:@""];
                name = [name stringByReplacingOccurrencesOfString:@">" withString:@""];
                NSArray *nameboxArray = [name componentsSeparatedByString:@" "];
                
                if (nameboxArray && nameboxArray.count >1) {
                    userM.userName = nameboxArray[0];
                    userM.userAddress = nameboxArray[1];
                } else {
                    userM.userName = [[name componentsSeparatedByString:@"@"] firstObject];
                    userM.userAddress = name;
                }
                [emailM.bccUserArray addObject:userM];
            }
        }
    }
    
    return emailM;
}
// sign 失败，取消菊花
- (void) googleSigninFaield
{
    self.isSend = NO;
    self.isFriendSend = NO;
    [self.view hideHud];
}














#pragma mark -----------menuJump---------
- (void) jumpCreateGroup
{
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
    AddGroupMemberViewController *vc = [[AddGroupMemberViewController alloc] initWithMemberArr:inputArr originArr:@[] type:ChatsGroupMemberTypeInGroupDetail];
    [self presentModalVC:vc animated:YES];
    
}
- (void) jumpNewEmail
{
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    if (!accountM) {
        [self.view showHint:@"You do not currently have a mailbox bound."];
        return;
    }
    if (!AppD.isGoogleSign && accountM.userId.length > 0) {
        self.isSend = YES;
        [self.view showHudInView:self.view hint:@""];
        NSArray *currentScopes = @[@"https://mail.google.com/"];
        [GIDSignIn sharedInstance].scopes = currentScopes;
        [[GIDSignIn sharedInstance] signIn];
    } else {
        PNEmailSendViewController *vc = [[PNEmailSendViewController alloc] initWithEmailListInfo:nil sendType:NewEmail];
        [self presentModalVC:vc animated:YES];
    }
}

- (void) jumpFriendNewEmail
{
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    if (!accountM) {
        [self.view showHint:@"You do not currently have a mailbox bound."];
        return;
    }
    if (!AppD.isGoogleSign && accountM.userId.length > 0) {
        self.isFriendSend = YES;
        [self.view showHudInView:self.view hint:@""];
        NSArray *currentScopes = @[@"https://mail.google.com/"];
        [GIDSignIn sharedInstance].scopes = currentScopes;
        [[GIDSignIn sharedInstance] signIn];
    } else {
        PNEmailSendViewController *vc = [[PNEmailSendViewController alloc] initWithEmailListInfo:nil sendType:FriendEmail];
        [self presentModalVC:vc animated:YES];
    }
}
- (void) jumpAddMembers
{
    NSString *rid = [RouterConfig getRouterConfig].currentRouterToxid;
    AddNewMemberViewController *vc = [[AddNewMemberViewController alloc] initWithRid:rid];
    [self presentModalVC:vc animated:YES];
}
- (void) jumpScanCoder
{
    @weakify_self
    QRViewController *vc = [[QRViewController alloc] initWithCodeQRCompleteBlock:^(NSString *codeValue) {
        if (codeValue != nil && codeValue.length > 0) {
            weakSelf.codeResultValue = codeValue;
            NSArray *codeValues = [codeValue componentsSeparatedByString:@","];
            NSString *codeType = codeValues[0];
            
            if ([codeValue isUrlAddress]) { // 是网址
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:codeValue] options:@{} completionHandler:nil];
            } else {
                if ([[NSString getNotNullValue:codeType] isEqualToString:@"type_1"]) { // 是节目点通信码
                    // router 码
                    NSString *result = aesDecryptString(codeValues[1],AES_KEY);
                    result = [result stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                    if (result && result.length == 114) {
                        
                        NSString *toxid = [result substringWithRange:NSMakeRange(6, 76)];
                        NSString *sn = [result substringWithRange:NSMakeRange(result.length-32, 32)];
                        NSLog(@"%@",[RouterConfig getRouterConfig].currentRouterSn);
                        
                        if ([[RouterConfig getRouterConfig].currentRouterToxid isEqualToString:toxid]) {
                            // 是当前帐户
                            [AppD.window showHint:@"Already in the same circle."];
                        } else {
                            [weakSelf showAlertVCWithValues:@[toxid,sn] isMac:NO];
                        }
                    }
                } else if ([[NSString getNotNullValue:codeType] isEqualToString:@"type_2"]) { // 是MAC码
                    // mac 码
                    NSString *result = aesDecryptString(codeValues[1],AES_KEY);
                    result = [result stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                    AppD.isScaner = YES;
                    [weakSelf showAlertVCWithValues:@[result] isMac:YES];
                    
                } else if ([[NSString getNotNullValue:codeType] isEqualToString:@"type_0"]) { // 是好友码
                    codeValue = codeValues[1];
                    if ([codeValue isEqualToString:[UserModel getUserModel].userId]) {
                        [AppD.window showHint:@"You cannot add yourself as a friend."];
                    } else if (codeValue.length != 76) {
                        [AppD.window showHint:@"QR code format is wrong."];
                        [weakSelf jumpCodeValueVC];
                    } else {
                        NSString *nickName = @"";
                        if (codeValues.count>2) {
                            nickName = codeValues[2];
                        }
                        [weakSelf addFriendRequest:codeValue nickName:nickName signpk:codeValues[3] toxid:@"" type:codeType];
                    }
                } else if ([[NSString getNotNullValue:codeType] isEqualToString:@"type_5"]) { // 是好友码
                    
                    NSString *aesCode = aesDecryptString(codeValues[1], AES_KEY)?:@"";
                    if (aesCode.length > 0) {
                        NSArray *codeArr = [aesCode componentsSeparatedByString:@","];
                        if (codeArr && codeArr.count == 5) {
                            
                           NSString *signPK = [EntryModel getShareObject].signPublicKey;
                            //NSString *toxid = [RouterModel getConnectRouter].toxid;
                            // && [codeArr[2] isEqualToString:toxid]
                            if ([codeArr[1] isEqualToString:signPK]) {
                                
                                [AppD.window showHint:@"You cannot add yourself as a friend."];
                                
                            } else {
                                
                                 [weakSelf addFriendRequest:@"" nickName:codeArr[3] signpk:codeArr[1] toxid:codeArr[2] type:codeType];
                            }
                        } else {
                            [weakSelf jumpCodeValueVC];
                        }
                    } else {
                        [weakSelf jumpCodeValueVC];
                    }
                          
                } else if ([[NSString getNotNullValue:codeType] isEqualToString:@"type_3"]) { //帐户码
                    [weakSelf showAlertImportAccount:codeValues];
                    
                } else if ([[NSString getNotNullValue:codeType] isEqualToString:@"type_4"]) { //邀请码
                    
                    NSString *result = aesDecryptString([codeValues lastObject],AES_KEY);
                    result = [result stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                    if (result && result.length == 114) {
                        
                        NSString *toxid = [result substringWithRange:NSMakeRange(6, 76)];
                        NSString *sn = [result substringWithRange:NSMakeRange(result.length-32, 32)];
                        NSLog(@"%@",[RouterConfig getRouterConfig].currentRouterSn);
                        
                        if ([[RouterConfig getRouterConfig].currentRouterToxid isEqualToString:toxid]) {
                            
                            // 是当前帐户
                            [SendRequestUtil sendAutoAddFriendWithFriendId:codeValues[1] email:@"" type:1 showHud:NO];
                             [AppD.window showHint:@"Already in the same circle."];
                            
                        } else {
                            [weakSelf showAlertVCWithValues:@[toxid,sn,codeValues[1]] isMac:NO];
                        }
                    }
                    
                } else if (codeValue.length == 12) { // 是MAC码
                    NSString *macAdress = @"";
                    for (int i = 0; i<12; i+=2) {
                        NSString *macIndex = [codeValue substringWithRange:NSMakeRange(i, 2)];
                        macAdress = [macAdress stringByAppendingString:macIndex];
                        if (i < 10) {
                            macAdress = [macAdress stringByAppendingString:@":"];
                        }
                    }
                    if ([macAdress isMacAddress]) {
                        [weakSelf showAlertVCWithValues:@[macAdress] isMac:YES];
                    } else {
                        [weakSelf jumpCodeValueVC];
                    }
                }  else { // 是乱码
                    //[weakSelf.view showHint:@"format error!"];
                    [weakSelf jumpCodeValueVC];
                }
            }
        }
    }];
    
    [self presentModalVC:vc animated:YES];
}

#pragma mark - Transition
- (void)addFriendRequest:(NSString *)friendId nickName:(NSString *) nickName signpk:(NSString *) signpk toxid:(NSString *) toxid type:(NSString *) type{
    
    FriendRequestViewController *vc = [[FriendRequestViewController alloc] initWithNickname:nickName userId:friendId signpk:signpk toxId:toxid codeType:type];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void) showAlertImportAccount:(NSArray *) values
{
    
    NSString *signpk = values[1];
    
    if ([signpk isEqualToString:[EntryModel getShareObject].signPrivateKey])
    {
        // 是当前帐户
        [AppD.window showHint:@"The same user."];
        return;
    }
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"" message:@"This operation will overwrite the current account. Do you want to continue?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    // @weakify_self
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![signpk isEqualToString:[EntryModel getShareObject].signPrivateKey]) {
            // 清除所有数据
            [SystemUtil clearAppAllData];
            // 更改私钥
            [UserPrivateKeyUtil changeUserPrivateKeyWithPrivateKey:values[1]];
            
            NSString *name = [values[3] base64DecodedString];
            [UserModel createUserLocalWithName:name];
            // 删除所有路由
            [RouterModel delegateAllRouter];
            [AppD setRootLoginWithType:ImportType];
        }
    }];
    
    [vc addAction:cancelAction];
    [vc addAction:confirm];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) jumpCodeValueVC
{
    CodeMsgViewController *vc = [[CodeMsgViewController alloc] initWithCodeValue:self.codeResultValue];
    [self presentModalVC:vc animated:YES];
}
- (void) showAlertVCWithValues:(NSArray *) values isMac:(BOOL) isMac
{
    
    NSString *friendId = @"";
    if (values.count > 2 && !isMac) {
        friendId = values[2];
    }
    AppD.isScaner = YES;
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:@"Do you want to switch the circle?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (isMac) {
            [RouterConfig getRouterConfig].currentRouterMAC = values[0];
            [[CircleOutUtil getCircleOutUtilShare] circleOutProcessingWithRid:values[0] friendid:friendId];
        } else {
            [RouterConfig getRouterConfig].currentRouterToxid = values[0];
            [RouterConfig getRouterConfig].currentRouterSn = values[1];
            [[CircleOutUtil getCircleOutUtilShare] circleOutProcessingWithRid:values[0] friendid:friendId];
        }
    }];
    [alert1 setValue:UIColorFromRGB(0x2C2C2C) forKey:@"_titleTextColor"];
    [alertC addAction:alert1];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:alertCancel];
    
    [self presentViewController:alertC animated:YES completion:nil];
    
}
#pragma mark - 通知回调
- (void) chooseContactNoti:(NSNotification *) noti
{
    NSArray *mutContacts = noti.object;
    if (mutContacts && mutContacts.count > 0) {
        CreateGroupChatViewController *vc = [[CreateGroupChatViewController alloc] initWithContacts:mutContacts groupPage:ChatCreateGroup];
        [self presentModalVC:vc animated:YES];
    }
}
#pragma  mark ---jump vc
- (void) jumpGroupChatNoti:(NSNotification *) noti
{
    GroupInfoModel *model = noti.object;
    GroupChatViewController *vc = [[GroupChatViewController alloc] initWihtGroupMode:model];
    [self.navigationController pushViewController:vc animated:YES];
    [self moveAllNavgationViewController];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
//    NSString *signPrivateKey = [EntryModel getShareObject].signPrivateKey;
//    
//    NSData *skData = [signPrivateKey base64DecodedData];
//    NSString *signHexKey = [[SystemUtil dataToHexString:skData] substringToIndex:64];
//    NSLog(@"signPrivateKeyLength = %ld",signHexKey.length);
//    NSString *qlcPrivateKey = [QLCUtil seedToPrivateKeyWithSeed:signHexKey index:0];
//    NSString *qlcPublicKey = [QLCUtil privateKeyToPublicKeyWithPrivateKey:qlcPrivateKey];
//    
//    NSString *qlcAccount = [QLCUtil publicKeyToAddressWithPublicKey:qlcPublicKey];
    
    // 接收
   // [[QLCWalletManage shareInstance] receive_accountsPending:qlcAccount baseUrl:QLC_TEST_URL privateKey:qlcPrivateKey];
    NSLog(@"-----------------------");
    /*
    @weakify_self
    [QLCDPKIManager getPubKeyByTypeAndID:QLC_TEST_URL type:@"email" ID:@"kuangzihui@163.com" successHandler:^(NSArray * _Nullable responseObj) {
        if (responseObj && responseObj.count > 0) {
            NSDictionary *regDic = responseObj[0];
            NSString *account = regDic[@"account"];
            NSString *pubKey = regDic[@"pubKey"];
            
           NSString *enMessage = [weakSelf enMessageStr:@"我是123" pk:pubKey];
            
           NSString *deMessage = [ENMessageUtil deMessageStr:enMessage];
            
        } else {
            NSLog(@"message = %@",@"没有找到id");
        }
       
    } failureHandler:^(NSError * _Nullable error, NSString * _Nullable message) {
        NSLog(@"message = %@",message);
    }];
    */
    /*
    
     //8675cb571688f7b1d4178f9a295087864653e20b4e236967c6006341a83259fd
      // 发送
    /*
    @weakify_self
    [[QLCWalletManage shareInstance] sendAssetWithTokenName:@"QGAS" from:qlcAccount to:@"qlc_36rqcyxr1ebxgsjo9bge6n75ieempzds8s1zdi6bf1g6huost18izwujibp1" amount:100000000 privateKey:qlcPrivateKey sender:nil receiver:nil message:nil data:nil baseUrl:QLC_TEST_URL workInLocal:NO successHandler:^(NSString * _Nullable responseObj) {
        [weakSelf.view hideHud];
        NSLog(@"发送成功!");
    } failureHandler:^(NSError * _Nullable error, NSString * _Nullable message) {
        [weakSelf.view hideHud];
        NSLog(@"message=%@",message);
    }];
     */
    
//    @weakify_self
//    [QLCDPKIManager getPubKeyByTypeAndID:QLC_TEST_URL type:@"email" ID:@"kuangzihui@163.com" successHandler:^(NSArray * _Nullable responseObj) {
//        if (responseObj && responseObj.count > 0) {
//            NSDictionary *regDic = responseObj[0];
//            NSString *account = regDic[@"account"];
//            NSString *pubKey = regDic[@"pubKey"];
//            
//           NSString *enMessage = [weakSelf enMessageStr:@"我是123" pk:pubKey];
//            
//           NSString *deMessage = [ENMessageUtil deMessageStr:enMessage];
//            
//        } else {
//            NSLog(@"message = %@",@"没有找到id");
//        }
//       
//    } failureHandler:^(NSError * _Nullable error, NSString * _Nullable message) {
//        NSLog(@"message = %@",message);
//    }];
    
    
    /*
    // 获取所有验证者
    [QLCDPKIManager getAllVerifiers:QLC_TEST_URL successHandler:^(NSArray * _Nullable responseObj) {
        
        NSMutableArray *verifiers = [NSMutableArray array];
        [responseObj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // 最多只能 5 个 ，暂定取前 5个
            NSDictionary *dic = obj;
            [verifiers addObject:dic[@"account"]];
            if (verifiers.count == 5) {
                *stop = YES;
            }
        }];
        // 拼接参数
        NSString *emailId = @"kuangzihui@163.com";
        NSData *pkData = [[EntryModel getShareObject].publicKey base64DecodedData];
        NSString *pkHex = [SystemUtil dataToHexString:pkData];
        NSDictionary *params1 = @{@"account":qlcAccount, @"type":@"email", @"id":emailId, @"pubkey":pkHex, @"fee":@"500000000", @"verifiers":verifiers};
        // 获取一个发布块以发布一个id / publicKey对
        [QLCDPKIManager getPublishBlock:QLC_TEST_URL params:params1 successHandler:^(NSDictionary * _Nullable responseObj) {
            
            NSDictionary *verifiers = responseObj[@"verifiers"];
            NSDictionary *block = responseObj[@"block"];
            //公私钥签名block
            // 私钥 @"8675cb571688f7b1d4178f9a295087864653e20b4e236967c6006341a83259fd931757bb80313d766353a5cc250a383193b7d793641f5c089681c47eeb9d00d0"
            // 公钥 931757bb80313d766353a5cc250a383193b7d793641f5c089681c47eeb9d00d0
            NSDictionary *signBlock = [QLCUtil getSignBlockWithBlockDic:block privateKey:qlcPrivateKey publicKey:qlcPublicKey];
            // 计算process
            [QLCDPKIManager process:QLC_TEST_URL params:signBlock successHandler:^(NSString * _Nullable responseObj) {
                 NSLog(@"responseObj = process%@",responseObj);
                
            } failureHandler:^(NSError * _Nullable error, NSString * _Nullable message) {
                NSLog(@"message = process%@",message);
            }];
            
        } failureHandler:^(NSError * _Nullable error, NSString * _Nullable message) {
            NSLog(@"message = getPublishBlock%@",message);
        }];
        
    } failureHandler:^(NSError * _Nullable error, NSString * _Nullable message) {
        NSLog(@"message = verifiers%@",message);
    }];
       */
}


//- (NSString *) enMessageStr:(NSString *) messageStr pk:(NSString *) pk
//{
//    NSString *enPk = [[SystemUtil HexStrToData:pk] base64EncodedString];
//    NSLog(@"pk = %@",[EntryModel getShareObject].publicKey);
//    NSString *symmetryString = [LibsodiumUtil getSymmetryWithPrivate:[EntryModel getShareObject].privateKey publicKey:enPk];
//    NSString *enMessage = [LibsodiumUtil encryMsgPairWithSymmetry:symmetryString enMsg:messageStr nonce:EN_NONCE];
//    return [ENMessageUtil enMessageStr:enMessage enType:@"00" qlcAccount:@"" tokenNum:@"" tokenType:@"" enNonce:EN_NONCE];
//}

@end
