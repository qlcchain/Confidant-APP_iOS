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
#import "NSString+Trim.h"
#import "SocketMessageUtil.h"

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
    
    NSString *aliasName = [NSString trimWhitespaceAndNewline:[NSString getNotNullValue:_nameTF.text]];
    
    switch (self.editType) {
        case EditName:
        {
            if ([aliasName isEmptyString]) {
                [AppD.window showHint:@"Please fill in the name"];
            } else {
                [SendRequestUtil sendUpdateWithNickName:aliasName];
                
            }
        }
            break;
        case EditFriendAlis:
        {
            if ([aliasName isEmptyString]) {
                [AppD.window showHint:@"Please fill in the name"];
            } else {
                [SendRequestUtil sendAddFriendNickName:aliasName friendId:self.friendModel.userId];
            }
        }
            break;
        case EditCompany:
        {
            if ([aliasName isEmptyString]) {
                [AppD.window showHint:@"Please fill in the name"];
            } else {
                UserModel *model = [UserModel getUserModel];
                model.commpany = aliasName;
                [model saveUserModeToKeyChain];
                [self leftNavBarItemPressedWithPop:YES];
            }
        }
            break;
        case EditPosition:
        {
            if ([aliasName isEmptyString]) {
                [AppD.window showHint:@"Please fill in the name"];
            } else {
                UserModel *model = [UserModel getUserModel];
                model.position = aliasName;
                [model saveUserModeToKeyChain];
                [self leftNavBarItemPressedWithPop:YES];
            }
        }
            break;
        case EditLocation:
        {
            if ([aliasName isEmptyString]) {
                [AppD.window showHint:@"Please fill in the name"];
            } else {
                UserModel *model = [UserModel getUserModel];
                model.location = aliasName;
                [model saveUserModeToKeyChain];
                [self leftNavBarItemPressedWithPop:YES];
            }
        }
            break;
        case EditAlis:
        {
            _routerM.aliasName = aliasName?:@"";
            [RouterModel updateRouterName:aliasName usersn:_routerM.userSn ownerName:@""];
            [self leftNavBarItemPressedWithPop:YES];
        }
            break;
        case EditCircleName:
        {
            if ([aliasName isEmptyString]) {
                [AppD.window showHint:@"Please fill in the name"];
            } else {
               [SocketMessageUtil sendUpdateRourerNickName:aliasName showHud:YES];
            }
        }
            break;
        case EditGroupAlias:
        {
            NSString *alias = [_groupInfoM.Remark base64DecodedString]?:@"";
            if ([aliasName isEmptyString]) {
                [AppD.window showHint:@"Please enter an alias"];
            } else {
                if ([alias isEqualToString:aliasName]) {
                    [AppD.window showHint:@"Please choose another alias"];
                } else {
                    NSString *base64Name = [aliasName base64EncodedString];
                    [SendRequestUtil sendGroupConfigWithGId:_groupInfoM.GId Type:@([NSString numberWithHexString:@"F1"]) ToId:nil Name:base64Name NeedVerify:nil showHud:YES];
                }
            }
        }
            break;
        case EditGroupName:
        {
            NSString *name = [_groupInfoM.GName base64DecodedString]?:@"";
            if ([aliasName isEmptyString]) {
                [AppD.window showHint:@"Please enter a group name"];
            } else {
                if ([name isEqualToString:aliasName]) {
                    [AppD.window showHint:@"Please choose another group name"];
                } else {
                    NSString *base64Name = [aliasName base64EncodedString];
                    [SendRequestUtil sendGroupConfigWithGId:_groupInfoM.GId Type:@(1) ToId:nil Name:base64Name NeedVerify:nil showHud:YES];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reviseGroupNameSuccessNoti:) name:Revise_Group_Name_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetRouterNameSuccess:) name:ResetRouterName_Success_Noti object:nil];
    
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
        case EditCircleName:
            _lblNavTitle.text = @"CircleName";
            _nameTF.placeholder = @"Edit Circle Name";
            _nameTF.text = _routerM.name;
            break;
        case EditFriendAlis:
            _lblNavTitle.text = @"Alias";
            _nameTF.placeholder = @"Edit alias";
            _nameTF.text = self.friendModel.remarks;
            break;
        case EditGroupAlias:
        {
            _lblNavTitle.text = @"Alias";
            _nameTF.placeholder = @"Edit Group Alias";
            _nameTF.text = [self.groupInfoM.Remark base64DecodedString];
        }
            break;
        case EditGroupName:
        {
            _lblNavTitle.text = @"Name";
            _nameTF.placeholder = @"Edit Group Name";
            _nameTF.text = [self.groupInfoM.GName base64DecodedString];
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
        self.friendModel.remarks = _nameTF.text.trim?:@"";
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
        model.groupAlias = _nameTF.text.trim;
        [model bg_saveOrUpdate];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MessageList_Update_Noti object:nil];
    
    if (_reviseSuccessB) {
        _reviseSuccessB(_nameTF.text.trim);
    }
    [self leftNavBarItemPressedWithPop:YES];
}

- (void)reviseGroupNameSuccessNoti:(NSNotification *)noti {
    NSString *GId = noti.object;
    // 更新消息列表数据库中群名称
    NSArray *friends = [ChatListModel bg_find:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"groupID"),bg_sqlValue(GId)]];
    if (friends && friends.count > 0) {
        ChatListModel *model = friends[0];
        model.groupName = _nameTF.text.trim;
        [model bg_saveOrUpdate];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MessageList_Update_Noti object:nil];
    
    if (_reviseSuccessB) {
        _reviseSuccessB(_nameTF.text.trim);
    }
    [self leftNavBarItemPressedWithPop:YES];
}

- (void)resetRouterNameSuccess:(NSNotification *)noti {
    NSString *aliasName = [NSString trimWhitespaceAndNewline:[NSString getNotNullValue:_nameTF.text]];
    _routerM.name = aliasName;
    [RouterModel updateCircleName:aliasName usersn:_routerM.userSn];
    [self leftNavBarItemPressedWithPop:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
