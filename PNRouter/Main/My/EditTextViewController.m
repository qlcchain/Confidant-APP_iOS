//
//  EditTextViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/15.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "EditTextViewController.h"
#import "UserModel.h"
#import "RouterModel.h"
#import "FriendModel.h"
#import "UserConfig.h"
#import "GroupInfoModel.h"
#import "NSString+Base64.h"
#import "NSString+HexStr.h"
#import "ChatListModel.h"

@interface EditTextViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblNavTitle;
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (nonatomic ,strong) FriendModel *friendModel;
@property (nonatomic, strong) GroupInfoModel *groupInfoM;

@end

@implementation EditTextViewController

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}

- (IBAction)okAction:(id)sender {
    [self.view endEditing:YES];
    switch (self.editType) {
        case EditName:
        {
            if ([_nameTF.text.trim isEmptyString]) {
                [AppD.window showHint:@"Nickname cannot be empty"];
            } else {
                
                [SendRequestUtil sendUpdateWithNickName:_nameTF.text.trim?:@""];
                
            }
        }
            break;
        case EditFriendAlis:
        {
            if ([_nameTF.text.trim isEmptyString]) {
                [AppD.window showHint:@"Nickname cannot be empty"];
            } else {
                [SendRequestUtil sendAddFriendNickName:_nameTF.text.trim?:@"" friendId:self.friendModel.userId];
            }
        }
            break;
        case EditCompany:
        {
            UserModel *model = [UserModel getUserModel];
            model.commpany = _nameTF.text.trim?:@"";
            [model saveUserModeToKeyChain];
             [self leftNavBarItemPressedWithPop:YES];
        }
            break;
        case EditPosition:
        {
            UserModel *model = [UserModel getUserModel];
            model.position = _nameTF.text.trim?:@"";
            [model saveUserModeToKeyChain];
             [self leftNavBarItemPressedWithPop:YES];
        }
            break;
        case EditLocation:
        {
            UserModel *model = [UserModel getUserModel];
            model.position = _nameTF.text.trim?:@"";
            [model saveUserModeToKeyChain];
             [self leftNavBarItemPressedWithPop:YES];
        }
            break;
        case EditAlis:
        {
            NSString *name = _nameTF.text.trim?:@"";
            _routerM.name = name;
            [RouterModel updateRouterName:name usersn:_routerM.userSn];
             [self leftNavBarItemPressedWithPop:YES];
        }
            break;
        case EditGroupAlias:
        {
            NSString *alias = [_groupInfoM.Remark base64DecodedString]?:@"";
            if (!_nameTF.text || _nameTF.text.length <= 0) {
                [AppD.window showHint:@"Please enter alias."];
            } else {
                if ([alias isEqualToString:_nameTF.text]) {
                    [AppD.window showHint:@"Please enter a different alias."];
                } else {
                    NSString *base64Name = [_nameTF.text base64EncodedString];
                    [SendRequestUtil sendGroupConfigWithGId:_groupInfoM.GId Type:@([NSString numberWithHexString:@"F1"]) ToId:nil Name:base64Name NeedVerify:nil showHud:YES];
                }
            }
        }
            break;
        default:
            break;
    }
    
   
}

- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNickSuccess:) name:REVER_UPDATE_NICKNAME_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNickSuccess:) name:REVER_UPDATE_FRIEND_NICKNAME_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviseGroupAliasSuccessNoti:) name:Revise_Group_Alias_SUCCESS_NOTI object:nil];
}

- (instancetype) initWithType:(EditType) type
{
    if (self = [super init]) {
        self.editType = type;
    }
    return self;
}
- (instancetype)initWithType:(EditType)type friendModel:(FriendModel *)friendModel
{
    if (self = [super init]) {
        self.editType = type;
        self.friendModel = friendModel;
    }
    return self;
}

- (instancetype) initWithType:(EditType) type groupInfoM:(GroupInfoModel *)groupInfoM {
    if (self = [super init]) {
        self.editType = type;
        self.groupInfoM = groupInfoM;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObserve];
    
    switch (self.editType) {
        case EditName:
            _lblNavTitle.text = @"EditName";
            _nameTF.placeholder = @"Please enter Nickname";
            _nameTF.text = [UserModel getUserModel].username?:@"";
            break;
        case EditCompany:
            _lblNavTitle.text = @"EditCompany";
            _nameTF.placeholder = @"Please enter Commpany";
            _nameTF.text = [UserModel getUserModel].commpany?:@"";
            break;
        case EditPosition:
            _lblNavTitle.text = @"EditPosition";
            _nameTF.placeholder = @"Please enter Position";
            _nameTF.text = [UserModel getUserModel].position?:@"";
            break;
        case EditLocation:
            _lblNavTitle.text = @"EditLocation";
            _nameTF.placeholder = @"Please enter Location";
            _nameTF.text = [UserModel getUserModel].location?:@"";
            break;
        case EditAlis:
            _lblNavTitle.text = @"Alias";
            _nameTF.placeholder = @"Edit alias";
            _nameTF.text = _routerM.name;
            break;
        case EditFriendAlis:
            _lblNavTitle.text = @"Alias";
            _nameTF.placeholder = @"Edit alias";
            _nameTF.text = self.friendModel.username;
            break;
        case EditGroupAlias:
        {
            _lblNavTitle.text = @"Alias";
            _nameTF.placeholder = @"Edit Group Alias";
            _nameTF.text = [self.groupInfoM.Remark base64DecodedString];
        }
            break;
        default:
            break;
    }
    
    [self performSelector:@selector(beginFirst) withObject:self afterDelay:0.7];
    
}

- (void) beginFirst
{
    [_nameTF becomeFirstResponder];
}

#pragma mark - 通知回调
- (void) updateNickSuccess:(NSNotification *) noti
{
    if (self.editType == EditFriendAlis) {
        self.friendModel.username = _nameTF.text.trim?:@"";
    } else {
        UserModel *model = [UserModel getUserModel];
        model.username = _nameTF.text.trim?:@"";
        [UserConfig getShareObject].userName = _nameTF.text.trim?:@"";
        [model saveUserModeToKeyChain];
    }
    [self leftNavBarItemPressedWithPop:YES];
}

- (void)reviseGroupAliasSuccessNoti:(NSNotification *)noti {
    NSString *GId = noti.object;
    // 更新消息列表数据库中群别名
    NSArray *friends = [ChatListModel bg_find:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"groupID"),bg_sqlValue(GId)]];
    if (friends && friends.count > 0) {
        ChatListModel *model = friends[0];
        model.groupAlias = _nameTF.text;
        [model bg_saveOrUpdate];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MessageList_Update_Noti object:nil];
    
    if (_reviseSuccessB) {
        _reviseSuccessB(_nameTF.text);
    }
    [self leftNavBarItemPressedWithPop:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
