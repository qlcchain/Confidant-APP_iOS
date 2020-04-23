//
//  AddGroupMenuViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "AddGroupMenuViewController.h"
#import "AddNewMemberViewController.h"
#import "QRViewController.h"
#import "UserModel.h"
#import "FriendRequestViewController.h"
#import "PersonCodeViewController.h"
#import "CreateGroupChatViewController.h"
#import "ChatListDataUtil.h"
#import "GroupChatViewController.h"
#import "GroupInfoModel.h"
#import "AddGroupMemberViewController.h"
#import "RouterConfig.h"
#import "FriendModel.h"
#import "RouterModel.h"
#import "CodeMsgViewController.h"
#import "NSString+RegexCategory.h"
#import "AESCipher.h"
#import "CircleOutUtil.h"
#import "NSString+Base64.h"
#import "SystemUtil.h"
#import "InvitationQRCodeViewController.h"
#import "PNNavViewController.h"
#import "EmailManage.h"
#import "PNEmailSendViewController.h"
#import "UserPrivateKeyUtil.h"

@interface AddGroupMenuViewController ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addNewMemberHeight; // 56
@property (nonatomic ,strong) NSString *codeResultValue;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailContraintV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *friendsHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *friendsContraintV;


@property (weak, nonatomic) IBOutlet UIView *chatBackView;
@property (weak, nonatomic) IBOutlet UIView *scanBackView;
@property (weak, nonatomic) IBOutlet UIView *cardBackView;
@property (weak, nonatomic) IBOutlet UIView *friendBackView;
@property (weak, nonatomic) IBOutlet UIView *membersBackView;
@property (weak, nonatomic) IBOutlet UIView *emailBackView;



@end

@implementation AddGroupMenuViewController
#pragma mark - action

- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)clickMenuAction:(UIButton *)sender {
    
    if (sender.tag == 10) { // create a group
        
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
        AddGroupMemberViewController *vc = [[AddGroupMemberViewController alloc] initWithMemberArr:inputArr originArr:@[] type:AddGroupMemberTypeBeforeCreate];
        [self presentModalVC:vc animated:YES];
        
    } else if (sender.tag == 30) { // scan to add contacts
        
        @weakify_self
        QRViewController *vc = [[QRViewController alloc] initWithCodeQRCompleteBlock:^(NSString *codeValue) {
            if (codeValue != nil && codeValue.length > 0) {
                weakSelf.codeResultValue = codeValue;
                NSArray *codeValues = [codeValue componentsSeparatedByString:@","];
                NSString *codeType = codeValues[0];
        
                if ([codeValue isUrlAddress]) { // 是网址
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:codeValue] options:@{} completionHandler:nil];
                } else {
                      if ([[NSString getNotNullValue:codeType] isEqualToString:@"type_1"]) { // 是节目点通信码
                        // router 码
                        NSString *result = aesDecryptString(codeValues[1],AES_KEY);
                        result = [result stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                        if (result && result.length == 114) {
                            
                            NSString *toxid = [result substringWithRange:NSMakeRange(6, 76)];
                            NSString *sn = [result substringWithRange:NSMakeRange(result.length-32, 32)];
                            NSLog(@"%@",[RouterConfig getRouterConfig].currentRouterSn);
                            
                            if ([[RouterConfig getRouterConfig].currentRouterToxid isEqualToString:toxid]) {
                                // 是当前帐户
                                [AppD.window showHint:@"Already in the same circle"];
                            } else {
                                [self showAlertVCWithValues:@[toxid,sn] isMac:NO];
                            }
                        }
                    } else if ([[NSString getNotNullValue:codeType] isEqualToString:@"type_2"]) { // 是MAC码
                        // mac 码
                        NSString *result = aesDecryptString(codeValues[1],AES_KEY);
                        result = [result stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                        AppD.isScaner = YES;
                        [self showAlertVCWithValues:@[result] isMac:YES];
                        
                    } else if ([[NSString getNotNullValue:codeType] isEqualToString:@"type_0"]) { // 是好友码
                        codeValue = codeValues[1];
                        if ([codeValue isEqualToString:[UserModel getUserModel].userId]) {
                            [AppD.window showHint:@"You can not add yourself as a circle contact."];
                        } else if (codeValue.length != 76) {
                            [AppD.window showHint:@"QR code format is wrong."];
                            [self jumpCodeValueVC];
                        } else {
                            NSString *nickName = @"";
                            if (codeValues.count>2) {
                                nickName = codeValues[2];
                            }
                            [weakSelf addFriendRequest:codeValue nickName:nickName signpk:codeValues[3] type:codeType toxid:@""];
                        }
                    } else if ([[NSString getNotNullValue:codeType] isEqualToString:@"type_5"]) { // 是好友码
                        
                        NSString *aesCode = aesDecryptString(codeValues[1], AES_KEY)?:@"";
                        if (aesCode.length > 0) {
                            NSArray *codeArr = [aesCode componentsSeparatedByString:@","];
                            if (codeArr && codeArr.count == 5) {
                                
                               NSString *signPK = [EntryModel getShareObject].signPublicKey;
                               // NSString *toxid = [RouterModel getConnectRouter].toxid;
                                //  && [codeArr[2] isEqualToString:toxid]
                                if ([codeArr[1] isEqualToString:signPK]) {
                                    
                                    [AppD.window showHint:@"You can not add yourself as a circle contact."];
                                    
                                } else {
                                    
                                     [weakSelf addFriendRequest:@"" nickName:codeArr[3] signpk:codeArr[1] type:codeType toxid:codeArr[2]];
                                }
                            } else {
                                [weakSelf jumpCodeValueVC];
                            }
                        } else {
                            [weakSelf jumpCodeValueVC];
                        }
                              
                    } else if ([[NSString getNotNullValue:codeType] isEqualToString:@"type_3"]) { //帐户码
                        [weakSelf showAlertImportAccount:codeValues];
                        
                    } else if ([[NSString getNotNullValue:codeType] isEqualToString:@"type_4"]) { // 邀请码
                        NSString *result = aesDecryptString([codeValues lastObject],AES_KEY);
                        result = [result stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                        if (result && result.length == 114) {
                            
                            NSString *toxid = [result substringWithRange:NSMakeRange(6, 76)];
                            NSString *sn = [result substringWithRange:NSMakeRange(result.length-32, 32)];
                            NSLog(@"%@",[RouterConfig getRouterConfig].currentRouterSn);
                            
                            if ([[RouterConfig getRouterConfig].currentRouterToxid isEqualToString:toxid]) {
                                
                                // 是当前帐户
                                [SendRequestUtil sendAutoAddFriendWithFriendId:codeValues[1] email:@"" type:1 showHud:NO];
                                [AppD.window showHint:@"Already in the same circle"];
                                
                            } else {
                                [weakSelf showAlertVCWithValues:@[toxid,sn,codeValues[1]] isMac:NO];
                            }
                        }
                    } else if (codeValue.length == 12) { // 是MAC码
                        NSString *macAdress = @"";
                        for (int i = 0; i<12; i+=2) {
                            NSString *macIndex = [codeValue substringWithRange:NSMakeRange(i, 2)];
                            macAdress = [macAdress stringByAppendingString:macIndex];
                            if (i < 10) {
                                macAdress = [macAdress stringByAppendingString:@":"];
                            }
                        }
                        if ([macAdress isMacAddress]) {
                            [self showAlertVCWithValues:@[macAdress] isMac:YES];
                        } else {
                            [self jumpCodeValueVC];
                        }
                    }  else { // 是乱码
                        [self jumpCodeValueVC];
                    }
                }
            }
        }];
        [self presentModalVC:vc animated:YES];
        
    } else if (sender.tag == 40) { // share a contact card
        
        PersonCodeViewController *vc = [[PersonCodeViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    } else if (sender.tag == 60) { // add a new member
        
        NSString *rid = [RouterConfig getRouterConfig].currentRouterToxid;
        AddNewMemberViewController *vc = [[AddNewMemberViewController alloc] initWithRid:rid];
        [self presentModalVC:vc animated:YES];
       // [self jumpToCircleCode];
    } else if (sender.tag == 20) { // new email
        
        PNEmailSendViewController *vc = [[PNEmailSendViewController alloc] initWithEmailListInfo:nil sendType:NewEmail];
        [self presentModalVC:vc animated:YES];
        
    }  else if (sender.tag == 50) { // new email friends
        
        PNEmailSendViewController *vc = [[PNEmailSendViewController alloc] initWithEmailListInfo:nil sendType:FriendEmail];
        [self presentModalVC:vc animated:YES];
        
    }
}



- (void) showAlertImportAccount:(NSArray *) values
{
    
    NSString *signpk = values[1];
   // NSString *usersn = values[2];
    if ([signpk isEqualToString:[EntryModel getShareObject].signPrivateKey])
    {
        // 是当前帐户
        [AppD.window showHint:@"The same user."];
    }
    
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"" message:@"This operation will overwrite the current account. Do you want to continue?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
   // @weakify_self
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
        if (![signpk isEqualToString:[EntryModel getShareObject].signPrivateKey]) {
            // 清除所有数据
            [SystemUtil clearAppAllData];
            // 更改私钥
            [UserPrivateKeyUtil changeUserPrivateKeyWithPrivateKey:values[1]];
            
            NSString *name = [values[3] base64DecodedString];
            [UserModel createUserLocalWithName:name];
            // 删除所有路由
            [RouterModel delegateAllRouter];
            [AppD setRootLoginWithType:ImportType];
        }
            
//        } else {
//            RouterModel *selectRouther = [RouterModel checkRoutherWithSn:usersn];
//            if (selectRouther) {
//                [RouterConfig getRouterConfig].currentRouterToxid = selectRouther.toxid;
//                [RouterConfig getRouterConfig].currentRouterSn = selectRouther.userSn;
//                [[CircleOutUtil getCircleOutUtilShare] circleOutProcessingWithRid:selectRouther.toxid];
//            } else {
//                 [AppD setRootLoginWithType:ImportType];
//            }
//        }
       
    }];
    
    [vc addAction:cancelAction];
    [vc addAction:confirm];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) jumpCodeValueVC
{
    CodeMsgViewController *vc = [[CodeMsgViewController alloc] initWithCodeValue:self.codeResultValue];
    [self presentModalVC:vc animated:YES];
}

- (void) showAlertVCWithValues:(NSArray *) values isMac:(BOOL) isMac
{
   
    AppD.isScaner = YES;
    NSString *friendId = @"";
    if (values.count > 2 && !isMac) {
        friendId = values[2];
    }
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:@"Do you want to switch the circle?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (isMac) {
            [RouterConfig getRouterConfig].currentRouterMAC = values[0];
            [[CircleOutUtil getCircleOutUtilShare] circleOutProcessingWithRid:values[0] friendid:friendId];
        } else {
            [RouterConfig getRouterConfig].currentRouterToxid = values[0];
            [RouterConfig getRouterConfig].currentRouterSn = values[1];
            [[CircleOutUtil getCircleOutUtilShare] circleOutProcessingWithRid:values[0] friendid:friendId];
        }
    }];
    [alert1 setValue:UIColorFromRGB(0x2C2C2C) forKey:@"_titleTextColor"];
    [alertC addAction:alert1];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:alertCancel];
    
    [self presentViewController:alertC animated:YES completion:nil];
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _chatBackView.layer.cornerRadius = 8.0f;
    _emailBackView.layer.cornerRadius = 8.0f;
    _friendBackView.layer.cornerRadius = 8.0f;
    _cardBackView.layer.cornerRadius = 8.0f;
    _membersBackView.layer.cornerRadius = 8.0f;
    _scanBackView.layer.cornerRadius = 8.0f;
    
    [self addNotifcation];
    [self showAddNewMember];
   
    if (!EmailManage.sharedEmailManage.imapSeeion) {
        if (!AppD.isGoogleSign) {
            _emailHeight.constant = 0;
            _emailContraintV.constant = 0;
            
            _friendsHeight.constant = 0;
            _friendsContraintV.constant = 0;
        }
        
    }
}

#pragma mark - Operation
- (void)showAddNewMember {
    NSString *currentRouterSn = [RouterConfig getRouterConfig].currentRouterSn;
    NSString *userType = [currentRouterSn substringWithRange:NSMakeRange(0, 2)];
    
    if ([userType isEqualToString:@"01"]) { // 01:admin
        _addNewMemberHeight.constant = 56;
    } else {
        _addNewMemberHeight.constant = 0;
    }
}


#pragma mark -- 添加通知
- (void) addNotifcation
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseContactNoti:) name:CHOOSE_FRIEND_CREATE_GROUOP_NOTI object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jumpGroupChatNoti:) name:ADD_CREATE_GROUP_SUCCESS_JUMP_NOTI object:nil];
}

#pragma mark - Transition
- (void)addFriendRequest:(NSString *)friendId nickName:(NSString *) nickName signpk:(NSString *) signpk type:(NSString *) type toxid:(NSString *) toxid{
    
    FriendRequestViewController *vc = [[FriendRequestViewController alloc] initWithNickname:nickName userId:friendId signpk:signpk toxId:toxid codeType:type];
    [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma mark - 通知回调
- (void) chooseContactNoti:(NSNotification *) noti
{
    NSArray *mutContacts = noti.object;
    if (mutContacts && mutContacts.count > 0) {
        CreateGroupChatViewController *vc = [[CreateGroupChatViewController alloc] initWithContacts:mutContacts groupPage:AddCreateGroup];
        [self presentModalVC:vc animated:YES];
    }
}
#pragma  mark ---jump vc
- (void) jumpGroupChatNoti:(NSNotification *) noti
{
    GroupInfoModel *model = noti.object;
    GroupChatViewController *vc = [[GroupChatViewController alloc] initWihtGroupMode:model];
    [self.navigationController pushViewController:vc animated:YES];
    [self moveAllNavgationViewController];
}
- (void)jumpToCircleCode {
    InvitationQRCodeViewController *vc = [[InvitationQRCodeViewController alloc] init];
    vc.routerM = [RouterModel getConnectRouter];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
