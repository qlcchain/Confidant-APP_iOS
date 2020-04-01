//
//  PNEntryViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/2/19.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNEntryViewController.h"
#import <libsodium/crypto_box.h>
#import <QLCFramework/QLCDPKIManager.h>
#import <QLCFramework/QLCWalletManage.h>
#import <QLCFramework/QLCFramework-Swift.h>
#import "ENMessageUtil.h"
#import "NSString+Base64.h"
#import "NSData+Base64.h"
#import "SystemUtil.h"
#import "NSString+Trim.h"
#import "PNRegisterAccountViewController.h"

@interface PNEntryViewController ()
@property (weak, nonatomic) IBOutlet UITextField *accountTF;

@property (weak, nonatomic) IBOutlet UITextField *typeTF;
@property (weak, nonatomic) IBOutlet UITextView *contentTV;
@property (nonatomic, strong) NSString *typeStr;
@end

@implementation PNEntryViewController
- (IBAction)clickBackAction:(id)sender {
    
    [self leftNavBarItemPressedWithPop:NO];
}
- (IBAction)regAccountAction:(id)sender {
     [self.view endEditing:YES];
    PNRegisterAccountViewController *vc = [[PNRegisterAccountViewController alloc] init];
    [self presentModalVC:vc animated:YES];
}
- (IBAction)clickTypeSel:(id)sender {
     [self.view endEditing:YES];
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"帐号类型" preferredStyle:UIAlertControllerStyleActionSheet];
    @weakify_self
    UIAlertAction *delAction = [UIAlertAction actionWithTitle:@"weChat" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.typeStr = @"weChat";
        weakSelf.typeTF.text = weakSelf.typeStr;
    }];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"email" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        weakSelf.typeStr = @"email";
        weakSelf.typeTF.text = weakSelf.typeStr;
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertVC addAction:delAction];
    [alertVC addAction:saveAction];
    [alertVC addAction:cancelAction];
    
    [self presentViewController:alertVC animated:YES completion:nil];
    
}
- (IBAction)clickDeMessage:(id)sender {
     [self.view endEditing:YES];
    NSString *enContent = _contentTV.text.trim;
    if (enContent.length == 0) {
        [self.view showHint:@"请输入加解密内容"];
        return;
    }
    NSString *deMessage = [ENMessageUtil deMessageStr:enContent];
    if (deMessage.length == 0) {
        [self.view showHint:@"解密失败"];
    } else {
        [self alertEnMessage:deMessage titleStr:@"加解密后内容"];
    }
}
- (IBAction)clickEnMessage:(id)sender {

     [self.view endEditing:YES];
    NSString *accountStr = [NSString trimWhitespaceAndNewline:[NSString getNotNullValue:_accountTF.text]];
   __block NSString *enContent = _contentTV.text.trim;
    
    if (_typeStr.length == 0) {
        [self.view showHint:@"请选择帐号类型"];
        return;
    }
    if (accountStr.length == 0) {
        [self.view showHint:@"请输入帐号"];
        return;
    }
    
    if (enContent.length == 0) {
        [self.view showHint:@"请输入加解密内容"];
        return;
    }
    // 转小写
    accountStr = [accountStr lowercaseString];
    [self.view showHudInView:self.view hint:@""];
    @weakify_self
    [QLCDPKIManager getPubKeyByTypeAndID:QLC_TEST_URL type:_typeStr ID:accountStr successHandler:^(NSArray * _Nullable responseObj) {
        [weakSelf.view hideHud];
        if (responseObj && responseObj.count > 0) {
            NSDictionary *regDic = responseObj[0];
           // NSString *account = regDic[@"account"];
            NSString *pubKey = regDic[@"pubKey"];
            NSString *enMessage = [weakSelf enMessageStr:enContent pk:pubKey]?:@"";
            if (enMessage.length == 0) {
                [weakSelf.view showHint:@"加密失败"];
            } else {
                [weakSelf alertEnMessage:enMessage titleStr:@"加解密后内容"];
            }
        } else {
            [weakSelf.view showHint:@"没有找到此帐号"];
        }
       
    } failureHandler:^(NSError * _Nullable error, NSString * _Nullable message) {
        [weakSelf.view hideHud];
        [weakSelf.view showHint:message];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    // Do any additional setup after loading the view from its nib.
    _contentTV.layer.cornerRadius = 8.0f;
    
    
}

- (NSString *) enMessageStr:(NSString *) messageStr pk:(NSString *) pk
{
    NSString *enPk = [[SystemUtil HexStrToData:pk] base64EncodedString];
    NSLog(@"pk = %@",[EntryModel getShareObject].publicKey);
    NSString *symmetryString = [LibsodiumUtil getSymmetryWithPrivate:[EntryModel getShareObject].tempPrivateKey publicKey:enPk];
    NSString *enMessage = [LibsodiumUtil encryMsgPairWithSymmetry:symmetryString enMsg:messageStr nonce:EN_NONCE];
    return [ENMessageUtil enMessageStr:enMessage enType:@"00" qlcAccount:@"" tokenNum:@"" tokenType:@"" enNonce:EN_NONCE];
}


- (void) alertEnMessage:(NSString *) message titleStr:(NSString *) titleStr
{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:titleStr message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = message;
    }];
    [alert1 setValue:UIColorFromRGB(0x2C2C2C) forKey:@"_titleTextColor"];
    [alertC addAction:alert1];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:alertCancel];
    
    [self presentViewController:alertC animated:YES completion:nil];
}
@end
