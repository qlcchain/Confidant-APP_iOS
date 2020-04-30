//
//  PNSendSelectViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/4/26.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNSendSelectViewController.h"
#import "ChooseContactViewController.h"
#import "PNEmailSendViewController.h"
#import "PNEmailTypeSelectView.h"
#import "EmailAccountModel.h"
#import "PNEmailConfigViewController.h"

#import <GoogleSignIn/GoogleSignIn.h>
#import "GoogleUserModel.h"
#import "NSString+Base64.h"
#import "GoogleServerManage.h"
#import "PNEmailLoginViewController.h"
#import "SystemUtil.h"

@interface PNSendSelectViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *fileTypeImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblFileName;
@property (weak, nonatomic) IBOutlet UILabel *lblFileInfo;
@property (nonatomic, assign) BOOL isMax;
@end

@implementation PNSendSelectViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark------button 点击事件

- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}
- (IBAction)clcikSendMessageAction:(id)sender {
    if (_isMax) {
        [AppD.window showHint:@"The File should not be larger than 100MB."];
        return;
    }
    [self jumpSelectContactVC];
}
- (IBAction)clickAddEmailAction:(id)sender {
    [self jumpSendEmailVC];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    
    NSString *fileName = [_fileURL lastPathComponent];
    _lblFileName.text = fileName;
    NSString *fileExtension = [_fileURL pathExtension];
    UIImage *fileTypeImg = [UIImage imageNamed:[[fileExtension lowercaseString] stringByAppendingString:@"_a"]];
    if (fileTypeImg) {
        [_fileTypeImgView setImage:fileTypeImg];
    } else {
        [_fileTypeImgView setImage:[UIImage imageNamed:@"other_a"]];
    }
    @weakify_self
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *localFileData = [NSData dataWithContentsOfURL:weakSelf.fileURL];
        NSString *fileInfo = [SystemUtil transformedZSValue:localFileData.length];
        if (localFileData.length/(1024*1024) > 100) {
            weakSelf.isMax = YES;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.lblFileInfo.text = [NSString stringWithFormat:@"%@ %@",fileExtension,fileInfo];
        });
    });
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emailLoginSuccess:) name:EMIAL_LOGIN_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(googleSigninFaield) name:GOOGLE_EMAIL_SIGN_FAIELD_NOTI object:nil];
}

- (void) jumpSelectContactVC
{
    ChooseContactViewController *vc = [[ChooseContactViewController alloc] init];
    vc.docOPenTag = 7;
    vc.fileURL = _fileURL;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self dismissViewControllerAnimated:NO completion:nil];
    [[SystemUtil getCurrentVC] presentViewController:vc animated:YES completion:nil];
}

- (void) jumpSendEmailVC
{
    EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
    if (accountModel) {
        
        if (!AppD.isGoogleSign && accountModel.userId.length > 0) {
            [self.view showHudInView:self.view hint:@""];
            NSArray *currentScopes = @[@"https://mail.google.com/"];
            [GIDSignIn sharedInstance].scopes = currentScopes;
            [[GIDSignIn sharedInstance] signIn];
        } else {
            [self jumpSendEmail];
        }
        
    } else {
        PNEmailTypeSelectView *vc = [[PNEmailTypeSelectView alloc] init];
        @weakify_self
        [vc setClickRowBlock:^(PNBaseViewController * _Nonnull vc, NSArray * _Nonnull arr) {
            [vc dismissViewControllerAnimated:NO completion:nil];
            if ([arr[1] intValue] == 255) {
                PNEmailConfigViewController *vc = [[PNEmailConfigViewController alloc] initWithIsEdit:NO];
                [weakSelf presentModalVC:vc animated:YES];
            } else if ([arr[1] intValue] == 4) { // gmail
                [weakSelf.view showHudInView:weakSelf.view hint:@""];
                [[GIDSignIn sharedInstance] signOut];
                AppD.isGoogleSign = NO;
                NSArray *currentScopes = @[@"https://mail.google.com/"];
                [GIDSignIn sharedInstance].scopes = currentScopes;
                [[GIDSignIn sharedInstance] signIn];
                
            } else {
                PNEmailLoginViewController *loginVC  = [[PNEmailLoginViewController alloc] initWithEmailType:[arr[1] intValue] optionType:LoginEmail];
                [weakSelf presentModalVC:loginVC animated:YES];
            }
        }];
        
        [self presentModalVC:vc animated:YES];
    }
    
}

- (void) jumpSendEmail
{
    PNEmailSendViewController *vc = [[PNEmailSendViewController alloc] initWithEmailListInfo:nil sendType:NewEmail];
    vc.fileURL = _fileURL;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self dismissViewControllerAnimated:NO completion:nil];
    [[SystemUtil getCurrentVC] presentViewController:vc animated:YES completion:nil];
}

#pragma email 登陆成功回调
- (void) emailLoginSuccess:(NSNotification *) noti
{
    [self.view hideHud];
    [self performSelector:@selector(jumpSendEmail) withObject:self afterDelay:0.7];
}
- (void) googleSigninFaield
{
    [self.view hideHud];
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
