//
//  CreateGroupChatViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/13.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "CreateGroupChatViewController.h"
#import "FriendModel.h"
#import "SystemUtil.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"

#import "GroupInfoModel.h"
#import "GroupMemberView.h"
#import "GroupChatViewController.h"
#import "RemoveGroupMemberViewController.h"
#import "AddGroupMemberViewController.h"
#import "ChatListDataUtil.h"
#import "RouterConfig.h"
#import "UserModel.h"

@interface CreateGroupChatViewController ()<UITextFieldDelegate>
{
    BOOL isInvacation;
}
@property (weak, nonatomic) IBOutlet GroupMemberView *memberBackView;
@property (nonatomic , strong) NSMutableArray *persons;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UIButton *createBtn;
@property (weak, nonatomic) IBOutlet UILabel *lblPerosnCount;

@property (nonatomic ,strong) GroupMemberView *memberView;
@end

@implementation CreateGroupChatViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithContacts:(NSArray *)contacts
{
    if (self = [super init]) {
        [self.persons addObjectsFromArray:contacts];
    }
    return self;
}
#pragma mark - layz
- (NSMutableArray *)persons
{
    if (!_persons) {
        _persons = [NSMutableArray array];
    }
    return _persons;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _createBtn.layer.cornerRadius = 4.0f;
    _createBtn.layer.masksToBounds = YES;
    _nameTF.delegate = self;
    
    isInvacation = YES;

    [self addNoti];
    
    [self groupMemberViewInit];
}

#pragma mark - Operation
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
    [_memberBackView addSubview:_memberView];
    [_memberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(weakSelf.memberBackView).offset(0);
    }];
}

- (void)refreshMemberView {
    NSMutableArray *arr = [NSMutableArray array];
    [self.persons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        GroupMemberShowModel *showM = [GroupMemberShowModel new];
        showM.userKey = model.signPublicKey;
        showM.userName = model.username;
        [arr addObject:showM];
    }];
    [_memberView updateConstraintWithPersonCount:arr];
    _lblPerosnCount.text = [NSString stringWithFormat:@"%lu people",(unsigned long)self.persons.count];
}

#pragma mark ---添加通知
- (void) addNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createGroupSuccessNoti:) name:CREATE_GROUP_SUCCESS_NOTI object:nil];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}

- (IBAction)approveSwitchAction:(UISwitch *)sender {
    isInvacation = sender.isOn;
}

- (IBAction)createGroupChatAction:(id)sender {
    [self.view endEditing:YES];
    if (_nameTF.text.trim.length == 0) {
        [self.view showHint:@"GroupName cannot be empty"];
        return;
    }
    // 生成32位对称密钥
    NSString *msgKey = [SystemUtil get32AESKey];
    NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
    NSString *symmetKey = [symmetData base64EncodedString];
    // 自己公钥加密对称密钥
    NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
    
   __block  NSString *friendids = @"";
   __block NSString *friendKeys = @"";
    
    @weakify_self
    [self.persons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        if (idx == weakSelf.persons.count-1) {
            friendids = [friendids stringByAppendingString:model.userId];
            friendKeys = [friendKeys stringByAppendingString:[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:model.publicKey]];
        } else {
            friendids = [friendids stringByAppendingString:model.userId];
            friendids = [friendids stringByAppendingString:@","];
            
            friendKeys = [friendKeys stringByAppendingString:[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:model.publicKey]];
            friendKeys = [friendKeys stringByAppendingString:@","];
        }
    }];
    
    [SendRequestUtil sendCreateGroupWithName:[_nameTF.text.trim base64EncodedString] userKey:srcKey verifyMode:[NSString stringWithFormat:@"%d",isInvacation] friendId:friendids friendKey:friendKeys showHud:YES];
}

#pragma mark - 通知回调
- (void) createGroupSuccessNoti:(NSNotification *) noti
{
    NSDictionary *resDic = noti.object;
    GroupInfoModel *model = [GroupInfoModel mj_objectWithKeyValues:resDic];
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:CREATE_GROUP_SUCCESS_JUMP_NOTI object:model];
    }];
}



#pragma mark --------- textfeild delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

#pragma mark - Transition
- (void)jumpToRemoveGroupMember {
    UserModel *userM = [UserModel getUserModel];
    NSMutableArray *tempArr = [NSMutableArray array];
    [self.persons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        if (![model.userId isEqualToString:userM.userId]) { // 不是自己
            [tempArr addObject:model];
        }
    }];
    RemoveGroupMemberViewController *vc = [[RemoveGroupMemberViewController alloc] initWithMemberArr:tempArr type:RemoveGroupMemberTypeInCreate];
    @weakify_self
    vc.removeCompleteB = ^(NSArray *memberArr) {
        [weakSelf.persons removeAllObjects];
        [weakSelf.persons addObjectsFromArray:memberArr];
        [weakSelf refreshMemberView];
    };
    [self presentModalVC:vc animated:YES];
}

- (void)jumpToAddGroupMember {
    NSArray *tempArr = [ChatListDataUtil getShareObject].friendArray;
    // 过滤非当前路由的好友
    NSString *currentToxid = [RouterConfig getRouterConfig].currentRouterToxid;
    NSMutableArray *memberArr = [NSMutableArray array];
    [tempArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        if ([model.RouteId isEqualToString:currentToxid]) {
            [memberArr addObject:model];
        }
    }];
    NSMutableArray *originArr = [NSMutableArray array];
    [self.persons enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        [originArr addObject:model];
    }];
    AddGroupMemberViewController *vc = [[AddGroupMemberViewController alloc] initWithMemberArr:memberArr originArr:originArr type:AddGroupMemberTypeInCreate];
    @weakify_self
    vc.addCompleteB = ^(NSArray *addArr) {
        [weakSelf.persons addObjectsFromArray:addArr];
        [weakSelf refreshMemberView];
    };
    [self presentModalVC:vc animated:YES];
}

@end
