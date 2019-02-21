//
//  AccountCodeViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/2/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "AccountCodeViewController.h"
#import "UserModel.h"
#import "HMScanner.h"
#import "NSString+Base64.h"
#import "EntryModel.h"

@interface AccountCodeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *codeImgView;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UILabel *lblName;

@end

@implementation AccountCodeViewController
- (IBAction)saveAction:(id)sender {
    [self loadImageFinished: self.codeImgView.image];
}
- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)shareAction:(id)sender {
     [self shareAction];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _saveBtn.layer.cornerRadius = RADIUS;
    _saveBtn.layer.masksToBounds = YES;
    
    _lblName.text = [UserModel getUserModel].username;
    NSString *coderValue = [NSString stringWithFormat:@"type_3,%@,%@,%@",[EntryModel getShareObject].signPrivateKey,[UserModel getUserModel].userSn,[[UserModel getUserModel].username base64EncodedString]];
    @weakify_self
    [HMScanner qrImageWithString:coderValue avatar:nil completion:^(UIImage *image) {
        weakSelf.codeImgView.image = image;
    }];
}

#pragma mark -系统分享
- (void) shareAction
{
    NSArray *images = @[_codeImgView.image];
    UIActivityViewController *activityController=[[UIActivityViewController alloc]initWithActivityItems:images applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

- (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [self.view showHint:@"Save Success"];
    } else {
        [self.view showHint:@"Save Failed"];
    }
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
