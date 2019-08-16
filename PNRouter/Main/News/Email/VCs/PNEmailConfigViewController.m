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

@end

@implementation PNEmailConfigViewController
- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = @[@[Email],@[HostName,UserName,Password,Port,Encrypted],@[HostName,UserName,Password,Port,Encrypted]];
    }
    return _dataArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    
    _accountM = [[EmailAccountModel alloc] init];
    _accountM.connectionType = MCOConnectionTypeTLS;
    _accountM.smtpConnectionType = MCOConnectionTypeTLS;
    _accountM.port = 993;
    _accountM.smtpPort = 465;
    _accountM.Type = 0;
    
    
    _mainTabView.delegate = self;
    _mainTabView.dataSource = self;
    _mainTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_mainTabView registerNib:[UINib nibWithNibName:EmailConfigCellResue bundle:nil] forCellReuseIdentifier:EmailConfigCellResue];
    
}
#pragma mark --------------IBOut btn clickaction------------
- (IBAction)clickCloseBtn:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}
- (IBAction)clickNextBtn:(id)sender {
    if (_accountM.User.length == 0) {
        [self.view showHint:@"Please enter Email."];
        return;
    }
    if (![_accountM.User isEmailAddress]) {
        [self.view showHint:@"Email format error."];
        return;
    }
    if (_accountM.hostname.length == 0 || _accountM.smtpHostname.length == 0) {
        [self.view showHint:@"Please enter hostName."];
        return;
    }
    if (_accountM.UserPass.length == 0) {
        [self.view showHint:@"Please enter password."];
        return;
    }
    if (_accountM.port == 0 || _accountM.smtpPort == 0) {
        [self.view showHint:@"Please enter port."];
        return;
    }
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
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"Incoming Mail Server";
    } else if (section == 2) {
        return @"Outgoing Mail Server";
    }
    return nil;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    EmailConfigCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailConfigCellResue];
    NSArray *arry = self.dataArray[indexPath.section];
    cell.lblTitle.text = arry[indexPath.row];
    cell.contentTF.enabled = YES;
    cell.arrowImgV.hidden = YES;
    cell.contentTF.tag = indexPath.section*10 + indexPath.row;
    cell.contentTF.keyboardType =  UIKeyboardTypeDefault;
    if (!cell.contentTF.delegate) {
        cell.contentTF.delegate = self;
        [cell.contentTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    }
   
    
    if (indexPath.section == 0) {
        if ([arry[indexPath.row] isEqualToString:Email]) {
            cell.contentTF.placeholder = @"user@example.com";
            cell.contentTF.text = _accountM.User;
        }
    } else if (indexPath.section == 1) {
        if ([arry[indexPath.row] isEqualToString:HostName]) {
            cell.contentTF.placeholder = @"imap.example.com";
            cell.contentTF.text = _accountM.User;
        } else if ([arry[indexPath.row] isEqualToString:UserName]) {
            cell.contentTF.placeholder = @"Optional";
            cell.contentTF.text = _accountM.userName;
        } else if ([arry[indexPath.row] isEqualToString:Password]) {
            cell.contentTF.placeholder = @"Required";
            cell.contentTF.text = _accountM.UserPass;
        } else if ([arry[indexPath.row] isEqualToString:Port]) {
            cell.contentTF.keyboardType = UIKeyboardTypeNumberPad;
            cell.contentTF.placeholder = @"Required";
            cell.contentTF.text = [NSString stringWithFormat:@"%d",_accountM.port];
        } else if ([arry[indexPath.row] isEqualToString:Encrypted]) {
            
            cell.contentTF.enabled = NO;
            cell.arrowImgV.hidden = NO;
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
            cell.contentTF.text = _accountM.smtpUserPass;
        } else if ([arry[indexPath.row] isEqualToString:Port]) {
            cell.contentTF.keyboardType = UIKeyboardTypeNumberPad;
            cell.contentTF.placeholder = @"Required";
            cell.contentTF.text = [NSString stringWithFormat:@"%d",_accountM.smtpPort];
        } else if ([arry[indexPath.row] isEqualToString:Encrypted]) {
            cell.contentTF.enabled = NO;
            cell.arrowImgV.hidden = NO;
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
    NSArray *arry = self.dataArray[indexPath.section];
    if ([arry[indexPath.row] isEqualToString:Encrypted]) {
        NSLog(@"-----------");
    }
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
            _accountM.smtpUserPass = content;
        } else if (row == 3) {
            _accountM.smtpPort = [content intValue];
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

