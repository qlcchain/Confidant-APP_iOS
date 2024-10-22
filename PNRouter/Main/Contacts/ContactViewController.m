//
//  ContactViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ContactViewController.h"
#import "ContactTableCell.h"
#import "ContactHeaderView.h"
#import "FriendDetailViewController.h"
#import "UserModel.h"
#import "SocketMessageUtil.h"
#import "QRViewController.h"
#import "FriendModel.h"
#import "NewRequestsViewController.h"
#import "RSAModel.h"
#import "ChatListDataUtil.h"
#import "NSString+Base64.h"
#import "SystemUtil.h"
#import "PersonCodeViewController.h"
#import "EditTextViewController.h"
#import "FriendRequestViewController.h"
#import "ContactShowModel.h"
#import "ChatViewController.h"
#import "NewRequestsViewController.h"
#import "GroupChatListViewController.h"
#import "AddGroupMenuViewController.h"

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
@property (nonatomic, assign) int logId;

@end

@implementation ContactViewController

- (void)viewDidAppear:(BOOL)animated {
    // [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
     [self sendGetFriendNoti];
    [super viewWillAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self refreshAddContactHD];
}

#pragma mark - Observe
- (void)observe {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(friendListChangeNoti:) name:FRIEND_LIST_CHANGE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendGetFriendNoti) name:FRIEND_DELETE_MY_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFriendListNoti:) name:GET_FRIEND_LIST_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getFriendListFailedNoti:) name:GET_FRIEND_LIST_FAILED_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(contactHDShow:) name:TABBAR_CONTACT_HD_NOTI object:nil];
}

- (IBAction)rightQRAction:(id)sender {
    
    AddGroupMenuViewController *vc = [[AddGroupMenuViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
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
     self.view.backgroundColor = MAIN_GRAY_COLOR;
    [self observe];
    
    _hdBackView.layer.cornerRadius = 6.0f;
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
    // 上传日志
    _logId = [SendRequestUtil sendLogRequestWtihAction:PULLFRIEND logid:0 type:0 result:0 info:@"send_pull_friendlist"];
}


- (void)refreshAddContactHD {
    if (AppD.showNewFriendAddRequestRedDot || AppD.showNewGroupAddRequestRedDot) {
        _hdBackView.hidden = NO;
    } else {
        _hdBackView.hidden = YES;
    }
}

#pragma mark - Action

- (IBAction)addContactAction:(UIButton *)sender {
    if (sender.tag == 10) { // new request
        
        NewRequestsViewController *vc = [NewRequestsViewController new];
        [self.navigationController pushViewController:vc animated:YES];
        
    } else { // group_chats
        GroupChatListViewController *vc = [[GroupChatListViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
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

    NSArray *arr = _isSearch ? self.searchDataArray : self.dataArray;
    ContactShowModel *model = arr[section];
    view.headerSection = section;
    [view configHeaderWithModel:model];
    @weakify_self
    view.showCellB = ^(NSInteger headerSection) {
        NSArray *arr = weakSelf.isSearch? self.searchDataArray : self.dataArray;
        ContactShowModel *tempM = arr[headerSection];
        if (tempM.showArrow) { // 显示隐藏cell
            tempM.showCell = !tempM.showCell;
            [weakSelf.tableV reloadSections:[NSIndexSet indexSetWithIndex:headerSection] withRowAnimation:UITableViewRowAnimationNone];
        } else { // 直接跳转详情
            ContactRouterModel *crModel = tempM.routerArr.firstObject;
            [weakSelf jumpToFriendDetail:[weakSelf getFriendModelWithContactShowModel:tempM contactRouterModel:crModel]];
        }
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

    [self jumpToFriendDetail:[self getFriendModelWithContactShowModel:model contactRouterModel:crModel]];
}

- (FriendModel *)getFriendModelWithContactShowModel:(ContactShowModel *)contactShowM contactRouterModel:(ContactRouterModel *)contactRouterM {
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
    friendM.Mails = contactRouterM.Mails;
    
    return friendM;
}

#pragma mark - Transition
- (void)jumpToChat:(FriendModel *)friendM {
    ChatViewController *vc = [[ChatViewController alloc] initWihtFriendMode:friendM];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToFriendDetail:(FriendModel *)friendM {
    FriendDetailViewController *vc = [[FriendDetailViewController alloc] init];
    vc.friendModel = friendM;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - NOTI
- (void) friendListChangeNoti:(NSNotification *)noti {
    [self sendGetFriendNoti];
}

- (void) getFriendListFailedNoti:(NSNotification *) noti {
    // 上传日志
    [SendRequestUtil sendLogRequestWtihAction:PULLFRIEND logid:_logId type:0xFF result:[noti.object intValue] info:@"pull_friend_failed"];
}
- (void) getFriendListNoti:(NSNotification *) noti {
    
    NSString *jsonModel =(NSString *)noti.object;
    NSArray *modelArr = [jsonModel mj_JSONObject];
    
    if (modelArr) {
       NSArray *friendArr = [FriendModel mj_objectArrayWithKeyValuesArray:modelArr];
        [friendArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FriendModel *model = obj;
//            NSString *nickName = model.username;
//            if (model.remarks && ![model.remarks isEmptyString]) {
//                model.username = model.remarks;
//            }
            model.publicKey = [LibsodiumUtil getFriendEnPublickkeyWithFriendSignPublicKey:model.signPublicKey];
            if ([model.username isEqualToString:@"R0hP"]) {
                NSLog(@"----------------%@",[model.username base64DecodedString]);
            }
          //  model.remarks = nickName;
        }];
        NSMutableArray *sortArr = [NSMutableArray arrayWithArray:friendArr];
        NSArray *showArr = [self handleShowData:sortArr];
        
        if (self.dataArray.count > 0) {
            [self.dataArray removeAllObjects];
        }
        [self.dataArray addObjectsFromArray:showArr];
        
        if ([ChatListDataUtil getShareObject].friendArray.count>0) {
            [[ChatListDataUtil getShareObject].friendArray removeAllObjects];
        }
        [[ChatListDataUtil getShareObject].friendArray addObjectsFromArray:friendArr];
    } else {
        if (self.dataArray.count > 0) {
            [self.dataArray removeAllObjects];
        }
        
        if ([ChatListDataUtil getShareObject].friendArray.count>0) {
            [[ChatListDataUtil getShareObject].friendArray removeAllObjects];
        }
    }
    
    [_tableV reloadData];
    [self refreshAddContactHD];
    
    // 上传日志
    [SendRequestUtil sendLogRequestWtihAction:PULLFRIEND logid:_logId type:100 result:0 info:@"pull_friend_success"];

}

- (void)contactHDShow:(NSNotification *)noti {
    [self refreshAddContactHD];
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
        if (!isExist) { // 不存在则创建
            ContactShowModel *showM = [ContactShowModel new];
//            showM.showCell = NO;
            showM.showCell = [weakSelf getOldShowCellStatus:friendM.signPublicKey];
            showM.showArrow = NO;
            showM.Index = friendM.Index;
            showM.Name = friendM.username;
            showM.Mails = friendM.Mails;
            showM.Remarks = friendM.remarks;
            showM.RouteName = friendM.RouteName;
            showM.UserKey = friendM.signPublicKey;
            showM.publicKey = friendM.publicKey;
            showM.Status = @(friendM.onLineStatu);
            showM.routerArr = [NSMutableArray array];
            ContactRouterModel *routerM = [ContactRouterModel new];
            routerM.Id = friendM.userId;
            routerM.RouteId = friendM.RouteId;
            routerM.RouteName = friendM.RouteName;
            routerM.Mails = friendM.Mails;
            [showM.routerArr addObject:routerM];
            
            [contactShowArr addObject:showM];
        } else { // 存在则合并
            ContactShowModel *existShowM = resultArr[1];
            ContactRouterModel *routerM = [ContactRouterModel new];
            routerM.Id = friendM.userId;
            routerM.RouteId = friendM.RouteId;
            routerM.RouteName = friendM.RouteName;
            routerM.Mails = friendM.Mails;
            if (existShowM.routerArr.count >= 1) {
                existShowM.showArrow = YES;
            }
            [existShowM.routerArr addObject:routerM];
        }
    }];
    
    return [self sortWith:contactShowArr];
}

- (BOOL)getOldShowCellStatus:(NSString *)userKey {
    __block BOOL showCell = NO;
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ContactShowModel *model = obj;
        if ([model.UserKey isEqualToString:userKey]) {
            showCell = model.showCell;
            *stop = YES;
        }
    }];
    return showCell;
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
    
    if (!isExist) {
        return @[@(isExist)];
    } else {
        return @[@(isExist),resultM];
    }
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

@end
