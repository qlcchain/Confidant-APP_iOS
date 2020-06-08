//
//  PNFeedCreateViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/20.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNFeedCreateViewController.h"
#import "PNFeedbackSheetViewController.h"
#import "PNImgCollectionCell.h"
#import "TZImagePickerController.h"
#import "PNFeedbackImgModel.h"
#import "FilePreviewViewController.h"
#import "UITextViewWithPlaceHolder.h"
#import "RequestService.h"
#import "NSDate+Category.h"
#import "UIImage+Resize.h"
#import "UserModel.h"
#import "RouterModel.h"
#import "AESCipher.h"
#import "NSString+Base64.h"
#import "NSString+RegexCategory.h"

@interface PNFeedCreateViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,TZImagePickerControllerDelegate,UINavigationControllerDelegate,
UIImagePickerControllerDelegate,UITextFieldDelegate,UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblType;
@property (weak, nonatomic) IBOutlet UITextViewWithPlaceHolder *contentTF;
@property (weak, nonatomic) IBOutlet UIView *meagessBackV;
@property (weak, nonatomic) IBOutlet UIView *typeBackV;
@property (weak, nonatomic) IBOutlet UIView *contentBackV;
@property (weak, nonatomic) IBOutlet UICollectionView *imgCollectionView;
@property (weak, nonatomic) IBOutlet UIView *imgBackV;
@property (weak, nonatomic) IBOutlet UIView *emailBackV;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;
@property (weak, nonatomic) IBOutlet UILabel *lblContentCount;
@property (weak, nonatomic) IBOutlet UILabel *lblImgCount;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (nonatomic, strong) NSMutableArray *imgArray;
@property (nonatomic, strong) NSMutableArray *typeArray;
@property (nonatomic, strong) NSMutableArray *scenarioArray;
@property (nonatomic ,assign) NSInteger selFeedbackType;
@end

@implementation PNFeedCreateViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}
- (IBAction)clickSendAction:(id)sender {
    [self sendFeedbackWQuest];
}
- (IBAction)clickTypeAction:(id)sender {
    [self jumpToSheetVCWithType:2];
}
- (IBAction)clickMesageAction:(id)sender {
    [self jumpToSheetVCWithType:1];
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
- (NSMutableArray *)typeArray
{
    if (!_typeArray) {
        _typeArray = [NSMutableArray array];
    }
    return _typeArray;
}
- (NSMutableArray *)scenarioArray
{
    if (!_scenarioArray) {
        _scenarioArray = [NSMutableArray array];
    }
    return _scenarioArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _meagessBackV.layer.cornerRadius = 8.0f;
    _typeBackV.layer.cornerRadius = 8.0f;
    _contentBackV.layer.cornerRadius = 8.0f;
    _imgBackV.layer.cornerRadius = 8.0f;
    _sendBtn.layer.cornerRadius = 8.0f;
    _emailBackV.layer.cornerRadius = 8.0f;
    
    _lblMessage.text = @"";
    _lblType.text = @"";
    _emailTF.delegate = self;
    _contentTF.delegate = self;
    
    _imgCollectionView.delegate = self;
    _imgCollectionView.dataSource = self;
    [_imgCollectionView registerNib:[UINib nibWithNibName:PNImgCollectionCellResue bundle:nil] forCellWithReuseIdentifier:PNImgCollectionCellResue];
    
    // 查询类型
    [self sendChekcTypeQuest];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectFeedbackTypeNoti:) name:Feedback_Type_Select_Noti object:nil];
}

// 创建
- (void) sendFeedbackWQuest
{
    NSString *emailAddress = _emailTF.text.trim;
    NSString *contentStr = _contentTF.text.trim;
    NSString *scenarioStr = _lblMessage.text?:@"";
    NSString *typeStr = _lblType.text?:@"";
    
    if (contentStr.length == 0) {
        [self.view showHint:@"The description cannot be empty"];
        return;
    }
    if (!(scenarioStr.length > 0 && typeStr.length > 0)) {
        [self.view showHint:@"Please select type"];
        return;
    }
    if (emailAddress && emailAddress.length > 0) {
        if (![emailAddress isEmailAddress] ) {
            [self.view showHint:@"Email format error"];
            return;
        }
    }
       
       UserModel *userM = [UserModel getUserModel];
       RouterModel *routerM = [RouterModel getConnectRouter];
       
       NSString *coderValue = [NSString stringWithFormat:@"%@,%@,%@,%@,%@",[routerM.userSn substringToIndex:6],[EntryModel getShareObject].signPublicKey,routerM.toxid,[userM.username base64EncodedString],userM.userId];
       coderValue = aesEncryptString(coderValue, AES_KEY);
       coderValue = [NSString stringWithFormat:@"type_5,%@",coderValue];
       
       NSDictionary *params = @{@"scenario":scenarioStr,@"type":typeStr,@"userId":userM.userId,@"userName":userM.username,@"publicKey":[EntryModel getShareObject].signPublicKey,@"qrCode":coderValue,@"email":emailAddress?:@"",@"question":contentStr};
       
       [self.view showHudInView:self.view hint:Uploading_Str];
       @weakify_self
       [RequestService postImage7:Feedback_Url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
           
           [weakSelf.imgArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                PNFeedbackImgModel *model = obj;
               if (![model.imgName isEqualToString:@"tabbar_feedback_add.png"]) {
                   NSLog(@"-------------%ld-----------",idx);
                  
                   NSString *fileName1 = [NSString stringWithFormat:@"%llu",[NSDate getMillisecondTimestampFromDate:[NSDate date]]];
                   NSData *data1 = [model.img compressJPGImage:model.img toMaxFileSize:Upload_Image_Size];
                   NSString *name1 = [NSString stringWithFormat:@"%@.jpg", fileName1];
                   [formData appendPartWithFileData:data1 name:@"feedbackImages" fileName:name1 mimeType:@"image/jpeg/jpg/png"];
               }
           }];
       } success:^(NSURLSessionDataTask *dataTask, id responseObject) {
           [weakSelf.view hideHud];
           if ([responseObject[@"code"] intValue] == 0) {
               [[NSNotificationCenter defaultCenter] postNotificationName:Feedback_Add_Success_Noti object:nil];
               [weakSelf leftNavBarItemPressedWithPop:NO];
               [AppD.window showHint:Send_Success_Str];
           } else {
               [weakSelf.view showFaieldHudInView:weakSelf.view hint:Failed];
           }
       } failure:^(NSURLSessionDataTask *dataTask, NSError *error) {
           [weakSelf.view hideHud];
           [weakSelf.view showFaieldHudInView:weakSelf.view hint:Failed];
       }];
}

// 查询类型列表
- (void) sendChekcTypeQuest
{
   // [self.view showHudInView:self.view hint:Loading_Str];
    NSDictionary *parames = @{@"dictType":@"app_dict"};
    @weakify_self
    [AFHTTPClientV2 requestConfidantWithBaseURLStr:Feedback_Type_Url params:parames httpMethod:HttpMethodPost userInfo:nil successBlock:^(NSURLSessionDataTask *dataTask, id responseObject) {
        
       // [weakSelf.view hideHud];
        NSDictionary *resultDic = responseObject[@"data"];
        if (resultDic && resultDic.count > 0) {
            NSString *result1 = resultDic[@"conFeedbackScenario"];
            NSString *result2 = resultDic[@"conFeedbackType"];
            if (result1 && result1.length > 0) {
                [weakSelf.scenarioArray addObjectsFromArray:[result1 componentsSeparatedByString:@","]];
                weakSelf.lblMessage.text = weakSelf.scenarioArray[0];
            }
            if (result2 && result2.length >0) {
                [weakSelf.typeArray addObjectsFromArray:[result2 componentsSeparatedByString:@","]];
                weakSelf.lblType.text = weakSelf.typeArray[0];
            }
        }
        
    } failedBlock:^(NSURLSessionDataTask *dataTask, NSError *error) {
        //[weakSelf.view hideHud];
        [weakSelf sendChekcTypeQuest];
    }];
}

#pragma mark------------通知回调
- (void) selectFeedbackTypeNoti:(NSNotification *) noti
{
    NSString *selTypeStr = noti.object;
    if (selTypeStr.length > 0) {
        if (_selFeedbackType == 1) {
            _lblMessage.text = selTypeStr;
        } else {
            _lblType.text = selTypeStr;
        }
    }
    
}

- (void) jumpToSheetVCWithType:(NSInteger) type
{
    if (self.typeArray.count == 0) {
        return;
    }
    _selFeedbackType = type;
    PNFeedbackSheetViewController *vc = [[PNFeedbackSheetViewController alloc] initWithSheetType:type dataArray:type ==1 ? self.scenarioArray : self.typeArray selectStr:type==1 ? _lblMessage.text : _lblType.text];
    [self presentModalVC:vc animated:YES];
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
    return self.imgArray.count>4 ? 4:self.imgArray.count;
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
        
        [weakSelf.imgCollectionView reloadData];
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
            [weakSelf.imgCollectionView reloadData];
        }
    }];
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

@end
