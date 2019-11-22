//
//  CircleUserCodeView.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/15.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "CircleUserCodeView.h"
#import "UserConfig.h"
#import "RouterModel.h"
#import "PNDefaultHeaderView.h"
#import "HMScanner.h"
#import "NSString+Base64.h"

#import "AESCipher.h"
#import "UIView+Visuals.h"
#import "UIImage+RoundedCorner.h"
#import "RouterUserModel.h"
#import "PNDefaultHeaderView.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"
#import "UIView+Screenshot.h"


@implementation CircleUserCodeView

+ (instancetype) loadCircleUserCodeView
{
    CircleUserCodeView *view = [[[NSBundle mainBundle] loadNibNamed:@"CircleUserCodeView" owner:self options:nil] lastObject];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    RouterModel *routerM = [RouterModel getConnectRouter];
    UserConfig *userM = [UserConfig getShareObject];
    
    _userCodeBackView.layer.cornerRadius = 5.0f;
    _userCodeBackView.layer.masksToBounds = YES;
    
    _userHeadImgView.layer.cornerRadius = _userHeadImgView.width/2.0;
    _userHeadImgView.layer.masksToBounds = YES;
    
    _lblRouterName.text = routerM.name?:@"";
    _lblUserName.text = [NSString stringWithFormat:@"Circle Owner:  %@", userM.adminName?:@""];
    
    NSString *userKey = [UserConfig getShareObject].adminKey;
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:routerM.name]];
    [_userHeadImgView setImage:defaultImg];
    
    
     NSString *userValue = [NSString stringWithFormat:@"%@,%@,%@",userM.userId,[userM.userName base64EncodedString],[EntryModel getShareObject].signPublicKey?:@""];
    NSString *aesCode = [NSString stringWithFormat:@"%@%@%@",@"010001",routerM.toxid?:@"",routerM.userSn?:@""];
    aesCode = aesEncryptString(aesCode, AES_KEY);
    aesCode = [NSString stringWithFormat:@"type_4,%@,%@",userValue,aesCode];
    
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
        weakSelf.userCodeImgView.image = image;
    }];
}

- (UIImage *) getCircleImage
{
    UIImage *codeImg = [_userCodeBackView getImageFromView];
    return codeImg;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
