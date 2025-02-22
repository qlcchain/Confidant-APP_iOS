//
//  AddNewMemberViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "AddNewMemberViewController.h"
#import "InvitationQRCodeViewController.h"
//#import "RouterUserCodeViewController.h"
#import "RouterUserModel.h"
#import "NSString+Base64.h"
#import "RouterModel.h"
#import "NSString+Trim.h"

@interface AddNewMemberViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (nonatomic ,strong) NSString *rid;

@end

@implementation AddNewMemberViewController

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createUserSuccess:) name:CREATE_USER_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullTmpAccountSuccessNoti:) name:PullTmpAccount_Success_Noti object:nil];
    
}

- (instancetype)initWithRid:(NSString *)rid {
    if (self = [super init]) {
        self.rid = rid;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObserve];
    
    _nextBtn.layer.cornerRadius = 3.0f;
    _nextBtn.layer.masksToBounds = YES;
    
    _nameTF.delegate = self;
   // _nameTF.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    [_nameTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    
}

#pragma mark - action
- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}

- (IBAction)nextAction:(id)sender {
    [self.view endEditing:YES];
    if ([_nameTF.text.trim isEmptyString]) {
        [self.view showHint:@"Please fill in the name a contact name"];
        return;
    }
    
    [SendRequestUtil createRouterUserWithRouterId:self.rid mnemonic:[_nameTF.text.trim base64EncodedString]];
}

- (IBAction)qrCodeAction:(id)sender {
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"Caution" message:@"Anyone with your Circle QR Code can create accounts in your Confidant Station without your permission. " preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"Next" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
         [SendRequestUtil sendPullTmpAccountWithShowHud:YES];
    }];
    [alert1 setValue:UIColorFromRGB(0x2C2C2C) forKey:@"_titleTextColor"];
    [alertC addAction:alert1];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:alertCancel];
    [self presentViewController:alertC animated:YES completion:nil];
    
   
}

#pragma -mark uitextfeildchange
- (void) textFieldTextChange:(UITextField *) tf
{
    if (![NSString trimWhitespaceAndNewline:tf.text] || [NSString trimWhitespaceAndNewline:tf.text].length == 0) {
        _nextBtn.backgroundColor = RGB(213, 213, 213);
        _nextBtn.enabled = NO;
    } else {
        _nextBtn.backgroundColor = MAIN_PURPLE_COLOR;
        _nextBtn.enabled = YES;
    }
}

#pragma textfeild delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    NSLog(@"textFieldShouldReturn");
    return YES;
}

#pragma mark - Transition
- (void)jumpToTempQR:(RouterUserModel *)model {
    InvitationQRCodeViewController *vc = [[InvitationQRCodeViewController alloc] init];
    vc.routerUserModel = model;
    vc.userManageType = 1;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark -NOTI
- (void) createUserSuccess:(NSNotification *) noti {
    NSString *qrCode = noti.object;
    
    [AppD.window showHint:@"Added successfully!"];
    
    RouterUserModel *model = [[RouterUserModel alloc] init];
    model.UserType = 2;
    model.Active = 0;
    model.Qrcode = qrCode;
    model.NickName = [RouterModel getConnectRouter].name;
    model.aliaName = [NSString trimWhitespaceAndNewline:_nameTF.text];
    [self jumpToTempQR:model];
}

- (void)pullTmpAccountSuccessNoti:(NSNotification *)noti {
    NSDictionary *params = noti.object;
    NSInteger retCode = [params[@"RetCode"] integerValue];
    if (retCode == 0) {
        NSString *Qrcode = params[@"Qrcode"];
        NSString *ToId = params[@"ToId"];
        NSString *UserSN = params[@"UserSN"];
        RouterUserModel *model = [[RouterUserModel alloc] init];
        model.UserType = 3;
        model.Active = 0;
        model.Qrcode = Qrcode;
        model.UserSN = UserSN;
        model.NickName = [RouterModel getConnectRouter].name;
        //    model.NickName = @"TEMP USER";
        [self jumpToTempQR:model];
    }
    
}

@end
