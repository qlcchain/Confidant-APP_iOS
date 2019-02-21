//
//  ContactViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ContactViewController.h"
#import "ContactTableCell.h"
//#import "GroupCell.h"
#import "ContactHeaderView.h"
#import "FriendDetailViewController.h"
#import "UserModel.h"
#import "SocketMessageUtil.h"
#import "QRViewController.h"
#import "FriendModel.h"
#import "AddFriendViewController.h"
#import "RSAModel.h"
#import "ChatListDataUtil.h"
#import "NSString+Base64.h"
#import "SystemUtil.h"
#import "PersonCodeViewController.h"
#import "EditTextViewController.h"
#import "FriendRequestViewController.h"
#import "LibsodiumUtil.h"
#import "ContactShowModel.h"
#import "ChatViewController.h"

@interface ContactViewController ()<UITableViewDelegate,UITableViewDataSource/*,SWTableViewCellDelegate*/,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UIView *hdBackView;

@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) NSMutableArray *searchDataArray;
@property (nonatomic ,strong) NSArray *groupArray;
@property (nonatomic) NSInteger deleteIndex;
@property (nonatomic) BOOL isSearch;

@end

@implementation ContactViewController

- (void)viewDidAppear:(BOOL)animated {
     [self sendGetFriendNoti];
    [super viewWillAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [super viewWillAppear:animated];
    
    [self refreshAddContactHD];
}

#pragma mark - Observe
- (void)observe {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendListChangeNoti:) name:FRIEND_LIST_CHANGE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendGetFriendNoti) name:FRIEND_DELETE_MY_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFriendListNoti:) name:GET_FRIEND_LIST_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestAddFriendNoti:) name:REQEUST_ADD_FRIEND_NOTI object:nil];
}

- (IBAction)rightQRAction:(id)sender {
    @weakify_self
    QRViewController *vc = [[QRViewController alloc] initWithCodeQRCompleteBlock:^(NSString *codeValue) {
        if (codeValue != nil && codeValue.length > 0) {
            NSArray *codeValues = [codeValue componentsSeparatedByString:@","];
            codeValue = codeValues[0];
            if ([codeValue isEqualToString:@"type_0"]) {
                codeValue = codeValues[1];
                if ([codeValue isEqualToString:[UserModel getUserModel].userId]) {
                    [AppD.window showHint:@"You cannot add yourself as a friend."];
                } else if (codeValue.length != 76) {
                    [AppD.window showHint:@"The two-dimensional code format is wrong."];
                } else {
                    NSString *nickName = @"";
                    if (codeValues.count>2) {
                        nickName = codeValues[2];
                    }
                    [weakSelf addFriendRequest:codeValue nickName:nickName];
                }
            } else {
                [weakSelf.view showHint:@"format error!"];
            }
        }
    }];
    [self presentModalVC:vc animated:YES];
}

#pragma mark -layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (NSMutableArray *)searchDataArray
{
    if (!_searchDataArray) {
        _searchDataArray = [NSMutableArray array];
    }
    return _searchDataArray;
}
- (NSArray *)groupArray
{
    if (!_groupArray) {
        _groupArray = @[@"Add Contact",@"Create a Group Chat"];
    }
    return _groupArray;
}
#pragma textfeild delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    NSLog(@"textFieldShouldReturn");
    return YES;
}

#pragma mark - Cycle Life
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
     self.view.backgroundColor = MAIN_PURPLE_COLOR;
    [self observe];
    
    _hdBackView.layer.cornerRadius = 6.0f;
    _hdBackView.backgroundColor = RGB(44, 44, 44);
    _hdBackView.hidden = YES;
    
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
//    [_tableV registerNib:[UINib nibWithNibName:GroupCellReuse bundle:nil] forCellReuseIdentifier:GroupCellReuse];
    [_tableV registerNib:[UINib nibWithNibName:ContactTableCellResue bundle:nil] forCellReuseIdentifier:ContactTableCellResue];
    [_tableV registerNib:[UINib nibWithNibName:ContactHeaderViewReuse bundle:nil] forHeaderFooterViewReuseIdentifier:ContactHeaderViewReuse];
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
            ContactShowModel *model = obj;
            NSString *userName = [[model.Name base64DecodedString] lowercaseString];
            if ([userName containsString:[tf.text.trim lowercaseString]]) {
                [weakSelf.searchDataArray addObject:model];
            }
        }];
    }
    [_tableV reloadData];
    [self refreshAddContactHD];
}

- (void) sendGetFriendNoti
{
    [SocketMessageUtil sendFriendListRequest];
}

#pragma mark -Operation-
- (void)addFriendRequest:(NSString *)friendId nickName:(NSString *) nickName{
    
   FriendRequestViewController *vc = [[FriendRequestViewController alloc] initWithNickname:nickName userId:friendId];
    [self.navigationController pushViewController:vc animated:YES];
   
}

- (void)refreshAddContactHD {
    _hdBackView.hidden = AppD.showHD?NO:YES;
}

#pragma mark - Action

- (IBAction)addContactAction:(id)sender {
    if (AppD.showHD) {
        AppD.showHD = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_CONTACT_HD_NOTI object:nil];
        [_tableV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self refreshAddContactHD];
    }
    AddFriendViewController *vc = [[AddFriendViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return _isSearch? self.searchDataArray.count : self.dataArray.count;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *arr = _isSearch? self.searchDataArray : self.dataArray;
    ContactShowModel *model = arr[section];
    if (model.showCell) {
        return model.routerArr.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ContactTableCellHeight;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ContactHeaderViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ContactHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ContactHeaderViewReuse];

    NSArray *arr = _isSearch? self.searchDataArray : self.dataArray;
    ContactShowModel *model = arr[section];
//    view.headerSection = section;
    [view configHeaderWithModel:model];
    @weakify_self
    view.showCellB = ^{
        model.showCell = !model.showCell;
        [weakSelf.tableV reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
    };
//    view.selectB = ^(NSInteger headerSection) {
//    };
    
    return view;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {

    ContactTableCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactTableCellResue];
    
    ContactShowModel *model = _isSearch? self.searchDataArray[indexPath.section] : self.dataArray[indexPath.section];
    ContactRouterModel *crModel = model.routerArr[indexPath.row];
    [cell configCellWithModel:crModel];
    @weakify_self
    cell.contactChatB = ^(ContactRouterModel * _Nonnull crModel) {
        [weakSelf jumpToChat:[weakSelf getFriendModelWithContactShowModel:model contactRouterModel:crModel]];
    };
    
    cell.tag = indexPath.row;
//    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:65.f];
//    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ContactShowModel *model = _isSearch? self.searchDataArray[indexPath.section] : self.dataArray[indexPath.section];
    ContactRouterModel *crModel = model.routerArr[indexPath.row];
    
    FriendDetailViewController *vc = [[FriendDetailViewController alloc] init];
    vc.friendModel = [self getFriendModelWithContactShowModel:model contactRouterModel:crModel];
    [self.navigationController pushViewController:vc animated:YES];
}

- (FriendModel *)getFriendModelWithContactShowModel:(ContactShowModel *)contactShowM contactRouterModel:(ContactRouterModel *)contactRouterM {
    FriendModel *friendM = [[FriendModel alloc] init];
    friendM.userId = contactRouterM.Id;
    friendM.username = [contactShowM.Name base64DecodedString]?:contactShowM.Name;
    friendM.remarks = [contactShowM.Remarks base64DecodedString]?:contactShowM.Remarks;
    friendM.Index = contactShowM.Index;
    friendM.onLineStatu = [contactShowM.Status integerValue];
    friendM.signPublicKey = contactShowM.UserKey;
    friendM.RouteId = contactRouterM.RouteId;
    friendM.RouteName = contactRouterM.RouteName;
    
    return friendM;
}

#pragma mark - SWTableViewDelegate
/*
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


- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [cell hideUtilityButtonsAnimated:YES];
    ContactShowModel *model = isSearch? self.searchDataArray[cell.tag] : self.dataArray[cell.tag];
    model.remarks = [model.remarks base64DecodedString]?:model.remarks;
    model.username = [model.username base64DecodedString]?:model.username;
    switch (index) {
        case 0:
        {
            PersonCodeViewController *vc = [[PersonCodeViewController alloc] initWithUserId:model.userId userNaem:model.remarks];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 1:
        {
            EditTextViewController *vc = [[EditTextViewController alloc] initWithType:EditFriendAlis friendModel:model];
            [self.navigationController pushViewController:vc animated:YES];
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

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     MAIN_PURPLE_COLOR
                                                icon:[UIImage imageNamed:@"icon_forward"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:
     MAIN_PURPLE_COLOR
                                                icon:[UIImage imageNamed:@"icon_writing"]];
    
    return rightUtilityButtons;
}
*/

#pragma mark - Transition
- (void)jumpToChat:(FriendModel *)friendM {
    ChatViewController *vc = [[ChatViewController alloc] initWihtFriendMode:friendM];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - NOTI
- (void) friendListChangeNoti:(NSNotification *)noti {
    [self sendGetFriendNoti];
}
// 有人请求加你为好友的红点通知
- (void) requestAddFriendNoti:(NSNotification *) noti
{
    if (![[self.navigationController.viewControllers lastObject] isKindOfClass:[AddFriendViewController class]]) {
        [_tableV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        [self refreshAddContactHD];
        // 通知tabbar 红点显示通知
    } else {
        AppD.showHD = NO;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_CONTACT_HD_NOTI object:nil];
    
}

- (void) getFriendListNoti:(NSNotification *) noti {
    
    NSString *jsonModel =(NSString *)noti.object;
    NSArray *modelArr = [jsonModel mj_JSONObject];
    if (self.dataArray.count > 0) {
        [self.dataArray removeAllObjects];
    }
    if ([ChatListDataUtil getShareObject].friendArray.count>0) {
        [[ChatListDataUtil getShareObject].friendArray removeAllObjects];
    }
    if (modelArr) {
       NSArray *friendArr = [FriendModel mj_objectArrayWithKeyValuesArray:modelArr];
        [friendArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FriendModel *model = obj;
            NSString *nickName = model.username;
            if (model.remarks && ![model.remarks isEmptyString]) {
                model.username = model.remarks;
            }
            model.publicKey = [LibsodiumUtil getFriendEnPublickkeyWithFriendSignPublicKey:model.signPublicKey];
            model.remarks = nickName;
        }];
        NSMutableArray *sortArr = [NSMutableArray arrayWithArray:friendArr];
        [self.dataArray addObjectsFromArray:[self handleShowData:sortArr]];
//        [self.dataArray addObjectsFromArray:[self sortWith:sortArr]];
        [[ChatListDataUtil getShareObject].friendArray addObjectsFromArray:friendArr];
    }
    
    [_tableV reloadData];
    [self refreshAddContactHD];

//    NSArray *finfAlls = [FriendModel bg_findAll:FRIEND_LIST_TABNAME];
//    if (self.dataArray.count > 0) {
//        [self.dataArray removeAllObjects];
//    }
//    if (finfAlls && finfAlls.count > 0) {
//        [self.dataArray addObjectsFromArray:finfAlls];
//    }
//    [_tableV reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
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

- (NSArray *)handleShowData:(NSMutableArray<FriendModel *> *)arr {
//    NSMutableArray *tempArr = [NSMutableArray arrayWithArray:arr];
    NSMutableArray *contactShowArr = [NSMutableArray array];
    @weakify_self
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *friendM = obj;
        NSArray *resultArr = [weakSelf isExist:friendM.signPublicKey InArr:contactShowArr];
        BOOL isExist = [resultArr[0] boolValue];
        ContactShowModel *existShowM = resultArr[1];
        if (!isExist) { // 不存在则创建
            ContactShowModel *showM = [ContactShowModel new];
            showM.showCell = NO;
            showM.showArrow = YES;
            showM.Index = friendM.Index;
            showM.Name = friendM.username;
            showM.Remarks = friendM.remarks;
            showM.UserKey = friendM.signPublicKey;
            showM.Status = @(friendM.onLineStatu);
            showM.routerArr = [NSMutableArray array];
            ContactRouterModel *routerM = [ContactRouterModel new];
            routerM.Id = friendM.userId;
            routerM.RouteId = friendM.RouteId;
            routerM.RouteName = friendM.RouteName;
            [showM.routerArr addObject:routerM];
            
            [contactShowArr addObject:showM];
        } else { // 存在则合并
            ContactRouterModel *routerM = [ContactRouterModel new];
            routerM.Id = friendM.userId;
            routerM.RouteId = friendM.RouteId;
            routerM.RouteName = friendM.RouteName;
            [existShowM.routerArr addObject:routerM];
        }
    }];
    
    return [self sortWith:contactShowArr];
}

- (NSArray *)isExist:(NSString *)userKey InArr:(NSArray<ContactShowModel *> *)arr {
    __block BOOL isExist = NO;
    __block ContactShowModel *resultM = nil;
    [arr enumerateObjectsUsingBlock:^(ContactShowModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ContactShowModel *model = obj;
        if ([model.UserKey isEqualToString:userKey]) {
            isExist = YES;
            resultM = model;
            *stop = YES;
        }
    }];
    
    return @[@(isExist),resultM];
}

//根据拼音的字母排序  ps：排序适用于所有类型
- (NSMutableArray *) sortWith:(NSMutableArray<ContactShowModel *> *)array{
    [array sortUsingComparator:^NSComparisonResult(ContactShowModel *node1, ContactShowModel *node2) {
        NSString *string1 = [NSString getNotNullValue:[self huoqushouzimuWithString:[node1.Name base64DecodedString]?:node1.Name]];
        NSString *string2 = [NSString getNotNullValue:[self huoqushouzimuWithString:[node2.Name base64DecodedString]?:node2.Name]];
        return [string1 compare:string2];
    }];
    return array;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -UITableViewDatasource

@end
