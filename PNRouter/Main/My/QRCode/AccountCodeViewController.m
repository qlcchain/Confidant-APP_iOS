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
#import "UIView+Visuals.h"
#import "UIImage+RoundedCorner.h"
#import <YBImageBrowser/YBImageBrowser.h>
#import "PNDefaultHeaderView.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"
#import "UIView+Screenshot.h"

@interface AccountCodeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *codeImgView;
@property (weak, nonatomic) IBOutlet UIButton *nameBtn;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIView *codeBackView;
@property (weak, nonatomic) IBOutlet UIView *codeBackGroupView;

@end

@implementation AccountCodeViewController
//- (IBAction)saveAction:(id)sender {
//    [self loadImageFinished:[_codeBackView getImageFromView]];
//}
- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)shareAction:(id)sender {
     [self shareAction];
}

- (IBAction)headAction:(id)sender {
    // 本地图片（推荐使用 YBImage）
    YBImageBrowseCellData *data1 = [YBImageBrowseCellData new];
    UIImage *resultImg = _nameBtn.currentImage;
    data1.imageBlock = ^__kindof UIImage * _Nullable{
        return resultImg;
    };
    data1.sourceObject = _nameBtn.imageView;
    
    // 设置数据源数组并展示
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.dataSourceArray = @[data1];
    browser.currentIndex = 0;
    [browser show];
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    _saveBtn.layer.cornerRadius = RADIUS;
//    _saveBtn.layer.masksToBounds = YES;
    
    NSString *userName = [UserModel getUserModel].username;
    NSString *userKey = [EntryModel getShareObject].signPublicKey;
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:userName]];
    _nameBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    _nameBtn.layer.cornerRadius = _nameBtn.width/2.0;
    _nameBtn.layer.masksToBounds = YES;
    [_nameBtn setImage:defaultImg forState:UIControlStateNormal];
    
    _codeBackView.layer.cornerRadius = 8;
    _codeBackView.layer.masksToBounds = YES;
    
    _codeBackGroupView.layer.cornerRadius = 8;
    _codeBackGroupView.layer.masksToBounds = YES;
    
    _lblName.text = [UserModel getUserModel].username;
    NSString *coderValue = [NSString stringWithFormat:@"type_3,%@,%@,%@",[EntryModel getShareObject].signPrivateKey,[UserModel getUserModel].userSn,[[UserModel getUserModel].username base64EncodedString]];
    
    
    defaultImg = [defaultImg thumbnailImage:100 transparentBorder:0 cornerRadius:10 interpolationQuality:kCGInterpolationDefault];
    UIImageView *backImgView  = [[UIImageView alloc] initWithImage:defaultImg];
    backImgView.frame = CGRectMake(6, 6, 100, 100);
    UIView *imgBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 112, 112)];
    imgBackView.backgroundColor = [UIColor whiteColor];
    imgBackView.layer.cornerRadius = 10;
    imgBackView.layer.masksToBounds = YES;
    [imgBackView addSubview:backImgView];
    // uiview 生成图片
    defaultImg = [imgBackView convertViewToImage];
    
    @weakify_self
    [HMScanner qrImageWithString:coderValue avatar:defaultImg completion:^(UIImage *image) {
        weakSelf.codeImgView.image = image;
    }];
}

#pragma mark -系统分享
- (void) shareAction
{
    NSArray *images = @[[_codeBackGroupView getImageFromView]];
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
        [AppD.window showSuccessHudInView:AppD.window hint:@"Saved"];
    } else {
        [AppD.window showFaieldHudInView:AppD.window hint:@"Failed to Save"];
    }
}

@end
