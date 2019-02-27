//
//  FileViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "FileViewController.h"
//#import "FileCell.h"
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
#import "MyFilesCell.h"
#import <MJRefresh/MJRefresh.h>
#import <MJRefresh/MJRefreshStateHeader.h>
#import <MJRefresh/MJRefreshHeader.h>
#import "PNRouter-Swift.h"
#import "FilePreviewDownloadViewController.h"
#import "FileDownUtil.h"

typedef enum : NSUInteger {
    FileTableTypeNormal,
    FileTableTypeSearch,
} FileTableType;

@interface FileViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource/*, SWTableViewCellDelegate*/>

//@property (weak, nonatomic) IBOutlet UILabel *fontLab;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (nonatomic, strong) NSMutableArray *searchArr;
@property (nonatomic, strong) NSArray *showArr;
//@property (nonatomic) FileTableType fileTableType;
@property (nonatomic) MyFilesTableType myFilesTableType;
@property (nonatomic ,strong) FileListModel *selectModel;

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
    
    _mainTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(sendPullFileList)];
    // Hide the time
    ((MJRefreshStateHeader *)_mainTable.mj_header).lastUpdatedTimeLabel.hidden = YES;
    // Hide the status
    ((MJRefreshStateHeader *)_mainTable.mj_header).stateLabel.hidden = YES;
    [_mainTable registerNib:[UINib nibWithNibName:MyFilesCellReuse bundle:nil] forCellReuseIdentifier:MyFilesCellReuse];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 刷新
    [self sendPullFileList];
}

#pragma mark - Operation

- (void)refreshTable {
    if (_myFilesTableType == MyFilesTableTypeNormal) {
        _showArr = _sourceArr;
    } else if (_myFilesTableType == MyFilesTableTypeSearch) {
        _showArr = _searchArr;
    }
    
    [_mainTable reloadData];
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
    FileMoreAlertView *view = [FileMoreAlertView getInstance];
    @weakify_self
    [view setSendB:^{
        if (model.localPath == nil) {
            [AppD.window showHint:@"Please download first"];
        } else {
            
        }
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
        
    }];
    [view setDeleteB:^{
        [weakSelf deleteFileWithModel:model];
    }];
    
    NSString *fileNameBase58 = model.FileName.lastPathComponent;
    NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58]?:@"";
    [view showWithFileName:fileName fileType:model.FileType];
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
    return _showArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MyFilesCellHeight;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MyFilesCell *cell = [tableView dequeueReusableCellWithIdentifier:MyFilesCellReuse];
    
    FileListModel *model = _showArr[indexPath.row];

    [cell configCellWithModel:model];
    @weakify_self
    [cell setMoreB:^{
        [weakSelf showFileMoreAlertView:model];
    }];
    
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

- (void)jumpToMyFile {
    MyFilesViewController *vc = [[MyFilesViewController alloc] init];
    vc.filesType = FilesTypeAll;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToDocumentShare {
    MyFilesViewController *vc = [[MyFilesViewController alloc] init];
    vc.filesType = FilesTypeSent;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToDocumentReceived {
    MyFilesViewController *vc = [[MyFilesViewController alloc] init];
    vc.filesType = FilesTypeReceived;
    [self.navigationController pushViewController:vc animated:YES];
}

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
- (void)pullFileListCompleteNoti:(NSNotification *)noti {
    [_mainTable.mj_header endRefreshing];
    NSDictionary *receiveDic = noti.object;
    NSString *Payload = receiveDic[@"params"][@"Payload"];
    NSArray *payloadArr = [FileListModel mj_objectArrayWithKeyValuesArray:Payload.mj_JSONObject];
    if (payloadArr == nil || payloadArr.count <= 0) {
//        [self showEmptyView];
        [_sourceArr removeAllObjects];
        [self refreshTable];
    } else {
//        [self hideEmptyView];
        
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
                [weakSelf.mainTable deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
