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

@interface PNEmailLoginViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UITextField *emailNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *advanceBtn;
@property (weak, nonatomic) IBOutlet UIView *emailBackView;
@property (weak, nonatomic) IBOutlet UIView *passwordBackView;

@end

@implementation PNEmailLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 配置UI
    [self configUI];
    
    _emailNameTF.delegate = self;
    _passwordTF.delegate = self;
    
    _emailNameTF.text = @"kuangzihui@163.com";
    _passwordTF.text = @"applela19890712";
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
    
    if (![_emailNameTF.text.trim isEmailAddress]) {
        [self.view showHint:@"Email format error."];
        return;
    }
    if (_passwordTF.text.trim.length == 0) {
        [self.view showHint:@"Please enter password."];
        return;
    }
    [self loginImapEmailName:_emailNameTF.text pass:_passwordTF.text];
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
                NSString *emailType = [strings lastObject];
                NSArray *names = [emailType componentsSeparatedByString:@"."];
                if (names.count == 2) {
                    hostName = [NSString stringWithFormat:@"imap.%@",emailType];
                    smtpHostName = [NSString stringWithFormat:@"smtp.%@",emailType];
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
    
    
    MCOIMAPSession *imapSession = [[MCOIMAPSession alloc] init];
    imapSession.hostname = hostName;
    imapSession.port = port;
    imapSession.username = name;
    imapSession.password = pass;
    imapSession.connectionType = MCOConnectionTypeTLS;
    
    EmailManage.sharedEmailManage.imapSeeion = imapSession;
    
    [self.view showHudInView:self.view hint:@"Login..."];
    MCOIMAPOperation *imapOperation = [imapSession checkAccountOperation];
    __weak typeof(self) weakSelf = self;
    [imapOperation start:^(NSError * __nullable error) {
        [weakSelf.view hideHud];
        if (error == nil) {
            
            // 保存到本地
            EmailAccountModel *model = [[EmailAccountModel alloc] init];
            model.User = name;
            model.UserPass = pass;
            model.hostname = hostName;
            model.port = port;
            model.connectionType = MCOConnectionTypeTLS;
            model.Type = 3;
            [EmailAccountModel addEmailAccountWith:model];
            model.isConnect = YES;
            [EmailAccountModel updateEmailAccountConnectStatus:model];
            
             [[NSNotificationCenter defaultCenter] postNotificationName:EMIAL_LOGIN_SUCCESS_NOTI object:nil];
            
            [weakSelf clickCloseAction:nil];
            [AppD.window showHint:@"login successed."];
        } else {
            [AppD.window showHint:@"login failure."];
            NSLog(@"login account failure: %@\n", error);
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
