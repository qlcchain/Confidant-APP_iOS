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
@property (nonatomic) FileTableType fileTableType;

@end

@implementation FileViewController

- (void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [super viewWillAppear:animated];
}
#pragma mark - Observe
- (void)addObserve {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullFileListCompleteNoti:) name:PullFileList_Complete_Noti object:nil];
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
    
    _fileTableType = FileTableTypeNormal;
    _sourceArr = [NSMutableArray array];
    _searchArr = [NSMutableArray array];
    [_mainTable registerNib:[UINib nibWithNibName:FileCellReuse bundle:nil] forCellReuseIdentifier:FileCellReuse];
    
//    [self sendPullFileList];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self refreshTable];
}


#pragma mark - Operation

- (void)refreshTable {
    if (_fileTableType == FileTableTypeNormal) {
        [_sourceArr removeAllObjects];
        [_sourceArr addObjectsFromArray:[OperationRecordModel getAllOperationRecordOrderByDesc]];
        
        _showArr = _sourceArr;
    } else if (_fileTableType == FileTableTypeSearch) {
        _showArr = _searchArr;
    }
    
    [_mainTable reloadData];
}



//- (void)showFileMoreAlertView:(OperationRecordModel *)model {
////    self.selectModel = model;
//    FileMoreAlertView *view = [FileMoreAlertView getInstance];
//    @weakify_self
//    [view setSendB:^{
//
//    }];
//    [view setDownloadB:^{
//
//    }];
//    [view setOtherApplicationOpenB:^{
//        [weakSelf otherApplicationOpen:[NSURL fileURLWithPath:@""]];
//    }];
//    [view setDetailInformationB:^{
//        [weakSelf jumpToDetailInformation:model];
//    }];
//    [view setRenameB:^{
//
//    }];
//    [view setDeleteB:^{
////        [weakSelf deleteFileWithModel:model];
//    }];
//
//    NSString *fileName = @"";
//    [view showWithFileName:fileName fileType:@(1)];
//}

#pragma mark -删除文件
- (void) deleteFileWithModel:(FileListModel *) model
{
    [SendRequestUtil sendDelFileWithUserId:[UserConfig getShareObject].userId FileName:model.FileName showHud:YES];
}

- (void)otherApplicationOpen:(NSURL *)fileURL {
    NSArray *items = @[fileURL];
    UIActivityViewController *activityController=[[UIActivityViewController alloc]initWithActivityItems:items applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - Request
//- (void)sendPullFileList {
//    NSString *UserId = [UserConfig getShareObject].userId;
//    NSNumber *MsgStartId = @(0);
//    NSNumber *MsgNum = @(15);
//    NSNumber *Category = @(0);
//    NSNumber *FileType = @(0);
//    [SendRequestUtil sendPullFileListWithUserId:UserId MsgStartId:MsgStartId MsgNum:MsgNum Category:Category FileType:FileType showHud:YES];
//}

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
    return FileCellHeight;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    FileCell *cell = [tableView dequeueReusableCellWithIdentifier:FileCellReuse];
    
    OperationRecordModel *model = _showArr[indexPath.row];
    [cell configCellWithModel:model];
    @weakify_self
    [cell setFileMoreB:^{
//        [weakSelf showFileMoreAlertView:<#(FileListModel *)#>];
    }];
    
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

#pragma mark - UITextField Add Target
- (void)addTFTarget {
    [_searchTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldTextChange:(UITextField *)tf {
    if (tf == _searchTF) {
        if ([tf.text.trim isEmptyString]) {
            _fileTableType = FileTableTypeNormal;
        } else {
            _fileTableType = FileTableTypeSearch;
            [_searchArr removeAllObjects];
            @weakify_self
            [_sourceArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                OperationRecordModel *model = obj;
                if ([model.fileName containsString:tf.text.trim]) {
                    [weakSelf.searchArr addObject:model];
                }
            }];
        }
        [self refreshTable];
    }
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



#pragma mark - Noti
//- (void)pullFileListCompleteNoti:(NSNotification *)noti {
//    NSArray *arr = noti.object;
//    if (arr.count <= 0) {
//        
//    } else {
//        
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
