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

@interface GroupDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *headImgView;
@property (weak, nonatomic) IBOutlet UITextField *groupNameTF;
@property (weak, nonatomic) IBOutlet UILabel *groupAliasLab;
@property (weak, nonatomic) IBOutlet UILabel *gorupMembersNumLab;
@property (weak, nonatomic) IBOutlet UISwitch *approveSwitch;
@property (weak, nonatomic) IBOutlet UIView *memberBackView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *normalBottomHeight; // 56
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ownerBottomHeight; // 168

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
    } else {
        _normalBottomHeight.constant = 56;
        _ownerBottomHeight.constant = 0;
    }
    [self groupMemberViewInit];
    
    _groupNameTF.text = [_groupModel.GName base64DecodedString];
    _groupAliasLab.text = [_groupModel.Remark base64DecodedString];
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
    [self jumpToEditGroupAlias];
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
    vc.inputGId = _groupModel.GId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToEditGroupAlias {
    EditTextViewController *vc = [[EditTextViewController alloc] initWithType:EditGroupAlias groupInfoM:_groupModel];
    @weakify_self
    vc.reviseSuccessB = ^(NSString *alias) {
        weakSelf.groupModel.Remark = [alias base64EncodedString];
        weakSelf.groupAliasLab.text = [weakSelf.groupModel.Remark base64DecodedString];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Noti
- (void)groupUserPullSuccessNoti:(NSNotification *)noti {
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
