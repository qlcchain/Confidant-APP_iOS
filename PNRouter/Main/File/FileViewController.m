//
//  FileViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "FileViewController.h"
#import "FileCell.h"
#import "TaskListViewController.h"
#import "UploadAlertView.h"
#import "MyFilesViewController.h"
#import "SendRequestUtil.h"
#import "UserConfig.h"
#import "PNNavViewController.h"
#import "PNDocumentPickerViewController.h"
#import "UploadFilesViewController.h"
#import "YWFilePreviewView.h"
#import "FilePreviewViewController.h"
#import "ChooseShareContactViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TZImagePickerController.h"
#import "NSDate+Category.h"
#import "SystemUtil.h"

@interface FileViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource/*, SWTableViewCellDelegate*/, UIDocumentPickerDelegate, UIImagePickerControllerDelegate,TZImagePickerControllerDelegate>

//@property (weak, nonatomic) IBOutlet UILabel *fontLab;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;

@property (nonatomic, strong) UploadAlertView *uploadAlertV;

@end

@implementation FileViewController

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullFileListCompleteNoti:) name:PullFileList_Complete_Noti object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObserve];
    
    self.view.backgroundColor = MAIN_PURPLE_COLOR;
    
    _searchBackView.layer.cornerRadius = 3.0f;
    _searchBackView.layer.masksToBounds = YES;
    _searchTF.delegate = self;
    
    [_mainTable registerNib:[UINib nibWithNibName:FileCellReuse bundle:nil] forCellReuseIdentifier:FileCellReuse];
    
    [self sendPullFileList];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - Operation

- (void)showUploadAlertView {
    _uploadAlertV = [UploadAlertView getInstance];
    @weakify_self
    [_uploadAlertV setPhotoB:^{
        [weakSelf showPhotoLib];
//        [weakSelf jumpToDocumentPicker:DocumentPickerTypePhoto];
    }];
    [_uploadAlertV setVideoB:^{
        [weakSelf showVideoLib];
//        [weakSelf jumpToDocumentPicker:DocumentPickerTypeVideo];
    }];
    [_uploadAlertV setDocumentB:^{
        [weakSelf jumpToDocumentPicker:DocumentPickerTypeDocument];
    }];
    [_uploadAlertV setOtherB:^{
        [weakSelf jumpToDocumentPicker:DocumentPickerTypeOther];
    }];
    [_uploadAlertV show];
}

- (void)showPhotoLib {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    @weakify_self
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
                // 无相机权限 做一个友好的提示
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view endEditing:YES];
                    [AppD.window showHint:@"请在iPhone的""设置-隐私-相册""中允许访问相册"];
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view endEditing:YES];
                    [weakSelf pushTZImagePickerControllerWithIsSelectImgage:YES];
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view endEditing:YES];
                [AppD.window showHint:@"Denied or Restricted"];
            });
        }
    }];
}

- (void)showVideoLib {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    @weakify_self
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view endEditing:YES];
                    [AppD.window showHint:@"请在iPhone的""设置-隐私-相册""中允许访问相册"];
                });
                // 无相机权限 做一个友好的提示
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf pushTZImagePickerControllerWithIsSelectImgage:NO];
                });
                
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view endEditing:YES];
                [AppD.window showHint:@"Denied or Restricted"];
            });
            
        }
    }];
}

- (void)pushTZImagePickerControllerWithIsSelectImgage:(BOOL) isImage {
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:3 delegate:self pushPhotoPickerVc:YES];
    // imagePickerVc.navigationBar.translucent = NO;
    
#pragma mark - 五类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = NO;
    imagePickerVc.allowTakePicture = isImage; // 在内部显示拍照按钮
    imagePickerVc.allowTakeVideo = !isImage;   // 在内部显示拍视频按
    imagePickerVc.videoMaximumDuration = 15; // 视频最大拍摄时间
    [imagePickerVc setUiImagePickerControllerSettingBlock:^(UIImagePickerController *imagePickerController) {
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }];
    
    // imagePickerVc.photoWidth = 1000;
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    imagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    imagePickerVc.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [imagePickerVc setPhotoPickerPageUIConfigBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
        [doneButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }];
    /*
     [imagePickerVc setAssetCellDidSetModelBlock:^(TZAssetCell *cell, UIImageView *imageView, UIImageView *selectImageView, UILabel *indexLabel, UIView *bottomView, UILabel *timeLength, UIImageView *videoImgView) {
     cell.contentView.clipsToBounds = YES;
     cell.contentView.layer.cornerRadius = cell.contentView.tz_width * 0.5;
     }];
     */
    
    // 3. Set allow picking video & photo & originalPhoto or not
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = !isImage;
    imagePickerVc.allowPickingImage = isImage;
    imagePickerVc.allowPickingOriginalPhoto = isImage;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingMultipleVideo = NO; // 是否可以多选视频
    
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    
    // imagePickerVc.minImagesCount = 3;
    imagePickerVc.alwaysEnableDoneBtn = YES;
    
    // imagePickerVc.minPhotoWidthSelectable = 3000;
    // imagePickerVc.minPhotoHeightSelectable = 2000;
    
    /// 5. Single selection mode, valid when maxImagesCount = 1
    /// 5. 单选模式,maxImagesCount为1时才生效
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = NO;
    imagePickerVc.needCircleCrop = NO;
    // 设置竖屏下的裁剪尺寸
    //    NSInteger left = 30;
    //    NSInteger widthHeight = self.view.tz_width - 2 * left;
    //    NSInteger top = (self.view.tz_height - widthHeight) / 2;
    //    imagePickerVc.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
    // 设置横屏下的裁剪尺寸
    // imagePickerVc.cropRectLandscape = CGRectMake((self.view.tz_height - widthHeight) / 2, left, widthHeight, widthHeight);
    /*
     [imagePickerVc setCropViewSettingBlock:^(UIView *cropView) {
     cropView.layer.borderColor = [UIColor redColor].CGColor;
     cropView.layer.borderWidth = 2.0;
     }];*/
    
    //imagePickerVc.allowPreview = NO;
    // 自定义导航栏上的返回按钮
    /*
     [imagePickerVc setNavLeftBarButtonSettingBlock:^(UIButton *leftButton){
     [leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
     [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 20)];
     }];
     imagePickerVc.delegate = self;
     */
    
    // Deprecated, Use statusBarStyle
    // imagePickerVc.isStatusBarDefault = NO;
    imagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    // 设置是否显示图片序号
    imagePickerVc.showSelectedIndex = NO;
    // 自定义gif播放方案
    //    [[TZImagePickerConfig sharedInstance] setGifImagePlayBlock:^(TZPhotoPreviewView *view, UIImageView *imageView, NSData *gifData, NSDictionary *info) {
    //        FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:gifData];
    //        FLAnimatedImageView *animatedImageView;
    //        for (UIView *subview in imageView.subviews) {
    //            if ([subview isKindOfClass:[FLAnimatedImageView class]]) {
    //                animatedImageView = (FLAnimatedImageView *)subview;
    //                animatedImageView.frame = imageView.bounds;
    //                animatedImageView.animatedImage = nil;
    //            }
    //        }
    //        if (!animatedImageView) {
    //            animatedImageView = [[FLAnimatedImageView alloc] initWithFrame:imageView.bounds];
    //            animatedImageView.runLoopMode = NSDefaultRunLoopMode;
    //            [imageView addSubview:animatedImageView];
    //        }
    //        animatedImageView.animatedImage = animatedImage;
    //    }];
    
    // 设置首选语言 / Set preferred language
    // imagePickerVc.preferredLanguage = @"zh-Hans";
    
    // 设置languageBundle以使用其它语言 / Set languageBundle to use other language
    // imagePickerVc.languageBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"tz-ru" ofType:@"lproj"]];
    
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    @weakify_self
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (photos.count > 0) {
            UIImage *img = photos[0];
            NSData *imgData = UIImageJPEGRepresentation(img,1.0);
            NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
            NSString *outputPath = [NSString stringWithFormat:@"%@.jpg",mills];
            outputPath =  [[SystemUtil getTempUploadPhotoBaseFilePath] stringByAppendingPathComponent:outputPath];
            NSURL *url = [NSURL fileURLWithPath:outputPath];
            BOOL success = [imgData writeToURL:url atomically:YES];
            if (success) {
                [weakSelf jumpToUploadFiles:@[url]];
            }
        }
    }];
    // 你可以通过block或者代理，来得到用户选择的视频.
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *asset) {
        [weakSelf extracted:asset evImage:coverImage];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark -视频导出到本地
- (void)extracted:(PHAsset *)asset evImage:(UIImage *) evImage {
    [AppD.window showHudInView:AppD.window hint:@""];
    NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    NSString *outputPath = [NSString stringWithFormat:@"%@.mp4",mills];
    outputPath =  [[SystemUtil getTempUploadVideoBaseFilePath] stringByAppendingPathComponent:outputPath];
    @weakify_self
    [TZImageManager manager].outputPath = outputPath;
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPreset640x480 success:^(NSString *outputPath) {
         [AppD.window hideHud];
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
//        __block NSData *mediaData = [NSData dataWithContentsOfFile:outputPath];
        NSURL *url = [NSURL fileURLWithPath:outputPath];
        [weakSelf jumpToUploadFiles:@[url]];
    } failure:^(NSString *errorMessage, NSError *error) {
        [AppD.window hideHud];
        [self.view showHint:@"不支持当前视频格式"];
    }];
}

#pragma mark - Request
- (void)sendPullFileList {
    NSString *UserId = [UserConfig getShareObject].userId;
    NSNumber *MsgStartId = @(0);
    NSNumber *MsgNum = @(15);
    NSNumber *Category = @(0);
    NSNumber *FileType = @(0);
    [SendRequestUtil sendPullFileListWithUserId:UserId MsgStartId:MsgStartId MsgNum:MsgNum Category:Category FileType:FileType showHud:YES];
}

#pragma mark - Action

- (IBAction)taskAction:(id)sender {
    [self jumpToTaskList];
}

- (IBAction)uploadAction:(id)sender {
    [self showUploadAlertView];
}

- (IBAction)myFileAction:(id)sender {
    [self jumpToMyFile];
}

- (IBAction)shareAction:(id)sender {
    [self jumpToDocumentShare];
}

- (IBAction)receiveAction:(id)sender {
    [self jumpToDocumentReceived];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FileCellHeight;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FileCell *cell = [tableView dequeueReusableCellWithIdentifier:FileCellReuse];
    
//    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:65.f];
//    cell.delegate = (id)self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

//#pragma mark - SWTableViewDelegate
//- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state {
//    switch (state) {
//        case 0:
//            NSLog(@"utility buttons closed");
//            break;
//        case 1:
//            NSLog(@"left utility buttons open");
//            break;
//        case 2:
//            NSLog(@"right utility buttons open");
//            break;
//        default:
//            break;
//    }
//}
//
//
//- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
//{
//    [cell hideUtilityButtonsAnimated:YES];
//    switch (index) {
//        case 0:
//        {
//            NSLog(@"More button was pressed  1");
//
//            break;
//        }
//        case 1:
//        {
//            NSLog(@"More button was pressed  2");
//            break;
//        }
//        default:
//            break;
//    }
//}
//
//- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
//{
//    // allow just one cell's utility button to be open at once
//    return YES;
//}
//
//- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
//{
//    switch (state) {
//        case 1:
//            // set to NO to disable all left utility buttons appearing
//            return YES;
//            break;
//        case 2:
//            // set to NO to disable all right utility buttons appearing
//            return YES;
//            break;
//        default:
//            break;
//    }
//
//    return YES;
//}
//
//- (NSArray *)rightButtons {
//    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     MAIN_PURPLE_COLOR
//                                                 icon:[UIImage imageNamed:@"icon_forward"]];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     MAIN_PURPLE_COLOR
//                                                 icon:[UIImage imageNamed:@"icon_right"]];
//    [rightUtilityButtons sw_addUtilityButtonWithColor:
//     MAIN_PURPLE_COLOR
//                                                 icon:[UIImage imageNamed:@"icon_delete"]];
//
//    return rightUtilityButtons;
//}

#pragma mark -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    NSData *imgData = UIImageJPEGRepresentation(img,1.0);
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    return YES;
}

#pragma mark - Transition
- (void)jumpToTaskList {
    TaskListViewController *vc = [[TaskListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToMyFile {
    MyFilesViewController *vc = [[MyFilesViewController alloc] init];
    vc.filesType = FilesTypeMy;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToDocumentShare {
    MyFilesViewController *vc = [[MyFilesViewController alloc] init];
    vc.filesType = FilesTypeShare;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToDocumentReceived {
    MyFilesViewController *vc = [[MyFilesViewController alloc] init];
    vc.filesType = FilesTypeReceived;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToDocumentPicker:(DocumentPickerType)type {
    NSArray *documentTypes = @[];
    if (type == DocumentPickerTypePhoto) {
        documentTypes = @[@"public.image"];
    } else if (type == DocumentPickerTypeVideo) {
        documentTypes = @[@"public.video"];
    } else if (type == DocumentPickerTypeDocument) {
        documentTypes = @[@"public.content"];
    } else if (type == DocumentPickerTypeOther) {
        documentTypes = @[@"public.item"];
    }
    PNDocumentPickerViewController *vc = [[PNDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeImport];
    vc.delegate = self;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    if (@available(iOS 11.0, *)) {
        vc.allowsMultipleSelection = YES;
    } else {
        // Fallback on earlier versions
    }
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)jumpToUploadFiles:(NSArray *)urlArr {
    UploadFilesViewController *vc = [[UploadFilesViewController alloc] init];
    vc.urlArr = urlArr;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls NS_AVAILABLE_IOS(11_0) {
    NSLog(@"didPickDocumentsAtURLs:%@",urls);
    
//    NSURL *first = urls.firstObject;
    
    [self jumpToUploadFiles:urls];
}

// called if the user dismisses the document picker without selecting a document (using the Cancel button)
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    NSLog(@"documentPickerWasCancelled");
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url NS_DEPRECATED_IOS(8_0, 11_0, "Implement documentPicker:didPickDocumentsAtURLs: instead") {
    NSLog(@"didPickDocumentAtURL:%@",url);
    [self jumpToUploadFiles:@[url]];
}

#pragma mark - Noti
- (void)pullFileListCompleteNoti:(NSNotification *)noti {
    NSArray *arr = noti.object;
    if (arr.count <= 0) {
        
    } else {
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
