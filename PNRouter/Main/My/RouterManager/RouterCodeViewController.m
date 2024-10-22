//
//  QRCodeViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "RouterCodeViewController.h"
#import "HMScanner.h"
#import "ShareView.h"
#import "UserModel.h"
#import "RouterModel.h"
#import "AESCipher.h"
#import "UIView+Visuals.h"
#import "UIImage+RoundedCorner.h"

@interface RouterCodeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblNavTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *codeImgView;
@property (nonatomic , strong) ShareView *shareView;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIView *codeBackView;

@end

@implementation RouterCodeViewController

- (IBAction)backBtnAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}

- (IBAction)rightShareAction:(id)sender {
    // [self.shareView show];
    [self shareCode];
}

- (IBAction)savePhoneAction:(id)sender {
    [self loadImageFinished:[_codeBackView getImageFromView]];
}

- (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [AppD.window showSuccessHudInView:AppD.window hint:@"Saved"];
    } else {
        [AppD.window showFaieldHudInView:AppD.window hint:@"Failed to Save"];
    }
}

- (IBAction)shareAction:(id)sender {
    // [self.shareView show];
    [self shareCode];
}

#pragma mark layz
- (ShareView *)shareView
{
    if (!_shareView) {
        _shareView = [ShareView loadShareView];
        @weakify_self
        [_shareView setClickItemBlock:^(NSInteger item) {
            [weakSelf clickCollectionWithItem:item];
        }];
    }
    return _shareView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _saveBtn.layer.cornerRadius = RADIUS;
    _saveBtn.layer.masksToBounds = YES;
    
    _shareBtn.layer.cornerRadius = RADIUS;
    _shareBtn.layer.masksToBounds = YES;
    
    _lblNavTitle.text = @"QR code Business Card";
    _lblName.text = _routerM.name;
    
    NSString *aesCode = [NSString stringWithFormat:@"%@%@%@",@"010001",_routerM.toxid?:@"",_routerM.userSn?:@""];
   aesCode = aesEncryptString(aesCode, AES_KEY);
    aesCode = [NSString stringWithFormat:@"type_1,%@",aesCode];
    
   UIImage *avatarImg =  [UIImage imageNamed:@"img_card_router"];
    @weakify_self
    [HMScanner qrImageWithString:aesCode avatar:avatarImg completion:^(UIImage *image) {
        weakSelf.codeImgView.image = image;
    }];
}

#pragma mark -自定义方法
- (void) clickCollectionWithItem:(NSInteger) item
{
    switch (item) {
        case 0:
            
            break;
        case 1:
            
            break;
        case 2:
            
            break;
        case 3:
            
            break;
        case 4:
            
            break;
            
        default:
            break;
    }
}

- (void) shareCode
{
    NSArray *images = @[[_codeBackView getImageFromView]];
    UIActivityViewController *activityController=[[UIActivityViewController alloc]initWithActivityItems:images applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
