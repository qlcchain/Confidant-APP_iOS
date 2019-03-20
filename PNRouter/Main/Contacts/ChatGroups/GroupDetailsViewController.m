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
    if (_groupModel.isOwner) {
        _normalBottomHeight.constant = 0;
        _ownerBottomHeight.constant = 168;
    } else {
        _normalBottomHeight.constant = 56;
        _ownerBottomHeight.constant = 0;
    }
    [self groupMemberViewInit];
    
    _groupNameTF.text = _groupModel.GName;
    _groupAliasLab.text = _groupModel.Remark;
    
}

- (void)groupMemberViewInit {
    self.memberView = [GroupMemberView getInstance];
    self.memberView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 48);
    @weakify_self
    _memberView.delB = ^{
//        [weakSelf jumpToRemoveGroupMember];
    };
    _memberView.addB = ^{
//        [weakSelf jumpToAddGroupMember];
    };
    [self refreshMemberView];
    [_memberBackView addSubview:_memberView];
    [_memberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(weakSelf.memberBackView).offset(0);
    }];
}

- (void)refreshMemberView {
    [_memberView updateConstraintWithPersonCount:self.membersArr];
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
    
}

- (IBAction)setGroupAliasAction:(id)sender {
    
}


- (IBAction)leaveAction:(id)sender {
    @weakify_self
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:@"You are leaving the group, the notice is only visible to the group owner. " preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert1 setValue:UIColorFromRGB(0x2C2C2C) forKey:@"_titleTextColor"];
    [alertC addAction:alert1];
    UIAlertAction *alert2 = [UIAlertAction actionWithTitle:@"Leave" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
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

@end
