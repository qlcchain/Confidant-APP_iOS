//
//  WalletQRViewController.m
//  Qlink
//
//  Created by 旷自辉 on 2018/4/4.
//  Copyright © 2018年 pan. All rights reserved.
//

#import "QRViewController.h"
#import "HMScannerMaskView.h"
#import "HMScannerBorder.h"
#import "HMScanner.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/UIButton+WebCache.h>
#import "UIImage+Resize.h"


@interface QRViewController ()<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *parentView;
@property (nonatomic ,strong) HMScanner *scanner;
@property (nonatomic ,strong) HMScannerBorder *scannerBorder;
@property (nonatomic ,strong) HMScannerMaskView *maskView;
@property (weak, nonatomic) IBOutlet UIButton *userHeadBtn;

@end

@implementation QRViewController

- (IBAction)clickBack:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}

- (IBAction)clickHead:(id)sender {
    [self clickAlbumButton];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [_scannerBorder startScannerAnimating];
    [_scanner startScan];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_scannerBorder startScannerAnimating];
    [self.scanner startScan];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_scannerBorder stopScannerAnimating];
    [_scanner stopScan];
}

- (instancetype) initWithCodeQRCompleteBlock:(void (^)(NSString *codeValue)) completion
{
    if (self = [super init]) {
        self.completeBlcok = completion;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _parentView.frame = CGRectMake(0, 110, SCREEN_WIDTH, SCREEN_HEIGHT-110);
    [self prepareScanerBorder];
    
}

#pragma mark - Config View
- (void)refreshContent {

}

/// 准备扫描框
- (void)prepareScanerBorder {
    
    CGFloat width = _parentView.frame.size.width - 90;
    
    _scannerBorder = [[HMScannerBorder alloc] initWithFrame:CGRectMake(45,100, width, width)];
   // _scannerBorder.center = self.view.center;
    _scannerBorder.tintColor = MAIN_PURPLE_COLOR;
    [_parentView addSubview:_scannerBorder];
    
    
    _maskView = [HMScannerMaskView maskViewWithFrame:_parentView.bounds cropRect:_scannerBorder.frame];
    [_parentView insertSubview:_maskView atIndex:0];
    
//    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [backBtn setBackgroundImage:[UIImage imageNamed:@"bg_gray_button"] forState:UIControlStateNormal];
//    [backBtn addTarget:self action:@selector(clickBack:) forControlEvents:UIControlEventTouchUpInside];
//    backBtn.frame = CGRectMake((SCREEN_WIDTH-140)/2,CGRectGetMaxY(_scannerBorder.frame)+20, 140, 44);
//    [backBtn setTitle:@"cancel" forState:UIControlStateNormal];
//    backBtn.titleLabel.font = [UIFont fontWithName:@"VAGRoundedBT-Regular" size:14];
//    [_parentView addSubview:backBtn];
}

#pragma mark - 选择图片
/// 点击相册按钮
- (void) clickAlbumButton {
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [AppD.window showHint:@"unable_photo"];
        return;
    }
    
   

    //调用系统相册的类
    UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
    //    更改titieview的字体颜色
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [pickerController.navigationBar setTitleTextAttributes:attrs];
    pickerController.navigationBar.translucent = NO;
    pickerController.navigationBar.barTintColor = MAIN_PURPLE_COLOR;
    //设置相册呈现的样式
    pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //UIImagePickerControllerSourceTypeSavedPhotosAlbum;//图片分组列表样式
    pickerController.delegate = self;
    //使用模态呈现相册
    [self.navigationController presentViewController:pickerController animated:YES completion:nil];
    
//    @weakify_self
//
//    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//        if (status == PHAuthorizationStatusAuthorized) {
//            //调用系统相册的类
//            UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
//            //    更改titieview的字体颜色
//            NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
//            attrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
//            [pickerController.navigationBar setTitleTextAttributes:attrs];
//            pickerController.navigationBar.translucent = NO;
//            pickerController.navigationBar.barTintColor = MAIN_PURPLE_COLOR;
//            //设置相册呈现的样式
//            pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //UIImagePickerControllerSourceTypeSavedPhotosAlbum;//图片分组列表样式
//            pickerController.delegate = weakSelf;
//            //使用模态呈现相册
//            [weakSelf.navigationController presentViewController:pickerController animated:YES completion:nil];
//        }else{
//            [AppD.window showHint:@"Denied or Restricted"];
//        }
//    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    //使用模态返回到软件界面
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *resultImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    if (resultImage) {
       // resultImage = [self resizeImage:resultImage];
        // 扫描图像
        @weakify_self
        [HMScanner scaneImage:resultImage completion:^(NSArray *values) {
            NSLog(@"values = %lu",(unsigned long)values.count);
            if (weakSelf.completeBlcok) {
                if (values.count > 0) {
                    [weakSelf leftNavBarItemPressedWithPop:NO];
                    weakSelf.completeBlcok(values.firstObject);
                } else {
                    [AppD.window showHint:@"no_code"];
                }
            } else {
                // 完成回调
                if (values.count > 0) {
                    [weakSelf.scanner startScan];
                    [weakSelf leftNavBarItemPressedWithPop:NO];
                } else {
                    [AppD.window showHint:@"no_code"];
                }
            }
            
        }];
    }
    
    
}

- (UIImage *)resizeImage:(UIImage *)image {
    
    if (image.size.width < kImageMaxSize.width && image.size.height < kImageMaxSize.height) {
        return image;
    }
    
    CGFloat xScale = kImageMaxSize.width / image.size.width;
    CGFloat yScale = kImageMaxSize.height / image.size.height;
    CGFloat scale = MIN(xScale, yScale);
    CGSize size = CGSizeMake(image.size.width * scale, image.size.height * scale);
    
    UIGraphicsBeginImageContext(size);
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return result;
}

#pragma mark - lazy
- (HMScanner *)scanner {
    if (!_scanner) {
        // 实例化扫描器
        @weakify_self
        _scanner = [HMScanner scanerWithView:_parentView scanFrame:_scannerBorder.frame completion:^(NSString *stringValue) {
            DDLogDebug(@"codeValue = %@",stringValue);
            if (weakSelf.completeBlcok) {
                [weakSelf leftNavBarItemPressedWithPop:NO];
                weakSelf.completeBlcok(stringValue);
            } else {
                // 完成回调
                [weakSelf.scanner startScan];
            }
            
        }];
    }
    return _scanner;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
