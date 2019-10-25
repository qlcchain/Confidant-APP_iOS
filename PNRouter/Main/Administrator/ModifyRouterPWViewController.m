//
//  LoginDeviceViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "ModifyRouterPWViewController.h"
#import "MyConfidant-Swift.h"
#import "SystemUtil.h"
#import "NSString+SHA256.h"

@interface ModifyRouterPWViewController ()<UITextFieldDelegate>
{
    BOOL isModifyRouterPWViewController;
}
@property (weak, nonatomic) IBOutlet UITextField *pwOldTF;
@property (weak, nonatomic) IBOutlet UITextField *pwNewTF;
@property (weak, nonatomic) IBOutlet UITextField *pwConfirmTF;

@property (weak, nonatomic) IBOutlet UIButton *updateBtn;

@end

@implementation ModifyRouterPWViewController

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetRouterKeySuccessNoti:) name:ResetRouterKey_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnConnect:) name:SOCKET_ON_CONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnDisconnect:) name:SOCKET_ON_DISCONNECT_NOTI object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
   // self.view.backgroundColor = MAIN_WHITE_COLOR;
    _pwOldTF.delegate = self;
    _pwNewTF.delegate = self;
    _pwConfirmTF.delegate = self;
    [self addObserve];
    [self renderView];
}

#pragma mark - Operation
- (void)renderView {
//    [_updateBtn setRoundedCorners:UIRectCornerAllCorners radius:4];
    _updateBtn.layer.cornerRadius = 4;
    _updateBtn.layer.masksToBounds = YES;
}

- (void)sendResetRouterKey {
    NSString *RouterId = _RouterId?:@"";
    NSString *OldKey = [_pwOldTF.text.trim?:@"" SHA256];
    NSString *NewKey = [_pwNewTF.text.trim?:@"" SHA256];
    
    [SendRequestUtil sendResetRouterKeyWithRouterId:RouterId OldKey:OldKey NewKey:NewKey showHud:YES];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}

- (IBAction)updateAction:(id)sender {
    
    [self.view endEditing:YES];
    
    if ([[NSString getNotNullValue:_pwOldTF.text.trim] isEmptyString] || _pwOldTF.text.trim.length !=8) {
        [self.view showHint:@"Your password must include 8 charactors."];
        return;
    }
    if (![_pwOldTF.text isEqualToString:_RouterPW]) {
        [AppD.window showHint:@"Old password is wrong."];
        return;
    }
    if ([[NSString getNotNullValue:_pwNewTF.text.trim] isEmptyString] || _pwNewTF.text.trim.length !=8) {
        [self.view showHint:@"Your password must include 8 charactors."];
        return;
    }
    if (![_pwNewTF.text.trim isEqualToString:_pwConfirmTF.text.trim]) {
        [self.view showHint:@"The new password entered twice is different."];
        return;
    }
    NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
    if (connectStatu == socketConnectStatusConnected) {
         [self sendResetRouterKey];
    } else {
        [self connectSocket];
    }
   
}
- (void) backPage
{
   [self leftNavBarItemPressedWithPop:YES];
}
#pragma mark - Noti
- (void)resetRouterKeySuccessNoti:(NSNotification *)noti {
    [self.view showHint:@"Modify Successful"];
    [self performSelector:@selector(backPage) withObject:self afterDelay:1.5];
}
#pragma mark -连接socket
- (void) connectSocket {
    NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
    if (connectStatu == socketConnectStatusConnected) {
        [[SocketUtil shareInstance] disconnect];
    }    // 连接
    [AppD.window showHudInView:AppD.window hint:Connect_Cricle];
    NSString *connectURL = [SystemUtil connectUrl];
    [SocketUtil.shareInstance connectWithUrl:connectURL];
}

#pragma mark -通知回调
- (void)socketOnConnect:(NSNotification *)noti {
    if (!isModifyRouterPWViewController) {
        return;
    }
    [AppD.window hideHud];
    [self sendResetRouterKey];
    
}

- (void)socketOnDisconnect:(NSNotification *)noti {
    if (!isModifyRouterPWViewController) {
        return;
    }
    [AppD.window hideHud];
    [AppD.window showHint:@"The connection fails"];
}

#pragma mark -codeTF 改变回调
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (range.length == 1 && string.length == 0) {
        return YES;
    } else if (textField.text.length >= 8) {
        textField.text = [textField.text substringToIndex:8];
        return NO;
    }
    return YES;
}

@end
