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
#import "MyFilesViewController.h"
#import "SendRequestUtil.h"
#import "UserConfig.h"
#import "PNNavViewController.h"
#import "YWFilePreviewView.h"
#import "FilePreviewViewController.h"
#import "ChooseShareContactViewController.h"
#import "NSDate+Category.h"
#import "OperationRecordModel.h"
#import "FileMoreAlertView.h"
#import "FileListModel.h"
#import "DetailInformationViewController.h"
#import "UploadFileHelper.h"
//#import "MyFilesCell.h"
#import <MJRefresh/MJRefresh.h>
#import <MJRefresh/MJRefreshStateHeader.h>
#import <MJRefresh/MJRefreshHeader.h>
#import "PNRouter-Swift.h"
#import "FilePreviewDownloadViewController.h"
#import "FileDownUtil.h"
#import "ArrangeAlertView.h"
#import "NSString+Base64.h"
#import "ChooseContactViewController.h"
#import "FriendModel.h"
#import "LibsodiumUtil.h"
#import "FileRenameHelper.h"


typedef enum : NSUInteger {
    FileTableTypeNormal,
    FileTableTypeSearch,
} FileTableType;

@interface FileViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource/*, SWTableViewCellDelegate*/>
{
    BOOL isFristLoad;
}

//@property (weak, nonatomic) IBOutlet UILabel *fontLab;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (weak, nonatomic) IBOutlet UIView *contentBack;
@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (nonatomic, strong) NSMutableArray *searchArr;
@property (nonatomic, strong) NSMutableArray *showArr;
//@property (nonatomic) FileTableType fileTableType;
@property (nonatomic) MyFilesTableType myFilesTableType;
@property (nonatomic ,strong) FileListModel *selectModel;
@property (nonatomic) ArrangeType arrangeType;

@end

@implementation FileViewController

- (void)viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [super viewWillAppear:animated];
}

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullFileListCompleteNoti:) name:PullFileList_Complete_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteFileCompleteNoti:) name:Delete_File_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileRenameSuccessNoti:) name:FileRename_Success_Noti object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileForwardNoti:) name:CHOOSE_FRIEND_NOTI object:nil];
    
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
    [self addTFTarget];
    
//    _fileTableType = FileTableTypeNormal;
    _myFilesTableType = MyFilesTableTypeNormal;
    _sourceArr = [NSMutableArray array];
    _searchArr = [NSMutableArray array];
    _arrangeType = ArrangeTypeByName;
    
    _mainTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(sendPullFileList)];
    // Hide the time
    ((MJRefreshStateHeader *)_mainTable.mj_header).lastUpdatedTimeLabel.hidden = YES;
    // Hide the status
    ((MJRefreshStateHeader *)_mainTable.mj_header).stateLabel.hidden = YES;
    [_mainTable registerNib:[UINib nibWithNibName:FileCellReuse bundle:nil] forCellReuseIdentifier:FileCellReuse];
    
    isFristLoad = YES;
     [_mainTable.mj_header beginRefreshing];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 刷新
    if (isFristLoad) {
        isFristLoad = NO;
    } else {
        [self sendPullFileList];
    }
}

#pragma mark - Operation

- (void)refreshTable {
    if (_myFilesTableType == MyFilesTableTypeNormal) {
        _showArr = _sourceArr;
    } else if (_myFilesTableType == MyFilesTableTypeSearch) {
        _showArr = _searchArr;
    }
    
    [self refreshTableWithArrange];
}

#pragma mark -删除文件
- (void) deleteFileWithModel:(FileListModel *) model {
    [SendRequestUtil sendDelFileWithUserId:[UserConfig getShareObject].userId FileName:model.FileName showHud:YES];
}

- (void)otherApplicationOpen:(NSURL *)fileURL {
    NSArray *items = @[fileURL];
    UIActivityViewController *activityController=[[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

- (void)showFileMoreAlertView:(FileListModel *)model {
    self.selectModel = model;
    NSString *fileNameBase58 = model.FileName.lastPathComponent;
    NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58]?:@"";
    
    FileMoreAlertView *view = [FileMoreAlertView getInstance];
    @weakify_self
    [view setSendB:^{
        [weakSelf jumpForwardVC];
    }];
    [view setDownloadB:^{
        [FileDownUtil downloadFileWithFileModel:model];
        [weakSelf jumpToTaskList];
    }];
    [view setOtherApplicationOpenB:^{
        if (model.localPath == nil) {
            [AppD.window showHint:@"Please download first"];
        } else {
            [weakSelf otherApplicationOpen:[NSURL fileURLWithPath:model.localPath]];
        }
    }];
    [view setDetailInformationB:^{
        [weakSelf jumpToDetailInformation:model];
    }];
    [view setRenameB:^{
        [FileRenameHelper showRenameViewWithModel:model vc:weakSelf];
    }];
    [view setDeleteB:^{
        [weakSelf deleteFileWithModel:model];
    }];
    
    [view showWithFileName:fileName fileType:model.FileType];
}


- (void)showArrangeAlertView {
    ArrangeAlertView *view = [ArrangeAlertView getInstance];
    @weakify_self
    [view setClickB:^(ArrangeType type) {
        weakSelf.arrangeType = type;
        [weakSelf refreshTableWithArrange];
    }];
    [view showWithArrange:_arrangeType];
}

- (void)refreshTableWithArrange {
    if (_arrangeType == ArrangeTypeByName) {
        [self.showArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            FileListModel *listM1 = obj1;
            NSString *fileName1 = [Base58Util Base58DecodeWithCodeName:listM1.FileName.lastPathComponent];
            FileListModel *listM2 = obj2;
            NSString *fileName2 = [Base58Util Base58DecodeWithCodeName:listM2.FileName.lastPathComponent];
            return [fileName1 compare:fileName2];
        }];
        [_mainTable reloadData];
        
    } else if (_arrangeType == ArrangeTypeByTime) {
        [self.showArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            FileListModel *listM1 = obj1;
            FileListModel *listM2 = obj2;
            return [listM2.Timestamp compare:listM1.Timestamp];
        }];
        [_mainTable reloadData];
    } else if (_arrangeType == ArrangeTypeBySize) {
        [self.showArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            FileListModel *listM1 = obj1;
            FileListModel *listM2 = obj2;
            return [listM1.FileSize compare:listM2.FileSize];
        }];
        [_mainTable reloadData];
    } else if (_arrangeType == ArrangeTypeByContact) {
        [self.showArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            FileListModel *listM1 = obj1;
            FileListModel *listM2 = obj2;
            return [[listM1.Sender base64DecodedString] compare:[listM2.Sender base64DecodedString]];
        }];
        [_mainTable reloadData];
    }
    
    if (_showArr.count <= 0) {
        [self showEmptyView];
    }
}

- (void)showEmptyView {
    NSString *imgStr = @"icon_documents_received_gray";
    NSString *tipStr = @"No documents yet Let friends share";
    [self showEmptyViewToView:_contentBack img:[UIImage imageNamed:imgStr] title:tipStr];
}

#pragma mark - Request
- (void)sendPullFileList {
    NSString *UserId = [UserConfig getShareObject].userId;
    NSNumber *MsgStartId = @(0);
    NSNumber *MsgNum = @(15);
    NSNumber *Category = @(0); // ALL
    NSNumber *FileType = @(0);
    
    [SendRequestUtil sendPullFileListWithUserId:UserId MsgStartId:MsgStartId MsgNum:MsgNum Category:Category FileType:FileType showHud:NO];
}

#pragma mark - Action

- (IBAction)taskAction:(id)sender {
    [self jumpToTaskList];
}

- (IBAction)uploadAction:(id)sender {
    UploadFileHelper *helper = [UploadFileHelper shareObject];
    [helper showUploadAlertView:self];
}

//- (IBAction)myFileAction:(id)sender {
//    [self jumpToMyFile];
//}
//
//- (IBAction)shareAction:(id)sender {
//    [self jumpToDocumentShare];
//}
//
//- (IBAction)receiveAction:(id)sender {
//    [self jumpToDocumentReceived];
//}

- (IBAction)arrangeAction:(id)sender {
    [self showArrangeAlertView];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _showArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FileCellHeight;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FileCell *cell = [tableView dequeueReusableCellWithIdentifier:FileCellReuse];
    
    FileListModel *model = _showArr[indexPath.row];

    [cell configCellWithModel:model];
    @weakify_self
    cell.fileMoreB = ^{
        [weakSelf showFileMoreAlertView:model];
    };
    cell.fileForwardB = ^{
        weakSelf.selectModel = model;
        [weakSelf jumpForwardVC];
    };
    cell.fileDownloadB = ^{
//        [FileDownUtil downloadFileWithFileModel:model];
//        [weakSelf jumpToTaskList];
        [weakSelf jumpToFilePreviewDownload:model];
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    FileListModel *model = _showArr[indexPath.row];
    [self jumpToFilePreviewDownload:model];
}

#pragma mark -
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
//    UIImage *img = info[UIImagePickerControllerOriginalImage];
//    NSData *imgData = UIImageJPEGRepresentation(img,1.0);
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextField Add Target
- (void)addTFTarget {
    [_searchTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldTextChange:(UITextField *)tf {
    if (tf == _searchTF) {
        [self refreshTableByTF:tf];
    }
}

- (void)refreshTableByTF:(UITextField *)tf {
    if ([tf.text.trim isEmptyString]) {
        _myFilesTableType = MyFilesTableTypeNormal;
    } else {
        _myFilesTableType = MyFilesTableTypeSearch;
        [_searchArr removeAllObjects];
        @weakify_self
        [_sourceArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FileListModel *model = obj;
            NSString *fileNameBase58 = model.FileName.lastPathComponent;
            NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58];
            if ([fileName containsString:tf.text.trim]) {
                [weakSelf.searchArr addObject:model];
            }
        }];
    }
    [self refreshTable];
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
- (void) jumpForwardVC
{
    ChooseContactViewController *vc = [[ChooseContactViewController alloc] init];
    [self presentModalVC:vc animated:YES];
}

//- (void)jumpToMyFile {
//    MyFilesViewController *vc = [[MyFilesViewController alloc] init];
//    vc.filesType = FilesTypeAll;
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
//- (void)jumpToDocumentShare {
//    MyFilesViewController *vc = [[MyFilesViewController alloc] init];
//    vc.filesType = FilesTypeSent;
//    [self.navigationController pushViewController:vc animated:YES];
//}
//
//- (void)jumpToDocumentReceived {
//    MyFilesViewController *vc = [[MyFilesViewController alloc] init];
//    vc.filesType = FilesTypeReceived;
//    [self.navigationController pushViewController:vc animated:YES];
//}

- (void)jumpToDetailInformation:(FileListModel *)model  {
    DetailInformationViewController *vc = [[DetailInformationViewController alloc] init];
    vc.fileListM = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToFilePreviewDownload:(FileListModel *)model {
    FilePreviewDownloadViewController *vc = [[FilePreviewDownloadViewController alloc] init];
    vc.fileListM = model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Noti
- (void)fileForwardNoti:(NSNotification *)noti {
    NSArray *modeArray = (NSArray *)noti.object;
    @weakify_self
    [modeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        // 自己私钥解密对称密钥
        NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:weakSelf.selectModel.UserKey];
         // 好友公钥加密对称密钥
        NSString *fileKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:datakey enPK:model.publicKey];
        
        [SendRequestUtil sendFileForwardMsgid:[NSString stringWithFormat:@"%@",weakSelf.selectModel.MsgId] toid:model.userId?:@"" fileName:weakSelf.selectModel.FileName filekey:fileKey?:@"" fileInfo:weakSelf.selectModel.FileInfo];
    }];
}
- (void)pullFileListCompleteNoti:(NSNotification *)noti {
    [_mainTable.mj_header endRefreshing];
    NSDictionary *receiveDic = noti.object;
    NSString *Payload = receiveDic[@"params"][@"Payload"];
    NSArray *payloadArr = [FileListModel mj_objectArrayWithKeyValuesArray:Payload.mj_JSONObject];
    if (payloadArr == nil || payloadArr.count <= 0) {
        [_sourceArr removeAllObjects];
        [self refreshTable];
        
        [self showEmptyView];
    } else {
        [self hideEmptyView];
        
        NSMutableArray *tempArr = [NSMutableArray array];
        [payloadArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FileListModel *model = obj;
            model.showSelect = NO;
            model.isSelect = NO;
            [tempArr addObject:model];
        }];
        
        [_sourceArr removeAllObjects];
        [_sourceArr addObjectsFromArray:tempArr];
        
        [self refreshTable];
    }
}

- (void)deleteFileCompleteNoti:(NSNotification *)noti {
    @weakify_self
    [_sourceArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FileListModel *model = obj;
        if ([model.MsgId integerValue] == [weakSelf.selectModel.MsgId integerValue]) {
            [weakSelf.sourceArr removeObject:model];
            if (weakSelf.myFilesTableType == MyFilesTableTypeNormal) {
//                [weakSelf.mainTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                [weakSelf refreshTable];
            } else if (weakSelf.myFilesTableType == MyFilesTableTypeSearch) {
                [weakSelf refreshTableByTF:weakSelf.searchTF];
            }
            
            // 删除成功-保存操作记录
            NSInteger timestamp = [NSDate getTimestampFromDate:[NSDate date]];
            NSString *operationTime = [NSDate getTimeWithTimestamp:[NSString stringWithFormat:@"%@",@(timestamp)] format:@"yyyy-MM-dd HH:mm:ss" isMil:NO];
            NSString *fileName = [Base58Util Base58DecodeWithCodeName:model.FileName.lastPathComponent];
            [OperationRecordModel saveOrUpdateWithFileType:model.FileType operationType:@(2) operationTime:operationTime operationFrom:[UserConfig getShareObject].userName operationTo:@"" fileName:fileName routerPath:model.FileName?:@"" localPath:@"" userId:[UserConfig getShareObject].userId];
            
            *stop = YES;
        }
    }];
}

- (void)fileRenameSuccessNoti:(NSNotification *)noti {
    NSDictionary *receiveDic = noti.object;
    NSInteger MsgId = [receiveDic[@"params"][@"MsgId"] integerValue];
    NSString *Filename = receiveDic[@"params"][@"Filename"];
    
    [_showArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FileListModel *model = obj;
        if ([model.MsgId integerValue] == MsgId) {
            model.FileName = [model.FileName stringByReplacingOccurrencesOfString:model.FileName.lastPathComponent withString:Filename];
            *stop = YES;
        }
    }];
    [self refreshTable];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
