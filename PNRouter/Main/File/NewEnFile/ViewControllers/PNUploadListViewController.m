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
#import "PNFileUploadModel.h"
#import "SystemUtil.h"
#import "NSDate+Category.h"

@interface PNUploadListViewController ()<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate>
{
    BOOL isSelect;
}
@property (weak, nonatomic) IBOutlet UITableView *mainTabView;
@property (nonatomic, strong) NSMutableArray *ongoingArray;
@property (nonatomic, strong) NSMutableArray *completedArray;

@end

@implementation PNUploadListViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(photoUploadFileDataNoti:) name:Photo_Upload_FileData_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadSuccessNoti:) name:Photo_File_Upload_Success_Noti object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadProgressNoti:) name:Photo_FileData_Upload_Progress_Noti object:nil];
    
    [self getLoaclUploadData];
}
- (void) getLoaclUploadData
{
    [self.view showHudInView:self.view hint:@""];
    @weakify_self
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSArray *colums = @[bg_sqlKey(@"fId"),bg_sqlKey(@"Depens"),bg_sqlKey(@"Type"),bg_sqlKey(@"Fname"),bg_sqlKey(@"Size"),bg_sqlKey(@"LastModify"),bg_sqlKey(@"Finfo"),bg_sqlKey(@"FKey"),bg_sqlKey(@"PathId"),bg_sqlKey(@"progressV"),bg_sqlKey(@"uploadStatus"),bg_sqlKey(@"toFloderId"),bg_sqlKey(@"delHidden")];
        
        NSString *columString = [colums componentsJoinedByString:@","];
              //NSString *sql  = [NSString stringWithFormat:@"select %@ from %@ where %@=%@ order by %@ desc limit 100",columString,EN_FILE_TABNAME,bg_sqlKey(@"PathId"),bg_sqlValue(@(_floderM.fId)),bg_sqlKey(@"updateTime")];
        NSString *sql  = [NSString stringWithFormat:@"select %@ from %@ where %@=%@ or %@=%@ and %@=%@ order by %@ desc",columString,EN_FILE_TABNAME,bg_sqlKey(@"uploadStatus"),bg_sqlValue(@(1)),bg_sqlKey(@"uploadStatus"),bg_sqlValue(@(-1)),bg_sqlKey(@"delHidden"),bg_sqlValue(@(0)),bg_sqlKey(@"LastModify")];
        
        NSArray *results = bg_executeSql(sql, EN_FILE_TABNAME,[PNFileModel class]);
        if (results && results.count > 0) {
            [weakSelf.ongoingArray addObjectsFromArray:results];
        }
        
        NSString *sql2  = [NSString stringWithFormat:@"select %@ from %@ where %@=%@ and %@=%@ order by %@ desc limit 50",columString,EN_FILE_TABNAME,bg_sqlKey(@"uploadStatus"),bg_sqlValue(@(2)),bg_sqlKey(@"delHidden"),bg_sqlValue(@(0)),bg_sqlKey(@"LastModify")];
        
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
        if (model.uploadStatus <= 0) {
            [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:65.f];
            cell.delegate = self;
            cell.tag = indexPath.row;
        } else {
            [cell setRightUtilityButtons:@[] WithButtonWidth:0.f];
        }
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

/**
 设置cell右边button icon
 
 @return 所有button
 */
- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     MAIN_PURPLE_COLOR
                                                 icon:[UIImage imageNamed:@"icon_delete"]];
    
    return rightUtilityButtons;
}


#pragma mark----------------通知
- (void) photoUploadFileDataNoti:(NSNotification *) noti
{
    PNFileUploadModel *uplodFileM = noti.object;
    if (uplodFileM.retCode != 0) {
        for (int i = 0; i<self.ongoingArray.count; i++) {
            PNFileModel *fileM = self.ongoingArray[i];
            if (fileM.fId == uplodFileM.fileId) {
                fileM.uploadStatus = -1;
                fileM.progressV = 0;
                [_mainTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                break;
            }
        }
    }
}
- (void) fileUploadSuccessNoti:(NSNotification *) noti
{
    NSDictionary *resultDic = noti.object;
    NSInteger retCode = [resultDic[@"RetCode"] integerValue];
    NSInteger srcFileID = [resultDic[@"SrcId"] integerValue];
    
    for (int i = 0; i<self.ongoingArray.count; i++) {
        PNFileModel *fileM = self.ongoingArray[i];
        if (fileM.fId == srcFileID) {
             fileM.progressV = 0;
            if (retCode == 0) {
                fileM.uploadStatus = 2;
                [self.ongoingArray removeObject:fileM];
                [self.completedArray addObject:fileM];
                [_mainTabView reloadData];
            } else {
                fileM.uploadStatus = -1;
                 [_mainTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            }
            break;
        }
    }
}
- (void) uploadProgressNoti:(NSNotification *) noti
{
    PNFileUploadModel *uploadFileM = noti.object;
    for (int i = 0; i<self.ongoingArray.count; i++) {
        PNFileModel *fileM = self.ongoingArray[i];
        if (fileM.fId == uploadFileM.fileId) {
            fileM.progressV = uploadFileM.progress;
            TaskOngoingCell *cell = [_mainTabView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            cell.progess.progress = fileM.progressV;
            
            NSInteger downSize = fileM.Size*fileM.progressV;
            NSInteger secons = [NSDate getTimestampFromDate:[NSDate date]] - fileM.LastModify;
            cell.lblProgess.text = [[SystemUtil transformedZSValue:downSize/secons] stringByAppendingString:@"/s"];
            
            break;
        }
    }
}





#pragma mark - SWTableViewDelegate
- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            break;
        case 1:
            NSLog(@"left utility buttons open");
            break;
        case 2:
            NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}


/**
 选择cell菜单回调
 
 @param cell cell
 @param index index
 */
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [cell hideUtilityButtonsAnimated:YES];
    switch (index) {
        case 0:
        {
            @weakify_self
            [_mainTabView performBatchUpdates:^{
                PNFileModel *model = weakSelf.ongoingArray[cell.tag];
                [PNFileModel bg_update:EN_FILE_TABNAME where:[NSString stringWithFormat:@"set %@=%@ where %@=%@",bg_sqlKey(@"delHidden"),bg_sqlValue(@(1)),bg_sqlKey(@"fId"),bg_sqlValue(@(model.fId))]];
                [weakSelf.ongoingArray removeObject:model];
                [weakSelf.mainTabView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }completion:^(BOOL finished){
                [weakSelf.mainTabView reloadData];
            }];
            break;
        }
        default:
            break;
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}
@end
