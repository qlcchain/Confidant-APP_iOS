//
//  PNFloderContentViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNFloderContentViewController.h"
#import "UploadFileCell.h"
#import <YBImageBrowser/YBImageBrowser.h>
#import "TZImagePickerController.h"
#import "PNFileOptionView.h"
#import "SystemUtil.h"
#import "NSData+Base64.h"
#import "AESCipher.h"
#import "NSDate+Category.h"
#import "PNFileModel.h"
#import "PNFloderModel.h"
#import "FilePreviewViewController.h"
#import "SocketDataUtil.h"
#import "SocketCountUtil.h"
#import "SocketManageUtil.h"
#import "PNSelectFloderViewController.h"
#import "PNFileUploadModel.h"
#import "MyConfidant-Swift.h"
#import "KeyBordHeadView.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "NSString+Trim.h"
#import "UIImage+Resize.h"

@interface PNFloderContentViewController ()<UITableViewDelegate,UITableViewDataSource,YBImageBrowserDelegate,TZImagePickerControllerDelegate,UINavigationControllerDelegate,
UIImagePickerControllerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblNavTitle;
@property (weak, nonatomic) IBOutlet UIButton *addFileBtn;

@property (weak, nonatomic) IBOutlet UITableView *mainTabView;
@property (nonatomic, strong) PNFileOptionView *optionView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) PNFloderModel *floderM;
@property (nonatomic, assign) NSInteger selFileCount;
@property (nonatomic, assign) NSInteger finshFileCount;
@property (nonatomic, strong) PNFileModel *selFileM;
@property (nonatomic, assign) NSInteger autoNum;
@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) KeyBordHeadView *keyHeadView;
@property (nonatomic, strong) NSIndexPath *checkIndexPath;
@end

@implementation PNFloderContentViewController
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
// 取消keyboard
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    if (self.checkIndexPath) {
        if (self.dataArray.count >self.checkIndexPath.row) {
            [_mainTabView reloadRowsAtIndexPaths:@[self.checkIndexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}
// 恢复keyboard
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}
#pragma mark-------------layz
- (PNFileOptionView *)optionView
{
    if (!_optionView) {
        _optionView = [PNFileOptionView loadPNFileOptionView];
        @weakify_self
        [_optionView setClickMenuBlock:^(NSInteger tag) {
            if (tag == 10) { // 上传到节点
                PNSelectFloderViewController *vc = [[PNSelectFloderViewController alloc] init];
                [weakSelf presentModalVC:vc animated:YES];
                //[weakSelf uploadNode];
            } else if (tag == 30) { // 重命名
                
                if (weakSelf.floderM.isLocal) {
                    weakSelf.keyHeadView.floderTF.text = [weakSelf.selFileM.Fname componentsSeparatedByString:@"."][0];
                } else {
                    weakSelf.keyHeadView.floderTF.text = [[Base58Util Base58DecodeWithCodeName:weakSelf.selFileM.Fname] componentsSeparatedByString:@"."][0];
                }
                [AppD.window addSubview:weakSelf.keyHeadView];
                weakSelf.keyHeadView.lblTitle.text = @"ReName";
                [weakSelf.keyHeadView.floderTF becomeFirstResponder];
                
            } else { // 删除
                if (weakSelf.floderM.isLocal) {
                    [weakSelf.view showHudInView:weakSelf.view hint:@""];
                    [PNFileModel bg_deleteAsync:EN_FILE_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"fId"),bg_sqlValue(@(weakSelf.selFileM.fId))] complete:^(BOOL isSuccess) {
                        
                        // 切换到主线程
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.view hideHud];
                            if (isSuccess) {
                                [weakSelf.dataArray removeObject:weakSelf.selFileM];
                                //[weakSelf.mainTabView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:weakSelf.selRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                                [weakSelf.mainTabView reloadData];
                            } else {
                                [weakSelf.view showHint:@"Delete failed."];
                            }
                        });
                        
                    }];
                } else { // 删除节点文件
                    
                    [SendRequestUtil sendUpdateloderWithFloderType:1 updateType:1 react:2 name:weakSelf.selFileM.Fname oldName:@"" fid:weakSelf.selFileM.fId pathid:weakSelf.floderM.fId showHud:YES];
                }
            }
        }];
    }
    return _optionView;
}
- (KeyBordHeadView *)keyHeadView
{
    if (!_keyHeadView) {
        _keyHeadView = [KeyBordHeadView getKeyBordHeadView];
        _keyHeadView.floderTF.delegate = self;
    }
    return _keyHeadView;
}
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (IBAction)clickBackAction:(id)sender {
    self.floderM.FilesNum = self.dataArray.count;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateFileNum" object:nil];
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)clickAddAction:(id)sender {
    [self pushTZImagePickerControllerWithIsSelectImgage:YES];
}
- (IBAction)clickSelAction:(id)sender {
    
}
- (instancetype)initWithFloderM:(PNFloderModel *)floderM
{
    if (self = [super init]) {
        self.floderM = floderM;
    }
    return self;
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    _lblNavTitle.text = [Base58Util Base58DecodeWithCodeName:self.floderM.PathName];
    if (!self.floderM.isLocal) {
        self.addFileBtn.hidden = YES;
    }
    
    _mainTabView.delegate = self;
    _mainTabView.dataSource = self;
    _mainTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_mainTabView registerNib:[UINib nibWithNibName:UploadFileCellResue bundle:nil] forCellReuseIdentifier:UploadFileCellResue];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoUploadFileDataNoti:) name:Photo_Upload_FileData_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadSuccessNoti:) name:Photo_File_Upload_Success_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filePullSuccessNoti:) name:Pull_Floder_File_List_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delFileSuccessNoti:) name:Create_Floder_Success_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadProgressNoti:) name:Photo_FileData_Upload_Progress_Noti object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectFloderSuccessNoti:) name:Photo_Select_Floder_Noti object:nil];
    
    
    [self createButton];
    // 查询文件夹文件
    [self checkFloderFileList];
}

- (void) checkFloderFileList
{
    if (self.floderM.isLocal) {
        NSArray *colums = @[bg_sqlKey(@"fId"),bg_sqlKey(@"Depens"),bg_sqlKey(@"Type"),bg_sqlKey(@"Fname"),bg_sqlKey(@"Size"),bg_sqlKey(@"LastModify"),bg_sqlKey(@"Finfo"),bg_sqlKey(@"FKey"),bg_sqlKey(@"PathId"),bg_sqlKey(@"progressV"),bg_sqlKey(@"uploadStatus"),bg_sqlKey(@"smallData")];
        
            NSString *columString = [colums componentsJoinedByString:@","];
              //NSString *sql  = [NSString stringWithFormat:@"select %@ from %@ where %@=%@ order by %@ desc limit 100",columString,EN_FILE_TABNAME,bg_sqlKey(@"PathId"),bg_sqlValue(@(_floderM.fId)),bg_sqlKey(@"updateTime")];
            NSString *sql  = [NSString stringWithFormat:@"select %@ from %@ where %@=%@ order by %@ desc",columString,EN_FILE_TABNAME,bg_sqlKey(@"PathId"),bg_sqlValue(@(_floderM.fId)),bg_sqlKey(@"LastModify")];
        
        @weakify_self
        [weakSelf.view showHudInView:weakSelf.view hint:@""];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSArray *results = bg_executeSql(sql, EN_FILE_TABNAME,[PNFileModel class]);
            dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf.view hideHud];
                if (results) {
                    [weakSelf.dataArray addObjectsFromArray:results];
                    [weakSelf.mainTabView reloadData];
                }
            });
           
        });
    } else {
        [SendRequestUtil sendPullFloderFileListWithFloderType:1 floderId:self.floderM.fId floderName:self.floderM.PathName sortType:1 startId:0 num:500 showHud:YES];
    }
}

#pragma mark -----------------tableview deleate ---------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
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
        lblName.text = @"Screen Capture";
    } else {
         lblName.text = @"Screen Capture";
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
    myCell.tag = indexPath.row;
    
//    if (indexPath.section == 1) {
//         myCell.progress.progress = 0;
//        [myCell.optionBtn setImage:[UIImage imageNamed:@"statusbar_hedo"] forState:UIControlStateNormal];
//    } else {
//        [myCell.optionBtn setImage:[UIImage imageNamed:@"noun_play_b"] forState:UIControlStateNormal];
//    }
    
    [myCell setFileM:self.dataArray[indexPath.row] isLocal:self.floderM.isLocal floderId:self.floderM.fId];
    @weakify_self
    [myCell setOptionBlock:^(PNFileModel * _Nonnull fileM, NSInteger cellTag) {
        weakSelf.selFileM = fileM;
        if (weakSelf.selFileM.uploadStatus !=1 && weakSelf.floderM.isLocal) {
            weakSelf.optionView.nodeBtn.enabled = YES;
            weakSelf.optionView.lblNode.textColor = MAIN_PURPLE_COLOR;
            [weakSelf.optionView.nodeImgView setImage:[UIImage imageNamed:@"statusbar_download_node"]];
        } else {
            weakSelf.optionView.nodeBtn.enabled = NO;
            weakSelf.optionView.lblNode.textColor = [UIColor lightGrayColor];
            [weakSelf.optionView.nodeImgView setImage:[UIImage imageNamed:@"statusbar_download_node_backups"]];
        }
        [weakSelf.optionView showOptionEnumView];
    }];
    return myCell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.checkIndexPath = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PNFileModel *fileM = self.dataArray[indexPath.row];
    
    FilePreviewViewController *vc = [[FilePreviewViewController alloc] init];
    if (self.floderM.isLocal) {
        if (!fileM.fileData) {
            
            NSString *sql  = [NSString stringWithFormat:@"select %@ from %@ where %@=%@",bg_sqlKey(@"fileData"),EN_FILE_TABNAME,bg_sqlKey(@"fId"),bg_sqlValue(@(fileM.fId))];
            NSArray *results = bg_executeSql(sql, EN_FILE_TABNAME,[PNFileModel class]);
            
            if (results && results.count > 0) {
                PNFileModel *fileModel = results[0];
                fileM.fileData = fileModel.fileData;
            }
        }
        vc.fileType = LocalPhotoFile;
        vc.localFileData = fileM.fileData;
    } else {
        vc.fileType = NodePhotoFile;
        vc.filePath = fileM.Paths;
    }
    
    vc.fileName = fileM.Fname;
    vc.userKey = fileM.FKey;
    vc.fileId = [NSString stringWithFormat:@"%ld",fileM.fId];
    vc.floderId = [NSString stringWithFormat:@"%ld",_floderM.fId];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

/// 本地文件夹列表文件上传到节点
/// @param floderId 节点文件夹 id
- (void) uploadNodeWithFloderId:(NSInteger) floderId
{
    NSString *fileName = self.selFileM.Fname;
    
    if (!self.selFileM.fileData) {
    
        NSString *sql  = [NSString stringWithFormat:@"select %@ from %@ where %@=%@",bg_sqlKey(@"fileData"),EN_FILE_TABNAME,bg_sqlKey(@"fId"),bg_sqlValue(@(self.selFileM.fId))];
        NSArray *results = bg_executeSql(sql, EN_FILE_TABNAME,[PNFileModel class]);
    
        if (results && results.count > 0) {
            PNFileModel *fileModel = results[0];
            self.selFileM.fileData = fileModel.fileData;
        
        }
    }
    NSData *fileData = self.selFileM.fileData;
    int fileType = (int)self.selFileM.Type;
    
    if ([SystemUtil isSocketConnect]) { // socket
        // 更新状态
        self.selFileM.uploadStatus = 1;
        [_mainTabView reloadData];
                   
        SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
        dataUtil.srcKey = self.selFileM.FKey;
        dataUtil.fileid = [NSString stringWithFormat:@"%ld",(long)self.selFileM.fId];
        dataUtil.isPhoto = YES;
        dataUtil.floderId = floderId;
        NSString *fileNameInfo = @"";
        if (self.selFileM.Finfo.length > 0) {
            fileNameInfo = [NSString stringWithFormat:@"%@,%@",fileName,self.selFileM.Finfo];
        } else {
            fileNameInfo = fileName;
        }
        [dataUtil sendFileId:@"" fileName:fileNameInfo fileData:fileData fileid:self.selFileM.fId fileType:fileType messageid:@"" srcKey:self.selFileM.FKey dstKey:@"" isGroup:NO];
        [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
                   
    }
}

/// 上传文件到节点文件夹
/// @param fileModel 文件模型
- (void) uploadPhotoToNodeFloderWithFileM:(PNFileModel *) fileModel
{
    NSString *fileName = fileModel.Fname;
    NSData *fileData = fileModel.fileData;
    int fileType = (int)fileModel.Type;
    
    if ([SystemUtil isSocketConnect]) { // socket

        SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
        dataUtil.srcKey = fileModel.FKey;
        dataUtil.fileid = [NSString stringWithFormat:@"%ld",(long)fileModel.fId];
        dataUtil.isPhoto = YES;
        dataUtil.floderId = fileModel.PathId;
        NSString *fileNameInfo = @"";
        if (fileModel.Finfo.length > 0) {
            fileNameInfo = [NSString stringWithFormat:@"%@,%@",fileName,fileModel.Finfo];
        } else {
            fileNameInfo = fileName;
        }
        [dataUtil sendFileId:@"" fileName:fileNameInfo fileData:fileData fileid:fileModel.fId fileType:fileType messageid:@"" srcKey:fileModel.FKey dstKey:@"" isGroup:NO];
        [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
        
        [FIRAnalytics logEventWithName:kFIREventSelectContent
        parameters:@{
                     kFIRParameterItemID:FIR_FLODER_UPLOAD_FILE,
                     kFIRParameterItemName:FIR_FLODER_UPLOAD_FILE,
                     kFIRParameterContentType:FIR_FLODER_UPLOAD_FILE
                     }];
                   
    }
}

#pragma mark----------------通知
- (void) photoUploadFileDataNoti:(NSNotification *) noti
{
    PNFileUploadModel *uplodFileM = noti.object;
    if (self.floderM.isLocal) { // 本地
        if (uplodFileM.retCode != 0) {
            for (int i = 0; i<self.dataArray.count; i++) {
                PNFileModel *fileM = self.dataArray[i];
                if (fileM.fId == uplodFileM.fileId) {
                    fileM.uploadStatus = -1;
                    fileM.progressV = 0;
                    [_mainTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    break;
                }
            }
        }
           
    } else {
        if (uplodFileM.floderId == self.floderM.fId) { // 节点
            
        }
    }
}
- (void) fileUploadSuccessNoti:(NSNotification *) noti
{
    NSDictionary *resultDic = noti.object;
    NSInteger retCode = [resultDic[@"RetCode"] integerValue];
    NSInteger srcFileID = [resultDic[@"SrcId"] integerValue];
    
    if (self.floderM.isLocal) {
        for (int i = 0; i<self.dataArray.count; i++) {
            PNFileModel *fileM = self.dataArray[i];
            if (fileM.fId == srcFileID) {
                if (retCode == 0) {
                    fileM.uploadStatus = 2;
                } else {
                    fileM.uploadStatus = -1;
                }
                fileM.progressV = 0;
                [_mainTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    } else {
        
        NSInteger floderId = [resultDic[@"PathId"] integerValue];
        //NSInteger fileID = [resultDic[@"FileId"] integerValue];
        
        if (floderId == self.floderM.fId) {
            
            [SendRequestUtil sendPullFloderFileListWithFloderType:1 floderId:self.floderM.fId floderName:self.floderM.PathName sortType:1 startId:0 num:500 showHud:NO];
                
//                NSString *PathName = resultDic[@"PathName"];
//                NSString *FilePath = resultDic[@"FilePath"];
//                NSString *Fname = resultDic[@"Fname"];
//                NSInteger fileID = [resultDic[@"FileId"] integerValue];
                
                
                
        //        PNFileModel *fileM = [[PNFileModel alloc] init];
        //        fileM.PathId = floderId;
        //        fileM.fId = fileID;
        //        fileM.Fname = Fname;
        //        fileM.
        }
    }
}
- (void) filePullSuccessNoti:(NSNotification *) noti
{
    NSDictionary *resultDic = noti.object;
    NSString *jsonStr = resultDic[@"Payload"]?:@"";
    NSArray *fileArr = [PNFileModel mj_objectArrayWithKeyValuesArray:jsonStr.mj_JSONObject]?:nil;
    if (fileArr) {
        if (self.dataArray.count > 0) {
            [self.dataArray removeAllObjects];
        }
        [self.dataArray addObjectsFromArray:fileArr];
        [self.mainTabView reloadData];
    }
}
- (void) delFileSuccessNoti:(NSNotification *) noti
{
    NSDictionary *responDic = noti.object?:@{};
    NSInteger fileId = [responDic[@"FileId"] integerValue];
    if (fileId <= 0) {
        return;
    }
    NSInteger react = [responDic[@"React"] integerValue];
    if (react == 1){ // 重命名
        self.selFileM.Fname = responDic[@"Name"];
    } else if (react == 2) {
        [self.dataArray removeObject:self.selFileM];
    }
    
    [_mainTabView reloadData];
}
- (void) selectFloderSuccessNoti:(NSNotification *) noti
{
    PNFloderModel *selFloderM = noti.object;
    [self uploadNodeWithFloderId:selFloderM.fId];
}

- (void) uploadProgressNoti:(NSNotification *) noti
{
    PNFileUploadModel *uploadFileM = noti.object;
    for (int i = 0; i<self.dataArray.count; i++) {
        PNFileModel *fileM = self.dataArray[i];
        if (fileM.fId == uploadFileM.fileId) {
            fileM.progressV = uploadFileM.progress;
            [_mainTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
    }
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
    imagePickerVc.allowPickingMultipleVideo = YES; //是否可以多选视频
    
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
            weakSelf.selFileCount = assets.count;
            weakSelf.finshFileCount = 0;
            [weakSelf.view showHudInView:weakSelf.view hint:Uploading_Str];
            [assets enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                PHAsset *asset = obj;
                NSString *fName = [asset valueForKey:@"filename"];
                NSLog(@"filename = %@",fName);
                if (asset.mediaType == 1) { // 图片
                    UIImage *img = photos[idx];
                    NSData *imgData = UIImageJPEGRepresentation(img,1.0);
                   
                    [weakSelf sendImgageWithImage:img imgData:imgData imgName:fName];
                    
                } else if (asset.mediaType == 2) { // 视频
                    [weakSelf getPHAssetVedioWithOverImg:photos[idx] phAsset:asset fName:fName isLast:idx == assets.count-1];
                }
            }];
            
            /**
                * 该方法是异步执行的，不会阻塞当前线程，而且执行完后会来到
                * completionHandler 的 block 中。
            */
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest deleteAssets:assets];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                NSLog(@"----success----");
            }];
        }
    }];
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
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
 得到选中的图片并发送

 @param img 图片
 @param imgData 图片data
 */
- (void) sendImgageWithImage:(UIImage *) img imgData:(NSData *) imgData imgName:(NSString *) imgName
{
   
    // 生成32位对称密钥
    NSString *msgKey = [SystemUtil get32AESKey];
    NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
    NSString *symmetKey = [symmetData base64EncodedString];
    // 自己公钥加密对称密钥
    NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
    
    NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
    imgData = aesEncryptData(imgData,msgKeyData);
    
    PNFileModel *fileM = [[PNFileModel alloc] init];
    fileM.PathId = _floderM.fId;
    fileM.toFloderId = _floderM.fId;
    _autoNum += 1;
    fileM.fId = [NSDate getTimestampFromDate:[NSDate date]]+_autoNum+(arc4random()%100);
    fileM.Fname = imgName;
    fileM.Size = imgData.length;
    fileM.FKey = srcKey;
    fileM.delHidden = 0;
    fileM.fileData = imgData;
    fileM.smallData = [img compressWithMaxLength:10*1024];
    fileM.LastModify = [NSDate getTimestampFromDate:[NSDate date]];
    fileM.Depens = 1;
    fileM.Type = 1;
    fileM.Finfo = [NSString stringWithFormat:@"%f*%f",img.size.width,img.size.height];
    fileM.bg_tableName = EN_FILE_TABNAME;
    if (!self.floderM.isLocal) {
        fileM.uploadStatus = 1;
    }
    @weakify_self
    [fileM bg_saveAsync:^(BOOL isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (isSuccess) {
                
                weakSelf.finshFileCount ++;
                if (weakSelf.finshFileCount == weakSelf.selFileCount) {
                    [weakSelf.view hideHud];
                    if (!weakSelf.floderM.isLocal) {
                         [weakSelf.view showHint:@"Added to the task list."];
                    }
                }
                
                if (weakSelf.floderM.isLocal) {
                    [weakSelf.dataArray insertObject:fileM atIndex:0];
                    [weakSelf.mainTabView reloadData];
                } else {
                    [weakSelf uploadPhotoToNodeFloderWithFileM:fileM];
                }
            } else {
                weakSelf.selFileCount--;
            }
        });
    }];
}

/**
 得到选择的视频
 
 @param coverImage 视频封面图
 @param phAsset phasset
 */
- (void) getPHAssetVedioWithOverImg:(UIImage *) coverImage phAsset:(PHAsset *)phAsset fName:(NSString *) fName isLast:(BOOL) isLast
{
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    @weakify_self
    [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
        if ([avAsset isKindOfClass:[AVURLAsset class]]) {
            AVURLAsset* urlAsset = (AVURLAsset*)avAsset;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf extractedVideWithAsset:urlAsset evImage:coverImage fName:fName];
            });
            /*
            NSNumber *size;
            [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
            CGFloat sizeMB = [size floatValue]/(1024.0*1024.0);
            if (sizeMB <= 100) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf extractedVideWithAsset:urlAsset evImage:coverImage fName:fName];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [AppD.window showHint:@"Video cannot be larger than 100MB"];
                    weakSelf.selFileCount--;
                    if (isLast) {
                        [weakSelf.view hideHud];
                    }
                });
            }*/
        }}];
}

/**
 导出视频并发送
 @param asset asset
 @param evImage 封面图
 */
- (void)extractedVideWithAsset:(AVURLAsset *)asset evImage:(UIImage *) evImage fName:(NSString *) fName
{
    NSData *attData = [NSData dataWithContentsOfURL:asset.URL];
   // NSString *attName = [asset.URL lastPathComponent];
    
    // 生成32位对称密钥
    NSString *msgKey = [SystemUtil get32AESKey];
    NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
    NSString *symmetKey = [symmetData base64EncodedString];
    // 自己公钥加密对称密钥
    NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
    
    NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
    attData = aesEncryptData(attData,msgKeyData);
    
    PNFileModel *fileM = [[PNFileModel alloc] init];
    fileM.PathId = _floderM.fId;
    fileM.toFloderId = _floderM.fId;
    fileM.fId = [NSDate getTimestampFromDate:[NSDate date]];
    fileM.Fname = fName;
    fileM.Size = attData.length;
    fileM.delHidden = 0;
    fileM.Type = 4;
    fileM.FKey = srcKey;
    fileM.fileData = attData;
    fileM.smallData = [evImage compressWithMaxLength:10*1024];
    fileM.Depens = 1;
    fileM.Finfo = [NSString stringWithFormat:@"%f*%f",evImage.size.width,evImage.size.height];
    fileM.bg_tableName = EN_FILE_TABNAME;
    if (!self.floderM.isLocal) {
        fileM.uploadStatus = 1;
    }
    @weakify_self
    [fileM bg_saveAsync:^(BOOL isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (isSuccess) {
                weakSelf.finshFileCount ++;
                if (weakSelf.finshFileCount == weakSelf.selFileCount) {
                    [weakSelf.view hideHud];
                    if (!weakSelf.floderM.isLocal) {
                         [weakSelf.view showHint:@"Added to the task list."];
                    }
                }
                if (weakSelf.floderM.isLocal) {
                    [weakSelf.dataArray insertObject:fileM atIndex:0];
                    [weakSelf.mainTabView reloadData];
                } else {
                     [weakSelf uploadPhotoToNodeFloderWithFileM:fileM];
                }
            } else {
                weakSelf.selFileCount--;
            }
        });
    }];
   
}




#pragma mark----------修改文件名---------------
- (void) updateFileWithName:(NSString *) fileName
{
    if (self.floderM.isLocal) {
        NSArray *names = [self.selFileM.Fname componentsSeparatedByString:@"."];
        NSString *fileTypeName = fileName;
        if (names.count >=2) {
            fileTypeName = names[1];
            fileTypeName = [fileName stringByAppendingFormat:@".%@", fileTypeName];
        }
        
        self.selFileM.Fname = fileTypeName;
        [PNFileModel bg_update:EN_FILE_TABNAME where:[NSString stringWithFormat:@"set %@=%@ where %@=%@",bg_sqlKey(@"Fname"),bg_sqlValue(self.selFileM.Fname),bg_sqlKey(@"fId"),bg_sqlValue(@(self.selFileM.fId))]];
        [_mainTabView reloadData];
    } else {
        NSString *oldName = [Base58Util Base58DecodeWithCodeName:self.selFileM.Fname];
        NSArray *names = [oldName componentsSeparatedByString:@"."];
        NSString *fileTypeName = fileName;
        if (names.count >=2) {
            fileTypeName = names[1];
            fileTypeName = [fileName stringByAppendingFormat:@".%@", fileTypeName];
        }
        [SendRequestUtil sendUpdateloderWithFloderType:1 updateType:1 react:1 name:[Base58Util Base58EncodeWithCodeName:fileTypeName] oldName:self.selFileM.Fname fid:self.selFileM.fId pathid:self.floderM.fId showHud:YES];
    }
}

#pragma mark ---点击键盘done
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *floderName = [NSString trimWhitespace:textField.text];
    if (floderName.length == 0) {
        [AppD.window showMiddleHint:@"The name cannot be empty."];
        return NO;
    }
    textField.text = @"";
    [self updateFileWithName:floderName];
    return [self.keyHeadView.floderTF resignFirstResponder];
}
#pragma mark ----KeyboardWillShowNotification
- (void) KeyboardWillShowNotification:(NSNotification *) notification
{
    if (_keyHeadView) {
        self.view.userInteractionEnabled = NO;
        NSDictionary *userInfo = [notification userInfo];
        CGFloat duration = [[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
        CGRect rect = [[userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];
        
        [UIView animateWithDuration:duration animations:^{
            self.keyHeadView.frame = CGRectMake(0, rect.origin.y-163, SCREEN_WIDTH, 163);
        }];
    }
    
}
- (void) KeyboardWillHideNotification:(NSNotification *) notification
{
    if (_keyHeadView) {
        NSDictionary *userInfo = [notification userInfo];
        CGFloat duration = [[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
        
        [UIView animateWithDuration:duration animations:^{
            self.keyHeadView.frame = CGRectMake(0,SCREEN_HEIGHT, SCREEN_WIDTH, 163);
        } completion:^(BOOL finished) {
            self.view.userInteractionEnabled = YES;
            [self.keyHeadView removeFromSuperview];
        }];
    }
}






#pragma mark - 创建悬浮的按钮

- (void)createButton{

    _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addBtn setImage:[UIImage imageNamed:@"upload_hover"] forState:UIControlStateNormal];
    _addBtn.frame = CGRectMake(SCREEN_WIDTH - 93, SCREEN_HEIGHT - 96, 93, 96);
    [_addBtn addTarget:self action:@selector(clickAddAction:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_addBtn];

    //放一个拖动手势，用来改变控件的位置
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changePostion:)];
    [_addBtn addGestureRecognizer:pan];

}

//手势事件 －－ 改变位置

-(void)changePostion:(UIPanGestureRecognizer *)pan{

    CGPoint point = [pan translationInView:_addBtn];

    CGFloat width = [UIScreen mainScreen].bounds.size.width;

    CGFloat height = [UIScreen mainScreen].bounds.size.height;

    CGRect originalFrame = _addBtn.frame;

    if (originalFrame.origin.x >= 0 && originalFrame.origin.x+originalFrame.size.width <= width) {
        originalFrame.origin.x += point.x;
    }
    
    if (originalFrame.origin.y >= 0 && originalFrame.origin.y+originalFrame.size.height <= height) {
        originalFrame.origin.y += point.y;
    }

    _addBtn.frame = originalFrame;

    [pan setTranslation:CGPointZero inView:_addBtn];

    if (pan.state == UIGestureRecognizerStateBegan) {

        _addBtn.enabled = NO;

    }else if (pan.state == UIGestureRecognizerStateChanged){

    } else {

        CGRect frame = _addBtn.frame;

        //是否越界

        BOOL isOver = NO;

        if (frame.origin.x < 0) {

            frame.origin.x = 0;

            isOver = YES;

        } else if (frame.origin.x+frame.size.width > width) {

            frame.origin.x = width - frame.size.width;

            isOver = YES;

        }if (frame.origin.y < 0) {

            frame.origin.y = 0;

            isOver = YES;

        } else if (frame.origin.y+frame.size.height > height) {

            frame.origin.y = height - frame.size.height;

            isOver = YES;

        }if (isOver) {
            @weakify_self
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.addBtn.frame = frame;
            }];

        }
        _addBtn.enabled = YES;
    }

}

@end
