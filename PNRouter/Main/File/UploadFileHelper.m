//
//  UploadFileHelper.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/30.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "UploadFileHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "TZImagePickerController.h"
#import "UploadAlertView.h"
#import "PNDocumentPickerViewController.h"
#import "NSDate+Category.h"
#import "UploadFilesViewController.h"
#import "SystemUtil.h"
#import "NSString+File.h"

@interface UploadFileHelper () <UIDocumentPickerDelegate, UIImagePickerControllerDelegate,TZImagePickerControllerDelegate>

@property (nonatomic , assign) DocumentPickerType pickerType;
@property (nonatomic, strong) UploadAlertView *uploadAlertV;
@property (nonatomic, strong) UIViewController *currentVC;
@property (nonatomic , assign) BOOL isSendMessenger;

@end

@implementation UploadFileHelper

+ (instancetype)shareObject {
    static UploadFileHelper *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
    });
    return shareObject;
}

- (void)showUploadAlertView:(UIViewController *)vc {
    _currentVC = vc;
    _uploadAlertV = [UploadAlertView getInstance];
    @weakify_self
    [_uploadAlertV setPhotoB:^{
        weakSelf.pickerType = DocumentPickerTypePhoto;
        [weakSelf showPhotoLib];
        //        [weakSelf jumpToDocumentPicker:DocumentPickerTypePhoto];
    }];
    [_uploadAlertV setVideoB:^{
        weakSelf.pickerType = DocumentPickerTypeVideo;
        [weakSelf showVideoLib];
        //        [weakSelf jumpToDocumentPicker:DocumentPickerTypeVideo];
    }];
    [_uploadAlertV setDocumentB:^{
        weakSelf.pickerType = DocumentPickerTypeDocument;
        [weakSelf jumpToDocumentPicker:DocumentPickerTypeDocument];
    }];
    [_uploadAlertV setOtherB:^{
        weakSelf.pickerType = DocumentPickerTypeDocument;
        [weakSelf jumpToDocumentPicker:DocumentPickerTypeDocument];
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
                    [weakSelf.currentVC.view endEditing:YES];
                    [AppD.window showHint:@"请在iPhone的""设置-隐私-相册""中允许访问相册"];
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.currentVC.view endEditing:YES];
                    [weakSelf pushTZImagePickerControllerWithIsSelectImgage:YES];
                });
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.currentVC.view endEditing:YES];
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
                    [weakSelf.currentVC.view endEditing:YES];
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
                [weakSelf.currentVC.view endEditing:YES];
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
    
    imagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    imagePickerVc.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [imagePickerVc setPhotoPickerPageUIConfigBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
        [doneButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }];
    
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
    imagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    // 设置是否显示图片序号
    imagePickerVc.showSelectedIndex = NO;
    // 自定义gif播放方案
    @weakify_self
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (photos.count > 0) {
            UIImage *img = photos[0];
            NSData *imgData = UIImageJPEGRepresentation(img,1.0);
            
            if (imgData.length/(1024*1024) > 100) {
                [AppD.window showHint:@"Image cannot be larger than 100MB"];
                return;
            }
            NSString *fileInfo = [NSString stringWithFormat:@"%f,%f",img.size.width,img.size.height];
            NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
            NSString *outputPath = [NSString stringWithFormat:@"%@.jpg",mills];
            outputPath =  [[SystemUtil getTempUploadPhotoBaseFilePath] stringByAppendingPathComponent:outputPath];
            NSURL *url = [NSURL fileURLWithPath:outputPath];
            BOOL success = [imgData writeToURL:url atomically:YES];
            if (success) {
                [weakSelf jumpToUploadFiles:@[url] fileInfo:fileInfo isDoc:NO];
            }
        }
    }];
    // 你可以通过block或者代理，来得到用户选择的视频.
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *phAsset) {
        dispatch_async(dispatch_get_main_queue(), ^{
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
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
        });
    }];
    [self.currentVC presentViewController:imagePickerVc animated:YES completion:nil];
    
}

#pragma mark -视频导出到本地
- (void)extractedVideWithAsset:(AVURLAsset *)asset evImage:(UIImage *) evImage
{
    NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    NSString *outputPath = [NSString stringWithFormat:@"%@.mp4",mills];
    outputPath =  [[SystemUtil getTempUploadVideoBaseFilePath] stringByAppendingPathComponent:outputPath];
    NSURL *url = [NSURL fileURLWithPath:outputPath];
    NSString *fileInfo = [NSString stringWithFormat:@"%f,%f",evImage.size.width,evImage.size.height];
    BOOL result = [[NSFileManager defaultManager] copyItemAtURL:asset.URL toURL:url error:nil];
    if (result) {
      //  [AppD.window hideHud];
        [self jumpToUploadFiles:@[url] fileInfo:fileInfo isDoc:NO];
    } else {
      //  [AppD.window hideHud];
        [self.currentVC.view showHint:@"The current video format is not supported"];
    }
}

//- (void)extracted:(PHAsset *)asset evImage:(UIImage *) evImage {
//
//    [AppD.window showHudInView:AppD.window hint:@"File encrypting"];
//
//    NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
//    NSString *outputPath = [NSString stringWithFormat:@"%@.mp4",mills];
//    outputPath =  [[SystemUtil getTempUploadVideoBaseFilePath] stringByAppendingPathComponent:outputPath];
//
//
//
//    @weakify_self
//    [TZImageManager manager].outputPath = outputPath;
//    [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPresetMediumQuality success:^(NSString *outputPath) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [AppD.window hideHud];
//            NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
//            //        __block NSData *mediaData = [NSData dataWithContentsOfFile:outputPath];
//            NSURL *url = [NSURL fileURLWithPath:outputPath];
//            [weakSelf jumpToUploadFiles:@[url] isDoc:NO];
//        });
//    } failure:^(NSString *errorMessage, NSError *error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [AppD.window hideHud];
//            [weakSelf.currentVC.view showHint:@"The current video format is not supported"];
//        });
//    }];
//}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls NS_AVAILABLE_IOS(11_0) {
    NSLog(@"didPickDocumentsAtURLs:%@",urls);
    
    //    NSURL *first = urls.firstObject;
    
    [self jumpToUploadFiles:urls fileInfo:@"" isDoc:YES];
}

// called if the user dismisses the document picker without selecting a document (using the Cancel button)
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    NSLog(@"documentPickerWasCancelled");
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url NS_DEPRECATED_IOS(8_0, 11_0, "Implement documentPicker:didPickDocumentsAtURLs: instead") {
    NSLog(@"didPickDocumentAtURL:%@",url);

    NSData *txtData = [NSData dataWithContentsOfURL:url];
    if (txtData.length/(1024*1024) > 100) {
        [AppD.window showHint:@"File cannot be larger than 100MB"];
        return;
    }
    [self jumpToUploadFiles:@[url] fileInfo:@"" isDoc:YES];
}

#pragma mark - Transition
- (void)jumpToUploadFiles:(NSArray *)urlArr fileInfo:(NSString *) fileInfo isDoc:(BOOL) isDoc {
    UploadFilesViewController *vc = [[UploadFilesViewController alloc] init];
    vc.documentType = self.pickerType;
    vc.isDoc = isDoc;
    vc.fileInfo = fileInfo;
    vc.urlArr = urlArr;
    [self.currentVC.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToDocumentPicker:(DocumentPickerType)type {
    NSArray *documentTypes = @[];
    if (type == DocumentPickerTypePhoto) {
        documentTypes = @[@"public.image"];
    } else if (type == DocumentPickerTypeVideo) {
        documentTypes = @[@"public.video"];
    } else if (type == DocumentPickerTypeDocument) {
        documentTypes = @[@"public.content"];
    }
//    else if (type == DocumentPickerTypeOther) {
//        documentTypes = @[@"public.item"];
//    }
    PNDocumentPickerViewController *vc = [[PNDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeImport];
    vc.delegate = self;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    if (@available(iOS 11.0, *)) {
        vc.allowsMultipleSelection = NO;
    } else {
        // Fallback on earlier versions
    }
    [self.currentVC presentViewController:vc animated:YES completion:nil];
}

@end
