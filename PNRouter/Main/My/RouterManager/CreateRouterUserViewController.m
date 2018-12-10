//
//  CreateRouterUserViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/26.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "CreateRouterUserViewController.h"
#import "NSString+RegexCategory.h"
#import "NSString+Base64.h"
#import "RouterUserCodeViewController.h"


@interface CreateRouterUserViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *createBtn;
@property (nonatomic ,strong) NSString *rid;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *codeContraintH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgContraintH;

@end

@implementation CreateRouterUserViewController
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)initWithRid:(NSString *)rid {
    if (self = [super init]) {
        self.rid = rid;
    }
    return self;
}

- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)createAction:(id)sender {
    
    if ([_nameTF.text.trim isEmptyString]) {
        [self.view showHint:@"The verification Name cannot be empty"];
        return;
    }
    if (self.userType == 0) {
        if ([_codeTF.text.trim isEmptyString]) {
            [self.view showHint:@"The verification code cannot be empty"];
            return;
        }
        if (![_codeTF.text.trim isRouterCode]) {
            [self.view showHint:@"Captchas must consist of 8-bit Numbers and letters"];
            return;
        }
    }
    [self.view endEditing:YES];
    [SendRequestUtil createRouterUserWithRouterId:self.rid mnemonic:[_nameTF.text.trim base64EncodedString] code:_codeTF.text.trim?:@""];
}

- (void)viewDidLoad {
    [super viewDidLoad];
     _createBtn.layer.cornerRadius = 5.0f;
    _codeTF.delegate = self;
    if (self.userType == 1) {
        _msgContraintH.constant = 0;
        _codeContraintH.constant = 0;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createUserSuccess:) name:CREATE_USER_SUCCESS_NOTI object:nil];
}

#pragma mark -codeTF 改变回调
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == _codeTF) {
        //这里的if时候为了获取删除操作,如果没有次if会造成当达到字数限制后删除键也不能使用的后果.
        if (range.length == 1 && string.length == 0) {
            return YES;
        }
        //so easy
        else if (_codeTF.text.length >= 8) {
            _codeTF.text = [textField.text substringToIndex:8];
            return NO;
        }
    }
    return YES;
}

#pragma mark -NOTI
- (void) createUserSuccess:(NSNotification *) noti
{
    NSString *qrCode = noti.object;
    [AppD.window showHint:@"User creation successful."];
    RouterUserCodeViewController *vc = [[RouterUserCodeViewController alloc] init];
    RouterUserModel *model = [[RouterUserModel alloc] init];
    model.UserType = 2;
    model.Active = 0;
    model.Qrcode = qrCode;
    model.NickName = _nameTF.text.trim;
    model.IdentifyCode = _codeTF.text.trim;
    vc.routerUserModel = model;
    
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
