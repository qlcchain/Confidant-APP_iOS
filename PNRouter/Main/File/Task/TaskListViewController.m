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
#import "NSDateFormatter+Category.h"
#import "NSDate+Category.h"
#import "UploadFileManager.h"
#import "SystemUtil.h"
#import "SocketManageUtil.h"
#import "ChatListDataUtil.h"
#import "FileDownUtil.h"

@interface TaskListViewController () <UITableViewDelegate, UITableViewDataSource>
{
    BOOL isRegiterNoti;
    BOOL isSelect;
}
@property (weak, nonatomic) IBOutlet UIButton *DelBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *delContraintH;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (nonatomic, strong) NSMutableArray *selectArr;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (weak, nonatomic) IBOutlet UIView *contentBack;

@end

@implementation TaskListViewController
- (void) addObserver
{
    if (!isRegiterNoti) {
        isRegiterNoti = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadFinshNoti:) name:File_Upload_Finsh_Noti object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileProgessNoti:) name:File_Progess_Noti object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downFileProgessNoti:) name:Tox_Down_File_Progess_Noti object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileUploadFaieldNoti:) name:File_Upload_Faield_Noti object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didToxDownFile:) name:DID_DOWN_FILE_NOTI object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didToxUploadFile:) name:DID_UPLOAD_FILE_NOTI object:nil];
        
        
    }
   
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark -layz
- (NSMutableArray *)selectArr
{
    if (!_selectArr) {
        _selectArr = [NSMutableArray array];
    }
    return _selectArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
     [self dataInit];
  //  [self.view showHudInView:self.view hint:@""];
    [self getAllTaskList];
 
}

- (void) getAllTaskList
{
    
  //  [FileData bg_drop:FILE_STATUS_TABNAME];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSArray *colums = @[bg_sqlKey(@"msgId"),bg_sqlKey(@"fileId"),bg_sqlKey(@"fileFrom"),bg_sqlKey(@"backSeconds"),bg_sqlKey(@"userId"),bg_sqlKey(@"toId"),bg_sqlKey(@"fileName"),bg_sqlKey(@"filePath"),bg_sqlKey(@"progess"),bg_sqlKey(@"speedSize"),bg_sqlKey(@"srcKey"),bg_sqlKey(@"optionTime"),bg_sqlKey(@"fileSize"),bg_sqlKey(@"status"),bg_sqlKey(@"fileType"),bg_sqlKey(@"fileOptionType"),bg_sqlKey(@"didStart")];
  
        NSString *columString = [colums componentsJoinedByString:@","];
        NSString *sql  = [NSString stringWithFormat:@"select %@ from %@ where %@=%@ order by %@ desc limit 100",columString,FILE_STATUS_TABNAME,bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"optionTime")];
        
       NSArray *results = bg_executeSql(sql, FILE_STATUS_TABNAME,[FileData class]);
        NSMutableArray *arr1 = [NSMutableArray array];
        NSMutableArray *arr2 = [NSMutableArray array];
        if (results && results.count>0) {
            
            [results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                FileData *fileModel = obj;
                if (fileModel.status != 1) {
                    [arr1 addObject:fileModel];
                } else {
                    [arr2 addObject:fileModel];
                }
            }];
           
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.sourceArr.count > 0) {
                [self.sourceArr removeAllObjects];
            }
            
            [self.sourceArr addObject:arr1];
            [self.sourceArr addObject:arr2];
            
            [self.mainTable reloadData];
            [self addObserver];
            [self.view hideHud];
            
            if ([self.sourceArr[0] count] == 0 && [self.sourceArr[1] count] == 0) {
                [self viewInit];
            }
        });
        
    });
    
    
 
  
    
    /*
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
                         
                         NSArray *sortArr = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                             FileData *model1 = obj1;
                             FileData *model2 = obj2;
                             return [model2.bg_updateTime compare:model1.bg_updateTime];
                         }];
                         
                         [arr2 addObjectsFromArray:sortArr];
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
     */
}

#pragma mark - Operation
- (void) updateLeftBtn
{
    if (isSelect) {
        [_backBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        [_backBtn setImage:[[UIImage alloc] init] forState:UIControlStateNormal];
    } else {
        [_backBtn setImage:[UIImage imageNamed:@"arrow-exit-h"] forState:UIControlStateNormal];
         [_backBtn setTitle:@"" forState:UIControlStateNormal];
    }
    _rightBtn.hidden = isSelect;
}
- (void)dataInit {
    
    [self updateLeftBtn];
    
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
    if (isSelect) {
        isSelect = NO;
        [self updateLeftBtn];
        if (self.selectArr.count > 0) {
            [self.selectArr removeAllObjects];
        }
        _delContraintH.constant = 0;
        [_mainTable reloadData];
    } else {
         [self.navigationController popViewControllerAnimated:YES];
    }
}
- (IBAction)delAction:(id)sender {
    
    [self.view showHudInView:self.view hint:@""];
    @weakify_self
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.selectArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *srcKey = obj[0];
            NSInteger fileid = [obj[1] integerValue];
            NSInteger status = [obj[2] integerValue];
            
            [FileData bg_delete:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"srcKey"),bg_sqlValue(srcKey),bg_sqlKey(@"fileId"),bg_sqlValue(@(fileid))]];
            
            if (status == 2) {
                NSInteger fileOptionType = [obj[3] integerValue];
                NSInteger msgid = [obj[5] integerValue];
                if (fileOptionType == 1) { // 上传
                    if ([SystemUtil isSocketConnect]) {
                        [[SocketManageUtil getShareObject] cancelFileOptionWithSrcKey:srcKey fileid:fileid];
                    } else {
                      //  [[ChatListDataUtil getShareObject].fileCancelParames setObject:@"1" forKey:[NSString stringWithFormat:@"%ld",(long)fileid]];
                       [SendToxRequestUtil cancelToxFileUploadWithFileid:[NSString stringWithFormat:@"%ld",(long)fileid]];
                    }
                } else { // 下载
                    if ([SystemUtil isSocketConnect]) {
                        [[FileDownUtil getShareObject] cancelDownWithFileid:fileid srckey:srcKey];
                    } else { // tox
                        NSString *msgidKey = [NSString stringWithFormat:@"%ld",(long)msgid];
                        [[ChatListDataUtil getShareObject].fileCancelParames setObject:@"1" forKey:msgidKey];
                    }
                }
            }
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view hideHud];
            self->isSelect = NO;
            [weakSelf updateLeftBtn];
            if (weakSelf.selectArr.count > 0) {
                [weakSelf.selectArr removeAllObjects];
            }
            weakSelf.delContraintH.constant = 0;
            [weakSelf getAllTaskList];
        });
    });
    
    
    
    
    
//    [_sourceArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSMutableArray *sectionArr = obj;
//        [sectionArr enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            FileData *model = obj;
//            BOOL isExit = [weakSelf containsSrckey:model.srcKey fileid:model.fileId];
//            if (isExit) {
//                if (model.status == 2) {
//                    if (model.fileOptionType == 1) { // 上传
//                        if ([SystemUtil isSocketConnect]) {
//                            [[SocketManageUtil getShareObject] cancelFileOptionWithSrcKey:model.srcKey fileid:model.fileId];
//                        }
//                    } else { // 下载
//
//                    }
//                }
//                [sectionArr removeObject:obj];
//            }
//        }];
//    }];
    
    
}

- (IBAction)multiSelectAction:(id)sender {
    isSelect = YES;
    [self updateLeftBtn];
    [_mainTable reloadData];
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
        [cell setFileModel:model isSelect:[self containsSrckey:model.srcKey fileid:model.fileId]];
        [cell updateSelectShow:isSelect];
        @weakify_self
        [cell setSelectBlock:^(NSArray *values) {
            [weakSelf selectFileDataWithSrckey:values];
        }];
        return cell;
    } else if (indexPath.section == 1) {
        TaskCompletedCell *cell = [tableView dequeueReusableCellWithIdentifier:TaskCompletedCellReuse];
        [cell setFileModel:model isSelect:[self containsSrckey:model.srcKey fileid:model.fileId]];
        [cell updateSelectShow:isSelect];
        @weakify_self
        [cell setSelectBlock:^(NSArray *values) {
            [weakSelf selectFileDataWithSrckey:values];
        }];
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
    CGFloat lblX = 16;
    if (isSelect) {
        lblX = 54;
    }
        titleLab = [UILabel new];
        titleLab.frame = CGRectMake(lblX, 10, 200, 20);
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

- (void) cancelUploadOrDownFile:(FileData *) fileData
{
    
}

#pragma mark -添加srckey
- (void) selectFileDataWithSrckey:(NSArray *) values
{
    __block BOOL isExit =NO;
    @weakify_self
    [self.selectArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *srcKey = obj[0];
        NSInteger fileid = [obj[1] integerValue];
        
        NSString *srcKey1 = values[0];
        NSInteger fileid1 = [values[1] integerValue];
        
        if ([srcKey isEqualToString:srcKey1] && fileid == fileid1) {
            [weakSelf.selectArr removeObject:obj];
            isExit = YES;
            *stop = YES;
        }
    }];
    if (!isExit) {
        [weakSelf.selectArr addObject:values];
    }
    
    if (_selectArr.count>0) {
        _delContraintH.constant = 44;
    } else {
        _delContraintH.constant = 0;
    }
    [_DelBtn setTitle:[NSString stringWithFormat:@"Delete(%lu)",(unsigned long)_selectArr.count] forState:UIControlStateNormal];
    [_mainTable reloadData];
}

- (BOOL) containsSrckey:(NSString *) srcKey fileid:(NSInteger) fileid
{
    __block BOOL result = NO;
    [self.selectArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *srcKey1 = obj[0];
        NSInteger fileid1 = [obj[1] integerValue];
        if ([srcKey isEqualToString:srcKey1] && fileid1 == fileid) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

#pragma mark -noti
- (void) fileProgessNoti:(NSNotification *) noti
{
    @synchronized (self) {
        FileData *resultModel = noti.object;
        if (_sourceArr.count == 0) {
            return;
        }
        NSMutableArray *uploadArr = _sourceArr[0];
        @weakify_self
        [uploadArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FileData *model = obj;
            if ([model.srcKey isEqualToString:resultModel.srcKey] && model.fileId == resultModel.fileId) {
                
                    if (model.status != 2) {
                        if (model.status == 3) {
                            if ([weakSelf.sourceArr[0] count] > idx) {
                                
                                TaskOngoingCell *myCell = [weakSelf.mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                                
                                model.speedSize = 0;
                                model.progess = 0;
                                model.backSeconds = 0;
                                myCell.lblProgess.text = @"0 KB/s";
                                myCell.progess.progress = model.progess;
                                
                            }
                        }
                    } else {
                        
                        model.progess = resultModel.progess;
                        NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
                        NSDate *updateDate = [formatter dateFromString:model.optionTime];
                        NSDate *date = [NSDate date];
                        NSInteger seconds = [updateDate millesAfterDate:date];
                        seconds = labs(seconds);
                        
                        if (seconds >=1) {
                            if (seconds - model.backSeconds >=2 || model.backSeconds == 0) {
                                int currentFinshSize = model.fileSize*model.progess;
                                model.speedSize = currentFinshSize/seconds;
                                model.backSeconds = seconds;
                                NSLog(@"----------speed%d",model.speedSize);
                            }
                        }
                        if (weakSelf.sourceArr.count > 0 && [weakSelf.sourceArr[0] count] > 0) {
                            
                            if ([weakSelf.sourceArr[0] count] > idx) {
                                TaskOngoingCell *myCell = [weakSelf.mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                                
                                myCell.progess.progress = model.progess;
                                if (model.speedSize == 0) {
                                    myCell.lblProgess.text = @"0 KB/s";
                                } else {
                                    myCell.lblProgess.text = [[SystemUtil transformedZSValue:model.speedSize] stringByAppendingString:@"/s"];
                                }
                            }
                        }
                    }
                *stop = YES;
            }
        }];
    }
}
- (void) downFileProgessNoti:(NSNotification *) noti
{
    @synchronized (self) {
        FileData *resultModel = noti.object;
        if (_sourceArr.count == 0 ) {
            return;
        }
        NSMutableArray *uploadArr = _sourceArr[0];
        @weakify_self
        [uploadArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FileData *model = obj;
            if (model.msgId == resultModel.msgId) {
                if (resultModel.progess > 1) {
                    
                    NSLog(@"resultModel.progess = %f",resultModel.progess);
                    if (model.status != 2) {
                        
                        if (model.status == 3) {
                            if ([weakSelf.sourceArr[0] count] > idx) {
                                
                                TaskOngoingCell *myCell = [weakSelf.mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                                
                                model.speedSize = 0;
                                model.progess = 0;
                                model.backSeconds = 0;
                                myCell.lblProgess.text = @"0 KB/s";
                                myCell.progess.progress = model.progess;
                                
                            }
                        }
                        
                    } else {
                        model.progess = resultModel.progess/model.fileSize;
                        NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
                        NSDate *updateDate = [formatter dateFromString:model.optionTime];
                        NSInteger seconds = [updateDate millesAfterDate:[NSDate date]];
                        seconds = labs(seconds);
                        if (seconds >=1) {
                            if (seconds - model.backSeconds >=2 || model.backSeconds == 0) {
                                model.speedSize = model.fileSize/seconds;
                                model.backSeconds = seconds;
                            }
                        }
                        if (weakSelf.sourceArr.count > 0 && [weakSelf.sourceArr[0] count] > 0) {
                            if ([weakSelf.sourceArr[0] count] > idx) {
                                
                                TaskOngoingCell *myCell = [weakSelf.mainTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
                                
                                myCell.progess.progress = model.progess;
                                if (model.speedSize == 0) {
                                    myCell.lblProgess.text = @"0 KB/s";
                                } else {
                                    myCell.lblProgess.text = [[SystemUtil transformedZSValue:model.speedSize] stringByAppendingString:@"/s"];
                                }
                            }
                            
                        }
                    }
                }
                *stop = YES;
            }
        }];
    }
    
}
- (void) fileUploadFaieldNoti:(NSNotification *) noti
{
    @synchronized (self) {
        FileData *resultModel = noti.object;
        if (_sourceArr.count == 0 || ![[UserConfig getShareObject].userId isEqualToString:resultModel.userId]) {
            return;
        }
        NSMutableArray *uploadArr = _sourceArr[0];
        @weakify_self
        [uploadArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FileData *model = obj;
            if ([model.srcKey isEqualToString:resultModel.srcKey] && model.fileId == resultModel.fileId) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (model.status == 1 || model.status == 3) {
                        *stop = YES;
                    }
                    model.progess = 0.0f;
                    model.status = 3;
                    if (weakSelf.sourceArr.count > 0 && [weakSelf.sourceArr[0] count] > 0) {
                        
                        if ([weakSelf.sourceArr[0] count] > idx) {
                            [UIView performWithoutAnimation:^{
                                
                                                    [weakSelf.mainTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            }];
                        }
                    }
                    
                    *stop = YES;
                });
            }
        }];
    }
   
}
- (void) fileUploadFinshNoti:(NSNotification *) noti
{
    [self getAllTaskList];
}

// tox文件正在下载
- (void) didToxDownFile:(NSNotification *) noti
{
    NSString *msgid = noti.object;
    NSMutableArray *uploadArr = _sourceArr[0];
    @weakify_self
    [uploadArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FileData *model = obj;
        model.didStart = 1;
        if (model.msgId == [msgid intValue]) {
            [weakSelf.mainTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            *stop = YES;
        }
    }];
}
// tox文件正在上传
- (void) didToxUploadFile:(NSNotification *) noti
{
    NSString *fileid = noti.object;
    NSMutableArray *uploadArr = _sourceArr[0];
    @weakify_self
    [uploadArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FileData *model = obj;
        model.didStart = 1;
        if (model.fileId == [fileid integerValue]) {
            [weakSelf.mainTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            *stop = YES;
        }
    }];
}

@end
