//
//  PNFeedbackSendViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/20.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNFeedbackSendViewController.h"
#import "PNImgCollectionCell.h"
#import "UITextViewWithPlaceHolder.h"
#import "TZImagePickerController.h"
#import "PNFeedbackImgModel.h"
#import "FilePreviewViewController.h"


@interface PNFeedbackSendViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,TZImagePickerControllerDelegate,UINavigationControllerDelegate,
UIImagePickerControllerDelegate,UITextFieldDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblTypeName;
@property (weak, nonatomic) IBOutlet UILabel *lblContentCount;
@property (weak, nonatomic) IBOutlet UITextViewWithPlaceHolder *contentTF;
@property (weak, nonatomic) IBOutlet UIView *contentBackV;
@property (weak, nonatomic) IBOutlet UILabel *lblImgCount;
@property (weak, nonatomic) IBOutlet UICollectionView *imgCollectionV;
@property (weak, nonatomic) IBOutlet UIView *imgBackV;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UIView *emailBackV;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (nonatomic, strong) NSMutableArray *imgArray;
@end

@implementation PNFeedbackSendViewController
- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}
- (IBAction)clickSendAction:(id)sender {
}
#pragma mark----------layz
- (NSMutableArray *)imgArray
{
    if (!_imgArray) {
        PNFeedbackImgModel *model = [[PNFeedbackImgModel alloc] init];
        model.img = [UIImage imageNamed:@"tabbar_feedback_add"];
        model.imgName = @"tabbar_feedback_add.png";
        _imgArray = [NSMutableArray arrayWithObject:model];
    }
    return _imgArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _contentBackV.layer.cornerRadius = 8.0f;
    _imgBackV.layer.cornerRadius = 8.0f;
    _sendBtn.layer.cornerRadius = 8.0f;
    _emailBackV.layer.cornerRadius = 8.0f;
    
    _emailTF.delegate = self;
    _contentTF.delegate = self;
    
    _imgCollectionV.delegate = self;
    _imgCollectionV.dataSource = self;
    [_imgCollectionV registerNib:[UINib nibWithNibName:PNImgCollectionCellResue bundle:nil] forCellWithReuseIdentifier:PNImgCollectionCellResue];
}


#pragma mark ---------colletion 代理回调
/**
 分区个数
 */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
/**
 每个分区item的个数
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imgArray.count;
}
/**
 创建cell
 */
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{

    PNImgCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PNImgCollectionCellResue forIndexPath:indexPath];
    cell.tag = indexPath.item;
    PNFeedbackImgModel *model = [self.imgArray objectAtIndex:indexPath.item];
    cell.imgV.image = model.img;
    if ([model.imgName isEqualToString:@"tabbar_feedback_add.png"]) {
        cell.closeBtn.hidden = YES;
    } else {
        cell.closeBtn.hidden = NO;
    }

    @weakify_self
    [cell setClickDelBlock:^(NSInteger item) {

        [weakSelf.imgCollectionV reloadData];
        [collectionView performBatchUpdates:^{
            [weakSelf.imgArray removeObjectAtIndex:item];
            [collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:item inSection:0]]];
        }completion:^(BOOL finished){
            weakSelf.lblImgCount.text =  [NSString stringWithFormat:@"%ld/%d",weakSelf.imgArray.count-1, 4];
            [collectionView reloadData];
        }];
    }];
    return cell;
}
/**
 点击某个cell
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == self.imgArray.count-1) { // 选择图片
        [self selectImage];
    } else {
        PNFeedbackImgModel*attachment = self.imgArray[indexPath.item];
        FilePreviewViewController*vc = [[FilePreviewViewController alloc] init];
        vc.fileType = EmailFile;
        vc.localFileData = attachment.imgData;
        vc.fileName = attachment.imgName;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
/**
 cell的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    CGFloat itemW = 130;
    CGFloat itemH = 112;
    return CGSizeMake(itemW,itemH);
}

/**
 分区内cell之间的最小行间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}
/**
 分区内cell之间的最小列间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}


#pragma mark-----uitextviewdelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString *str = [NSString stringWithFormat:@"%@%@", textView.text, text];

    if (str.length > LimitMaxWord)
    {
      NSRange rangeIndex = [str rangeOfComposedCharacterSequenceAtIndex:LimitMaxWord];

      if (rangeIndex.length == 1)//字数超限
      {
          textView.text = [str substringToIndex:LimitMaxWord];
    //这里重新统计下字数，字数超限，我发现就不走textViewDidChange方法了，你若不统计字数，忽略这行
          self.lblContentCount.text = [NSString stringWithFormat:@"%lu/%ld", (unsigned long)textView.text.length, LimitMaxWord];
      }else{
          NSRange rangeRange = [str rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, LimitMaxWord)];
          textView.text = [str substringWithRange:rangeRange];
      }
       return NO;
   }
   return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > LimitMaxWord)
    {
      textView.text = [textView.text substringToIndex:LimitMaxWord];
    }
    //记录输入的字数，你若不统计字数，忽略这行
    self.lblContentCount.text = [NSString stringWithFormat:@"%lu/%ld", (unsigned long)[textView.text length], LimitMaxWord];
}

#pragma mark ---选择相册
//调用系统相册
- (void)selectImage{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    @weakify_self
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
                // 无相机权限 做一个友好的提示
                dispatch_async(dispatch_get_main_queue(), ^{
                    [AppD.window showHint:@"Please allow access to album in \"Settings - privacy - album\" of iPhone"];
                });

            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf pushTZImagePickerControllerWithIsSelectImgage:YES];
                });

            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view endEditing:YES];
                [AppD.window showHint:@"Denied or restricted"];
            });

        }
    }];
}
/**
 跳转到选择图片vc

 @param isImage 是
 */
- (void)pushTZImagePickerControllerWithIsSelectImgage:(BOOL) isImage {

    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:3 delegate:self pushPhotoPickerVc:YES];
    // imagePickerVc.navigationBar.translucent = NO;

#pragma mark - 五类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = YES;
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    imagePickerVc.allowTakeVideo = NO;   // 在内部显示拍视频按
    imagePickerVc.videoMaximumDuration = 15; // 视频最大拍摄时间
    [imagePickerVc setUiImagePickerControllerSettingBlock:^(UIImagePickerController *imagePickerController) {
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }];

    [imagePickerVc setNaviBgColor:MAIN_GRAY_COLOR];
    [imagePickerVc setNaviTitleColor:MAIN_PURPLE_COLOR];
    [imagePickerVc setBarItemTextColor:MAIN_PURPLE_COLOR];
    imagePickerVc.needShowStatusBar = YES;

    imagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    imagePickerVc.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [imagePickerVc setPhotoPickerPageUIConfigBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
        [doneButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }];

    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingImage = YES;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingMultipleVideo = NO; //是否可以多选视频

    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    imagePickerVc.maxImagesCount = 5 -self.imgArray.count;
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
                NSString *fName = [asset valueForKey:@"filename"];
                NSLog(@"filename = %@",fName);
                if (asset.mediaType == 1) { // 图片
                    PNFeedbackImgModel *model = [[PNFeedbackImgModel alloc] init];
                    model.img = photos[idx];
                    model.imgName = fName;
                    model.imgData = UIImageJPEGRepresentation(model.img,1.0);
                    [weakSelf.imgArray insertObject:model atIndex:0];
                }
            }];
            weakSelf.lblImgCount.text =  [NSString stringWithFormat:@"%ld/%d",weakSelf.imgArray.count-1, 4];
            [weakSelf.imgCollectionV reloadData];
        }
    }];
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

@end
