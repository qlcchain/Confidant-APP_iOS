//
//  ChooseContactViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/21.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ChooseContactViewController.h"
//#import "GroupCell.h"
//#import "ChooseContactCell.h"
//#import "ContactsHeadView.h"
#import "ChooseDownView.h"
#import "ChatListDataUtil.h"
#import "ChooseContactShowModel.h"
#import "NSString+Base64.h"
#import "ChooseContactTableCell.h"
#import "ChooseContactHeaderView.h"
#import "FriendModel.h"
#import "GroupInfoModel.h"

@interface ChooseContactViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource> {
    BOOL isMutable;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableContraintV;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (nonatomic, strong) ChooseDownView *downView;

@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) NSMutableArray *searchDataArray;
//@property (nonatomic ,strong) NSArray *groupArray;
@property (nonatomic ,strong) NSMutableArray *selectArray;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (nonatomic) BOOL isSearch;

@end

@implementation ChooseContactViewController

- (void)viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [super viewWillAppear:animated];
}

- (IBAction)backAction:(id)sender {
    if (isMutable) {
        isMutable = NO;
        
        [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChooseContactShowModel *showModel = obj;
            showModel.showSelect = self->isMutable;
            showModel.isSelect = NO;
            [showModel.routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ChooseContactRouterModel *routerModel = obj;
                routerModel.showSelect = self->isMutable;
                routerModel.isSelect = NO;
            }];
        }];
        
        [_tableV reloadData];
        _rightBtn.hidden = NO;
        if (self.downView.frame.origin.y == SCREEN_HEIGHT-Tab_BAR_HEIGHT) {
            [UIView animateWithDuration:0.3f animations:^{
                self.downView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, Tab_BAR_HEIGHT);
                self.tableContraintV.constant = 0;
            }];
        }
    } else {
         [self backVCWithSendNoti:NO];
    }
}
- (void) backVCWithSendNoti:(BOOL) isSend
{
    [self.selectArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        model.isSelect = NO;
    }];
   
        @weakify_self
    [self dismissViewControllerAnimated:YES completion:^{
        if (isSend) {
            if (weakSelf.selectArray.count > 0) {
                [[NSNotificationCenter defaultCenter] postNotificationName:CHOOSE_FRIEND_NOTI object:weakSelf.selectArray];
            }
        }
    }];
    
}
- (IBAction)rightAction:(id)sender {
    isMutable = !isMutable;
    if (isMutable) {
        _rightBtn.hidden = YES;
        if (self.selectArray.count > 0) {
            [UIView animateWithDuration:0.3f animations:^{
                self.downView.frame = CGRectMake(0, SCREEN_HEIGHT-Tab_BAR_HEIGHT, SCREEN_WIDTH, Tab_BAR_HEIGHT);
            }];
        }
    }
    
    [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChooseContactShowModel *showModel = obj;
        if (showModel.showArrow) {
            showModel.showSelect = NO;
        } else {
            showModel.showSelect = YES;
        }
        
        [showModel.routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChooseContactRouterModel *routerModel = obj;
            routerModel.showSelect = self->isMutable;
        }];
    }];
    
    [_tableV reloadData];
}

#pragma mark - Operation Data
- (NSArray *)handleShowData:(NSMutableArray<FriendModel *> *)arr {
    //    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:arr];
    NSMutableArray *contactShowArr = [NSMutableArray array];
    @weakify_self
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *friendM = obj;
        NSArray *resultArr = [weakSelf isExist:friendM.signPublicKey InArr:contactShowArr];
        BOOL isExist = [resultArr[0] boolValue];
        if (!isExist) { // 不存在则创建
            ChooseContactShowModel *showM = [ChooseContactShowModel new];
            showM.showSelect = NO;
            showM.isSelect = NO;
            showM.showCell = [weakSelf getOldShowCellStatus:friendM.signPublicKey];
            showM.showArrow = NO;
            showM.Index = friendM.Index;
            showM.Name = friendM.username;
            if (friendM.remarks && friendM.remarks.length > 0) {
                 showM.Remarks = friendM.remarks;
            }
           
            showM.UserKey = friendM.signPublicKey;
            showM.publicKey = friendM.publicKey;
            showM.Status = @(friendM.onLineStatu);
            showM.routerArr = [NSMutableArray array];
            //            showM.remarks = friendM.remarks;
            ChooseContactRouterModel *routerM = [ChooseContactRouterModel new];
            routerM.Id = friendM.userId;
            routerM.RouteId = friendM.RouteId;
            routerM.RouteName = friendM.RouteName;
            routerM.showSelect = NO;
            routerM.isSelect = NO;
            [showM.routerArr addObject:routerM];
            
            [contactShowArr addObject:showM];
        } else { // 存在则合并
            ChooseContactShowModel *existShowM = resultArr[1];
            ChooseContactRouterModel *routerM = [ChooseContactRouterModel new];
            routerM.Id = friendM.userId;
            routerM.RouteId = friendM.RouteId;
            routerM.RouteName = friendM.RouteName;
            routerM.showSelect = NO;
            routerM.isSelect = NO;
            if (existShowM.routerArr.count >= 1) {
                existShowM.showArrow = YES;
            }
            [existShowM.routerArr addObject:routerM];
        }
    }];
    
    return [self sortWith:contactShowArr];
}

- (NSArray *)handleShowGroupData:(NSMutableArray<GroupInfoModel *> *)arr {
    //    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:arr];
    NSMutableArray *contactShowArr = [NSMutableArray array];
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GroupInfoModel *groupM = obj;
        
        //不存在则创建
        ChooseContactShowModel *showM = [ChooseContactShowModel new];
        showM.showSelect = NO;
        showM.isSelect = NO;
        showM.isGroup = YES;
        showM.showCell = NO;
        showM.showArrow = NO;
        showM.Name = groupM.GName;
        if (groupM.Remark && groupM.Remark.length>0) {
            showM.Remarks = groupM.Remark;
        }
        showM.UserKey = groupM.UserKey;
     
        showM.routerArr = [NSMutableArray array];
        //            showM.remarks = friendM.remarks;
        ChooseContactRouterModel *routerM = [ChooseContactRouterModel new];
        routerM.Id = groupM.GId;
        routerM.showSelect = NO;
        routerM.isSelect = NO;
        [showM.routerArr addObject:routerM];
        
        [contactShowArr addObject:showM];
        
    }];
    
    return [self sortWith:contactShowArr];
}


- (BOOL)getOldShowCellStatus:(NSString *)userKey {
    __block BOOL showCell = NO;
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChooseContactShowModel *model = obj;
        if ([model.UserKey isEqualToString:userKey]) {
            showCell = model.showCell;
            *stop = YES;
        }
    }];
    return showCell;
}

- (NSArray *)isExist:(NSString *)userKey InArr:(NSArray<ChooseContactShowModel *> *)arr {
    __block BOOL isExist = NO;
    __block ChooseContactShowModel *resultM = nil;
    [arr enumerateObjectsUsingBlock:^(ChooseContactShowModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChooseContactShowModel *model = obj;
        if ([model.UserKey isEqualToString:userKey]) {
            isExist = YES;
            resultM = model;
            *stop = YES;
        }
    }];
    
    if (!isExist) {
        return @[@(isExist)];
    } else {
        return @[@(isExist),resultM];
    }
}

//根据拼音的字母排序  ps：排序适用于所有类型
- (NSMutableArray *) sortWith:(NSMutableArray<ChooseContactShowModel *> *)array{
    [array sortUsingComparator:^NSComparisonResult(ChooseContactShowModel *node1, ChooseContactShowModel *node2) {
        NSString *string1 = [NSString getNotNullValue:[self huoqushouzimuWithString:[node1.Name base64DecodedString]?:node1.Name]];
        NSString *string2 = [NSString getNotNullValue:[self huoqushouzimuWithString:[node2.Name base64DecodedString]?:node2.Name]];
        return [string1 compare:string2];
    }];
    return array;
}

//获取其拼音
- (NSString *)huoqushouzimuWithString:(NSString *)string{
    if (!string || [string isEmptyString]) {
        return @"";
    }
    NSMutableString *ms = [[NSMutableString alloc]initWithString:string];
    CFStringTransform((__bridge CFMutableStringRef)ms, 0,kCFStringTransformStripDiacritics, NO);
    NSString *bigStr = [ms uppercaseString];
    NSString *cha = [bigStr substringToIndex:1];
    return cha;
}

#pragma mark -layz

- (NSMutableArray *)searchDataArray
{
    if (!_searchDataArray) {
        _searchDataArray = [NSMutableArray array];
    }
    return _searchDataArray;
}
//- (NSArray *)groupArray
//{
//    if (!_groupArray) {
//        _groupArray = @[@"New Chat"];
//    }
//    return _groupArray;
//}
- (NSMutableArray *)selectArray
{
    if (!_selectArray) {
        _selectArray = [NSMutableArray array];
    }
    return _selectArray;
}
- (ChooseDownView *)downView
{
    if (!_downView) {
        _downView = [ChooseDownView loadChooseDownView];
        _downView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, Tab_BAR_HEIGHT);
        [_downView.comfirmBtn addTarget:self action:@selector(comfirmBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_downView];
    }
    return _downView;
}
#pragma textfeild delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn");
    return YES;
}
#pragma mark -viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _searchBackView.layer.cornerRadius = 3.0f;
    _searchBackView.layer.masksToBounds = YES;
    
    _searchTF.delegate = self;
    _searchTF.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    _searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addTargetMethod];
    
    _dataArray = [NSMutableArray array];
    NSArray *groupArr = [self handleShowGroupData:[ChatListDataUtil getShareObject].groupArray];
    [_dataArray addObjectsFromArray:groupArr];
    NSArray *arr = [self handleShowData:[ChatListDataUtil getShareObject].friendArray];
    [_dataArray addObjectsFromArray:arr];
    
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableV registerNib:[UINib nibWithNibName:ChooseContactTableCellResue bundle:nil] forCellReuseIdentifier:ChooseContactTableCellResue];
    [_tableV registerNib:[UINib nibWithNibName:ChooseContactHeaderViewReuse bundle:nil] forHeaderFooterViewReuseIdentifier:ChooseContactHeaderViewReuse];
    [self.view addSubview:self.downView];
}

- (NSMutableArray *) getIsSelectRouter{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    @weakify_self
    [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChooseContactShowModel *showModel = obj;
        if (showModel.isSelect) {
            [array addObject:[weakSelf getFriendModelWithContactShowModel:showModel contactRouterModel:showModel.routerArr.firstObject]];
        }
        [showModel.routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChooseContactRouterModel *routerModel = obj;
            if (routerModel.isSelect) {
                [array addObject:[weakSelf getFriendModelWithContactShowModel:showModel contactRouterModel:routerModel]];
            }
        }];
    }];
    return array;
}
- (NSInteger) getGroupCountWithArr:(NSMutableArray *) arr
{
    __block NSInteger groupCount = 0;
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        if (model.isGroup) {
            groupCount++;
        }
    }];
    return groupCount;
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return _isSearch? self.searchDataArray.count : self.dataArray.count;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = _isSearch? self.searchDataArray : self.dataArray;
    ChooseContactShowModel *model = arr[section];
    if (model.showCell) {
        return model.routerArr.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ChooseContactTableCellHeight;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ChooseContactHeaderViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ChooseContactHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ChooseContactHeaderViewReuse];
    
    NSArray *arr = _isSearch? self.searchDataArray : self.dataArray;
    ChooseContactShowModel *model = arr[section];
    view.headerSection = section;
    [view configHeaderWithModel:model];
    @weakify_self
    view.showCellB = ^(NSInteger headerSection) {
        NSArray *arr = weakSelf.isSearch? weakSelf.searchDataArray : weakSelf.dataArray;
        ChooseContactShowModel *tempM = arr[headerSection];
        if (tempM.showArrow) { // 显示隐藏cell
           // tempM.showArrow = !tempM.showArrow;
            tempM.showCell = !tempM.showCell;
             [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
        } else { // 直接跳转详情
            if (!self->isMutable) {
                [weakSelf.selectArray addObject:[weakSelf getFriendModelWithContactShowModel:tempM contactRouterModel:tempM.routerArr.firstObject]];
               // [[NSNotificationCenter defaultCenter] postNotificationName:CHOOSE_FRIEND_NOTI object:weakSelf.selectArray];
                [weakSelf backVCWithSendNoti:YES];
            } else {
                
                model.isSelect = !model.isSelect;
                
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
                NSMutableArray *selectArr = [weakSelf getIsSelectRouter];
                if (selectArr.count > 0) {
                    
                    if (weakSelf.downView.frame.origin.y == SCREEN_HEIGHT) {
                        [UIView animateWithDuration:0.3f animations:^{
                            weakSelf.downView.frame = CGRectMake(0, SCREEN_HEIGHT-Tab_BAR_HEIGHT, SCREEN_WIDTH, Tab_BAR_HEIGHT);
                            weakSelf.tableContraintV.constant = Tab_BAR_HEIGHT;
                        }];
                    }
                    NSInteger groupCount = [weakSelf getGroupCountWithArr:selectArr];
                    weakSelf.downView.lblContent.text = [NSString stringWithFormat:@"Selected: %lu persons, %ld groups",(unsigned long)selectArr.count-groupCount,(long)groupCount];
                    
                } else {
                    [UIView animateWithDuration:0.3f animations:^{
                        weakSelf.downView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, Tab_BAR_HEIGHT);
                        weakSelf.tableContraintV.constant = 0;
                    }];
                }
            }
        }
    };
    //    view.selectB = ^(NSInteger headerSection) {
    //    };
    
    return view;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    ChooseContactTableCell *cell = [tableView dequeueReusableCellWithIdentifier:ChooseContactTableCellResue];
    
    ChooseContactShowModel *model = _isSearch? self.searchDataArray[indexPath.section] : self.dataArray[indexPath.section];
    ChooseContactRouterModel *crModel = model.routerArr[indexPath.row];
    [cell configCellWithModel:crModel];
    cell.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (indexPath.section >=0) {
            
            NSArray *arr = _isSearch? self.searchDataArray : self.dataArray;
            ChooseContactShowModel *model = arr[indexPath.section];
            ChooseContactRouterModel *subModel = model.routerArr[indexPath.row];
            
            FriendModel *friendModel = [self getFriendModelWithContactShowModel:model contactRouterModel:subModel];
            
            if (isMutable) {
                subModel.isSelect = !subModel.isSelect;
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                NSMutableArray *selectArr = [self getIsSelectRouter];
                if (selectArr.count > 0) {
                   
                    if (!_downView) {
                        self.downView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, Tab_BAR_HEIGHT);
                        [self.view addSubview:_downView];
                    }
                    if (self.downView.frame.origin.y == SCREEN_HEIGHT) {
                        [UIView animateWithDuration:0.3f animations:^{
                            self.downView.frame = CGRectMake(0, SCREEN_HEIGHT-Tab_BAR_HEIGHT, SCREEN_WIDTH, Tab_BAR_HEIGHT);
                             self.tableContraintV.constant = Tab_BAR_HEIGHT;
                        }];
                    }
                    self.downView.lblContent.text = [NSString stringWithFormat:@"Selected: %lu persons, %d groups",(unsigned long)selectArr.count,0];
 
                } else {
                    
                    [UIView animateWithDuration:0.3f animations:^{
                        self.downView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, Tab_BAR_HEIGHT);
                        self.tableContraintV.constant = 0;
                    }];
                }
            } else {
                [self.selectArray addObject:friendModel];
               // [[NSNotificationCenter defaultCenter] postNotificationName:CHOOSE_FRIEND_NOTI object:self.selectArray];
                [self backVCWithSendNoti:YES];
            }
           
        } else if (indexPath.section == 0) {
           
        }
    }
    
}

#pragma mark -mode转换
- (FriendModel *)getFriendModelWithContactShowModel:(ChooseContactShowModel *)contactShowM contactRouterModel:(ChooseContactRouterModel *)contactRouterM {
    FriendModel *friendM = [[FriendModel alloc] init];
    friendM.userId = contactRouterM.Id;
    friendM.isGroup = contactShowM.isGroup;
    friendM.username = [contactShowM.Name base64DecodedString]?:contactShowM.Name;
    friendM.publicKey = contactShowM.publicKey;
    if (contactShowM.isGroup) {
        friendM.publicKey = contactShowM.UserKey;
    }
    friendM.remarks = [contactShowM.Remarks base64DecodedString]?:contactShowM.Remarks;
    friendM.Index = contactShowM.Index;
    friendM.onLineStatu = [contactShowM.Status integerValue];
    friendM.signPublicKey = contactShowM.UserKey;
    friendM.RouteId = contactRouterM.RouteId;
    friendM.RouteName = contactRouterM.RouteName;
    
    return friendM;
}

#pragma mark - 直接添加监听方法
-(void)addTargetMethod{
    [_searchTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void) textFieldTextChange:(UITextField *) tf
{
    if ([tf.text.trim isEmptyString]) {
        _isSearch = NO;
    } else {
        _isSearch = YES;
        [self.searchDataArray removeAllObjects];
        @weakify_self
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChooseContactShowModel *model = obj;
            NSString *userName = [[model.Name base64DecodedString] lowercaseString];
            if ([userName containsString:[tf.text.trim lowercaseString]]) {
                [weakSelf.searchDataArray addObject:model];
            }
        }];
    }
    [_tableV reloadData];
}

#pragma mark -uibutton_tag
- (void) comfirmBtnAction {
    [self.selectArray addObjectsFromArray:[self getIsSelectRouter]];
    //[[NSNotificationCenter defaultCenter] postNotificationName:CHOOSE_FRIEND_NOTI object:self.selectArray];
    [self backVCWithSendNoti:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
