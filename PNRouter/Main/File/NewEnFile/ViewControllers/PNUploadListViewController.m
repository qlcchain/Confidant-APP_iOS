//
//  PNUploadListViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/12/24.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNUploadListViewController.h"
#import "PNFileModel.h"
#import "TaskOngoingCell.h"
#import "TaskCompletedCell.h"

@interface PNUploadListViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL isSelect;
}
@property (weak, nonatomic) IBOutlet UITableView *mainTabView;
@property (nonatomic, strong) NSMutableArray *ongoingArray;
@property (nonatomic, strong) NSMutableArray *completedArray;

@end

@implementation PNUploadListViewController

- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}

#pragma mark ----layz
- (NSMutableArray *)ongoingArray
{
    if (!_ongoingArray) {
        _ongoingArray = [NSMutableArray array];
    }
    return _ongoingArray;
}
- (NSMutableArray *)completedArray
{
    if (!_completedArray) {
        _completedArray = [NSMutableArray array];
    }
    return _completedArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    
    _mainTabView.delegate = self;
    _mainTabView.dataSource = self;
    _mainTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_mainTabView registerNib:[UINib nibWithNibName:TaskOngoingCellReuse bundle:nil] forCellReuseIdentifier:TaskOngoingCellReuse];
    [_mainTabView registerNib:[UINib nibWithNibName:TaskCompletedCellReuse bundle:nil] forCellReuseIdentifier:TaskCompletedCellReuse];
    
    [self getLoaclUploadData];
}
- (void) getLoaclUploadData
{
    [self.view showHudInView:self.view hint:@""];
    @weakify_self
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSArray *colums = @[bg_sqlKey(@"fId"),bg_sqlKey(@"Depens"),bg_sqlKey(@"Type"),bg_sqlKey(@"Fname"),bg_sqlKey(@"Size"),bg_sqlKey(@"LastModify"),bg_sqlKey(@"Finfo"),bg_sqlKey(@"FKey"),bg_sqlKey(@"PathId"),bg_sqlKey(@"progressV"),bg_sqlKey(@"uploadStatus")];
        
        NSString *columString = [colums componentsJoinedByString:@","];
              //NSString *sql  = [NSString stringWithFormat:@"select %@ from %@ where %@=%@ order by %@ desc limit 100",columString,EN_FILE_TABNAME,bg_sqlKey(@"PathId"),bg_sqlValue(@(_floderM.fId)),bg_sqlKey(@"updateTime")];
        NSString *sql  = [NSString stringWithFormat:@"select %@ from %@ where %@=%@",columString,EN_FILE_TABNAME,bg_sqlKey(@"uploadStatus"),bg_sqlValue(@(1))];
        
        NSArray *results = bg_executeSql(sql, EN_FILE_TABNAME,[PNFileModel class]);
        if (results && results.count > 0) {
            [weakSelf.ongoingArray addObjectsFromArray:results];
        }
        
        NSString *sql2  = [NSString stringWithFormat:@"select %@ from %@ where %@=%@",columString,EN_FILE_TABNAME,bg_sqlKey(@"uploadStatus"),bg_sqlValue(@(2))];
        
        NSArray *results2 = bg_executeSql(sql2, EN_FILE_TABNAME,[PNFileModel class]);
        if (results2 && results2.count > 0) {
            [weakSelf.completedArray addObjectsFromArray:results2];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf.view hideHud];
            [weakSelf.mainTabView reloadData];
            
        });
        
    });
}
#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.ongoingArray.count;
    } else {
        return self.completedArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return TaskOngoingCellHeight;
    } else if (indexPath.section == 1) {
        return TaskCompletedCellHeight;
    }
    return 0;
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

    UILabel *titleLab = nil;
    UIView *view = [UIView new];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    view.backgroundColor = [UIColor whiteColor];

    CGFloat lblX = 16;
    if (isSelect) {
        lblX = 54;
    }
    titleLab = [UILabel new];
    titleLab.frame = CGRectMake(lblX, 10, 200, 20);
    titleLab.font = [UIFont systemFontOfSize:14];
    titleLab.textColor = UIColorFromRGB(0x2c2c2c);
    [view addSubview:titleLab];

    if (section == 0) {
        titleLab.text = [NSString stringWithFormat:@"Ongoing (%lu)",(unsigned long)self.ongoingArray.count];
    } else if (section == 1) {
        titleLab.text = [NSString stringWithFormat:@"Completed (%lu)",(unsigned long)self.completedArray.count];
    }
    
    return view;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    PNFileModel *model = nil;
    if (indexPath.section == 0) {
        model = self.ongoingArray[indexPath.row];
    } else {
        model = self.completedArray[indexPath.row];
    }
    if (indexPath.section == 0) {
        TaskOngoingCell *cell = [tableView dequeueReusableCellWithIdentifier:TaskOngoingCellReuse];
        [cell setPhotoFileModel:model isSelect:isSelect];
        [cell updateSelectShow:isSelect];
        @weakify_self
        [cell setSelectBlock:^(NSArray *values) {
            
        }];
        return cell;
    } else if (indexPath.section == 1) {
        TaskCompletedCell *cell = [tableView dequeueReusableCellWithIdentifier:TaskCompletedCellReuse];
        [cell setPhotoFileModel:model isSelect:isSelect];
        [cell updateSelectShow:isSelect];
        @weakify_self
        [cell setSelectBlock:^(NSArray *values) {
            
        }];
        return cell;
    }
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
