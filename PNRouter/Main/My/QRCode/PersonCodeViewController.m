//
//  QRCodeViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "PersonCodeViewController.h"
#import "HMScanner.h"
#import "ShareView.h"
#import "UserModel.h"
#import "NSString+Base64.h"
#import "EntryModel.h"
#import "PNDefaultHeaderView.h"
#import <YBImageBrowser/YBImageBrowser.h>
#import "UIView+Visuals.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+Resize.h"
#import "UIView+Screenshot.h"

@interface PersonCodeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *nameBtn;
@property (weak, nonatomic) IBOutlet UIImageView *codeImgView;
@property (nonatomic , strong) ShareView *shareView;
@property (nonatomic , copy) NSString *userId;
@property (nonatomic , copy) NSString *signPublicKey;
@property (nonatomic , copy) NSString *userName;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;
@property (weak, nonatomic) IBOutlet UIView *codeBackView;

@end

@implementation PersonCodeViewController
- (IBAction)backBtnAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)rightShareAction:(id)sender {
    // [self.shareView show];
    [self shareAction];
}
- (IBAction)savePhoneAction:(id)sender {
   
    [self loadImageFinished:[_codeBackView getImageFromView]];
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

- (IBAction)shareAction:(id)sender {
    // [self.shareView show];
    [self shareAction];
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
- (instancetype) initWithUserId:(NSString *) userId userNaem:(NSString *)userNaem signPK:(NSString *)signPK
{
    if (self = [super init]) {
        self.userId = userId;
        self.userName = userNaem;
        self.signPublicKey = signPK;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _saveBtn.layer.cornerRadius = RADIUS;
    _saveBtn.layer.masksToBounds = YES;
    
    _shareBtn.layer.cornerRadius = RADIUS;
    _shareBtn.layer.masksToBounds = YES;
    
    _codeBackView.layer.cornerRadius = 5.0f;
    _codeBackView.layer.masksToBounds = YES;
    
    
    if (!self.userId || [self.userId isEmptyString]) {
        self.userName =  [UserModel getUserModel].username;
        self.userId = [UserModel getUserModel].userId;
        self.signPublicKey = [EntryModel getShareObject].signPublicKey;
    }
   // _lblNavTitle.text = self.userName;
    _lblName.text = self.userName;
//    NSString *userKey = [EntryModel getShareObject].signPublicKey;
    NSString *userKey = self.signPublicKey;
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:self.userName]];
    _nameBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    _nameBtn.layer.cornerRadius = _nameBtn.width/2.0;
    _nameBtn.layer.masksToBounds = YES;
    [_nameBtn setImage:defaultImg forState:UIControlStateNormal];
//    [_nameBtn setTitle:[StringUtil getUserNameFirstWithName:self.userName] forState:UIControlStateNormal];
    NSString *coderValue = [NSString stringWithFormat:@"type_0,%@,%@,%@",self.userId,[self.userName base64EncodedString],self.signPublicKey?:@""];
    
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
    
   // CGFloat cornt = defaultImg.size.height/7;
    // [defaultImg roundedCornerImage:cornt borderSize:0]
    @weakify_self
    [HMScanner qrImageWithString:coderValue avatar:defaultImg completion:^(UIImage *image) {
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

#pragma mark -系统分享
- (void) shareAction
{
    ;
    NSArray *images = @[[_codeBackView getImageFromView]];
    UIActivityViewController *activityController=[[UIActivityViewController alloc]initWithActivityItems:images applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
