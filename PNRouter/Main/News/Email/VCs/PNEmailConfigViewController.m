//
//  PNEmailConfigViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/8/14.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNEmailConfigViewController.h"
#import "EmailConfigCell.h"
#import "EmailAccountModel.h"
#import "EmailManage.h"
#import "NSString+Trim.h"
#import "NSString+RegexCategory.h"
#import "PNEmailEncrypedViewController.h"
#import "EmailErrorAlertView.h"

static NSString *Email = @"Email";
static NSString *HostName = @"Host Name";
static NSString *UserName = @"User Name";
static NSString *Password = @"Password";
static NSString *Port = @"Port";
static NSString *Encrypted = @"Type of Encrypted Connections";


@interface PNEmailConfigViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTabView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) EmailAccountModel *accountM;
@property (nonatomic, assign) NSInteger currentSection;
@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, assign) BOOL isEditPass;
@property (nonatomic, assign) BOOL isEditSmtpPass;
@end

@implementation PNEmailConfigViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [self.view endEditing:YES];
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
     
}
- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = @[@[Email],@[HostName,UserName,Password,Port,Encrypted],@[HostName,UserName,Password,Port,Encrypted]];
    }
    return _dataArray;
}

- (instancetype)initWithIsEdit:(BOOL)isEdit
{
    if (self = [super init]) {
        self.isEdit = isEdit;
        if (isEdit) {
            self.accountM = [EmailAccountModel getConnectEmailAccount];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    
    if (!_isEdit) {
        _accountM = [[EmailAccountModel alloc] init];
        _accountM.connectionType = MCOConnectionTypeTLS;
        _accountM.smtpConnectionType = MCOConnectionTypeTLS;
        _accountM.port = 993;
        _accountM.smtpPort = 465;
        _accountM.Type = 255;
    }
    
    _mainTabView.delegate = self;
    _mainTabView.dataSource = self;
    _mainTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_mainTabView registerNib:[UINib nibWithNibName:EmailConfigCellResue bundle:nil] forCellReuseIdentifier:EmailConfigCellResue];
    
    [self performSelector:@selector(tfBecomeFirst) withObject:nil afterDelay:0.7];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectEntrypedNoti:) name:EMAIL_ENTRYPED_CHOOSE_NOTI object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailConfigNoti:) name:EMAIL_CONFIG_NOTI object:nil];
    
    
}
- (void) tfBecomeFirst
{
    EmailConfigCell *cell = [_mainTabView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (cell) {
        [cell.contentTF becomeFirstResponder];
    }
}
#pragma mark --------------IBOut btn clickaction------------
- (IBAction)clickCloseBtn:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}
- (IBAction)clickNextBtn:(id)sender {
    if (_accountM.User.length == 0) {
        [self.view showHint:@"Please enter an Email service"];
        return;
    }
    if (![_accountM.User isEmailAddress]) {
        [self.view showHint:@"Email format error"];
        return;
    }
    if (_accountM.hostname.length == 0 || _accountM.smtpHostname.length == 0) {
        [self.view showHint:@"Please enter a hostName"];
        return;
    }
    if (_accountM.UserPass.length == 0) {
        [self.view showHint:@"Please enter a password"];
        return;
    }
    if (_accountM.port == 0 || _accountM.smtpPort == 0) {
        [self.view showHint:@"Please enter a port."];
        return;
    }
    
    
    MCOIMAPSession *imapSession = [[MCOIMAPSession alloc] init];
    imapSession.hostname = _accountM.hostname;
    imapSession.port = _accountM.port;
    imapSession.username = _accountM.User;
    imapSession.password = _accountM.UserPass;
    imapSession.connectionType = _accountM.connectionType;
    
    NSString *hitStr = @"Verification...";
    
    [self.view showHudInView:self.view hint:hitStr userInteractionEnabled:NO hideTime:REQEUST_TIME_60];
    
    MCOIMAPOperation *imapOperation = [imapSession checkAccountOperation];
    @weakify_self
    [imapOperation start:^(NSError * __nullable error) {
        
        if (error == nil) {
            
            // 验证smtp
            MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
            smtpSession.hostname = weakSelf.accountM.smtpHostname;
            smtpSession.port = weakSelf.accountM.smtpPort;
            
            smtpSession.username = weakSelf.accountM.User;
            smtpSession.password = weakSelf.accountM.UserPass;
            smtpSession.connectionType = weakSelf.accountM.smtpConnectionType;
            
           // smtpSession.authType = MCOAuthTypeSASLLogin;
            smtpSession.timeout = 60.0;
            
            MCOAddress *addressM = [MCOAddress addressWithMailbox:weakSelf.accountM.User];
            MCOSMTPOperation *smtpOperation = [smtpSession checkAccountOperationWithFrom:addressM];
            
            [smtpOperation start:^(NSError * _Nullable error) {
                if (error == nil) {
                    if (weakSelf.isEdit) {
                        // 更改密码
                        [EmailAccountModel updateEmailAccountPass:weakSelf.accountM];
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:EMIAL_LOGIN_SUCCESS_NOTI object:nil];
                        [weakSelf.view hideHud];
                        [weakSelf clickCloseBtn:nil];
                        [AppD.window showHint:@"Verification successfully!"];
                        
                    } else {
                        
                        [SendRequestUtil sendEmailConfigWithEmailAddress:weakSelf.accountM.User type:@(255) caller:@(0) configJson:@"" ShowHud:NO];
                    }
                } else {
                    [weakSelf.view hideHud];
                    NSLog(@"ERROR = %@",error.domain);
                    NSString *errorStr = [NSString stringWithFormat:@"\"%@\" Username or password is incorrect, or the SMTP service is not available",weakSelf.accountM.User];
                    if (error.code == 1) {
                        errorStr = @"Unable to connect to email SMTP server.";
                    }
                    EmailErrorAlertView *alertView = [EmailErrorAlertView loadEmailErrorAlertView];
                    alertView.lblContent.text = errorStr;
                    [alertView showEmailAttchSelView];
                }
            }];
        } else {
            
            [weakSelf.view hideHud];
            NSLog(@"ERROR = %@",error.domain);
            NSString *errorStr = [NSString stringWithFormat:@"\"%@\" Username or password is incorrect, or the IMAP service is not available",weakSelf.accountM.User];
            if (error.code == 1) {
                errorStr = @"Unable to connect to email IMAP server.";
            }
            EmailErrorAlertView *alertView = [EmailErrorAlertView loadEmailErrorAlertView];
            alertView.lblContent.text = errorStr;
            [alertView showEmailAttchSelView];
            
        }
    }];
    
}


#pragma mark--------------UITableViewDelegate----------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.dataArray[section];
    return [array count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *array = self.dataArray[indexPath.section];
    if (indexPath.row == array.count-1) {
        return 110;
    }
    return EmailConfigCellHeight;
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.1;
    }
    return 30;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    headView.backgroundColor = RGBP(117, 115, 128,0.1);
    
    UILabel *lblContent = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, SCREEN_WIDTH-32, 30)];
    lblContent.backgroundColor = [UIColor clearColor];
    if (section == 1) {
        lblContent.text = @"Incoming Mail Server";
    } else if (section == 2) {
        lblContent.text = @"Outgoing Mail Server";
    }
    lblContent.textColor = RGB(148, 150, 161);
    lblContent.font = [UIFont systemFontOfSize:14];
    [headView addSubview:lblContent];
    return headView;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    EmailConfigCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailConfigCellResue];
    NSArray *arry = self.dataArray[indexPath.section];
    cell.tag = indexPath.section;
    cell.lblTitle.text = arry[indexPath.row];
    cell.contentTF.enabled = YES;
    cell.arrowImgV.hidden = YES;
    cell.backBtn.hidden = YES;
    cell.passOpenW.constant = 0;
    cell.contentTF.tag = indexPath.section*10 + indexPath.row;
    cell.contentTF.keyboardType =  UIKeyboardTypeDefault;
    cell.contentTF.secureTextEntry = NO;
    if (!cell.contentTF.delegate) {
        cell.contentTF.delegate = self;
        [cell.contentTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    }
    
    @weakify_self
    [cell setBackBlock:^(NSInteger section) {
       
        weakSelf.currentSection = section;
        int contectType = 4;
        if (indexPath.section == 1) {
            contectType = weakSelf.accountM.connectionType;
        } else {
            contectType = weakSelf.accountM.smtpConnectionType;
        }
        PNEmailEncrypedViewController *vc = [[PNEmailEncrypedViewController alloc] initWithConnectType:contectType];
        [weakSelf presentModalVC:vc animated:YES];
    }];
   
    
    if (indexPath.section == 0) {
        if ([arry[indexPath.row] isEqualToString:Email]) {
            
            cell.contentTF.text = _accountM.User;
            if (_isEdit) {
                cell.contentTF.enabled = NO;
            } else {
                cell.contentTF.placeholder = @"user@example.com";
                cell.contentTF.keyboardType = UIKeyboardTypeEmailAddress;
            }
        }
    } else if (indexPath.section == 1) {
        if ([arry[indexPath.row] isEqualToString:HostName]) {
            cell.contentTF.placeholder = @"imap.example.com";
            cell.contentTF.text = _accountM.hostname;
        } else if ([arry[indexPath.row] isEqualToString:UserName]) {
            cell.contentTF.placeholder = @"Optional";
            cell.contentTF.text = _accountM.userName;
        } else if ([arry[indexPath.row] isEqualToString:Password]) {
            
            cell.contentTF.placeholder = @"Required";
            if (_isEdit) {
                if (_isEditPass) {
                    cell.contentTF.text = _accountM.UserPass;
                } else {
                    cell.contentTF.text = @"";
                }
                
            } else {
                cell.contentTF.text = _accountM.UserPass;
            }
            
            cell.contentTF.secureTextEntry = !cell.isPassOpen;
            cell.passOpenW.constant = 30;
        } else if ([arry[indexPath.row] isEqualToString:Port]) {
            cell.contentTF.keyboardType = UIKeyboardTypeNumberPad;
            cell.contentTF.placeholder = @"Required";
            cell.contentTF.text = [NSString stringWithFormat:@"%d",_accountM.port];
        } else if ([arry[indexPath.row] isEqualToString:Encrypted]) {
            
            cell.contentTF.enabled = NO;
            cell.arrowImgV.hidden = NO;
            cell.backBtn.hidden = NO;
            if (_accountM.connectionType == MCOConnectionTypeClear) {
                cell.contentTF.text = @"None";
            } else if (_accountM.connectionType == MCOConnectionTypeStartTLS) {
                cell.contentTF.text = @"STARTTLS";
            } else {
                cell.contentTF.text = @"SSL/TLS";
            }
        }
    } else {
        if ([arry[indexPath.row] isEqualToString:HostName]) {
            cell.contentTF.placeholder = @"smtp.example.com";
            cell.contentTF.text = _accountM.smtpHostname;
        } else if ([arry[indexPath.row] isEqualToString:UserName]) {
            cell.contentTF.placeholder = @"Optional";
            cell.contentTF.text = _accountM.smtpUserName;
        } else if ([arry[indexPath.row] isEqualToString:Password]) {
            cell.contentTF.placeholder = @"Optional";
            if (_isEdit) {
                if (_isEditSmtpPass) {
                    cell.contentTF.text = _accountM.smtpUserPass;
                } else {
                    cell.contentTF.text = @"";
                }
            } else {
                cell.contentTF.text = _accountM.smtpUserPass;
            }
            
            cell.contentTF.secureTextEntry = !cell.isPassOpen;
            cell.passOpenW.constant = 30;
        } else if ([arry[indexPath.row] isEqualToString:Port]) {
            cell.contentTF.keyboardType = UIKeyboardTypeNumberPad;
            cell.contentTF.placeholder = @"Required";
            cell.contentTF.text = [NSString stringWithFormat:@"%d",_accountM.smtpPort];
        } else if ([arry[indexPath.row] isEqualToString:Encrypted]) {
            cell.contentTF.enabled = NO;
            cell.arrowImgV.hidden = NO;
            cell.backBtn.hidden = NO;
            if (_accountM.smtpConnectionType == MCOConnectionTypeClear) {
                cell.contentTF.text = @"None";
            } else if (_accountM.smtpConnectionType == MCOConnectionTypeStartTLS) {
                cell.contentTF.text = @"STARTTLS";
            } else {
                cell.contentTF.text = @"SSL/TLS";
            }
        }
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSArray *arry = self.dataArray[indexPath.section];
//    if ([arry[indexPath.row] isEqualToString:Encrypted]) {
//        _currentSection = indexPath.section;
//        int contectType = 4;
//        if (indexPath.section == 1) {
//            contectType = self.accountM.connectionType;
//        } else {
//            contectType = self.accountM.smtpConnectionType;
//        }
//        PNEmailEncrypedViewController *vc = [[PNEmailEncrypedViewController alloc] initWithConnectType:contectType];
//        [self presentModalVC:vc animated:YES];
//    }
}


#pragma mark -------textfeild delegate-----
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}

- (void) textFieldTextChange:(UITextField *) tf
{
    NSInteger section = tf.tag/10;
    NSInteger row = tf.tag%10;
    NSString *content = [NSString trimWhitespace:tf.text];
    if (section == 0) {
        if (row == 0) {
            _accountM.User = content;
        }
    } else if (section == 1) {
        if (row == 0) {
            _accountM.hostname = content;
        } else if (row == 1) {
            _accountM.userName = content;
        } else if (row == 2) {
            if (_isEdit) {
                _isEditPass = YES;
            }
            _accountM.UserPass = content;
        } else if (row == 3) {
            _accountM.port = [content intValue];
        }
    }  else if (section == 2) {
        if (row == 0) {
            _accountM.smtpHostname = content;
        } else if (row == 1) {
            _accountM.smtpUserName = content;
        } else if (row == 2) {
            if (_isEdit) {
                _isEditSmtpPass = YES;
            }
            _accountM.smtpUserPass = content;
        } else if (row == 3) {
            _accountM.smtpPort = [content intValue];
        }
    }
    
}



#pragma mark---------------通知--------------------
- (void) selectEntrypedNoti:(NSNotification *) noti
{
    int connectType = [noti.object intValue];
    if (_currentSection == 1) {
        self.accountM.connectionType = connectType;
        
    } else {
        self.accountM.smtpConnectionType = connectType;
    }
    
    if (connectType == 1) {
        if (_currentSection == 1) {
            self.accountM.port = 143;
        } else {
            self.accountM.smtpPort = 25;
        }
    } else if (connectType == 2) {
        if (_currentSection == 1) {
            self.accountM.port = 993;
        } else {
            self.accountM.smtpPort = 587;
        }
    } else {
        if (_currentSection == 1) {
            self.accountM.port = 993;
        } else {
            self.accountM.smtpPort = 465;
        }
    }
    
    [_mainTabView reloadSections:[NSIndexSet indexSetWithIndex:_currentSection] withRowAnimation:UITableViewRowAnimationNone];
}
- (void) emailConfigNoti:(NSNotification *) noti
{
    NSDictionary *dic = noti.object;
    NSInteger retCode = [dic[@"RetCode"] integerValue];
    if (retCode == 0) { // 成功
        // 保存到本地
        [EmailAccountModel addEmailAccountWith:_accountM];
        [EmailAccountModel updateEmailAccountConnectStatus:_accountM];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:EMIAL_LOGIN_SUCCESS_NOTI object:nil];
        [self.view hideHud];
        [self clickCloseBtn:nil];
        [AppD.window showHint:@"Verification successfully!"];
    } else {
        [self.view hideHud];
        if (retCode == 2) {
            [self.view showHint:@"The Email service has been configured"];
        } else {
            [self.view showHint:@"The number of your configured email services has met the upper limit."];
        }
    }
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

