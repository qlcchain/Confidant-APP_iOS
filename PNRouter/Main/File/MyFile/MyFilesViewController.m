//
//  MyFilesViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "MyFilesViewController.h"
#import "MyFilesCell.h"
#import "DetailInformationViewController.h"
#import "FilePreviewViewController.h"
#import "ArrangeAlertView.h"
#import "FileMoreAlertView.h"
#import "FilePreviewDownloadViewController.h"
#import "UserConfig.h"
#import "FileListModel.h"

@interface MyFilesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIView *contentBack;
@property (nonatomic) ArrangeType arrangeType;

@end

@implementation MyFilesViewController

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullFileListCompleteNoti:) name:PullFileList_Complete_Noti object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addObserve];
    [self dataInit];
    [self viewInit];
    [self sendPullFileList];
}

#pragma mark - Operation
- (void)dataInit {
    if (_filesType == FilesTypeMy) {
        _titleLab.text = @"My Files";
    } else if (_filesType == FilesTypeShare) {
        _titleLab.text = @"Documents I Share";
    } else if (_filesType == FilesTypeReceived) {
        _titleLab.text = @"Documents Received";
    }
    
    _sourceArr = [NSMutableArray array];
    _arrangeType = ArrangeTypeByName;
    
    [_mainTable registerNib:[UINib nibWithNibName:MyFilesCellReuse bundle:nil] forCellReuseIdentifier:MyFilesCellReuse];
}

- (void)viewInit {
    [self showEmptyView];
    
}

- (void)showEmptyView {
    NSString *imgStr = @"";
    NSString *tipStr = @"";
    if (_filesType == FilesTypeMy) {
        imgStr = @"icon_documents_my_gray";
        tipStr = @"No document yet Come and upload it";
    } else if (_filesType == FilesTypeShare) {
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
            [weakSelf.sourceArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                FileListModel *listM1 = obj1;
                FileListModel *listM2 = obj2;
                return [listM1.FileName compare:listM2.FileName];
            }];
            [weakSelf.mainTable reloadData];
            
        } else if (type == ArrangeTypeByTime) {
            [weakSelf.sourceArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                FileListModel *listM1 = obj1;
                FileListModel *listM2 = obj2;
                return [listM1.Timestamp compare:listM2.Timestamp];
            }];
            [weakSelf.mainTable reloadData];
        } else if (type == ArrangeTypeBySize) {
            [weakSelf.sourceArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                FileListModel *listM1 = obj1;
                FileListModel *listM2 = obj2;
                return [listM1.FileSize compare:listM2.FileSize];
            }];
            [weakSelf.mainTable reloadData];
        }
    }];
    [view showWithArrange:_arrangeType];
}

- (void)showFileMoreAlertView:(FileListModel *)model {
    FileMoreAlertView *view = [FileMoreAlertView getInstance];
    @weakify_self
    [view setSendB:^{
        
    }];
    [view setDownloadB:^{
        
    }];
    [view setOtherApplicationOpenB:^{
        [weakSelf otherApplicationOpen:[NSURL fileURLWithPath:@""]];
    }];
    [view setDetailInformationB:^{
        [weakSelf jumpToDetailInformation:model];
    }];
    [view setRenameB:^{
        
    }];
    [view setDeleteB:^{
        
    }];
    
    [view show];
}

- (void)otherApplicationOpen:(NSURL *)fileURL {
    NSArray *items = @[fileURL];
    UIActivityViewController *activityController=[[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
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

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)multiSelectAction:(id)sender {
    
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MyFilesCellHeight;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MyFilesCell *cell = [tableView dequeueReusableCellWithIdentifier:MyFilesCellReuse];
    
    FileListModel *model = _sourceArr[indexPath.row];
    [cell configCellWithModel:model];
    @weakify_self
    [cell setMoreB:^{
        [weakSelf showFileMoreAlertView:model];
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self jumpToFilePreviewDownload];
}

#pragma mark - Transition
- (void)jumpToDetailInformation:(FileListModel *)model  {
    DetailInformationViewController *vc = [[DetailInformationViewController alloc] init];
    vc.fileListM = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToFilePreviewDownload {
    FilePreviewDownloadViewController *vc = [[FilePreviewDownloadViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Noti
- (void)pullFileListCompleteNoti:(NSNotification *)noti {
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
        [_mainTable reloadData];
    }
}

@end
