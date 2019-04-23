//
//  CreateAccountViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/2/20.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "CreateAccountViewController.h"
#import "UserModel.h"
#import "ImportAccountViewController.h"
#import "NSString+Trim.h"
#import "TermsViewController.h"

@interface CreateAccountViewController ()
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UILabel *lblBottom;

@end

@implementation CreateAccountViewController
- (IBAction)bottomAction:(id)sender {
    TermsViewController *vc = [[TermsViewController alloc] init];
    [self presentModalVC:vc animated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [super viewWillAppear:animated];
}

- (IBAction)importAccountAction:(id)sender {
    [self jumpImportAccountVC];
}
- (IBAction)nextAction:(id)sender {
    [self.view endEditing:YES];
     NSString *aliasName = [NSString trimWhitespaceAndNewline:[NSString getNotNullValue:_nameTF.text]];
    if ([aliasName isEmptyString]) {
        [self.view showHint:@"Nickname cannot be empty."];
        return;
    }
    [self createUserName:aliasName];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *urlStr = @"I accept the Terms & Privacy Policy.";
    
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc]initWithString:urlStr];
    NSRange contentRange = [urlStr rangeOfString:@"Terms & Privacy Policy."];//{0,[content length]};
    [content addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:contentRange];
    _lblBottom.attributedText = content;
    
    _nextBtn.layer.cornerRadius = 4.0f;
    [_nameTF becomeFirstResponder];
}

// 创建用户昵称
- (void) createUserName:(NSString *) nickName
{
    [UserModel createUserLocalWithName:nickName];
    [AppD setRootLoginWithType:RouterType];
}
#pragma mark - jump vc
- (void) jumpImportAccountVC
{
    ImportAccountViewController *vc = [[ImportAccountViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
