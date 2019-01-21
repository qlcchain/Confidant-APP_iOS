//
//  LoginDeviceViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "ModifyActivateCodeViewController.h"
#import "PNRouter-Swift.h"
#import "SystemUtil.h"
#import "NSString+SHA256.h"

@interface ModifyActivateCodeViewController ()<UITextFieldDelegate>
{
    BOOL isModifyActivateCodeViewController;
}
@property (weak, nonatomic) IBOutlet UITextField *activationCodeTF;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;


@end

@implementation ModifyActivateCodeViewController

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetUserIdcodeSuccessNoti:) name:ResetUserIdcode_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnConnect:) name:SOCKET_ON_CONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnDisconnect:) name:SOCKET_ON_DISCONNECT_NOTI object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //self.view.backgroundColor = MAIN_WHITE_COLOR;
    _activationCodeTF.delegate = self;
    [self addObserve];
    [self renderView];
}

#pragma mark - Operation
- (void)renderView {
    [_updateBtn setRoundedCorners:UIRectCornerAllCorners radius:4];
}

- (void)sendResetUserIdcode {
    NSString *RouterId = _RouterId?:@"";
    NSString *UserSn = _UserSn?:@"";
    NSString *OldCode = _IdentifyCode?:@"";
    NSString *NewCode = _activationCodeTF.text?:@"";
    [SendRequestUtil sendResetUserIdcodeWithRouterId:RouterId UserSn:UserSn OldCode:OldCode NewCode:NewCode showHud:YES];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}

- (IBAction)updateAction:(id)sender {
    [self.view endEditing:YES];
    if (_activationCodeTF.text == nil || _activationCodeTF.text.length != 8) {
        [AppD.window showHint:@"Your activation code must include 8 charactors."];
        return;
    }
    NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
    if (connectStatu == socketConnectStatusConnected) {
        [self sendResetUserIdcode];
    } else {
        [self connectSocket];
    }
    
}
- (void) backPage
{
    [self leftNavBarItemPressedWithPop:YES];
}
#pragma mark - Noti
- (void)resetUserIdcodeSuccessNoti:(NSNotification *)noti {
    [self.view showHint:@"Modify Successful"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserIdcodeSuccessNoti" object:_activationCodeTF.text.trim];
    [self performSelector:@selector(backPage) withObject:self afterDelay:1.5];
}

#pragma mark -连接socket
- (void) connectSocket {
    NSInteger connectStatu = [SocketUtil.shareInstance getSocketConnectStatus];
    if (connectStatu == socketConnectStatusConnected) {
        [[SocketUtil shareInstance] disconnect];
    }    // 连接
    [AppD.window showHudInView:AppD.window hint:@"Connect Router..."];
    NSString *connectURL = [SystemUtil connectUrl];
    [SocketUtil.shareInstance connectWithUrl:connectURL];
}

#pragma mark -通知回调
- (void)socketOnConnect:(NSNotification *)noti {
    if (!isModifyActivateCodeViewController) {
        return;
    }
    [AppD.window hideHud];
    [self sendResetUserIdcode];
    
}

- (void)socketOnDisconnect:(NSNotification *)noti {
    if (!isModifyActivateCodeViewController) {
        return;
    }
    [AppD.window hideHud];
    [AppD.window showHint:@"The connection fails"];
}
#pragma mark -codeTF 改变回调
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField == _activationCodeTF) {
        //这里的if时候为了获取删除操作,如果没有次if会造成当达到字数限制后删除键也不能使用的后果.
        if (range.length == 1 && string.length == 0) {
            return YES;
        }
        //so easy
        else if (_activationCodeTF.text.length >= 8) {
            _activationCodeTF.text = [textField.text substringToIndex:8];
            return NO;
        }
    }
    return YES;
}
@end
