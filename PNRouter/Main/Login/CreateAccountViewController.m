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

@interface CreateAccountViewController ()
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;

@end

@implementation CreateAccountViewController

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
    if ([_nameTF.text.trim isEmptyString]) {
        [self.view showHint:@"Nickname cannot be empty."];
        return;
    }
    [self createUserName:_nameTF.text.trim];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _nextBtn.layer.cornerRadius = 4.0f;
}

// 创建用户昵称
- (void) createUserName:(NSString *) nickName
{
    [UserModel createUserLocalWithName:nickName];
    [AppD setRootLogin];
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
