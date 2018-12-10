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

@interface PersonCodeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *nameBtn;
@property (weak, nonatomic) IBOutlet UIImageView *codeImgView;
@property (nonatomic , strong) ShareView *shareView;
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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _saveBtn.layer.cornerRadius = RADIUS;
    _saveBtn.layer.masksToBounds = YES;
    
    _shareBtn.layer.cornerRadius = RADIUS;
    _shareBtn.layer.masksToBounds = YES;
    
    _lblNavTitle.text = [UserModel getUserModel].username;
    _lblName.text = [UserModel getUserModel].username;
    [_nameBtn setTitle:[StringUtil getUserNameFirstWithName:[UserModel getUserModel].username] forState:UIControlStateNormal];
    @weakify_self
    [HMScanner qrImageWithString:[UserModel getUserModel].userId avatar:nil completion:^(UIImage *image) {
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
