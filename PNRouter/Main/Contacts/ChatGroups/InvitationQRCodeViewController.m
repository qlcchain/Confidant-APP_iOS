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
    _userHeadBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _userHeadBtn.layer.borderWidth = 2.0f;
    _userHeadBtn.layer.cornerRadius = _userHeadBtn.width/2.0;
    _userHeadBtn.layer.masksToBounds = YES;
    
    if (_userManageType == 1) {
        _lblName.text = [NSString stringWithFormat:@"【%@】",_routerUserModel.NickName];
        
        if (_routerUserModel.UserType !=2) {
            _lblDesc.text = @"Please note data sychronization is not supported\nwhen you are logged in to a temporary account.";
        }
        
        NSString *userKey = _routerUserModel.UserKey;
        UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:self.routerUserModel.NickName]];
        [_userHeadBtn setImage:defaultImg forState:UIControlStateNormal];
        
       // CGFloat cornt = defaultImg.size.height/7;
      // UIImage *borderImg = [self addBorderToImage:defaultImg];
         UIImage *avatarImg =  [UIImage imageNamed:@"icon_small_60"];
        @weakify_self
        [HMScanner qrImageWithString:_routerUserModel.Qrcode avatar:[avatarImg roundedCornerImage:10 borderSize:0] completion:^(UIImage *image) {
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
       // UIImage *borderImg = [self addBorderToImage:avatarImg];
        @weakify_self
        [HMScanner qrImageWithString:aesCode avatar:[avatarImg roundedCornerImage:10 borderSize:0] completion:^(UIImage *image) {
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
