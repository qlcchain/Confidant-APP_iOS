//
//  MyFilesViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#warning MyFilesViewController已废弃

#import "MyFilesViewController.h"
#import "MyFilesCell.h"
#import "DetailInformationViewController.h"
#import "FilePreviewViewController.h"
#import "ArrangeAlertView.h"
#import "FileMoreAlertView.h"
#import "FilePreviewDownloadViewController.h"
#import "UserConfig.h"
#import "FileListModel.h"
#import "NSDate+Category.h"
#import "OperationRecordModel.h"
#import "PNRouter-Swift.h"
#import "UploadFileHelper.h"
#import <MJRefresh/MJRefresh.h>
#import <MJRefresh/MJRefreshStateHeader.h>
#import <MJRefresh/MJRefreshHeader.h>
#import "FileDownUtil.h"
#import "TaskListViewController.h"
#import "NSString+Base64.h"

@interface MyFilesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (nonatomic, strong) NSMutableArray *searchArr;
@property (nonatomic, strong) NSMutableArray *showArr;
@property (nonatomic) MyFilesTableType myFilesTableType;

@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIView *contentBack;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (nonatomic) ArrangeType arrangeType;
@property (nonatomic ,strong) FileListModel *selectModel;

@end

@implementation MyFilesViewController

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
    // Do any additional setup after loading the view from its nib.
    
    [self addObserve];
    [self dataInit];
   // [self viewInit];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //进入刷新状态
    [_mainTable.mj_header beginRefreshing];
}

#pragma mark - Operation
- (void)dataInit {
    _myFilesTableType = MyFilesTableTypeNormal;
    _searchBackView.layer.cornerRadius = 3.0f;
    _searchBackView.layer.masksToBounds = YES;
    [self addTFTarget];
    
    if (_filesType == FilesTypeAll) {
        _titleLab.text = @"All Files";
    } else if (_filesType == FilesTypeSent) {
        _titleLab.text = @"Files Sent";
    } else if (_filesType == FilesTypeReceived) {
        _titleLab.text = @"Files Received";
    }
    
    _sourceArr = [NSMutableArray array];
    _searchArr = [NSMutableArray array];
    _arrangeType = ArrangeTypeByName;
    _mainTable.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(sendPullFileList)];
    // Hide the time
    ((MJRefreshStateHeader *)_mainTable.mj_header).lastUpdatedTimeLabel.hidden = YES;
    // Hide the status
    ((MJRefreshStateHeader *)_mainTable.mj_header).stateLabel.hidden = YES;
    
    [_mainTable registerNib:[UINib nibWithNibName:MyFilesCellReuse bundle:nil] forCellReuseIdentifier:MyFilesCellReuse];
    
   
}

- (void)viewInit {
    [self showEmptyView];
    
}

- (void)refreshTable {
    if (_myFilesTableType == MyFilesTableTypeNormal) {
        _showArr = _sourceArr;
    } else if (_myFilesTableType == MyFilesTableTypeSearch) {
        _showArr = _searchArr;
    }
    
    [_mainTable reloadData];
}

- (void)showEmptyView {
    NSString *imgStr = @"";
    NSString *tipStr = @"";
    if (_filesType == FilesTypeAll) {
        imgStr = @"icon_documents_my_gray";
        tipStr = @"No document yet Come and upload it";
    } else if (_filesType == FilesTypeSent) {
        imgStr = @"icon_documents_share_gray";
        tipStr = @"No documents yet Share them";
    } else if (_filesType == FilesTypeReceived) {
        imgStr = @"icon_documents_received_gray";
        tipStr = @"No documents yet Let friends share";
    }
    
    [self showEmptyViewToView:_contentBack img:[UIImage imageNamed:imgStr] title:tipStr];
}

- (void)showArrangeAlertView {
    ArrangeAlertView *view = [ArrangeAlertView getInstance];
    @weakify_self
    [view setClickB:^(ArrangeType type) {
        weakSelf.arrangeType = type;
        if (type == ArrangeTypeByName) {
            [weakSelf.showArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                FileListModel *listM1 = obj1;
                NSString *fileName1 = [Base58Util Base58DecodeWithCodeName:listM1.FileName.lastPathComponent];
                FileListModel *listM2 = obj2;
                NSString *fileName2 = [Base58Util Base58DecodeWithCodeName:listM2.FileName.lastPathComponent];
                return [fileName1 compare:fileName2];
            }];
            [weakSelf refreshTable];
            
        } else if (type == ArrangeTypeByTime) {
            [weakSelf.showArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                FileListModel *listM1 = obj1;
                FileListModel *listM2 = obj2;
                return [listM1.Timestamp compare:listM2.Timestamp];
            }];
            [weakSelf refreshTable];
        } else if (type == ArrangeTypeBySize) {
            [weakSelf.showArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                FileListModel *listM1 = obj1;
                FileListModel *listM2 = obj2;
                return [listM1.FileSize compare:listM2.FileSize];
            }];
            [weakSelf refreshTable];
        } else if (type == ArrangeTypeByContact) {
            [weakSelf.showArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                FileListModel *listM1 = obj1;
                FileListModel *listM2 = obj2;
                return [[listM1.Sender base64DecodedString] compare:[listM2.Sender base64DecodedString]];
            }];
            [weakSelf refreshTable];
        }
    }];
    [view showWithArrange:_arrangeType];
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

#pragma mark -删除文件
- (void) deleteFileWithModel:(FileListModel *) model
{
    [SendRequestUtil sendDelFileWithUserId:[UserConfig getShareObject].userId FileName:model.FileName showHud:YES];
}

- (void)otherApplicationOpen:(NSURL *)fileURL {
    if (!fileURL) {
        return;
    }
    NSArray *items = @[fileURL];
    UIActivityViewController *activityController=[[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - Request
- (void)sendPullFileList {
    NSString *UserId = [UserConfig getShareObject].userId;
    NSNumber *MsgStartId = @(0);
    NSNumber *MsgNum = @(15);
    NSNumber *Category = @(3);
    if (_filesType == FilesTypeAll) {
        Category = @(0);
    } else if (_filesType == FilesTypeSent) {
        Category = @(1);
    } else if (_filesType == FilesTypeReceived) {
        Category = @(2);
    }
    NSNumber *FileType = @(0);
    
    [SendRequestUtil sendPullFileListWithUserId:UserId MsgStartId:MsgStartId MsgNum:MsgNum Category:Category FileType:FileType showHud:NO];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)uploadAction:(id)sender {
    UploadFileHelper *helper = [UploadFileHelper shareObject];
    [helper showUploadAlertView:self];
}

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

#pragma mark - Transition
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

- (void)jumpToTaskList {
    TaskListViewController *vc = [[TaskListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Noti
- (void)pullFileListCompleteNoti:(NSNotification *)noti {
     [_mainTable.mj_header endRefreshing];
    NSDictionary *receiveDic = noti.object;
    NSString *Payload = receiveDic[@"params"][@"Payload"];
    NSArray *payloadArr = [FileListModel mj_objectArrayWithKeyValuesArray:Payload.mj_JSONObject];
    if (payloadArr == nil || payloadArr.count <= 0) {
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

- (void)deleteFileCompleteNoti:(NSNotification *) noti {
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

@end
