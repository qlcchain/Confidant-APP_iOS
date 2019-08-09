//
//  LeftViewController.m
//  TTTT
//
//  Created by 刘亚军 on 2019/3/19.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import "LeftViewController.h"
#import "EmailNameCell.h"
#import "EmailFloderCell.h"
#import "UIViewController+YJSideMenu.h"
#import "RouterModel.h"
#import "EmailManage.h"
#import "EmailAccountModel.h"
#import "FloderModel.h"
#import "RSAUtil.h"
#import "EmailFloderConfig.h"
#import "PNEmailTypeSelectView.h"
#import "PNEmailLoginViewController.h"
#import "StringUtil.h"
#import "EmailDataBaseUtil.h"
#import "UserConfig.h"

@interface LeftViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *menuBackView;
@property (weak, nonatomic) IBOutlet UITableView *mainTabView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (nonatomic , strong) NSMutableArray *messageDataArray;
@property (nonatomic,assign) NSInteger selectRow;
@property (nonatomic ,strong) NSMutableArray *emailFolders;
@property (nonatomic ,strong) NSMutableArray *emails;
@property (nonatomic, assign) BOOL isEmailPage;
    @property (weak, nonatomic) IBOutlet UIButton *editBtn;
    @end

@implementation LeftViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewWillAppear:(BOOL)animated
{
    if (AppD.isEmailPage) {
        _lblTitle.text = @"Email";
    } else {
        _lblTitle.text = @"Message";
    }
    if (!_isEmailPage && AppD.isEmailPage) {
        _isEmailPage = AppD.isEmailPage;
        [_mainTabView reloadData];
    }
    [self getFloaderEmailCount];
    
    [super viewWillAppear:animated];
}
#pragma mark --layz-------------
- (NSMutableArray *) emails
{
    if (!_emails) {
        _emails =[NSMutableArray array];
    }
    return _emails;
}
- (NSMutableArray *) emailFolders
{
    if (!_emailFolders) {
        _emailFolders =[NSMutableArray array];
        NSArray *floderArr = @[Inbox,Node_backed_up,Starred,Drafts,Sent,Spam,Trash];
        for (int i = 0; i<floderArr.count; i++) {
            FloderModel *model = [[FloderModel alloc] init];
            model.name = floderArr[i];
            [_emailFolders addObject:model];
        }
    }
    return _emailFolders;
}
- (NSMutableArray *) messageDataArray
{
    if (!_messageDataArray) {
        NSArray *routerArr =  [RouterModel getLocalRouters];
        _messageDataArray =[NSMutableArray arrayWithObjects:routerArr,@[@"Add a New Circle"],nil];
    }
    return _messageDataArray;
}
- (IBAction)clcikEditAction:(id)sender {
    
}
    
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *emailAccounts = [EmailAccountModel getLocalAllEmailAccounts];
    [self.emails addObjectsFromArray:emailAccounts];
    
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    _menuBackView.backgroundColor = MAIN_GRAY_COLOR;
    _selectRow = 0;
    _mainTabView.delegate = self;
    _mainTabView.dataSource = self;
    _mainTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _mainTabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_mainTabView registerNib:[UINib nibWithNibName:EmailNameCellResue bundle:nil] forCellReuseIdentifier:EmailNameCellResue];
    [_mainTabView registerNib:[UINib nibWithNibName:EmailFloderCellResue bundle:nil] forCellReuseIdentifier:EmailFloderCellResue];
    // 拉取文件夹
    [self pullFloder];
    // 添加通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailLoginSuccessNoti:) name:EMIAL_LOGIN_SUCCESS_NOTI object:nil];
    // 邮件删除和移动通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailFalgsChangeSuccessNoti:) name:EMIAL_FLAGS_CHANGE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailNodeCountSuccessNoti:) name:EMAIL_NODE_COUNT_NOTI object:nil];
    
    
}

#pragma mark --tabledelegate------------
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (AppD.isEmailPage) {
        return 3;
    }
    return self.messageDataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (AppD.isEmailPage) {
        if (section == 0) {
            return self.emails.count;
        }
        if (section == 1) {
            return 1;
        }
        if (section == 2) {
            if (self.emails.count == 0) {
                return 0;
            }
            return self.emailFolders.count;
        }
    }
    NSArray *arr = self.messageDataArray[section];
    return [arr count];
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (AppD.isEmailPage) {
        if (indexPath.section == 2) {
            return EmailFloderCellHeight;
        }
    }
    return EmailNameCellHeight;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        return 10;
    }
    return 0;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (AppD.isEmailPage) {
        if (indexPath.section == 2) {
            EmailFloderCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailFloderCellResue];
            FloderModel *floderM = self.emailFolders[indexPath.row];
            //解决中文folder乱码问题
            cell.lblContent.text = floderM.name;
            
            if (floderM.path.length == 0) {
                cell.lblCount.text = @"";
                if ([floderM.name isEqualToString:Starred]) {
                    NSInteger startCount = [EmailDataBaseUtil getStartCount];
                    if (startCount > 0) {
                        cell.lblCount.text = [NSString stringWithFormat:@"%ld",(long)startCount];
                    }
                } else if ([floderM.name isEqualToString:Node_backed_up]){
                    if (floderM.count == 0) {
                        cell.lblCount.text = @"";
                    } else {
                        cell.lblCount.text = [NSString stringWithFormat:@"%d",floderM.count];
                    }
                }
            } else {
                cell.lblCount.text = [NSString stringWithFormat:@"%@",floderM.count==0? @"":[NSString stringWithFormat:@"%d",floderM.count]];
            }
           
            
            if (_selectRow == indexPath.row) {
                cell.contentView.backgroundColor = MAIN_ZS_COLOR;
                cell.lblContent.textColor = MAIN_WHITE_COLOR;
                cell.lblCount.textColor = MAIN_WHITE_COLOR;
                cell.headImgView.image = [UIImage imageNamed:[floderM.name stringByAppendingString:@"_h"]];
            } else {
                cell.contentView.backgroundColor = MAIN_WHITE_COLOR;
                cell.lblContent.textColor = MAIN_PURPLE_COLOR;
                cell.lblCount.textColor = MAIN_PURPLE_COLOR ;
                cell.headImgView.image = [UIImage imageNamed:floderM.name];
            }
            return cell;
        } else {
            EmailNameCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailNameCellResue];
            if (indexPath.section == 0) {
                EmailAccountModel *emailInfo = self.emails[indexPath.row];
                cell.lblName.text = emailInfo.User;
                if (emailInfo.isConnect) {
                    cell.connectImgView.hidden = NO;
                } else {
                    cell.connectImgView.hidden = YES;
                }
                if (emailInfo.unReadCount == 0) {
                    cell.countContraintW.constant = 0;
                } else if (emailInfo.unReadCount > 99) {
                    cell.countContraintW.constant = 25;
                } else {
                    cell.countContraintW.constant = 16;
                }
                cell.lblCount.text = [NSString stringWithFormat:@"%d",emailInfo.unReadCount];
                cell.lblFirstName.text = [StringUtil getUserNameFirstWithName:emailInfo.User];
                
            } else {
                cell.lblName.text = @"New Account";
                cell.connectImgView.hidden = YES;
            }
            if (indexPath.section == 1) {
                cell.topLineView.hidden = NO;
                cell.lblCount.hidden = YES;
                cell.lblFirstName.hidden = YES;
                cell.headImgView.image = AppD.isEmailPage? [UIImage imageNamed:@"email_icon_addemail"]:[UIImage imageNamed:@"email_icon_addemail"];
            } else {
                cell.topLineView.hidden = YES;
                cell.lblCount.hidden = NO;
                cell.lblFirstName.hidden = NO;
                cell.headImgView.image = AppD.isEmailPage? [UIImage imageNamed:@"email_icon_selected"]:[UIImage imageNamed:@"email_icon_selected"];
            }
            return cell;
        }
    }
    
    // message
    EmailNameCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailNameCellResue];
    cell.connectImgView.hidden = YES;
    if (indexPath.section == 0) {
        RouterModel *model = self.messageDataArray[indexPath.section][indexPath.row];
        cell.lblName.text = model.name;
        cell.lblFirstName.text = [StringUtil getUserNameFirstWithName:model.name];
        if (model.isConnected) {
            cell.connectImgView.hidden = NO;
        }
    } else {
        cell.lblName.text = self.messageDataArray[indexPath.section][indexPath.row];
    }
    
    if (indexPath.section == 1) {
        cell.topLineView.hidden = NO;
        cell.lblCount.hidden = YES;
        cell.lblFirstName.hidden = YES;
        cell.lblName.text = @"Add a New Circle";
        cell.headImgView.image = AppD.isEmailPage? [UIImage imageNamed:@"email_icon_addemail"]:[UIImage imageNamed:@"email_icon_addemail"];
    } else {
        
        cell.topLineView.hidden = YES;
        cell.lblCount.hidden = YES;
        cell.lblFirstName.hidden = NO;
        cell.headImgView.image = AppD.isEmailPage? [UIImage imageNamed:@"email_icon_selected"]:[UIImage imageNamed:@"email_icon_selected"];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (AppD.isEmailPage) { // 是邮箱
            PNEmailTypeSelectView *vc = [[PNEmailTypeSelectView alloc] init];
            [self presentModalVC:vc animated:YES];
            @weakify_self
            [vc setClickRowBlock:^(PNBaseViewController * _Nonnull vc, NSArray * _Nonnull arr) {
                [vc dismissViewControllerAnimated:NO completion:nil];
                PNEmailLoginViewController *loginVC  = [[PNEmailLoginViewController alloc] initWithEmailType:[arr[1] intValue]];
                [weakSelf presentModalVC:loginVC animated:YES];
            }];
        }
    } else if (indexPath.section == 2) {
        if (_selectRow >=0) {
            EmailFloderCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectRow inSection:2]];
            cell.contentView.backgroundColor = MAIN_WHITE_COLOR;
            cell.lblContent.textColor = MAIN_PURPLE_COLOR;
            cell.lblCount.textColor = MAIN_PURPLE_COLOR;
        }
        _selectRow = indexPath.row;
        FloderModel *model = self.emailFolders[indexPath.row];
        EmailFloderCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if (cell.lblCount.text.length > 0) {
            model.count = [cell.lblCount.text intValue];
        }
        [self clickFloderHideMenuViewController:model];
    } else if (indexPath.section == 0) {
        if (AppD.isEmailPage) {
            // 切换邮箱
             EmailAccountModel *accountModel = self.emails[indexPath.row];
            if (!accountModel.isConnect) {
                _selectRow = 0;
                // 修改当前连接邮箱
                accountModel.isConnect = YES;
                [EmailAccountModel updateEmailAccountConnectStatus:accountModel];
                // 拉取文件夹
                [self pullFloder];
            }
            
        }
    }
    
}

#pragma mark -----------通知回调----------
- (void) emailLoginSuccessNoti:(NSNotification *) noti
{
    [self pullFloder];
}
- (void) emailFalgsChangeSuccessNoti:(NSNotification *) noti
{
    int optionType = [noti.object intValue];
    if (optionType == 2 || optionType == 3) { // 删除和移动
        [self.mainTabView reloadData];
    }
}
- (void) emailNodeCountSuccessNoti:(NSNotification *) noti
{
    NSDictionary *dic = noti.object;
    NSInteger retCode = [dic[@"RetCode"] integerValue];
    if (retCode == 0) {
        int numCount =[dic[@"Num"] intValue];
        NSString *toid = dic[@"ToId"];
        if ([toid isEqualToString:[UserConfig getShareObject].userId]) {
            FloderModel *floderM = self.emailFolders[1];
            floderM.count = numCount;
            [_mainTabView reloadData];
        }
    }

}
    
    

- (void) pullFloder{
    
    NSArray *emailAccounts = [EmailAccountModel getLocalAllEmailAccounts];
    if (emailAccounts.count == 0) {
        return;
    }
    [self.emails removeAllObjects];
    [self.emails addObjectsFromArray:emailAccounts];
    
    // 获取当前连接email
    EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
    if (accountModel) {
        MCOIMAPSession *imapSession = [[MCOIMAPSession alloc] init];
        imapSession.hostname = accountModel.hostname;
        imapSession.port = accountModel.port;
        imapSession.username = accountModel.User;
        imapSession.password = accountModel.UserPass;
        imapSession.connectionType = accountModel.connectionType;
        EmailManage.sharedEmailManage.imapSeeion = imapSession;
        
        MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
        smtpSession.hostname = [accountModel.hostname stringByReplacingOccurrencesOfString:@"imap" withString:@"smtp"];
        smtpSession.port = 465;
        smtpSession.username = accountModel.User;;
        smtpSession.password = accountModel.UserPass;
        smtpSession.connectionType = accountModel.connectionType;
        smtpSession.authType = MCOAuthTypeSASLLogin;
        smtpSession.timeout = 60.0;
        EmailManage.sharedEmailManage.smtpSession = smtpSession;
    }
    
    // 获取email 文件夹配置
    NSDictionary *floderDic = [EmailFloderConfig getFloderConfigWithEmailType:accountModel.Type];
    // 得到对应文件夹path
    [self.emailFolders enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FloderModel *model = obj;
        model.path = [floderDic objectForKey:model.name]?:@"";
    }];
    [self getFloaderEmailCount];
    
 //   MCOIMAPFetchFoldersOperation *imapFetchFolderOp = [EmailManage.sharedEmailManage.imapSeeion fetchAllFoldersOperation];
//    @weakify_self
//    [imapFetchFolderOp start:^(NSError * error, NSArray * folders) {
//        [folders enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            MCOIMAPFolder *info = obj;
//            NSLog(@"path = %@,name= %@",info.path,[EmailManage.sharedEmailManage.imapSeeion.defaultNamespace componentsFromPath:info.path][0]);
//        }];
//    }];
    
    
    /*
    [self.view showHudInView:self.view hint:@"Loading"];
    // 获取当前连接email
    EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
    // 获取email 文件夹配置
    NSDictionary *floderDic = [EmailFloderConfig getFloderConfigWithEmailType:accountModel.Type];
    
    if (!EmailManage.sharedEmailManage.imapSeeion) {
        
        MCOIMAPSession *imapSession = [[MCOIMAPSession alloc] init];
        imapSession.hostname = accountModel.hostname;
        imapSession.port = accountModel.port;
        imapSession.username = accountModel.User;
        imapSession.password = accountModel.UserPass;
        imapSession.connectionType = accountModel.connectionType;
        EmailManage.sharedEmailManage.imapSeeion = imapSession;
    }
    MCOIMAPFetchFoldersOperation *imapFetchFolderOp = [EmailManage.sharedEmailManage.imapSeeion fetchAllFoldersOperation];
    @weakify_self
    [imapFetchFolderOp start:^(NSError * error, NSArray * folders) {
        [weakSelf.view hideHud];
        if (weakSelf.emailFolders.count > 0) {
            [weakSelf.emailFolders removeAllObjects];
        }
        if (error) {
            [weakSelf.view showHint:[NSString stringWithFormat:@"%@",error]];
        } else {
            
            [self.emailFolders enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FloderModel *model = obj;
                NSString *flodePath = [floderDic objectForKey:model.name]?:@"";
                [folders enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    MCOIMAPFolder *floder = obj;
                    if ([flodePath isEqualToString:floder.path]) {
                        model.
                    }
                }];
                
            }];
            
            
            [weakSelf.emailFolders addObjectsFromArray:folders];
        }
        [weakSelf.mainTabView reloadData];
    }];
    */
    [[NSNotificationCenter defaultCenter] postNotificationName:EMIAL_ACCOUNT_CHANGE_NOTI object:nil];
}

- (void) getFloaderEmailCount
{
    
    
    // check 节点邮箱数量
    EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
    _editBtn.hidden = accountModel? NO:YES;
    if (accountModel) {
        @weakify_self
        __block NSInteger finshCount = 0;
        [self.emailFolders enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FloderModel *model = obj;
            if (model.path && model.path.length > 0) {
                MCOIMAPFolderInfoOperation * folderInfoOperation = [EmailManage.sharedEmailManage.imapSeeion folderInfoOperation:model.path];
                model.folderInfoOperation = folderInfoOperation;
                
                [model.folderInfoOperation start:^(NSError *error, MCOIMAPFolderInfo * info) {
                    finshCount++;
                    model.count = info.messageCount;
                    if (finshCount == 5) {
                        [weakSelf.mainTabView reloadData];
                    }
                }];
            }
        }];
        [SendRequestUtil sendEmailCheckNodeCountShowHud:NO];
    }
    
}
@end
