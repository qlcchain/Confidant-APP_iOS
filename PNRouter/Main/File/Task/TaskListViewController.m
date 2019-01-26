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

@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (weak, nonatomic) IBOutlet UIView *contentBack;

@end

@implementation TaskListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self getAllTaskList];
    [self dataInit];
   
    
}

- (void) getAllTaskList
{
    // 得到已完成的
    NSArray *finshTasks = [FileData bg_find:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"status"),bg_sqlValue(@(1))]];
    
    // 正在上传或下载的
     NSArray *uploadTasks = [FileData bg_find:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@!=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"status"),bg_sqlValue(@(1))]];
    
    NSMutableArray *arr1 = [NSMutableArray array];
    if (finshTasks && uploadTasks.count>0) {
        [arr1 addObjectsFromArray:uploadTasks];
    }
    [_sourceArr addObject:arr1];
    
    NSMutableArray *arr2 = [NSMutableArray array];
    if (finshTasks && finshTasks.count>0) {
        [arr2 addObjectsFromArray:finshTasks];
    }
    [_sourceArr addObject:arr2];
    
    if ((!finshTasks || finshTasks.count == 0) && (!uploadTasks || uploadTasks.count == 0)) {
        [self viewInit];
    }
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
    return _sourceArr.count;
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
    if (indexPath.section == 0) {
        TaskOngoingCell *cell = [tableView dequeueReusableCellWithIdentifier:TaskOngoingCellReuse];
        
        return cell;
    } else if (indexPath.section == 1) {
        TaskCompletedCell *cell = [tableView dequeueReusableCellWithIdentifier:TaskCompletedCellReuse];
        
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

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *headerReuse = @"headerReuse";
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuse];
    UILabel *titleLab = nil;
    if (nil == headerView) {
        headerView = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerReuse];
        
        UIView *view = [UIView new];
        view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
        view.backgroundColor = [UIColor whiteColor];
        [headerView.contentView addSubview:view];
        
        titleLab = [UILabel new];
        titleLab.frame = CGRectMake(16, 10, 200, 20);
        titleLab.font = [UIFont systemFontOfSize:14];
        titleLab.textColor = UIColorFromRGB(0x2c2c2c);
        [view addSubview:titleLab];
    }
    
    NSMutableArray *ongoingArr = _sourceArr[section];
    if (section == 0) {
        titleLab.text = [NSString stringWithFormat:@"Ongoing (%lu)",(unsigned long)ongoingArr.count];
    } else if (section == 1) {
        titleLab.text = [NSString stringWithFormat:@"Completed (%lu)",(unsigned long)ongoingArr.count];
    }
    
    return headerView;
}

@end
