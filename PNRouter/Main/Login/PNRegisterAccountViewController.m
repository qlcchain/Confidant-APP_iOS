//
//  PNRegisterAccountViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/2/19.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNRegisterAccountViewController.h"
#import <QLCFramework/QLCDPKIManager.h>
#import <QLCFramework/QLCWalletManage.h>
#import <QLCFramework/QLCFramework-Swift.h>
#import "NSString+Base64.h"
#import "NSData+Base64.h"
#import "SystemUtil.h"
#import "NSString+Trim.h"
#import "ENMessageUtil.h"
#import "NSDate+Category.h"

@interface PNRegisterAccountViewController ()
@property (weak, nonatomic) IBOutlet UITextField *typeTF;
@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (nonatomic, strong) NSString *typeStr;
@property (nonatomic, strong) NSString *signHexKey;
@property (nonatomic, strong) NSString *qlcAccount;
@property (nonatomic, strong) NSString *orcaleSPK;
@property (nonatomic, strong) NSMutableDictionary *accountDic;
@end

@implementation PNRegisterAccountViewController

#pragma mark----------layz
- (NSMutableDictionary *)accountDic
{
    if (!_accountDic) {
        _accountDic = [NSMutableDictionary dictionary];
    }
    return _accountDic;
}

- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}

- (IBAction)clickAccountAction:(id)sender {
    
    NSString *signPrivateKey = [EntryModel getShareObject].signPrivateKey;
    NSData *skData = [signPrivateKey base64DecodedData];
    _signHexKey = [[SystemUtil dataToHexString:skData] substringToIndex:64];
    NSLog(@"signPrivateKeyLength = %ld",_signHexKey.length);
    NSString *qlcPrivateKey = [QLCUtil seedToPrivateKeyWithSeed:_signHexKey index:0];
    NSString *qlcPublicKey = [QLCUtil privateKeyToPublicKeyWithPrivateKey:qlcPrivateKey];
    _qlcAccount = [QLCUtil publicKeyToAddressWithPublicKey:qlcPublicKey];
    
    [self alertEnMessage:[NSString stringWithFormat:@"Seed: %@\nAccount: %@",self.signHexKey,self.qlcAccount] titleStr:@"Account信息"];
    
}
- (IBAction)clickRegisterAction:(id)sender {
    
    [self.view endEditing:YES];
    
    NSString *signPrivateKey = [EntryModel getShareObject].signPrivateKey;
    NSData *skData = [signPrivateKey base64DecodedData];
    _signHexKey = [[SystemUtil dataToHexString:skData] substringToIndex:64];
    NSLog(@"signPrivateKeyLength = %ld",_signHexKey.length);
    NSString *qlcPrivateKey = [QLCUtil seedToPrivateKeyWithSeed:_signHexKey index:0];
    NSString *qlcPublicKey = [QLCUtil privateKeyToPublicKeyWithPrivateKey:qlcPrivateKey];
    _qlcAccount = [QLCUtil publicKeyToAddressWithPublicKey:qlcPublicKey];
    
    __block NSString *accountStr = [NSString trimWhitespaceAndNewline:[NSString getNotNullValue:_accountTF.text]];
     
     if (_typeStr.length == 0) {
         [self.view showHint:@"请选择帐号类型"];
         return;
     }
     if (accountStr.length == 0) {
         [self.view showHint:@"请输入帐号"];
         return;
     }
    // 转小写
    accountStr = [accountStr lowercaseString];
    
    [self.view showHudInView:self.view hint:@""];
  
    @weakify_self
    [QLCDPKIManager getAccountPublicKey:QLC_TEST_URL address:@"qlc_38k6bk5wh9tpfh57wb3nicg9wyap4iaqhx9qxg18dz7u94cx7deweyhdsn6x" successHandler:^(NSArray * _Nullable responseObj) {
        weakSelf.orcaleSPK = (NSString *)responseObj;
        // 获取所有验证者
        [QLCDPKIManager getAllVerifiers:QLC_TEST_URL successHandler:^(NSArray * _Nullable responseObj) {
            
            NSMutableArray *verifiers = [NSMutableArray array];
            [responseObj enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                // 最多只能 5 个 ，暂定取前 5个
                NSDictionary *dic = obj;
                [verifiers addObject:dic[@"account"]];
                if (verifiers.count == 4) {
                    *stop = YES;
                }
            }];
            // orcale 地址
            [verifiers addObject:@"qlc_38k6bk5wh9tpfh57wb3nicg9wyap4iaqhx9qxg18dz7u94cx7deweyhdsn6x"];
            // 拼接参数
            //NSString *emailId = @"kuangzihui@163.com";
            NSData *pkData = [[EntryModel getShareObject].publicKey base64DecodedData];
            NSString *pkHex = [SystemUtil dataToHexString:pkData];
            NSDictionary *params1 = @{@"account":weakSelf.qlcAccount, @"type":weakSelf.typeStr, @"id":accountStr, @"pubkey":pkHex, @"fee":@"500000000", @"verifiers":verifiers};
            // 获取一个发布块以发布一个id / publicKey对
            [QLCDPKIManager getPublishBlock:QLC_TEST_URL params:params1 successHandler:^(NSDictionary * _Nullable responseObj) {
                
                NSDictionary *verifiers = responseObj[@"verifiers"]?:@{};
                NSDictionary *accDic = verifiers[@"19464572@qq.com"]?:@{};
                [weakSelf.accountDic addEntriesFromDictionary:accDic];
                // account code pubKey hash
                NSDictionary *block = responseObj[@"block"];
          
                NSDictionary *signBlock = [QLCUtil getSignBlockWithBlockDic:block privateKey:qlcPrivateKey publicKey:qlcPublicKey];
                
                NSString *emailContent = [weakSelf enEmailContentMessage];
                
                [weakSelf alertEnMessage:emailContent titleStr:@"EamilContent"];
                
                // 计算process
                [QLCDPKIManager process:QLC_TEST_URL params:signBlock successHandler:^(NSString * _Nullable responseObj) {
                     NSLog(@"responseObj = process%@",responseObj);
                     [weakSelf.view hideHud];
                    [AppD.window showHint:@"Registered successfully."];
                    
                    NSString *emailContent = [weakSelf enEmailContentMessage];
                    
                    [weakSelf alertEnMessage:emailContent titleStr:@"EamilContent"];
                    
                } failureHandler:^(NSError * _Nullable error, NSString * _Nullable message) {
                    [weakSelf.view hideHud];
                    [AppD.window showHint:message];
                    NSLog(@"message = process%@",message);
                    
                    [weakSelf alertEnMessage:[NSString stringWithFormat:@"Seed: %@\nAccount: %@",weakSelf.signHexKey,weakSelf.qlcAccount] titleStr:@"Account信息"];
                }];
                
            } failureHandler:^(NSError * _Nullable error, NSString * _Nullable message) {
                [weakSelf.view hideHud];
                [weakSelf.view showHint:message];
                NSLog(@"message = getPublishBlock%@",message);
                [weakSelf alertEnMessage:[NSString stringWithFormat:@"Seed: %@\nAccount: %@",weakSelf.signHexKey,weakSelf.qlcAccount] titleStr:@"Account信息"];
            }];
            
        } failureHandler:^(NSError * _Nullable error, NSString * _Nullable message) {
            [weakSelf.view hideHud];
            [weakSelf.view showHint:message];
            NSLog(@"message = verifiers%@",message);
        }];
        
    } failureHandler:^(NSError * _Nullable error, NSString * _Nullable message) {
        [weakSelf.view hideHud];
        [weakSelf.view showHint:message];
        NSLog(@"message = verifiers%@",message);
    }];
    
}


- (IBAction)clickSelTypeAction:(id)sender {
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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = MAIN_GRAY_COLOR;
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

- (NSString *) enEmailContentMessage
{
    NSString *hexSpk = @"8057548d32982953a687f0811639c814de94b42d1cfdc200804ba2583fdff924";//self.orcaleSPK?:@"";
    NSString *code = self.accountDic[@"code"]?:@"";
    NSString *hash = self.accountDic[@"hash"]?:@"";
    
    
    NSString *spk = [[SystemUtil HexStrToData:hexSpk] base64EncodedString];
    NSString *ppk = [LibsodiumUtil getFriendEnPublickkeyWithFriendSignPublicKey:spk]?:@"";
    NSString *enPk = [ppk stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    
   
    
    
    NSString *symmetryString = [LibsodiumUtil getSymmetryWithPrivate:[EntryModel getShareObject].tempPrivateKey publicKey:enPk];
    
     ;
    NSLog(@"tempPrivateKey = %@",[SystemUtil dataToHexString:[[EntryModel getShareObject].tempPrivateKey base64DecodedData]]);
     NSLog(@"对方公钥 = %@",[SystemUtil dataToHexString:[ppk base64DecodedData]]);
    
    NSString *signPrivateKey = [EntryModel getShareObject].signPrivateKey;
       NSData *skData = [signPrivateKey base64DecodedData];
       signPrivateKey = [SystemUtil dataToHexString:skData];
       NSLog(@"signPrivateKey = %@",signPrivateKey);
    
    NSString *signPublicKey = [EntryModel getShareObject].signPublicKey;
    NSData *pkData = [signPublicKey base64DecodedData];
    signPublicKey = [SystemUtil dataToHexString:pkData];
    NSLog(@"signPublicKey = %@",signPublicKey);
    
    NSLog(@"symmetryString = %@",symmetryString);
    /*
     1) Pk，用户自己的签名公钥，即E(pub_key1)（44字符长度）
     (2) Code, 16字符长度的字符串，由dpki_getPublishBlock的response中得到
     (3) Hash，64字符长度字符串，由dpki_getPublishBlock的response中得到，标识对应的publish块
     (4) Timestamp,一个14位字符串，形如20200221160423，精确到秒
     (5) Sign，签名，用户用自己的签名私钥对code+Timestamp签名。
     */
    
    NSString *emailContent = [EntryModel getShareObject].signPublicKey;
    emailContent = [emailContent stringByAppendingString:code];
    emailContent = [emailContent stringByAppendingString:hash];
    NSString *timestamp = [NSString stringWithFormat:@"%ld",[NSDate getTimestampFromDate:[NSDate date]]];
    emailContent = [emailContent stringByAppendingString:timestamp];
    NSString *signContent = [LibsodiumUtil getOwenrSignTemp:[code stringByAppendingString:timestamp]]?:@"";
    emailContent = [emailContent stringByAppendingString:signContent];
    
    NSLog(@"emailContent = %@",emailContent);
    
    NSString *enMessage = [LibsodiumUtil encryMsgPairWithSymmetry:symmetryString enMsg:emailContent nonce:EN_NONCE];
    
    return [ENMessageUtil enMessageStr:enMessage enType:@"04" qlcAccount:@"" tokenNum:@"" tokenType:@"" enNonce:EN_NONCE];
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
