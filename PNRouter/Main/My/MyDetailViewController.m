//
//  MyDetailViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "MyDetailViewController.h"
#import "MyCell.h"
#import "PersonCodeViewController.h"
#import "UserModel.h"
#import "UIImage+Resize.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "EditTextViewController.h"
#import "UserConfig.h"
#import "PNRouter-Swift.h"
#import "LibsodiumUtil.h"
#import "SystemUtil.h"
#import "EntryModel.h"
#import "AESCipher.h"
#import "SocketDataUtil.h"
#import "SocketManageUtil.h"
#import "NSDate+Category.h"
#import "SocketCountUtil.h"
#import "MD5Util.h"
#import "PNDefaultHeaderView.h"
#import "UserHeaderModel.h"
#import "UserHeadUtil.h"
#import <TZImagePickerController.h>

@interface MyDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    UIImage *_selectImage;
}

@property (nonatomic , strong) NSMutableArray *dataArray;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic, strong) NSData *uploadImgData;
@property (nonatomic, strong) NSString *uploadFileName;

@end

@implementation MyDetailViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userHeadChangeNoti:) name:USER_HEAD_CHANGE_NOTI object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    [_tableV reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObserve];
    
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableV registerNib:[UINib nibWithNibName:MyCellReuse bundle:nil] forCellReuseIdentifier:MyCellReuse];
}

#pragma mark - Action
- (IBAction)backBtnAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}

#pragma mark - Operation
//- (void)showPickPhoto {
//    @weakify_self
//    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [weakSelf selectImage:YES];
//    }];
//    [alertC addAction:alert1];
//    UIAlertAction *alert2 = [UIAlertAction actionWithTitle:@"Select From Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [weakSelf selectImage:NO];
//    }];
//    [alertC addAction:alert2];
//    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//    }];
//    [alertC addAction:alertCancel];
//    [self presentViewController:alertC animated:YES completion:nil];
//}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MyCellReuse_Height;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCellReuse];
    cell.iconWidth.constant = 0;
    cell.lblContent.text = self.dataArray[indexPath.row];
    if (indexPath.row == 0 || indexPath.row == 2) {
        cell.lblSubContent.hidden = YES;
        cell.subBtn.hidden = NO;
        if (indexPath.row == 0) {
            if ([UserModel getUserModel].headBaseStr) {
                [cell.subBtn setImage:[UIImage imageWithData:[UserModel getUserModel].headBaseStr.base64DecodedData] forState:UIControlStateNormal];
//                [cell.subBtn setTitle:@"" forState:UIControlStateNormal];
            } else {
                NSString *userKey = [EntryModel getShareObject].signPublicKey;
                UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:[UserModel getUserModel].username]];
                [cell.subBtn setImage:defaultImg forState:UIControlStateNormal];
//                [cell.subBtn setBackgroundImage:[UIImage imageNamed:@"detailHead"] forState:UIControlStateNormal];
//                [cell.subBtn setTitle:[StringUtil getUserNameFirstWithName:[UserModel getUserModel].username] forState:UIControlStateNormal];
            }
        
        } else {
             [cell.subBtn setImage:[UIImage imageNamed:@"icon_code"] forState:UIControlStateNormal];
        }
    } else {
        UserModel *userModel = [UserModel getUserModel];
        cell.lblSubContent.hidden = NO;
        cell.subBtn.hidden = YES;
        if (indexPath.row == 1) {
            cell.lblSubContent.text = userModel.username;
        } else if (indexPath.row ==3){ // 公司
            cell.lblSubContent.text = userModel.commpany?:@"";
        } else if (indexPath.row ==4){ // 职业
            cell.lblSubContent.text = userModel.position?:@"";
        }  else if (indexPath.row ==5){ // 地区
            cell.lblSubContent.text =userModel.location?:@"";
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 2) {
        PersonCodeViewController *vc = [[PersonCodeViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 0) {
//        [self showPickPhoto];
        [self pushTZImagePickerController];
    } else {
        EditType type = EditName;
        if (indexPath.row ==3){ // 公司
            type = EditCompany;
        } else if (indexPath.row ==4){ // 职业
            type = EditPosition;
        }  else if (indexPath.row ==5){ // 地区
            type = EditLocation;
        }
        EditTextViewController *vc = [[EditTextViewController alloc] initWithType:type];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - 调用相册
- (void)pushTZImagePickerController {
    BOOL isImage = YES;
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:3 delegate:nil pushPhotoPickerVc:YES];
    // imagePickerVc.navigationBar.translucent = NO;
    
#pragma mark - 五类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = NO;
    imagePickerVc.allowTakePicture = isImage; // 在内部显示拍照按钮
    imagePickerVc.allowTakeVideo = !isImage;   // 在内部显示拍视频按钮
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
    imagePickerVc.allowCrop = YES;
    imagePickerVc.cropRect = CGRectMake(0, (SCREEN_HEIGHT-SCREEN_WIDTH)/2.0, SCREEN_WIDTH, SCREEN_WIDTH);
    imagePickerVc.needCircleCrop = NO;
    imagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    // 设置是否显示图片序号
    imagePickerVc.showSelectedIndex = NO;
    // 自定义gif播放方案
//    @weakify_self
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (photos.count > 0) {
            UIImage *resultImage = photos[0];
            NSData *imgData = [resultImage compressJPGImage:resultImage toMaxFileSize:User_Header_Size];
            [[UserHeadUtil getUserHeadUtilShare] uploadHeader:imgData showToast:YES];
            
//            NSData *imgData = UIImageJPEGRepresentation(img,1.0);
//            if (imgData.length/(1024*1024) > 100) {
//                [AppD.window showHint:@"Image cannot be larger than 100MB"];
//                return;
//            }
//            NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
//            NSString *outputPath = [NSString stringWithFormat:@"%@.jpg",mills];
//            outputPath =  [[SystemUtil getTempUploadPhotoBaseFilePath] stringByAppendingPathComponent:outputPath];
//            NSURL *url = [NSURL fileURLWithPath:outputPath];
//            BOOL success = [imgData writeToURL:url atomically:YES];
//            if (success) {
//                [weakSelf jumpToUploadFiles:@[url] isDoc:NO];
//            }
        }
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

////调用系统相册
//- (void)selectImage:(BOOL)isCamera {
//    //调用系统相册的类
//    UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
//    //    更改titieview的字体颜色
//    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
//    attrs[NSForegroundColorAttributeName] = MAIN_PURPLE_COLOR;
//    [pickerController.navigationBar setTitleTextAttributes:attrs];
//    pickerController.navigationBar.translucent = NO;
//    pickerController.navigationBar.barTintColor = MAIN_WHITE_COLOR;
//    //设置选取的照片是否可编辑
//    pickerController.allowsEditing = YES;
//    //设置相册呈现的样式
//    if (isCamera) {
//        pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//    } else {
//        pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
//    }
//    //UIImagePickerControllerSourceTypeSavedPhotosAlbum;//图片分组列表样式
//    //照片的选取样式还有以下两种
//    // UIImagePickerControllerSourceTypePhotoLibrary,直接全部呈现系统相册
//    //UIImagePickerControllerSourceTypeCamera//调取摄像头
//    //选择完成图片或者点击取消按钮都是通过代理来操作我们所需要的逻辑过程
//    pickerController.delegate = self;
//    //使用模态呈现相册
//    //[self showDetailViewController:pickerController sender:nil];
//    [self.navigationController presentViewController:pickerController animated:YES completion:nil];
//
//}
//
//#pragma UIImagePickerController delegate
//
//-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
//
//    //    UIImagePickerControllerEditedImage//编辑过的图片
//    //    UIImagePickerControllerOriginalImage//原图
//    UIImage *resultImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
//    if (resultImage) {
//        NSData *imgData = [resultImage compressJPGImage:resultImage toMaxFileSize:User_Header_Size];
//        [[UserHeadUtil getUserHeadUtilShare] uploadHeader:imgData showToast:YES];
//
//////        resultImage = [resultImage resizeImage:resultImage];
////        UserModel *model = [UserModel getUserModel];
//////        model.headBaseStr = UIImagePNGRepresentation(resultImage).base64EncodedString;
////        model.headBaseStr = imgData.base64EncodedString;
////        [model saveUserModeToKeyChain];
////        _selectImage = [UIImage imageWithData:imgData];
////        [_tableV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
////        [[NSNotificationCenter defaultCenter] postNotificationName:USER_HEAD_CHANGE_NOTI object:nil];
//    }
//
//    //使用模态返回到软件界面
//    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    [picker dismissViewControllerAnimated:YES completion:nil];
////    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
//}

#pragma mark - Noti
- (void)userHeadChangeNoti:(NSNotification *)noti {
    [_tableV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        //_dataArray = [NSMutableArray arrayWithObjects:@"Profile Photo",@"Name",@"My QR Code",@"Company",@"Occupation",@"Region", nil];
        _dataArray = [NSMutableArray arrayWithObjects:@"Profile Photo",@"Name",@"My QR Code", nil];
    }
    return _dataArray;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
