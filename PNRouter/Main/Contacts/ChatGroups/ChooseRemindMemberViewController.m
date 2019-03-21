//
//  ChooseContactViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/21.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ChooseRemindMemberViewController.h"
#import "ChooseDownView.h"
#import "ChatListDataUtil.h"
#import "ChooseContactShowModel.h"
#import "NSString+Base64.h"
#import "ChooseContactTableCell.h"
#import "ChooseContactHeaderView.h"
#import "FriendModel.h"

@interface ChooseRemindMemberViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;

@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) NSMutableArray *searchDataArray;
//@property (nonatomic ,strong) NSArray *groupArray;
@property (nonatomic ,strong) NSMutableArray *selectArray;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UILabel *selectLab;
@property (weak, nonatomic) IBOutlet UIButton *confrimBtn;

@property (nonatomic) BOOL isSearch;

@end

@implementation ChooseRemindMemberViewController

#pragma mark - Action
- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)confirmAction:(id)sender {
    [self.selectArray addObjectsFromArray:[self getIsSelectRouter]];
    
    if (self.selectArray.count <= 0) {
        [AppD.window showHint:@"Please select group member"];
        return;
    }
    
    @weakify_self
    [self dismissViewControllerAnimated:YES completion:^{
        if (weakSelf.selectArray.count > 0) {
//            [[NSNotificationCenter defaultCenter] postNotificationName:CHOOSE_FRIEND_NOTI object:weakSelf.selectArray];
        }
    }];
}

#pragma mark - Operation
- (void)multiSelectInit {
    [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChooseContactShowModel *showModel = obj;
        if (showModel.showArrow) {
            showModel.showSelect = NO;
        } else {
            showModel.showSelect = YES;
        }
        
        [showModel.routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChooseContactRouterModel *routerModel = obj;
            routerModel.showSelect = YES;
        }];
    }];
    
    [self refreshSelectLab];
    [_tableV reloadData];
}

- (void)refreshSelectLab {
    NSMutableArray *selectArr = [self getIsSelectRouter];
    if (selectArr.count >= 0) {
        _selectLab.text = [NSString stringWithFormat:@"Selected: %lu persons",(unsigned long)selectArr.count];
    }
}

- (NSArray *)handleShowData:(NSArray<FriendModel *> *)arr {
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
            showM.Remarks = friendM.remarks;
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
//            if (existShowM.routerArr.count >= 1) {
//                existShowM.showArrow = YES;
//            }
            [existShowM.routerArr addObject:routerM];
        }
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

#pragma mark - Lazy

- (NSMutableArray *)searchDataArray
{
    if (!_searchDataArray) {
        _searchDataArray = [NSMutableArray array];
    }
    return _searchDataArray;
}

- (NSMutableArray *)selectArray
{
    if (!_selectArray) {
        _selectArray = [NSMutableArray array];
    }
    return _selectArray;
}

#pragma mark - UITextFeildDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"textFieldShouldReturn");
    return YES;
}

#pragma mark - Init
- (instancetype)initWithMemberArr:(NSArray<FriendModel *> *)arr {
    if (self = [super init]) {
        _dataArray = [NSMutableArray array];
        [_dataArray addObjectsFromArray:[self handleShowData:arr]];
    }
    return self;
}

#pragma mark - Life Cycle
- (void)viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _confrimBtn.layer.cornerRadius = 4.0f;
    _confrimBtn.layer.masksToBounds = YES;
    
    _searchBackView.layer.cornerRadius = 3.0f;
    _searchBackView.layer.masksToBounds = YES;
    
    _searchTF.delegate = self;
    _searchTF.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    _searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addTargetMethod];
    
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableV registerNib:[UINib nibWithNibName:ChooseContactTableCellResue bundle:nil] forCellReuseIdentifier:ChooseContactTableCellResue];
    [_tableV registerNib:[UINib nibWithNibName:ChooseContactHeaderViewReuse bundle:nil] forHeaderFooterViewReuseIdentifier:ChooseContactHeaderViewReuse];
    
    [self multiSelectInit];
}

- (NSMutableArray *)getIsSelectRouter {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    @weakify_self
    [_dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChooseContactShowModel *showModel = obj;
        if (showModel.isSelect) {
            [array addObject:[weakSelf getFriendModelWithContactShowModel:showModel contactRouterModel:showModel.routerArr.firstObject]];
        }
//        [showModel.routerArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            ChooseContactRouterModel *routerModel = obj;
//            if (routerModel.isSelect) {
//                [array addObject:[weakSelf getFriendModelWithContactShowModel:showModel contactRouterModel:routerModel]];
//            }
//        }];
    }];
    return array;
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
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
        tempM.isSelect = !tempM.isSelect;
        
        [tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
        [weakSelf refreshSelectLab];
    };
    
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
    }
}

#pragma mark -mode转换
- (FriendModel *)getFriendModelWithContactShowModel:(ChooseContactShowModel *)contactShowM contactRouterModel:(ChooseContactRouterModel *)contactRouterM {
    FriendModel *friendM = [[FriendModel alloc] init];
    friendM.userId = contactRouterM.Id;
    friendM.username = [contactShowM.Name base64DecodedString]?:contactShowM.Name;
    friendM.publicKey = contactShowM.publicKey;
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
