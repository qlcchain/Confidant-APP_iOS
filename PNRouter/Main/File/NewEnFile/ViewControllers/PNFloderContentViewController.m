//
//  PNFloderContentViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNFloderContentViewController.h"
#import "FingerprintVerificationUtil.h"
#import "UploadFileCell.h"
#import <YBImageBrowser/YBImageBrowser.h>
#import "TZImagePickerController.h"

@interface PNFloderContentViewController ()<UITableViewDelegate,UITableViewDataSource,YBImageBrowserDelegate,TZImagePickerControllerDelegate,UINavigationControllerDelegate,
UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTabView;

@end

@implementation PNFloderContentViewController
- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)clickAddAction:(id)sender {
    [self pushTZImagePickerControllerWithIsSelectImgage:YES];
}
- (IBAction)clickSelAction:(id)sender {
    
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    
    [FingerprintVerificationUtil checkFloderShow];
    
    _mainTabView.delegate = self;
    _mainTabView.dataSource = self;
    _mainTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_mainTabView registerNib:[UINib nibWithNibName:UploadFileCellResue bundle:nil] forCellReuseIdentifier:UploadFileCellResue];
}

#pragma mark -----------------tableview deleate ---------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    headView.backgroundColor = MAIN_GRAY_COLOR;
    UILabel *lblName  =[[UILabel alloc] initWithFrame:CGRectMake(20, 0, 150, 30)];
    lblName.textColor = [UIColor blackColor];
    lblName.font = [UIFont systemFontOfSize:12];
    [headView addSubview:lblName];
    if (section == 0) {
        lblName.text = @"UPLOADING";
    } else {
         lblName.text = @"UPLOADING";
    }
    return headView;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UploadFileCellHeight;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UploadFileCell *myCell = [tableView dequeueReusableCellWithIdentifier:UploadFileCellResue];
    return myCell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark ---选择相册
/**
 跳转到选择图片vc
 
 @param isImage 是
 */
- (void)pushTZImagePickerControllerWithIsSelectImgage:(BOOL) isImage {
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:3 delegate:self pushPhotoPickerVc:YES];
    // imagePickerVc.navigationBar.translucent = NO;
    
#pragma mark - 五类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = NO;
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    imagePickerVc.allowTakeVideo = NO;   // 在内部显示拍视频按
    imagePickerVc.videoMaximumDuration = 15; // 视频最大拍摄时间
    [imagePickerVc setUiImagePickerControllerSettingBlock:^(UIImagePickerController *imagePickerController) {
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }];
    
    
    imagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    imagePickerVc.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [imagePickerVc setPhotoPickerPageUIConfigBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
        [doneButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }];
    
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingMultipleVideo = YES; // 是否可以多选视频
    
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    
    imagePickerVc.maxImagesCount = 9;
    imagePickerVc.alwaysEnableDoneBtn = YES;
    
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = NO;
    imagePickerVc.needCircleCrop = NO;
    
    imagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    // 设置是否显示图片序号
    imagePickerVc.showSelectedIndex = NO;
    
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    @weakify_self
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (assets && assets.count > 0) {
            [assets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                 PHAsset *asset = obj;
                if (asset.mediaType == 1) { // 图片
                   UIImage *img = photos[idx];
                } else if (asset.mediaType == 2) { // 视频
                    [weakSelf getPHAssetVedioWithOverImg:photos[idx] phAsset:asset];
                }
            }];
        }
        /**
         * 该方法是异步执行的，不会阻塞当前线程，而且执行完后会来到
         * completionHandler 的 block 中。
         */
        //            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //                [PHAssetChangeRequest deleteAssets:assets];
        //            } completionHandler:^(BOOL success, NSError * _Nullable error) {
        //                NSLog(@"----success----");
        //            }];
        
       
    }];
   
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

/**
 通过资源获取图片的数据
 @param mAsset 资源文件
 */
- (void)fetchImageWithAsset:(PHAsset*)mAsset {
    [[PHImageManager defaultManager] requestImageDataForAsset:mAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        // 直接得到最终的 NSData 数据
        
    }];
}


/**
 得到选择的视频
 
 @param coverImage 视频封面图
 @param phAsset phasset
 */
- (void) getPHAssetVedioWithOverImg:(UIImage *) coverImage phAsset:(PHAsset *)phAsset
{
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    @weakify_self
    [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
        if ([avAsset isKindOfClass:[AVURLAsset class]]) {
            AVURLAsset* urlAsset = (AVURLAsset*)avAsset;
            NSNumber *size;
            [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
            CGFloat sizeMB = [size floatValue]/(1024.0*1024.0);
            if (sizeMB <= 100) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf extractedVideWithAsset:urlAsset evImage:coverImage];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [AppD.window showHint:@"Video cannot be larger than 100MB"];
                });
            }
        }}];
}

/**
 导出视频并发送
 @param asset asset
 @param evImage 封面图
 */
- (void)extractedVideWithAsset:(AVURLAsset *)asset evImage:(UIImage *) evImage
{
    NSData *attData = [NSData dataWithContentsOfURL:asset.URL];
    NSString *attName = [asset.URL lastPathComponent];
   
}
@end
