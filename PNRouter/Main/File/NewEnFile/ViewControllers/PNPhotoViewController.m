//
//  PNPhotoViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/20.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNPhotoViewController.h"
#import "EnPhotoCell.h"
#import "AddFloderCell.h"
#import "PNFloderContentViewController.h"
#import "KeyBordHeadView.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "PNFloderModel.h"
#import "NSString+Trim.h"
#import "NSDate+Category.h"

@interface PNPhotoViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,SWTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *mainTabView;
@property (nonatomic, strong) KeyBordHeadView *keyHeadView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation PNPhotoViewController

- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
#pragma mark ---layz
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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    
    _mainTabView.delegate = self;
    _mainTabView.dataSource = self;
    _mainTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_mainTabView registerNib:[UINib nibWithNibName:EnPhotoCellResue bundle:nil] forCellReuseIdentifier:EnPhotoCellResue];
    [_mainTabView registerNib:[UINib nibWithNibName:AddFloderCellResue bundle:nil] forCellReuseIdentifier:AddFloderCellResue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullFloderListNoti:) name:Pull_Floder_List_Noti object:nil];
    
    // 查询文件夹列表
   // [SendRequestUtil sendPullFloderListWithFloderType:1 showHud:YES];
    // 查询本地文件夹列表
    [self checkLocalFloderList];
}

// 取消keyboard
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}
// 恢复keyboard
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}

- (void)dealloc {
    //移除键盘监听
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark --------------查询本地文件夹列表
- (void) checkLocalFloderList
{
    @weakify_self
    [self.view showHudInView:self.view hint:@""];
    [PNFloderModel bg_findAllAsync:EN_FLODER_TABNAME complete:^(NSArray * _Nullable array) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view hideHud];
            if (array && array.count > 0) {
                [weakSelf.dataArray addObjectsFromArray:array];
                [weakSelf.mainTabView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
        });
        
    }];
}

#pragma mark -----------------tableview deleate ---------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return self.dataArray.count;
    }
    return 1;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return EnPhotoCellHeight;
    }
    return AddFloderCellHeight;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        EnPhotoCell *myCell = [tableView dequeueReusableCellWithIdentifier:EnPhotoCellResue];
        [myCell setRightUtilityButtons:[self rightButtons] WithButtonWidth:85.f];
        myCell.delegate = self;
        myCell.tag = indexPath.row;
        [myCell setFloderM:self.dataArray[indexPath.row]];
        return myCell;
    } else {
        AddFloderCell *myCell = [tableView dequeueReusableCellWithIdentifier:AddFloderCellResue];
        return myCell;
    }
   
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        PNFloderContentViewController *vc = [[PNFloderContentViewController alloc] initWithFloderM:self.dataArray[indexPath.row]];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [AppD.window addSubview:self.keyHeadView];
        [self.keyHeadView.floderTF becomeFirstResponder];
    }
    
}

#pragma mark-----------左滑出现操作菜单
/**
 设置cell右边button icon
 
 @return 所有button
 */
- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];

    [rightUtilityButtons sw_addUtilityButtonWithColor:RGB(255, 89, 85) title:@"Delete"];
    [rightUtilityButtons sw_addUtilityButtonWithColor:RGB(102, 71, 246) title:@"ReName"];
   
    
    return rightUtilityButtons;
}

#pragma mark-----------左滑菜单delegate SWTableViewDelegate

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
        case 0: // 删除
        {
            PNFloderModel *floderM = self.dataArray[cell.tag];
            @weakify_self
            [self.view showHudInView:self.view hint:@""];
            [PNFloderModel bg_deleteAsync:EN_FLODER_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"fId"),bg_sqlValue(@(floderM.fId))] complete:^(BOOL isSuccess) {
                // 切换到主线程
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view hideHud];
                    if (isSuccess) {
                        [weakSelf.dataArray removeObjectAtIndex:cell.tag];
                        [weakSelf.mainTabView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                    } else {
                        [weakSelf.view showHint:@"Delete failed."];
                    }
                });
                
            }];
            
            break;
        }
        case 1: // 重命名
        {
            PNFloderModel *floderM = self.dataArray[cell.tag];
            [PNFloderModel bg_update:EN_FLODER_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"PathName"),bg_sqlValue(@"")]];
            floderM.PathName = @"";
            [self.mainTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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

#pragma mark ------------创建文件夹
- (void) createFloderWithName:(NSString *) name
{
    PNFloderModel *floderM = [[PNFloderModel alloc] init];
    floderM.PathName = name;
    floderM.fId = [NSDate getTimestampFromDate:[NSDate date]];// 秒时间戳
    floderM.bg_tableName = EN_FLODER_TABNAME;
    
    @weakify_self
    [self.view showHudInView:self.view hint:@""];
    [floderM bg_saveAsync:^(BOOL isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view hideHud];
            if (isSuccess) {
                 [weakSelf.dataArray addObject:floderM];
                   [weakSelf.mainTabView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            } else {
                [weakSelf.view showHint:@"Create a failure."];
            }
        });
    }];
}

#pragma makr-------------请求通知
- (void) pullFloderListNoti:(NSNotification *) noti
{
    NSDictionary *responDic = noti.object?:@{};
    NSString *jsonStr = responDic[@"Payload"]?:@"";
    NSArray *floderArr = [PNFloderModel mj_objectArrayWithKeyValuesArray:jsonStr.mj_JSONObject]?:nil;
    if (floderArr) {
        [self.dataArray addObjectsFromArray:floderArr];
        [_mainTabView reloadData];
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
    [self createFloderWithName:floderName];
    return [self.keyHeadView.floderTF resignFirstResponder];
}

#pragma mark ----KeyboardWillShowNotification
- (void) KeyboardWillShowNotification:(NSNotification *) notification
{
    self.view.userInteractionEnabled = NO;
    NSDictionary *userInfo = [notification userInfo];
    CGFloat duration = [[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    CGRect rect = [[userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.keyHeadView.frame = CGRectMake(0, rect.origin.y-163, SCREEN_WIDTH, 163);
    }];
}
- (void) KeyboardWillHideNotification:(NSNotification *) notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGFloat duration = [[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.keyHeadView.frame = CGRectMake(0,SCREEN_HEIGHT, SCREEN_WIDTH, 163);
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
        [self.keyHeadView removeFromSuperview];
    }];
}
@end
