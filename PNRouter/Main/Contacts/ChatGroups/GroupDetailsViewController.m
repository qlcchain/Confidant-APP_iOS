//
//  GroupDetailsViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/13.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "GroupDetailsViewController.h"
#import "GroupInfoModel.h"
#import "GroupMembersViewController.h"
#import "GroupMemberView.h"
#import "GroupMembersModel.h"
#import "NSString+Base64.h"
#import "EditTextViewController.h"
#import "RemoveGroupMemberViewController.h"
#import "AddGroupMemberViewController.h"
#import "ChatListDataUtil.h"
#import "RouterConfig.h"
#import "FriendModel.h"
#import "UserModel.h"
#import "FriendDetailViewController.h"


@interface GroupDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *headImgView;
@property (weak, nonatomic) IBOutlet UITextField *groupNameTF;
@property (weak, nonatomic) IBOutlet UILabel *setGroupAliasLab;
@property (weak, nonatomic) IBOutlet UILabel *groupAliasLab;
@property (weak, nonatomic) IBOutlet UILabel *gorupMembersNumLab;
@property (weak, nonatomic) IBOutlet UISwitch *approveSwitch;
@property (weak, nonatomic) IBOutlet UIView *memberBackView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *normalBottomHeight; // 56
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ownerBottomHeight; // 168
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *groupAliasHeight; // 56
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *groupAliasTop; // 10

@property (nonatomic ,strong) GroupInfoModel *groupModel;
@property (nonatomic, strong) GroupMemberView *memberView;
@property (nonatomic, strong) NSMutableArray *membersArr;

@end

@implementation GroupDetailsViewController

- (instancetype) initWithGroupInfo:(GroupInfoModel *) model
{
    if (self = [super init]) {
        self.groupModel = model;
    }
    return self;
}

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupUserPullSuccessNoti:) name:GroupUserPull_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupQuitSuccessNoti:) name:GroupQuit_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(approveInvitationsSuccessNoti:) name:Set_Approve_Invitations_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(approveInvitationsFailNoti:) name:Set_Approve_Invitations_FAIL_NOTI object:nil];
    
}

#pragma mark - Life Cycle
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObserve];
    [self dataInit];
    [self viewInit];
    [self sendGroupUserPull];
}

#pragma mark - Operation
- (void)dataInit {
    _membersArr = [NSMutableArray array];
}

- (void)viewInit {
    if (_groupModel.UserType == 0) { // 群主
        _normalBottomHeight.constant = 0;
        _ownerBottomHeight.constant = 168;
        _setGroupAliasLab.text = @"Set Group Name";
        _groupAliasLab.text = [_groupModel.GName base64DecodedString];
    } else {
        _normalBottomHeight.constant = 56;
        _ownerBottomHeight.constant = 0;
        _setGroupAliasLab.text = @"Set Group Alias";
        _groupAliasLab.text = [_groupModel.Remark base64DecodedString];
    }
    [self groupMemberViewInit];
    
    _groupNameTF.text = [_groupModel.GName base64DecodedString];
    _approveSwitch.on = [_groupModel.Verify boolValue];
}

- (void)groupMemberViewInit {
    self.memberView = [GroupMemberView getInstance];
    self.memberView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 48);
    @weakify_self
    _memberView.delB = ^{
        [weakSelf jumpToRemoveGroupMember];
    };
    _memberView.addB = ^{
        [weakSelf jumpToAddGroupMember];
    };
    _memberView.headB = ^(NSInteger index) {
         GroupMembersModel *model = weakSelf.membersArr[index];
        if (![model.ToxId isEqualToString:[UserModel getUserModel].userId]) {
            FriendModel *fModel = [[ChatListDataUtil getShareObject] getFriendWithUserid:model.ToxId];
            FriendModel *friendModel = [[FriendModel alloc] init];
            if (!fModel) {
                friendModel.userId = model.ToxId;
                friendModel.username = [model.Nickname base64DecodedString];
                friendModel.signPublicKey = model.UserKey;
                friendModel.noFriend = YES;
            } else {
                friendModel.userId = fModel.userId;
                friendModel.username = [fModel.username base64DecodedString]?:fModel.username;
                friendModel.publicKey = fModel.publicKey;
                friendModel.remarks = [fModel.remarks base64DecodedString]?:fModel.remarks;
                friendModel.Index = fModel.Index;
                friendModel.onLineStatu = fModel.onLineStatu;
                friendModel.signPublicKey = fModel.signPublicKey;
                friendModel.RouteId = fModel.RouteId;
                friendModel.RouteName = fModel.RouteName;
                friendModel.signPublicKey = fModel.publicKey;
                
            }
            [weakSelf jumpFriendDetailVC:friendModel];
        }
    };
    [self refreshMemberView];
    [_memberView showDelBtn:_groupModel.UserType == 0?YES:NO];
    [_memberBackView addSubview:_memberView];
    [_memberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(weakSelf.memberBackView).offset(0);
    }];
}

- (void)refreshMemberView {
    NSMutableArray *arr = [NSMutableArray array];
    [self.membersArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GroupMembersModel *model = obj;
        GroupMemberShowModel *showM = [GroupMemberShowModel new];
        showM.userKey = model.UserKey;
        showM.userName = [model.Nickname base64DecodedString];
        [arr addObject:showM];
    }];
    [_memberView updateConstraintWithPersonCount:arr];
    _gorupMembersNumLab.text = [NSString stringWithFormat:@"%lu people",(unsigned long)self.membersArr.count];
    
}

#pragma mark ---jumpVC
- (void) jumpFriendDetailVC:(FriendModel *) model
{
    FriendDetailViewController *vc = [[FriendDetailViewController alloc] init];
    vc.friendModel = model;
    vc.isGroup = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Request
- (void)sendGroupUserPull {
    [SendRequestUtil sendGroupUserPullWithGId:_groupModel.GId?:@"" TargetNum:@(0) StartId:@"0" showHud:YES];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)approveSwitchAction:(id)sender {
    [SendRequestUtil sendGroupConfigWithGId:_groupModel.GId Type:@(2) ToId:nil Name:nil NeedVerify:_approveSwitch.on?@(1):@(0) showHud:YES];
}

- (IBAction)setGroupAliasAction:(id)sender {
    if (_groupModel.UserType == 0) { // 群主
        [self jumpToEditGroupName];
    } else {
        [self jumpToEditGroupAlias];
    }
}

- (IBAction)leaveAction:(id)sender {
    @weakify_self
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:@"You are leaving the group, the notice is only visible to the group owner. " preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert1 setValue:UIColorFromRGB(0x2C2C2C) forKey:@"_titleTextColor"];
    [alertC addAction:alert1];
    UIAlertAction *alert2 = [UIAlertAction actionWithTitle:@"Leave" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SendRequestUtil sendGroupQuitWithGId:weakSelf.groupModel.GId GroupName:nil showHud:YES];
    }];
    [alert2 setValue:UIColorFromRGB(0x2C2C2C) forKey:@"_titleTextColor"];
    [alertC addAction:alert2];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (IBAction)dismissAction:(id)sender {
    @weakify_self
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:@"Are you sure you want to dismiss the group?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert1 setValue:UIColorFromRGB(0x2C2C2C) forKey:@"_titleTextColor"];
    [alertC addAction:alert1];
    UIAlertAction *alert2 = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SendRequestUtil sendGroupQuitWithGId:weakSelf.groupModel.GId GroupName:nil showHud:YES];
    }];
    [alert2 setValue:UIColorFromRGB(0x2C2C2C) forKey:@"_titleTextColor"];
    [alertC addAction:alert2];
    [self presentViewController:alertC animated:YES completion:nil];
}

- (IBAction)groupMembersAction:(id)sender {
    [self jumpToGroupMembers];
}

#pragma mark - Transition
- (void)jumpToGroupMembers {
    GroupMembersViewController *vc = [GroupMembersViewController new];
    vc.groupInfoM = _groupModel;
    vc.optionType = CheckType;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToEditGroupName {
    EditTextViewController *vc = [[EditTextViewController alloc] initWithType:EditGroupName groupInfoM:_groupModel];
    @weakify_self
    vc.reviseSuccessB = ^(NSString *text) {
        weakSelf.groupModel.GName = [text base64EncodedString];
         weakSelf.groupAliasLab.text = [weakSelf.groupModel.GName base64DecodedString];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToEditGroupAlias {
    EditTextViewController *vc = [[EditTextViewController alloc] initWithType:EditGroupAlias groupInfoM:_groupModel];
    @weakify_self
    vc.reviseSuccessB = ^(NSString *text) {
        weakSelf.groupModel.Remark = [text base64EncodedString];
        weakSelf.groupAliasLab.text = [weakSelf.groupModel.Remark base64DecodedString];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToRemoveGroupMember {
    UserModel *userM = [UserModel getUserModel];
    NSMutableArray *inputMemberArr = [NSMutableArray array];
    [self.membersArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GroupMembersModel *groupMembersM = obj;
        FriendModel *friendM = [FriendModel new];
//        friendM.userId = [NSString stringWithFormat:@"%@",groupMembersM.Id];
//        friendM.RouteId = groupMembersM.ToxId;
        friendM.userId = groupMembersM.ToxId;
        friendM.username = groupMembersM.Nickname;
        friendM.signPublicKey = groupMembersM.UserKey;
        if (![friendM.userId isEqualToString:userM.userId]) { // 不是自己
            [inputMemberArr addObject:friendM];
        }
    }];
    RemoveGroupMemberViewController *vc = [[RemoveGroupMemberViewController alloc] initWithMemberArr:inputMemberArr type:RemoveGroupMemberTypeInGroupDetail];
    vc.groupInfoM = _groupModel;
    @weakify_self
    vc.removeCompleteB = ^(NSArray *memberArr) {
//        [weakSelf.persons removeAllObjects];
//        [weakSelf.persons addObjectsFromArray:memberArr];
//        [weakSelf refreshMemberView];
        [weakSelf sendGroupUserPull];
    };
    [self presentModalVC:vc animated:YES];
}

- (void)jumpToAddGroupMember {
    NSArray *tempArr = [ChatListDataUtil getShareObject].friendArray;
    // 过滤非当前路由的好友
    NSString *currentToxid = [RouterConfig getRouterConfig].currentRouterToxid;
    NSMutableArray *inputArr = [NSMutableArray array];
    [tempArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        if ([model.RouteId isEqualToString:currentToxid]) {
            [inputArr addObject:model];
        }
    }];
    NSMutableArray *originArr = [NSMutableArray array];
    [self.membersArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GroupMembersModel *groupMembersM = obj;
        FriendModel *friendM = [FriendModel new];
        friendM.userId = [NSString stringWithFormat:@"%@",groupMembersM.Id];
        friendM.RouteId = groupMembersM.ToxId;
        friendM.username = groupMembersM.Nickname;
        friendM.signPublicKey = groupMembersM.UserKey;
        [originArr addObject:friendM];
    }];
    AddGroupMemberViewController *vc = [[AddGroupMemberViewController alloc] initWithMemberArr:inputArr originArr:originArr type:AddGroupMemberTypeInGroupDetail];
    vc.groupInfoM = _groupModel;
    @weakify_self
    vc.addCompleteB = ^(NSArray *addArr) {
//        [weakSelf.persons addObjectsFromArray:addArr];
//        [weakSelf refreshMemberView];
        [weakSelf sendGroupUserPull];
    };
    [self presentModalVC:vc animated:YES];
}

#pragma mark - Noti
- (void)groupUserPullSuccessNoti:(NSNotification *)noti {
    NSNumber *Verify = @([noti.userInfo[@"Verify"] integerValue]);
    _groupModel.Verify = Verify;
    _approveSwitch.on = [_groupModel.Verify boolValue];
    
    NSArray *arr = noti.object;
    arr = [arr sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        GroupMembersModel *model1 = obj1;
        GroupMembersModel *model2 = obj2;
        return [model1.Type compare:model2.Type];
    }];
    [_membersArr removeAllObjects];
    [_membersArr addObjectsFromArray:arr];
    [self refreshMemberView];
}

- (void)groupQuitSuccessNoti:(NSNotification *)noti {
//    NSString *GId = noti.object;
    [self moveNavgationBackOneViewController];
    [self backAction:nil];
}

- (void)approveInvitationsSuccessNoti:(NSNotification *)noti {
    _groupModel.Verify = _approveSwitch.on?@(1):@(0);
    _approveSwitch.on = [_groupModel.Verify boolValue];
}

- (void)approveInvitationsFailNoti:(NSNotification *)noti {
    _approveSwitch.on = [_groupModel.Verify boolValue];
}

@end
