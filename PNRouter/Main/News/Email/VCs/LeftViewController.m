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
#import "PNEmailLoginViewController.h"
#import "EmailManage.h"
#import "EmailAccountModel.h"
#import "FloderModel.h"
#import "RSAUtil.h"

@interface LeftViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIView *menuBackView;
@property (weak, nonatomic) IBOutlet UITableView *mainTabView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (nonatomic , strong) NSMutableArray *messageDataArray;
@property (nonatomic,assign) NSInteger selectRow;
@property (nonatomic ,strong) NSMutableArray *emailFolders;
@property (nonatomic ,strong) NSMutableArray *emails;
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
    [_mainTabView reloadData];
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
        NSArray *floderArr = @[@"Inbox",@"Node backed up",@"Starred",@"Drafts",@"Sent",@"Spam",@"Trash"];
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
            MCOIMAPFolder *floder = self.emailFolders[indexPath.row];
            //解决中文folder乱码问题
            NSString *floderName = [[EmailManage.sharedEmailManage.imapSeeion defaultNamespace] componentsFromPath:floder.path][0];
            cell.lblContent.text = floderName;
            NSString *floderPath = floder.path;
            MCOIMAPFolderInfoOperation * folderInfoOperation = [EmailManage.sharedEmailManage.imapSeeion folderInfoOperation:floderPath];
            [folderInfoOperation start:^(NSError *error, MCOIMAPFolderInfo * info) {
                cell.lblCount.text = [NSString stringWithFormat:@"%d",info.messageCount];
            }];
            //            UIView *selectBackView = [[UIView alloc] initWithFrame:cell.bounds];
            //            selectBackView.backgroundColor = MAIN_PURPLE_COLOR;
            //            cell.selectedBackgroundView = selectBackView;
            if (_selectRow == indexPath.row) {
                cell.contentView.backgroundColor = MAIN_ZS_COLOR;
                cell.lblContent.textColor = MAIN_WHITE_COLOR;
                cell.lblCount.textColor = MAIN_WHITE_COLOR;
            } else {
                cell.contentView.backgroundColor = MAIN_WHITE_COLOR;
                cell.lblContent.textColor = MAIN_PURPLE_COLOR;
                cell.lblCount.textColor = MAIN_PURPLE_COLOR ;
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
            } else {
                cell.lblName.text = @"New Account";
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
    } else {
        cell.lblName.text = self.messageDataArray[indexPath.section][indexPath.row];
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 1) {
        if (AppD.isEmailPage) {
            PNEmailLoginViewController *vc = [[PNEmailLoginViewController alloc] init];
            [self presentModalVC:vc animated:YES];
        }
    } else if (indexPath.section == 2) {
        if (_selectRow >=0) {
            EmailFloderCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_selectRow inSection:2]];
            cell.contentView.backgroundColor = MAIN_WHITE_COLOR;
            cell.lblContent.textColor = MAIN_PURPLE_COLOR;
            cell.lblCount.textColor = MAIN_PURPLE_COLOR;
        }
        _selectRow = indexPath.row;
        MCOIMAPFolder *floder = self.emailFolders[indexPath.row];
        FloderModel *model = [[FloderModel alloc] init];
        model.name =  [[EmailManage.sharedEmailManage.imapSeeion defaultNamespace] componentsFromPath:floder.path][0];
        model.path = floder.path;
        EmailFloderCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        model.count = [cell.lblCount.text intValue];
        [self clickFloderHideMenuViewController:model];
    }
    
}

#pragma mark -----------通知回调----------
- (void) emailLoginSuccessNoti:(NSNotification *) noti
{
    [self pullFloder];
}

- (void) pullFloder{
    
    NSArray *emailAccounts = [EmailAccountModel getLocalAllEmailAccounts];
    if (emailAccounts.count == 0) {
        return;
    }
    [self.emails removeAllObjects];
    [self.emails addObjectsFromArray:emailAccounts];
    
    [_mainTabView reloadData];
    
    [self.view showHudInView:self.view hint:@"Loading"];
    
    EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
    
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
                [folders enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    MCOIMAPFolder *floder = obj;
                    if (model) {
                        
                    }
                }];
                
            }];
            
            
            [weakSelf.emailFolders addObjectsFromArray:folders];
        }
        [weakSelf.mainTabView reloadData];
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:EMIAL_ACCOUNT_CHANGE_NOTI object:nil];
}
@end
