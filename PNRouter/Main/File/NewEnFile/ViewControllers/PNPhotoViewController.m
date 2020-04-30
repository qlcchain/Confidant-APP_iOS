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
#import "MyConfidant-Swift.h"
#import "PNUploadListViewController.h"
#import "FingerprintVerificationUtil.h"
#import "UserConfig.h"

@interface PNPhotoViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,SWTableViewCellDelegate,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *localTabView;
@property (weak, nonatomic) IBOutlet UITableView *nodeTabView;
@property (weak, nonatomic) IBOutlet UIButton *nodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *localBtn;
@property (weak, nonatomic) IBOutlet UIView *lineBackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineContraintLeft;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentContraintW;

@property (nonatomic, assign) NSInteger react; // 文件夹操作类型
@property (nonatomic, assign) NSInteger cellTag; // 当前操作celltag
@property (nonatomic, strong) KeyBordHeadView *keyHeadView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *nodeDataArray;
@end

@implementation PNPhotoViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (IBAction)clickTaskAction:(id)sender {
    PNUploadListViewController *vc = [[PNUploadListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)clickMenuBtn:(UIButton *)sender {
    
    sender.selected = YES;
    if (sender.tag == 0) {
        _nodeBtn.selected = NO;
        _lineContraintLeft.constant = 0;
    } else {
        _localBtn.selected = NO;
        _lineContraintLeft.constant = sender.tag*SCREEN_WIDTH/2;
    }
    [_mainScrollerView setContentOffset:CGPointMake(sender.tag*SCREEN_WIDTH, 0) animated:YES];
    [self getDataSource];
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
- (NSMutableArray *)nodeDataArray
{
    if (!_nodeDataArray) {
        _nodeDataArray = [NSMutableArray array];
    }
    return _nodeDataArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    
    if (![UserConfig getShareObject].showFileLock) {
        // 开启手势
        [FingerprintVerificationUtil checkFloderShow];
        [UserConfig getShareObject].showFileLock = YES;
    }
    
    
    _localBtn.selected = YES;
    _contentContraintW.constant = SCREEN_WIDTH*2;
    _mainScrollerView.delegate = self;
    
    _localTabView.delegate = self;
    _localTabView.dataSource = self;
    _localTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_localTabView registerNib:[UINib nibWithNibName:EnPhotoCellResue bundle:nil] forCellReuseIdentifier:EnPhotoCellResue];
    [_localTabView registerNib:[UINib nibWithNibName:AddFloderCellResue bundle:nil] forCellReuseIdentifier:AddFloderCellResue];
    
    _nodeTabView.delegate = self;
    _nodeTabView.dataSource = self;
    _nodeTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_nodeTabView registerNib:[UINib nibWithNibName:EnPhotoCellResue bundle:nil] forCellReuseIdentifier:EnPhotoCellResue];
    [_nodeTabView registerNib:[UINib nibWithNibName:AddFloderCellResue bundle:nil] forCellReuseIdentifier:AddFloderCellResue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullFloderListNoti:) name:Pull_Floder_List_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createFloderSuccessNoti:) name:Create_Floder_Success_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFileNumNoti:) name:@"updateFileNum" object:nil];
    
    [self getDataSource];
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

#pragma mark------------加载文件夹
- (void) getDataSource
{
    if (_nodeBtn.selected) {
         // 查询文件夹列表
        if (self.nodeDataArray.count == 0) {
            [SendRequestUtil sendPullFloderListWithFloderType:1 showHud:YES];
        }
           
    } else {
        // 查询本地文件夹列表
        if (self.dataArray.count == 0) {
            [self checkLocalFloderList];
        }
           
    }
   
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
                [weakSelf.localTabView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
            }
        });
        
    }];
}

#pragma mark - UIScrollViewDelegate-------------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _mainScrollerView) {
       // if (_scrollIsManual == NO) {
            CGPoint offset = scrollView.contentOffset;
            _lineContraintLeft.constant = offset.x/2;
      // }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _mainScrollerView) {
        CGPoint offset = scrollView.contentOffset;
        if (offset.x >= SCREEN_WIDTH) {
           // UIButton *btn = [_menuBackView viewWithTag:20];
            [self clickMenuBtn:_nodeBtn];
        } else {
          //  UIButton *btn = [_menuBackView viewWithTag:10];
            [self clickMenuBtn:_localBtn];
        }
      //  _scrollIsManual = NO;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == _mainScrollerView) {
       // _scrollIsManual = NO;
    }
}


#pragma mark -----------------tableview deleate ---------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (tableView == _localTabView) {
             return self.dataArray.count;
        }
        return self.nodeDataArray.count;
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
        PNFloderModel *floderM = tableView == _localTabView? self.dataArray[indexPath.row]:self.nodeDataArray[indexPath.row];
        if (floderM.fId == 1) {
            [myCell setRightUtilityButtons:@[] WithButtonWidth:0.f];
        } else {
            [myCell setRightUtilityButtons:[self rightButtons] WithButtonWidth:85.f];
        }
        
        myCell.delegate = self;
        myCell.tag = indexPath.row;
        if (tableView == _localTabView) {
             [myCell setFloderM:floderM isLocal:YES];
        } else {
             [myCell setFloderM:floderM isLocal:NO];
        }
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
        PNFloderModel *floderM = _localBtn.selected?self.dataArray[indexPath.row]:self.nodeDataArray[indexPath.row];
        if (_localBtn.selected) {
            floderM.isLocal = YES;
        } else {
            floderM.isLocal = NO;
        }
        PNFloderContentViewController *vc = [[PNFloderContentViewController alloc] initWithFloderM:floderM];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        self.react = 3;
        [AppD.window addSubview:self.keyHeadView];
        self.keyHeadView.lblTitle.text = @"Create Floder";
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
    self.cellTag = cell.tag;
    switch (index) {
        case 0: // 删除
        {
            self.react = 2;
            if (_localBtn.selected) {
                PNFloderModel *floderM = self.dataArray[cell.tag];
                @weakify_self
                [self.view showHudInView:self.view hint:@""];
                [PNFloderModel bg_deleteAsync:EN_FLODER_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"fId"),bg_sqlValue(@(floderM.fId))] complete:^(BOOL isSuccess) {
                    // 切换到主线程
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.view hideHud];
                        if (isSuccess) {
                            [weakSelf.dataArray removeObjectAtIndex:cell.tag];
                            [weakSelf.localTabView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:cell.tag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                        } else {
                            [weakSelf.view showHint:Delete_Failed];
                        }
                    });
                    
                }];
            } else {
                
                PNFloderModel *floderM = self.nodeDataArray[cell.tag];
                [SendRequestUtil sendUpdateloderWithFloderType:1 updateType:2 react:2 name:floderM.PathName oldName:@"" fid:0 pathid:floderM.fId showHud:YES];
            }
           
            
            break;
        }
        case 1: // 重命名
        {
            self.react = 1;
            [AppD.window addSubview:self.keyHeadView];
            PNFloderModel *floderM = nil;
            if (_localBtn.selected) {
                floderM = self.dataArray[cell.tag];
            } else {
                floderM = self.nodeDataArray[cell.tag];
            }
            NSString *deName = [Base58Util Base58DecodeWithCodeName:floderM.PathName];
            self.keyHeadView.floderTF.text = deName.length >0 ?deName:floderM.PathName;
            self.keyHeadView.lblTitle.text = @"ReName";
            [self.keyHeadView.floderTF becomeFirstResponder];
            
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
    
    NSString *fname = [Base58Util Base58EncodeWithCodeName:name];
    
    if (self.react == 3) {
        
        if (_localBtn.selected) {
            
             PNFloderModel *floderM = [[PNFloderModel alloc] init];
               floderM.PathName = fname;
               floderM.fId = [NSDate getTimestampFromDate:[NSDate date]];// 秒时间戳
               floderM.bg_tableName = EN_FLODER_TABNAME;
               
               @weakify_self
               [self.view showHudInView:self.view hint:@""];
               [floderM bg_saveAsync:^(BOOL isSuccess) {
                   dispatch_async(dispatch_get_main_queue(), ^{
                       [weakSelf.view hideHud];
                       if (isSuccess) {
                            [weakSelf.dataArray addObject:floderM];
                            [weakSelf.localTabView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
                       } else {
                           [weakSelf.view showHint:Create_Failed];
                       }
                   });
               }];
            
        } else {
            
            [SendRequestUtil sendUpdateloderWithFloderType:1 updateType:2 react:3 name:fname oldName:@"" fid:0 pathid:0 showHud:YES];
        }
        
    } else if (self.react == 1) {
        
        if (_localBtn.selected) {
            PNFloderModel *floderM = self.dataArray[self.cellTag];
            floderM.PathName = fname;
            [PNFloderModel bg_update:EN_FLODER_TABNAME where:[NSString stringWithFormat:@"set %@=%@ where %@=%@",bg_sqlKey(@"PathName"),bg_sqlValue(fname),bg_sqlKey(@"fId"),bg_sqlValue(@(floderM.fId))]];
            [self.localTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.cellTag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            
            PNFloderModel *floderM = self.nodeDataArray[self.cellTag];
            [SendRequestUtil sendUpdateloderWithFloderType:1 updateType:2 react:1 name:fname oldName:floderM.PathName fid:0 pathid:floderM.fId showHud:YES];
            
            [FIRAnalytics logEventWithName:kFIREventSelectContent
            parameters:@{
                         kFIRParameterItemID:FIR_FLODER_CREATE,
                         kFIRParameterItemName:FIR_FLODER_CREATE,
                         kFIRParameterContentType:FIR_FLODER_CREATE
                         }];
        }
    }
}

#pragma makr-------------请求通知
- (void) pullFloderListNoti:(NSNotification *) noti
{
    NSDictionary *responDic = noti.object?:@{};
    NSString *jsonStr = responDic[@"Payload"]?:@"";
    NSArray *floderArr = [PNFloderModel mj_objectArrayWithKeyValuesArray:jsonStr.mj_JSONObject]?:nil;
    if (floderArr) {
        if (self.nodeDataArray.count > 0) {
            [self.nodeDataArray removeAllObjects];
        }
        [self.nodeDataArray addObjectsFromArray:floderArr];
        [_nodeTabView reloadData];
    }
}
- (void) createFloderSuccessNoti:(NSNotification *) noti
{
    NSDictionary *responDic = noti.object?:@{};
    NSInteger fileId = [responDic[@"FileId"] integerValue];
    if (fileId > 0) {
        return;
    }
    self.react = [responDic[@"React"] integerValue];

    if (self.react == 3) { // 新建
        
        PNFloderModel *floderM = [[PNFloderModel alloc] init];
        floderM.PathName = responDic[@"Name"];
        floderM.fId = [responDic[@"PathId"] integerValue];
        [self.nodeDataArray addObject:floderM];
        [self.nodeTabView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    } else if (self.react == 2) { // 删除
      
        [self.nodeDataArray removeObjectAtIndex:self.cellTag];
        [self.nodeTabView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.cellTag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        
    } else if (self.react == 1){ // 重命名
        PNFloderModel *floderM = self.nodeDataArray[self.cellTag];
        floderM.PathName = responDic[@"Name"];
        [self.nodeTabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.cellTag inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
    
}

- (PNFloderModel *) getFloderModelWithFid:(NSInteger) fid
{
    PNFloderModel *floderM = nil;
    for (int i = 0; i<self.nodeDataArray.count; i++) {
        PNFloderModel *fm = self.nodeDataArray[i];
        if (fm.fId == fid) {
            floderM = fm;
            break;
        }
    }
    return floderM;
}
- (void) updateFileNumNoti:(NSNotification *) noti
{
    if (_localBtn.selected) {
        [_localTabView reloadData];
    } else {
        [_nodeTabView reloadData];
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
    if (_keyHeadView) {
        self.view.userInteractionEnabled = NO;
        NSDictionary *userInfo = [notification userInfo];
        CGFloat duration = [[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
        CGRect rect = [[userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];
        
        [UIView animateWithDuration:duration animations:^{
            self.keyHeadView.frame = CGRectMake(0, rect.origin.y-163, SCREEN_WIDTH, 163);
        }];
    }
    
}
- (void) KeyboardWillHideNotification:(NSNotification *) notification
{
    if (_keyHeadView) {
        NSDictionary *userInfo = [notification userInfo];
        CGFloat duration = [[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
        
        [UIView animateWithDuration:duration animations:^{
            self.keyHeadView.frame = CGRectMake(0,SCREEN_HEIGHT, SCREEN_WIDTH, 163);
        } completion:^(BOOL finished) {
            self.view.userInteractionEnabled = YES;
            [self.keyHeadView removeFromSuperview];
        }];
    }
    
}
@end
