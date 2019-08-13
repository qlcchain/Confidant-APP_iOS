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
#import "PNEmailSendViewController.h"
#import "EmailUserModel.h"
#import "EmailAttchModel.h"

#import <MJRefresh/MJRefresh.h>
#import "EmailOptionUtil.h"
#import "NSString+HexStr.h"
#import "EmailDataBaseUtil.h"

#import "NSData+Base64.h"
#import "LibsodiumUtil.h"
#import "EntryModel.h"
#import "AESCipher.h"
#import "NSString+Base64.h"
#import "EmailNodeModel.h"

#import "NSString+Trim.h"

#import "PNSearchViewController.h"

@interface NewsViewController ()<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate,UITextFieldDelegate,YJSideMenuDelegate,UIScrollViewDelegate,UISearchControllerDelegate,UISearchBarDelegate> {
    BOOL isSearch;
    BOOL isRequestFloderCount;
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
// 记录最大uid
@property (nonatomic ,assign) int maxUid;
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
    // 邮件flags 改变通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailFlagsChangeNoti:) name:EMIAL_FLAGS_CHANGE_NOTI object:nil];
    // 拉取节点邮件通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullEmailNoti:) name:EMAIL_PULL_NODE_NOTI object:nil];
    // 搜索界面点击 邮件或消息状态发生改变
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MessageStatusChangeNoti:) name:SEARCH_MODEL_STATUS_CHANGE_NOTI object:nil];
    // 删除邮箱通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noEmailConfigNoti:) name:EMAIL_NO_CONFIG_NOTI object:nil];
    
}
// 搜索
- (IBAction)clickSearchAction:(id)sender {
    PNSearchViewController *vc = [[PNSearchViewController alloc] initWithData:AppD.isEmailPage?self.emailDataArray:self.dataArray isMessage:!AppD.isEmailPage floder:self.floderModel];
    [self.navigationController pushViewController:vc animated:YES];
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
    if (self.emailDataArray.count > 0) {
        [self.emailDataArray removeAllObjects];
        [self.emailTabView reloadData];
    }
    _page = 1;
    EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
    if (accountModel) {
        
        self.floderModel = [[FloderModel alloc] init];
        self.floderModel.path = @"INBOX";
        self.floderModel.name = @"Inbox";
        
        _lblTitle.text = self.floderModel.name;
        _lblSubTitle.text = accountModel.User;
        
        MCOIMAPFolderInfoOperation * folderInfoOperation = [EmailManage.sharedEmailManage.imapSeeion folderInfoOperation:self.floderModel.path];
        
        [self.view showHudInView:self.view hint:@"Loading" userInteractionEnabled:NO hideTime:REQEUST_TIME];
        
        @weakify_self
        [folderInfoOperation start:^(NSError *error, MCOIMAPFolderInfo * info) {
            if (error) {
                [weakSelf.view hideHud];
                [weakSelf.view showHint:@"Failed to pull mail."];
            } else {
                isRequestFloderCount = YES;
                weakSelf.floderModel.count = info.messageCount;
                [weakSelf pullEmailList];
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
    
    
    _page = 1;
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
    [self chatMessageChangeNoti:nil];
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
        
//        if (_maxUid == 0) {
//            MCOIMAPFolderInfoOperation * folderInfoOperation = [EmailManage.sharedEmailManage.imapSeeion folderInfoOperation:self.floderModel.path];
//            @weakify_self
//            [folderInfoOperation start:^(NSError *error, MCOIMAPFolderInfo * info) {
//                if (error) {
//                    [weakSelf.emailTabView.mj_header endRefreshing];
//                } else {
//                    if (weakSelf.floderModel.count != info.messageCount) {
//                        weakSelf.isRefresh = YES;
//                        weakSelf.currentEmailCount = weakSelf.floderModel.count;
//                        weakSelf.floderModel.count = info.messageCount;
//                        [weakSelf pullEmailList];
//                    } else {
//                        [weakSelf.emailTabView.mj_header endRefreshing];
//                    }
//                }
//            }];
//        } else { // 根据最大uid 拉取10条
//            self.isRefresh = YES;
//            [self pullEmailList];
//        }
    }
}

// 更新头部标题
- (void) updateTopTitle
{
    if (AppD.isEmailPage) {
        EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
        if (accountModel) {
            _lblTitle.text = self.floderModel.name;
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

        if (listInfo.deKey && listInfo.deKey.length > 0) {
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
                if ([listInfo.Subject containsString:@"英语"]) {
                    NSLog(@"-----");
                }
                NSString *content = [messageParser plainTextBodyRenderingAndStripWhitespace:YES]?:@"";
                
                // 检测是否需要解密
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
                } //htmlContents && htmlContents.length > 0
                
                // 解密正文
                if (dsKey.length > 0) {
                    NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:dsKey];
                    if (datakey && datakey.length >= 16) {
                        datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
                        NSString *bodyStr = [htmlContents componentsSeparatedByString:@"</body>"][0];
                        NSArray *bodys = [bodyStr componentsSeparatedByString:@"<body>"];
                        NSString *enStr = [bodys lastObject];
                        
                        if (listInfo.attachCount > 0) {
                            
                            NSString *attchHtml = bodys[0];
                           htmlContents = [htmlContents stringByReplacingOccurrencesOfString:attchHtml withString:htmlHead];
                        }
                        
                        NSString *spanStr = [enStr componentsSeparatedByString:@"<span style='display:none'"][0];
                        NSString *deStr = aesDecryptString(spanStr, datakey)?:@"";
                        if (deStr.length > 0) {
                            htmlContents = [htmlContents stringByReplacingOccurrencesOfString:enStr withString:[deStr stringByAppendingString:confidantHtmlStr]];
                        }
                        
                        content = [content stringByReplacingOccurrencesOfString:confidantEmialStr withString:@""];
                        content = [NSString trimWhitespace:content];
                        
                        // 去除带有附件名字段
                        if (listInfo.attachCount > 0) {
                            NSArray *contentArr = [content componentsSeparatedByString:@" "];
                            if ([contentArr[0] containsString:@"-"] ) {
                                content = [contentArr lastObject];
                            } else {
                                content = contentArr[0];
                            }
                        }
                       NSString *deContent = aesDecryptString([content componentsSeparatedByString:@" "][0], datakey);
                        if (deContent && deContent.length > 0) {
                           content = [self filterHTML:deContent];
                        } 
                        
                        listInfo.deKey = datakey;
                    }
                } // dsKey.length > 0
                
                // 获取附件
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
                listInfo.content = [content componentsSeparatedByString:@" "][0];
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
                    
                    if (listInfo.deKey && listInfo.deKey.length > 0) {
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
        model.floderPath = self.floderModel.path;
        selEmailRow = indexPath.row;
        
        if ([self.floderModel.name isEqualToString:Drafts]) { //草稿箱
            PNEmailSendViewController *vc = [[PNEmailSendViewController alloc] initWithEmailListInfo:model sendType:DraftEmail];
            [self presentModalVC:vc animated:YES];
            
        } else {
            PNEmailDetailViewController *vc = [[PNEmailDetailViewController alloc] initWithEmailListModer:model];
            [self.navigationController pushViewController:vc animated:YES];
            // 设为已读
            if (model.Read == 0) {
                model.Read = 1;
                [_emailTabView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                // 设为已读
                [EmailOptionUtil setEmailReaded:YES uid:model.uid folderPath:model.floderPath complete:^(BOOL success) {
                    
                }];
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
    // 上传邮箱配置到节点
    NSArray *emails = [EmailAccountModel getLocalAllEmailAccounts];
    [emails enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        EmailAccountModel *accountM = obj;
        [SendRequestUtil sendEmailConfigWithEmailAddress:[accountM.User lowercaseString] type:@(accountM.Type) configJson:@"" ShowHud:NO];
    }];
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
    [self firstPullEmailList];
}
- (void) pullEmailNoti:(NSNotification *) noti
{
    NSDictionary *dic = noti.object;
    NSInteger retCode = [dic[@"RetCode"] integerValue];
    if (retCode == 0) {
        
        @weakify_self
        NSArray *Payloads = dic[@"Payload"];
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
                [weakSelf.emailDataArray addObject:emailM];
            }
        }];
        [self.emailTabView reloadData];
    } else {
        [self.view showHint:@"pull faield."];
    }
}
    
// 邮件flags改变
- (void) emailFlagsChangeNoti:(NSNotification *) noti
{
    int optionType = [noti.object intValue];
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
    _lblTitle.text = floderModel.name;
    self.floderModel = floderModel;
    _page = 1;
    _maxUid = 0;
    if (self.floderModel.path.length > 0) {
         self.emailTabView.mj_header.hidden = NO;
         [self pullEmailList];
    } else {
        if (self.emailDataArray.count > 0) {
            [self.emailDataArray removeAllObjects];
            [_emailTabView reloadData];
        }
        
        _emailTabView.mj_footer.hidden = YES;
        _emailTabView.mj_header.hidden = YES;
        
        if ([self.floderModel.name isEqualToString:Starred]) {
            EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
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
            [SendRequestUtil sendPullEmailWithStarid:@(0) num:@(50) showHud:YES];
        }
    }
}
// 拉取邮件列表
- (void) pullEmailList
{
    if (_isRefresh) { // 上拉
        
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
            if (isRequestFloderCount) {
                [self.view hideHud];
            }
            return;
        }
        if (_page == 1 && !isRequestFloderCount) {
            [self.view showHudInView:self.view hint:@"Loading" userInteractionEnabled:NO hideTime:REQEUST_TIME];
        }
        isRequestFloderCount = NO;
    }
    
    MCOIMAPMessagesRequestKind requestKind = (MCOIMAPMessagesRequestKind)
    (MCOIMAPMessagesRequestKindHeaders |MCOIMAPMessagesRequestKindExtraHeaders |MCOIMAPMessagesRequestKindStructure |MCOIMAPMessagesRequestKindInternalDate |MCOIMAPMessagesRequestKindHeaderSubject |MCOIMAPMessagesRequestKindFlags);
    
    uint64_t locationf = 1;
    uint64_t lengthf = 10;
    if (_isRefresh) {
        if (_maxUid == 0) {
            lengthf = self.floderModel.count - self.currentEmailCount;
            locationf = self.currentEmailCount+1;
        } else {
            lengthf = 9;
            locationf = _maxUid+1;
        }
        
    } else {
        CGFloat syCount = self.floderModel.count - self.emailDataArray.count;
        if (syCount > 10) {
            locationf = (syCount - _pageCount)+1;
            lengthf = 9;
        } else {
            lengthf = syCount;
        }
    }
    
    MCOIndexSet *numbers = [MCOIndexSet indexSetWithRange:MCORangeMake(locationf, lengthf)];
    
    
    MCOIMAPFetchMessagesOperation *imapMessagesFetchOp = nil;
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
        
        if (error) {
            if (weakSelf.isRefresh) { // 是上拉刷新
                weakSelf.floderModel.count = (int) weakSelf.currentEmailCount;
                weakSelf.isRefresh = NO;
                [weakSelf.view showHint:@"Failed to pull mail."];
                [weakSelf.emailTabView.mj_header endRefreshing];
            } else {
                if (weakSelf.page == 1) {
                    [weakSelf.view hideHud];
                } else {
                    weakSelf.emailTabView.mj_footer.hidden = NO;
                }
                [weakSelf.view showHint:@"Failed to pull mail."];
                [weakSelf.emailTabView.mj_footer endRefreshing];
            }
            
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
            
            if (!weakSelf.isRefresh) {
                if (messages.count == 10) {
                    weakSelf.emailTabView.mj_footer.hidden = NO;
                } else {
                    weakSelf.emailTabView.mj_footer.hidden = YES;
                }
            }
            
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
        if (listInfo.uid >weakSelf.maxUid) { // 取到最大uid
            weakSelf.maxUid = listInfo.uid;
        }
        listInfo.Read = message.flags;
        listInfo.messageid = headrMessage.messageID;
       // NSLog(@"-----messageid------%@",listInfo.messageid);
        listInfo.fromName = address.displayName?:@"";
        listInfo.fromName = [listInfo.fromName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        listInfo.From = address.mailbox;
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
    NSDictionary *dic = @{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType};
    NSData *data = [html dataUsingEncoding:NSUnicodeStringEncoding];
    NSAttributedString *attriStr = [[NSAttributedString alloc] initWithData:data options:dic documentAttributes:nil error:nil];
    NSString *str = attriStr.string;
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
    return str;
    
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
