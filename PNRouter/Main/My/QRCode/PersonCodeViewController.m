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
   
    [self loadImageFinished: self.codeImgView.image];
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
    if (!self.userId || [self.userId isEmptyString]) {
        self.userName =  [UserModel getUserModel].username;
        self.userId = [UserModel getUserModel].userId;
        self.signPublicKey = [EntryModel getShareObject].signPublicKey;
    }
    _lblNavTitle.text = self.userName;
    _lblName.text = self.userName;
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithName:[StringUtil getUserNameFirstWithName:self.userName]];
    [_nameBtn setImage:defaultImg forState:UIControlStateNormal];
//    [_nameBtn setTitle:[StringUtil getUserNameFirstWithName:self.userName] forState:UIControlStateNormal];
    NSString *coderValue = [NSString stringWithFormat:@"type_0,%@,%@,%@",self.userId,[self.userName base64EncodedString],self.signPublicKey?:@""];
    @weakify_self
    [HMScanner qrImageWithString:coderValue avatar:nil completion:^(UIImage *image) {
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
    NSArray *images = @[_codeImgView.image];
    UIActivityViewController *activityController=[[UIActivityViewController alloc]initWithActivityItems:images applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
