//
//  CircleLoginCodeViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/4/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "CircleLoginCodeViewController.h"
#import "UserModel.h"
#import "RouterModel.h"
#import "AESCipher.h"
#import "UIView+Visuals.h"
#import "UIImage+RoundedCorner.h"
#import "RouterUserModel.h"
#import "PNDefaultHeaderView.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"
#import "UIView+Screenshot.h"
#import "UserConfig.h"
#import "HMScanner.h"
#import "EntryModel.h"
#import "NSString+Base64.h"

@interface CircleLoginCodeViewController ()
{
    NSInteger saveCount;
}
@property (weak, nonatomic) IBOutlet UIView *codeBackView;
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblRouterName;
@property (weak, nonatomic) IBOutlet UILabel *lblAdminName;
@property (weak, nonatomic) IBOutlet UIImageView *codeImgView;

@property (weak, nonatomic) IBOutlet UILabel *lblUserName;
@property (weak, nonatomic) IBOutlet UIImageView *userHeadImgView;
@property (weak, nonatomic) IBOutlet UIImageView *userCodeImgView;
@property (weak, nonatomic) IBOutlet UIView *userCodeBackView;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@end

@implementation CircleLoginCodeViewController
- (IBAction)rightAction:(id)sender {
     [self shareCode];
}
- (IBAction)leftAction:(id)sender {
     [self leftNavBarItemPressedWithPop:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    _codeBackView.layer.cornerRadius = 5.0f;
    _codeBackView.layer.masksToBounds = YES;
    
    _headImgView.layer.cornerRadius = _headImgView.width/2.0;
    _headImgView.layer.masksToBounds = YES;
    
    _userCodeBackView.layer.cornerRadius = 5.0f;
    _userCodeBackView.layer.masksToBounds = YES;
    
    _userHeadImgView.layer.cornerRadius = _headImgView.width/2.0;
    _userHeadImgView.layer.masksToBounds = YES;
    
    _saveBtn.layer.cornerRadius = 4.0f;
    _saveBtn.layer.masksToBounds = YES;
    
    

    _lblRouterName.text = _routerM.name?:@"";
    _lblAdminName.text = [NSString stringWithFormat:@"Circle Owner:  %@", [UserConfig getShareObject].adminName];
    
    NSString *userKey = [UserConfig getShareObject].adminKey;
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:_routerM.name]];
    [_headImgView setImage:defaultImg];
    
    NSString *aesCode = [NSString stringWithFormat:@"%@%@%@",@"010001",_routerM.toxid?:@"",_routerM.userSn?:@""];
    aesCode = aesEncryptString(aesCode, AES_KEY);
    aesCode = [NSString stringWithFormat:@"type_1,%@",aesCode];
    
    UIImage *avatarImg =  [UIImage imageNamed:@"icon_small_60"];
    avatarImg = [avatarImg thumbnailImage:100 transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationDefault];
    UIImageView *backImgView  = [[UIImageView alloc] initWithImage:avatarImg];
    backImgView.frame = CGRectMake(6, 6, 100, 100);
    UIView *imgBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 112, 112)];
    imgBackView.backgroundColor = [UIColor whiteColor];
    imgBackView.layer.cornerRadius = 10;
    imgBackView.layer.masksToBounds = YES;
    [imgBackView addSubview:backImgView];
    // uiview 生成图片
    avatarImg = [imgBackView convertViewToImage];
    //UIImage *avatarImg =  [UIImage imageNamed:@"icon_small_60"];
    //[avatarImg roundedCornerImage:10 borderSize:0]
    @weakify_self
    [HMScanner qrImageWithString:aesCode avatar:avatarImg completion:^(UIImage *image) {
        weakSelf.codeImgView.image = image;
    }];
    
    NSString *userName = [UserModel getUserModel].username;
    userKey = [EntryModel getShareObject].signPublicKey;
    defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:userName]];
    [_userHeadImgView setImage:defaultImg];
    
    _lblUserName.text = [UserModel getUserModel].username;
    NSString *coderValue = [NSString stringWithFormat:@"type_3,%@,%@,%@",[EntryModel getShareObject].signPrivateKey,[UserModel getUserModel].userSn,[[UserModel getUserModel].username base64EncodedString]];
    
    
    defaultImg = [defaultImg thumbnailImage:100 transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationDefault];
    UIImageView *userImgView  = [[UIImageView alloc] initWithImage:defaultImg];
    userImgView.frame = CGRectMake(6, 6, 100, 100);
    UIView *userImgBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 112, 112)];
    userImgBackView.backgroundColor = [UIColor whiteColor];
    userImgBackView.layer.cornerRadius = 10;
    userImgBackView.layer.masksToBounds = YES;
    [userImgBackView addSubview:userImgView];
    // uiview 生成图片
    defaultImg = [userImgBackView convertViewToImage];
    
    [HMScanner qrImageWithString:coderValue avatar:defaultImg completion:^(UIImage *image) {
        weakSelf.userCodeImgView.image = image;
    }];
}


- (void) shareCode
{
    
    UIImage *userCodeImg = [_userCodeBackView getImageFromView];
    UIImage *codeImg = [_codeBackView getImageFromView];
    
    [self loadImageFinished:userCodeImg];
    [self loadImageFinished:codeImg];
    
//    NSArray *images = @[[_codeBackView getImageFromView]];
//    UIActivityViewController *activityController=[[UIActivityViewController alloc]initWithActivityItems:images applicationActivities:nil];
//    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

- (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    saveCount ++;
    if (saveCount == 1) {
        if (!error) {
            [AppD.window showSuccessHudInView:AppD.window hint:@"Saved"];
        } else {
            [AppD.window showFaieldHudInView:AppD.window hint:@"Failed to Save"];
        }
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
