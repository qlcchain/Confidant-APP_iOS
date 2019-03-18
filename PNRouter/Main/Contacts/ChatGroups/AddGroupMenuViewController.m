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
#import "ChooseContactViewController.h"
#import "CreateGroupChatViewController.h"

@interface AddGroupMenuViewController ()

@end

@implementation AddGroupMenuViewController
#pragma mark - action

- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)clickMenuAction:(UIButton *)sender {
    
    if (sender.tag == 10) { // create a group
        
        ChooseContactViewController *vc = [[ChooseContactViewController alloc] init];
        [self presentModalVC:vc animated:YES];
        
    } else if (sender.tag == 20) { // scan to add contacts
        
        @weakify_self
        QRViewController *vc = [[QRViewController alloc] initWithCodeQRCompleteBlock:^(NSString *codeValue) {
            if (codeValue != nil && codeValue.length > 0) {
                NSArray *codeValues = [codeValue componentsSeparatedByString:@","];
                codeValue = codeValues[0];
                if ([codeValue isEqualToString:@"type_0"]) {
                    codeValue = codeValues[1];
                    if ([codeValue isEqualToString:[UserModel getUserModel].userId]) {
                        [AppD.window showHint:@"You cannot add yourself as a friend."];
                    } else if (codeValue.length != 76) {
                        [AppD.window showHint:@"The two-dimensional code format is wrong."];
                    } else {
                        NSString *nickName = @"";
                        if (codeValues.count>2) {
                            nickName = codeValues[2];
                        }
                        [weakSelf addFriendRequest:codeValue nickName:nickName signpk:codeValues[3]];
                    }
                } else {
                    [weakSelf.view showHint:@"format error!"];
                }
            }
        }];
        [self presentModalVC:vc animated:YES];
        
    } else if (sender.tag == 30) { // share a contact card
        
        PersonCodeViewController *vc = [[PersonCodeViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        
    } else { // add a new member
        
        AddNewMemberViewController *vc = [[AddNewMemberViewController alloc] init];
        [self presentModalVC:vc animated:YES];
        
    }
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifcation];
}
#pragma mark -- 添加通知

- (void) addNotifcation
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseContactNoti:) name:CHOOSE_FRIEND_NOTI object:nil];
}

#pragma mark --通知回调
- (void) chooseContactNoti:(NSNotification *) noti
{
    NSArray *mutContacts = noti.object;
    if (mutContacts && mutContacts.count > 0) {
        CreateGroupChatViewController *vc = [[CreateGroupChatViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark -Operation-
- (void)addFriendRequest:(NSString *)friendId nickName:(NSString *) nickName signpk:(NSString *) signpk{
    
    FriendRequestViewController *vc = [[FriendRequestViewController alloc] initWithNickname:nickName userId:friendId signpk:signpk];
    [self.navigationController pushViewController:vc animated:YES];
    
}


@end
