//
//  RouterUserCodeViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/26.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "RouterUserCodeViewController.h"
#import "StringUtil.h"
#import <Social/Social.h>
#import "HMScanner.h"
#import "PNDefaultHeaderView.h"
#import "EntryModel.h"
#import <YBImageBrowser/YBImageBrowser.h>
#import "UIView+Visuals.h"

@interface RouterUserCodeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *UserHeadBtn;
@property (weak, nonatomic) IBOutlet UIImageView *codeImage;
@property (weak, nonatomic) IBOutlet UIButton *delUserBtn;
@property (weak, nonatomic) IBOutlet UIButton *delRightBtn;
@property (weak, nonatomic) IBOutlet UIButton *invitaionBtn;
@property (weak, nonatomic) IBOutlet UIView *codeBackView;

@end

@implementation RouterUserCodeViewController
- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)delUserAction:(id)sender {
}
- (IBAction)invitationAction:(id)sender {
    
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:self.routerUserModel.IdentifyCode message:@"Invitation code security designated user." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertVC addAction:alertCancel];
    [self presentViewController:alertVC animated:YES completion:nil];
}
- (IBAction)shareAction:(id)sender {
    [self shareCode];
}

- (IBAction)headAction:(id)sender {
    // 本地图片（推荐使用 YBImage）
    YBImageBrowseCellData *data1 = [YBImageBrowseCellData new];
    UIImage *resultImg = _UserHeadBtn.currentImage;
    data1.imageBlock = ^__kindof UIImage * _Nullable{
        return resultImg;
    };
    data1.sourceObject = _UserHeadBtn.imageView;
    
    // 设置数据源数组并展示
    YBImageBrowser *browser = [YBImageBrowser new];
    browser.dataSourceArray = @[data1];
    browser.currentIndex = 0;
    [browser show];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    _delUserBtn.layer.cornerRadius = 5.0f;
    _invitaionBtn.layer.cornerRadius = 5.0f;
    _delRightBtn.layer.cornerRadius = 5.0f;
    _lblUserName.text = self.routerUserModel.NickName;
    
//    NSString *userKey = [EntryModel getShareObject].signPublicKey;
    NSString *userKey = _routerUserModel.UserKey;
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:self.routerUserModel.NickName]];
    _UserHeadBtn.layer.cornerRadius = _UserHeadBtn.width/2.0;
    _UserHeadBtn.layer.masksToBounds = YES;
    [_UserHeadBtn setImage:defaultImg forState:UIControlStateNormal];
//    [_UserHeadBtn setTitle:[StringUtil getUserNameFirstWithName:self.routerUserModel.NickName] forState:UIControlStateNormal];
    if (self.routerUserModel.UserType == 2) {
        _lblNavTitle.text = @"User Details";
        _delUserBtn.hidden = YES;
    } else {
        _lblNavTitle.text = @"Temporary User Details";
        _delUserBtn.hidden = NO;
    }
    if (self.routerUserModel.Active == 1) {
        _lblDesc.hidden = YES;
    } else {
        _lblDesc.hidden = NO;
    }
    
    @weakify_self
    [HMScanner qrImageWithString:self.routerUserModel.Qrcode avatar:nil completion:^(UIImage *image) {
        weakSelf.codeImage.image = image;
    }];
}

- (void)shareCode {
    NSArray *images = @[[_codeBackView getImageFromView]];
    UIActivityViewController *activityController=[[UIActivityViewController alloc]initWithActivityItems:images applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

@end
