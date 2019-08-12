//
//  PNEmailLoginViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/10.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNEmailLoginViewController.h"
#import "NSString+RegexCategory.h"
#import "EmailManage.h"
#import "NSString+Trim.h"
#import "EmailAccountModel.h"
#import "RSAUtil.h"
#import "EmailErrorAlertView.h"


@interface PNEmailLoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITextField *emailNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *advanceBtn;
@property (weak, nonatomic) IBOutlet UIView *emailBackView;
@property (weak, nonatomic) IBOutlet UIView *passwordBackView;
@property (nonatomic ,assign) int emailType;
@property (nonatomic ,strong) NSString *typeName;
@property (nonatomic ,strong) EmailAccountModel *accountM;
@property (weak, nonatomic) IBOutlet UILabel *navTitle;

@end

@implementation PNEmailLoginViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype) initWithEmailType:(int) type optionType:(EmailOptionType)optionType
{
    if (self = [super init]) {
        self.emailType = type;
        self.optionType = optionType;
        if (type == 3) {
            self.typeName = @"163.com";
        } else if (type == 2) {
            self.typeName = @"qq.com";
        } else if (type == 1) {
            self.typeName = @"exmail.qq.com";
        } else {
            self.typeName = @"gmail.com";
        }
        _emailNameTF.placeholder = [NSString stringWithFormat:@"example@%@",self.typeName];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 配置UI
    [self configUI];
    
    [self addNoti];
    
    _emailNameTF.delegate = self;
    _passwordTF.delegate = self;
    
    if (self.optionType == ConfigEmail) {
        _navTitle.text = @"Configure";
        _emailNameTF.enabled = NO;
        EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
        _emailNameTF.text = accountM.User;
        [_loginBtn setTitle:@"Configure" forState:UIControlStateNormal];
    }
}
// 添加通知
- (void) addNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailConfigNoti:) name:EMAIL_CONFIG_NOTI object:nil];
}
// 配置UI
- (void) configUI
{
    _loginBtn.layer.cornerRadius = 8.0f;
    _loginBtn.layer.masksToBounds = YES;
    
    _emailBackView.layer.cornerRadius = 8.0f;
    _emailBackView.layer.masksToBounds = YES;
    
    _passwordBackView.layer.cornerRadius = 8.0f;
    _passwordBackView.layer.masksToBounds = YES;
    
    _advanceBtn.layer.cornerRadius = 8.0f;
    _advanceBtn.layer.masksToBounds = YES;
    _advanceBtn.layer.borderColor = [UIColor colorWithRed:57/255.0 green:60/255.0 blue:71/255.0 alpha:1.0].CGColor;
    _advanceBtn.layer.borderWidth = 1.0f;
    
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    _topView.backgroundColor = MAIN_GRAY_COLOR;
}
#pragma mark -----xib btnaction----------

- (IBAction)clickLoginAction:(id)sender {
    
    [self.view endEditing:YES];
    NSString *emailName = [NSString trimWhitespace:_emailNameTF.text];
    NSString *emailPass = [NSString trimWhitespace:_passwordTF.text];
    if (![emailName isEmailAddress]) {
        [self.view showHint:@"Email format error."];
        return;
    }
    if (emailPass.length == 0) {
        [self.view showHint:@"Please enter password."];
        return;
    }
    [self loginImapEmailName:emailName pass:emailPass];
}
- (IBAction)clickAdanceAction:(id)sender {
    
}
- (IBAction)clickCloseAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}

#pragma makr ---------登录邮箱------------
- (void) loginImapEmailName:(NSString *) name pass:(NSString *) pass
{
    [self.view endEditing:YES];
    
    unsigned int port = 993;
    NSString *hostName = @"";
    NSString *smtpHostName = @"";
    // 去除前后空格
    name = [NSString trimWhitespace:name];
    pass = [NSString trimNewline:pass];
    if (name && name.length > 0) {
        if ([name isEmailAddress]) {
            NSArray *strings = [name componentsSeparatedByString:@"@"];
            if (strings.count == 2) {
                NSString *emailT = [strings lastObject];
                if (![emailT isEqualToString:self.typeName] && self.emailType !=1) {
                    [self.view showHint:@"Email format error."];
                    return;
                }
                NSArray *names = [emailT componentsSeparatedByString:@"."];
                if (names.count == 2) {
                    hostName = [NSString stringWithFormat:@"imap.%@",self.typeName];
                    smtpHostName = [NSString stringWithFormat:@"smtp.%@",self.typeName];
                } else {
                    [self.view showHint:@"Email format error."];
                    return;
                }
            } else {
                [self.view showHint:@"Email format error."];
                return;
            }
        } else {
            [self.view showHint:@"Email format error."];
            return;
        }
    }
    
    _accountM = [[EmailAccountModel alloc] init];
    _accountM.User = name;
    _accountM.UserPass = pass;
    _accountM.hostname = hostName;
    _accountM.port = port;
    _accountM.connectionType = MCOConnectionTypeTLS;
    _accountM.Type = self.emailType;
    _accountM.isConnect = YES;
    
    MCOIMAPSession *imapSession = [[MCOIMAPSession alloc] init];
    imapSession.hostname = hostName;
    imapSession.port = port;
    imapSession.username = name;
    imapSession.password = pass;
    imapSession.connectionType = MCOConnectionTypeTLS;
    
    NSString *hitStr = @"Login...";
    if (self.optionType == ConfigEmail) {
        hitStr = @"Configure...";
    }
    [self.view showHudInView:self.view hint:hitStr userInteractionEnabled:NO hideTime:REQEUST_TIME];
   
    MCOIMAPOperation *imapOperation = [imapSession checkAccountOperation];
    @weakify_self
    [imapOperation start:^(NSError * __nullable error) {
       
        if (error == nil) {
            if (weakSelf.optionType == ConfigEmail) {
                
                // 更改密码
                [EmailAccountModel updateEmailAccountPass:weakSelf.accountM];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:EMIAL_LOGIN_SUCCESS_NOTI object:nil];
                [self.view hideHud];
                [self clickCloseAction:nil];
                [AppD.window showHint:@"Configure successed."];
                
            } else {
                [SendRequestUtil sendEmailConfigWithEmailAddress:name type:@(weakSelf.emailType) configJson:@"" ShowHud:NO];
            }
        } else {
            
            [weakSelf.view hideHud];
            NSLog(@"ERROR = %@",error.domain);
            NSString *errorStr = [NSString stringWithFormat:@"\"imap.%@\" Username or password is incorrect, or the IMAP service is not available",self.typeName];
            if (error.code == 1) {
                errorStr = @"Unable to connect to email server.";
            }
            EmailErrorAlertView *alertView = [EmailErrorAlertView loadEmailErrorAlertView];
            alertView.lblContent.text = errorStr;
            [alertView showEmailAttchSelView];
   
        }
    }];

}
#pragma mark -------textfeild delegate-----
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    textField.text = text;
    
    if (self.emailNameTF.text.length>0&&self.passwordTF.text.length>0) {
        self.loginBtn.enabled = YES;
        self.loginBtn.alpha = 1;
    }else{
        self.loginBtn.enabled = NO;
        self.loginBtn.alpha = 0.5;
    }
    return NO;
}


#pragma mark ----------------通知回调-----------------
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
        [self clickCloseAction:nil];
        [AppD.window showHint:@"login successed."];
    } else {
        [self.view hideHud];
        if (retCode == 2) {
            [self.view showHint:@"The mailbox has been configured"];
        } else {
            [self.view showHint:@"Configuration quantity exceeds limit."];
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
