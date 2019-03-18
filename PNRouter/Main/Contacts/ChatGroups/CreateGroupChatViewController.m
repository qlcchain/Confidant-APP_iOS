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
#import "LibsodiumUtil.h"
#import "EntryModel.h"
#import "GroupInfoModel.h"
#import "GroupMemberView.h"



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
    _lblPerosnCount.text = [NSString stringWithFormat:@"%lu people",(unsigned long)self.persons.count];
    
    self.memberView = [GroupMemberView getInstance];
    self.memberView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 48);
    [_memberView updateConstraintWithPersonCount:self.persons];
    [_memberBackView addSubview:_memberView];
    @weakify_self
    [_memberView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.top.mas_equalTo(weakSelf.memberBackView).offset(0);
    }];
    
    [self addNoti];
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
            friendKeys = [friendids stringByAppendingString:model.signPublicKey];
        } else {
            friendids = [friendids stringByAppendingString:model.userId];
            friendids = [friendids stringByAppendingString:@","];
            friendKeys = [friendids stringByAppendingString:model.signPublicKey];
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
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    return YES;
}
@end
