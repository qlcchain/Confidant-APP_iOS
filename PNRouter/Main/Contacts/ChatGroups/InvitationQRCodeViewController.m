//
//  InvitationQRCodeViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/13.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "InvitationQRCodeViewController.h"
#import "HMScanner.h"
#import "ShareView.h"
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

@interface InvitationQRCodeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *codeImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet UIButton *userHeadBtn;
@property (weak, nonatomic) IBOutlet UIView *backView;

@end

@implementation InvitationQRCodeViewController
#pragma mark - action

- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)shareAction:(id)sender {
     [self shareCode];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _backView.layer.cornerRadius = 8.0f;
    _backView.layer.masksToBounds = YES;
   
    _userHeadBtn.layer.cornerRadius = _userHeadBtn.width/2.0;
    _userHeadBtn.layer.masksToBounds = YES;
    _userHeadBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _userHeadBtn.layer.borderWidth = 2.0f;
    _userHeadBtn.backgroundColor = MAIN_PURPLE_COLOR;
    
    if (_userManageType == 1) {
        _lblName.text = [NSString stringWithFormat:@"【%@】",_routerUserModel.NickName];
        
        if (_routerUserModel.UserType !=2) {
            _lblDesc.text = @"Please note data sychronization is not supported\nwhen you are logged in to a temporary account.";
        }
        
        NSString *userKey = _routerUserModel.UserKey;
        UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:self.routerUserModel.NickName]];
        [_userHeadBtn setImage:defaultImg forState:UIControlStateNormal];
        
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
      
        // UIImage *avatarImg =  [UIImage imageNamed:@"icon_small_60"];
        // [avatarImg roundedCornerImage:10 borderSize:0]
        @weakify_self
        [HMScanner qrImageWithString:_routerUserModel.Qrcode avatar:avatarImg completion:^(UIImage *image) {
            weakSelf.codeImgView.image = image;
        }];
    } else {
        _lblName.text = [NSString stringWithFormat:@"【%@】",_routerM.name];
        NSString *userType = [_routerM.userSn substringWithRange:NSMakeRange(0, 2)];
        if ([userType isEqualToString:@"03"]) { // 临时
            _lblDesc.text = @"Please note data sychronization is not supported\nwhen you are logged in to a temporary account.";
        }
        
        NSString *userKey = _routerUserModel.UserKey;
        UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:_routerM.name]];
        [_userHeadBtn setImage:defaultImg forState:UIControlStateNormal];
        
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
    }
    
}

- (UIImage *)addBorderToImage:(UIImage *)image {
    CGImageRef bgimage = [image CGImage];
    float width = CGImageGetWidth(bgimage);
    float height = CGImageGetHeight(bgimage);
    //创建临时纹理数据缓冲区
    void *data = malloc(width * height * 4);
    //将图片绘制到缓冲区中
    CGContextRef ctx = CGBitmapContextCreate(data,
                                             width,
                                             height,
                                             8,
                                             width * 4,
                                             CGImageGetColorSpace(image.CGImage),
                                             kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(ctx, CGRectMake(0, 0, (CGFloat)width, (CGFloat)height), bgimage);
    CGFloat lineWidth = 4.0; //线宽
    CGContextSetRGBStrokeColor(ctx,255,255,255,1.0);//画笔线的颜色
    CGContextSetLineWidth(ctx, lineWidth);//线的宽度
    // x,y为圆点坐标，radius半径，startAngle为开始的弧度，endAngle为 结束的弧度，clockwise 0为顺时针，1为逆时针。
    CGContextAddArc(ctx, width/2, width/2, width/2-lineWidth/2, 0, 2*3.14159265358979323846, 0); //添加一个圆
    CGContextDrawPath(ctx, kCGPathStroke); //绘制路径
    //绘制
    CGContextStrokePath(ctx);
    //将其绘制到新的图片上
    CGImageRef cgimage = CGBitmapContextCreateImage(ctx);
    UIImage *newImage = [UIImage imageWithCGImage:cgimage];
    CFRelease(cgimage);
    CGContextRelease(ctx);
    return newImage;
}



- (void) shareCode
{
    NSArray *images = @[[_backView getImageFromView]];
    UIActivityViewController *activityController=[[UIActivityViewController alloc]initWithActivityItems:images applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

@end
