//
//  TaskListViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "TaskListViewController.h"
#import "TaskOngoingCell.h"
#import "TaskCompletedCell.h"
#import "FileData.h"
#import "UserConfig.h"

@interface TaskListViewController () <UITableViewDelegate, UITableViewDataSource>
{
    BOOL isRegiterNoti;
}
@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (weak, nonatomic) IBOutlet UIView *contentBack;

@end

@implementation TaskListViewController
- (void) addObserver
{
    if (!isRegiterNoti) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadFinshNoti:) name:File_Upload_Finsh_Noti object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileProgessNoti:) name:File_Progess_Noti object:nil];
    }
   
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
     [self dataInit];
    [self.view showHudInView:self.view hint:@""];
    [self getAllTaskList];
   
   
    
}

- (void) getAllTaskList
{
  //  [FileData bg_drop:FILE_STATUS_TABNAME];
    if (_sourceArr.count > 0) {
        [_sourceArr removeAllObjects];
    }
    
    
    @weakify_self
    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@!=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"status"),bg_sqlValue(@(1))] complete:^(NSArray * _Nullable array) {
        
         dispatch_async(dispatch_get_main_queue(), ^{
             NSMutableArray *arr1 = [NSMutableArray array];
             if (array && array.count>0) {
                 [arr1 addObjectsFromArray:array];
             }
             [weakSelf.sourceArr addObject:arr1];
             
             [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"status"),bg_sqlValue(@(1))] complete:^(NSArray * _Nullable array) {
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     NSMutableArray *arr2 = [NSMutableArray array];
                     if (array && array.count>0) {
                         [arr2 addObjectsFromArray:array];
                     }
                     [weakSelf.sourceArr addObject:arr2];
                     [weakSelf addObserver];
                     [weakSelf.view hideHud];
                     [weakSelf.mainTable reloadData];
                     if ([weakSelf.sourceArr[0] count] == 0 && [weakSelf.sourceArr[1] count] == 0) {
                         [weakSelf viewInit];
                     }
                 });
                 
             }];
             
         });
    }];
}

#pragma mark - Operation
- (void)dataInit {
    _sourceArr = [NSMutableArray array];
    
    [_mainTable registerNib:[UINib nibWithNibName:TaskOngoingCellReuse bundle:nil] forCellReuseIdentifier:TaskOngoingCellReuse];
    [_mainTable registerNib:[UINib nibWithNibName:TaskCompletedCellReuse bundle:nil] forCellReuseIdentifier:TaskCompletedCellReuse];
    _mainTable.sectionFooterHeight = 10;
}

- (void)viewInit {
    
    NSString *imgStr = @"icon_task_list_empty_gray";
    NSString *tipStr = @"No Task Record";
    [self showEmptyViewToView:_contentBack img:[UIImage imageNamed:imgStr] title:tipStr];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)multiSelectAction:(id)sender {
    
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sourceArr.count;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_sourceArr[section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return TaskOngoingCellHeight;
    } else if (indexPath.section == 1) {
        return TaskCompletedCellHeight;
    }
    return 0;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    NSMutableArray *modelArr = _sourceArr[indexPath.section];
    FileData *model = modelArr[indexPath.row];
    if (indexPath.section == 0) {
        TaskOngoingCell *cell = [tableView dequeueReusableCellWithIdentifier:TaskOngoingCellReuse];
        [cell setFileModel:model];
        return cell;
    } else if (indexPath.section == 1) {
        TaskCompletedCell *cell = [tableView dequeueReusableCellWithIdentifier:TaskCompletedCellReuse];
        [cell setFileModel:model];
        return cell;
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return 10;
    }
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    NSString *headerReuse = @"headerReuse";
//    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuse];
    UILabel *titleLab = nil;
//    if (nil == headerView) {
//        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerReuse];
    
        UIView *view = [UIView new];
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
        view.backgroundColor = [UIColor whiteColor];
       // [headerView.contentView addSubview:view];
        
        titleLab = [UILabel new];
        titleLab.frame = CGRectMake(16, 10, 200, 20);
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.textColor = UIColorFromRGB(0x2c2c2c);
        [view addSubview:titleLab];
  //  }
    
    NSMutableArray *ongoingArr = _sourceArr[section];
    if (section == 0) {
        titleLab.text = [NSString stringWithFormat:@"Ongoing (%lu)",(unsigned long)ongoingArr.count];
    } else if (section == 1) {
        titleLab.text = [NSString stringWithFormat:@"Completed (%lu)",(unsigned long)ongoingArr.count];
    }
    
    return view;
}

#pragma mark -noti
- (void) fileProgessNoti:(NSNotification *) noti
{
    
    FileData *resultModel = noti.object;
    if (_sourceArr.count == 0) {
        return;
    }
        NSMutableArray *uploadArr = _sourceArr[0];
        @weakify_self
        [uploadArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FileData *model = obj;
            if ([model.srcKey isEqualToString:resultModel.srcKey]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    model.progess = resultModel.progess;
                    model.status = 2;
                    [weakSelf.mainTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    *stop = YES;
                });
            }
        }];
    
}
- (void) fileUploadFinshNoti:(NSNotification *) noti
{
    [self getAllTaskList];
}
@end
