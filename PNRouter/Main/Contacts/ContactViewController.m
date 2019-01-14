//
//  ContactViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ContactViewController.h"
#import "ContactsCell.h"
#import "GroupCell.h"
#import "ContactsHeadView.h"
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

@interface ContactViewController ()<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate,UITextFieldDelegate>
{
    BOOL isSearch;
}
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) NSMutableArray *searchDataArray;
@property (nonatomic ,strong) NSArray *groupArray;
@property (nonatomic) NSInteger deleteIndex;

@end

@implementation ContactViewController

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
            if ([codeValue isEqualToString:[UserModel getUserModel].userId]) {
                [AppD.window showHint:@"You cannot add yourself as a friend."];
            } else if (codeValue.length != 76) {
                [AppD.window showHint:@"The two-dimensional code format is wrong."];
            } else {
                NSString *nickName = @"";
                if (codeValues.count>1) {
                    nickName = codeValues[1];
                }
                [weakSelf addFriendRequest:codeValue nickName:nickName];
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
    
    [self observe];
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
    [_tableV registerNib:[UINib nibWithNibName:GroupCellReuse bundle:nil] forCellReuseIdentifier:GroupCellReuse];
     [_tableV registerNib:[UINib nibWithNibName:ContactsCellReuse bundle:nil] forCellReuseIdentifier:ContactsCellReuse];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self sendGetFriendNoti];
  
}

#pragma mark - 直接添加监听方法
-(void)addTargetMethod{
    [_searchTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
}
- (void) textFieldTextChange:(UITextField *) tf
{
    if ([tf.text.trim isEmptyString]) {
        isSearch = NO;
    } else {
        isSearch = YES;
        [self.searchDataArray removeAllObjects];
        @weakify_self
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FriendModel *model = obj;
            NSString *userName = [[model.username base64DecodedString] lowercaseString];
            if ([userName containsString:[tf.text.trim lowercaseString]]) {
                [weakSelf.searchDataArray addObject:model];
            }
        }];
    }
    [_tableV reloadData];
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

#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return isSearch? self.searchDataArray.count : self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return GroupCellHeight;
    }
    return ContactsCellHeight;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 64;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    backView.backgroundColor = [UIColor clearColor];
    ContactsHeadView *view = [ContactsHeadView loadContactsHeadView];
    view.frame = backView.bounds;
    [backView addSubview:view];
    return backView;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupCellReuse];
        cell.lblName.text = self.groupArray[indexPath.row];
        cell.hdBackView.hidden = YES;
        if (indexPath.row == 0) {
            if (AppD.showHD) {
                cell.hdBackView.hidden = NO;
            }
        }
        return cell;
    }
    ContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:ContactsCellReuse];
    FriendModel *model = isSearch? self.searchDataArray[indexPath.row] : self.dataArray[indexPath.row];
    [cell setModeWithModel:model];
    cell.tag = indexPath.row;
    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:65.f];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if (indexPath.section == 1) {
            FriendModel *model = isSearch? self.searchDataArray[indexPath.row] : self.dataArray[indexPath.row];
            FriendDetailViewController *vc = [[FriendDetailViewController alloc] init];
            model.username = [model.username base64DecodedString]?:model.username;
            model.remarks = [model.remarks base64DecodedString]?:model.remarks;
            vc.friendModel = model;
            [self.navigationController pushViewController:vc animated:YES];
        } else if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                if (AppD.showHD) {
                    AppD.showHD = NO;
                    [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_CONTACT_HD_NOTI object:nil];
                    [_tableV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                }
                AddFriendViewController *vc = [[AddFriendViewController alloc] init];
                [self.navigationController pushViewController:vc animated:YES];
            } else if (indexPath.row == 1 ){
               
            }
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


- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    [cell hideUtilityButtonsAnimated:YES];
    FriendModel *model = isSearch? self.searchDataArray[cell.tag] : self.dataArray[cell.tag];
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

#pragma mark - NOTI
- (void) friendListChangeNoti:(NSNotification *)noti {
    [self sendGetFriendNoti];
}
// 有人请求加你为好友的红点通知
- (void) requestAddFriendNoti:(NSNotification *) noti
{
    if (![[self.navigationController.viewControllers lastObject] isKindOfClass:[AddFriendViewController class]]) {
        [_tableV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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
        // 按名字首字母排序.
       NSArray *friendArr = [FriendModel mj_objectArrayWithKeyValuesArray:modelArr];
        [friendArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FriendModel *model = obj;
            NSString *nickName = model.username;
            if (model.remarks && ![model.remarks isEmptyString]) {
                model.username = model.remarks;
            }
            model.remarks = nickName;
        }];
        NSMutableArray *sortArr = [NSMutableArray arrayWithArray:friendArr];
        [self.dataArray addObjectsFromArray:[self sortWith:sortArr]];
        [[ChatListDataUtil getShareObject].friendArray addObjectsFromArray:friendArr];
    }
    
    [_tableV reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];

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
//根据拼音的字母排序  ps：排序适用于所有类型
- (NSMutableArray *) sortWith:(NSMutableArray *)array{
    [array sortUsingComparator:^NSComparisonResult(FriendModel *node1, FriendModel *node2) {
        NSString *string1 = [NSString getNotNullValue:[self huoqushouzimuWithString:[node1.username base64DecodedString]?:node1.username]];
        NSString *string2 = [NSString getNotNullValue:[self huoqushouzimuWithString:[node2.username base64DecodedString]?:node2.username]];
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
