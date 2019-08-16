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

static NSString *strqq = @"Step 1: Check that IMAP is turned on\n1. On your computer, open QQ Mail.\n2. In the top right, click Settings.\n3. Find POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV.\n4. Enable IMAP/SMTP.\n\nStep 2: Get authorization to log in the third-party Email client\n1. Generate authorization code.\n2. Check the SMS message sent by QQ Mail.\n3. Fill in the authorization code.\n\nThen enter your Email address and password to log in.";

static NSString *str163 = @"Step 1: Check that IMAP is turned on\n1. On your computer, open 163 Mail.\n2. In the top right, click Settings.\n3. Click Settings.\n4. Click POP3/SMTP/IMAP tab.\n5. In the POP3/SMTP/IMAP setting section, select Enable IMAP/SMTP.\n6. Click Save Changes.\n\nStep 2: Get authorization to log in the third-party Email client\n1. Pass security verification.\n2. Set up authorization code.\n3. Click Confirm.\n\nThen enter your Email address and password to log in.";

static NSString *strgmail = @"Step 1: Check that IMAP is turned on\n1. On your computer, open Gmail.\n2. In the top right, click Settings.\n3. Click Settings.\n 4. Click the Forwarding and POP/IMAP tab.\n5. In the \"IMAP access\" section, select Enable IMAP.\n6. Click Save Changes.\n\n\nStep 2: Allow less secure apps\n 1. In the top right, click Account.\n2. Click Security in the left bar.\n3. Turn on Less secure app access.\n4. Open the alert email sent by Google.\n5. Confirm the turn on activity.\n\nThen enter your Email address and password to log in.";


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
@property (nonatomic ,strong) NSString *iconName;
@property (nonatomic ,strong) EmailAccountModel *accountM;
@property (weak, nonatomic) IBOutlet UILabel *navTitle;
@property (weak, nonatomic) IBOutlet UIImageView *emailIconImgV;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollerView;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;


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
            self.iconName = @"email_icon_163_n";
        } else if (type == 2) {
            self.typeName = @"qq.com";
            self.iconName = @"email_icon_qq_n";
        } else if (type == 1) {
            self.typeName = @"exmail.qq.com";
            self.iconName = @"email_icon_qqmailbox_n";
        } else if (type == 4){
            self.typeName = @"gmail.com";
            self.iconName = @"email_icon_google_n";
        } else if (type == 5){
            self.typeName = @"office365.com";
            self.iconName = @"email_icon_outlook_n";
        } else if (type == 6){
            self.typeName = @"icloud.com";
            self.iconName = @"email_icon_icloud_n";
        }
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDictionary *contentDic = @{@"1":strqq,@"2":strqq,@"3":str163,@"4":strgmail};
    NSString *contentStr = contentDic[[NSString stringWithFormat:@"%d",self.emailType]];
    if (contentStr && contentStr.length>0) {
        _lblContent.text = contentStr;
    } else {
        _lblContent.text = @"";
    }
    
    if (self.emailNameTF.text.length>0&&self.passwordTF.text.length>0) {
        self.loginBtn.enabled = YES;
        self.loginBtn.alpha = 1;
    }else{
        self.loginBtn.enabled = NO;
        self.loginBtn.alpha = 0.5;
    }
    
    // 配置UI
    [self configUI];
    
    [self addNoti];
    
    [_emailNameTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    [_passwordTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    
    _emailIconImgV.image = [UIImage imageNamed:self.iconName];
    
    _emailNameTF.delegate = self;
    _passwordTF.delegate = self;
    
    if (self.optionType == ConfigEmail) {
        _navTitle.text = @"Configure";
        _emailNameTF.enabled = NO;
        EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
        _emailNameTF.text = accountM.User;
        [_loginBtn setTitle:@"Configure" forState:UIControlStateNormal];
    }
    
    _emailNameTF.placeholder = [NSString stringWithFormat:@"example@%@",self.typeName];
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
    if (emailName.length == 0) {
        [self.view showHint:@"Please enter Email."];
        return;
    }
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
                if (self.emailType == 5) {
                    
                } else if (![emailT isEqualToString:self.typeName] && self.emailType !=1 && self.emailType !=4) {
                    [self.view showHint:@"Email format error."];
                    return;
                }
                NSArray *names = [emailT componentsSeparatedByString:@"."];
                if (names.count == 2) {
                    if (self.emailType == 5) {
                        hostName = [NSString stringWithFormat:@"outlook.%@",self.typeName];
                    } else {
                        hostName = [NSString stringWithFormat:@"imap.%@",self.typeName];
                    }
                    
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
    _accountM.smtpHostname = smtpHostName;
    _accountM.port = port;
    
    if (self.emailType == 5) { // outlook
        _accountM.smtpPort = 587;
        _accountM.smtpConnectionType = MCOConnectionTypeStartTLS;
    } else if (self.emailType == 6) {
        _accountM.smtpPort = 587;
        _accountM.hostname = @"imap.mail.me.com";
        _accountM.smtpHostname = @"smtp.mail.me.com";
        _accountM.smtpConnectionType = MCOConnectionTypeStartTLS;
    }
    _accountM.connectionType = MCOConnectionTypeTLS;
    _accountM.Type = self.emailType;
    _accountM.isConnect = YES;
    
    MCOIMAPSession *imapSession = [[MCOIMAPSession alloc] init];
    imapSession.hostname = _accountM.hostname;
    imapSession.port = _accountM.port;
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
            NSString *errorStr = [NSString stringWithFormat:@"\"%@\" Username or password is incorrect, or the IMAP service is not available",weakSelf.accountM.User];
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

//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//
//   // NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    textField.text =[textField.text stringByAppendingString:string];
//
//    if (self.emailNameTF.text.length>0&&self.passwordTF.text.length>0) {
//        self.loginBtn.enabled = YES;
//        self.loginBtn.alpha = 1;
//    }else{
//        self.loginBtn.enabled = NO;
//        self.loginBtn.alpha = 0.5;
//    }
//    return NO;
//}

- (void) textFieldTextChange:(UITextField *) tf
{
    if (self.emailNameTF.text.length>0&&self.passwordTF.text.length>0) {
        self.loginBtn.enabled = YES;
        self.loginBtn.alpha = 1;
    }else{
        self.loginBtn.enabled = NO;
        self.loginBtn.alpha = 0.5;
    }
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
