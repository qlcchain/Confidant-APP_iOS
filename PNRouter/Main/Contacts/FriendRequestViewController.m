//
//  FriendRequestViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/12/29.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "FriendRequestViewController.h"
#import "NSString+Base64.h"
#import "UserConfig.h"
#import "FriendModel.h"

@interface FriendRequestViewController ()
@property (weak, nonatomic) IBOutlet UITextField *msgTF;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (nonatomic , strong) NSString *userName;
@property (nonatomic , strong) NSString *userId;
@end

@implementation FriendRequestViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}
- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)sendApplicationAction:(id)sender {
    [self.view endEditing:YES];
    NSString *msg = _msgTF.text?:@"";
    if (msg && ![msg isEmptyString]) {
        msg = [msg base64EncodedString];
    } else {
        msg = [NSString stringWithFormat:@"I'm %@",[UserConfig getShareObject].userName];
        msg = [msg base64EncodedString];
    }
    [SendRequestUtil sendAddFriendWithFriendId:self.userId msg:msg];
}

- (instancetype) initWithNickname:(NSString *) nickName userId:(NSString *) userId
{
    if (self = [super init]) {
        self.userName = nickName;
        self.userId = userId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _sendBtn.layer.cornerRadius = 5.0f;
    _lblName.text = self.userName? [self.userName base64DecodedString] : @"";
    _msgTF.text = [NSString stringWithFormat:@"I'm %@",[UserConfig getShareObject].userName];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addFriendSuccess:) name:ADD_FRIEND_NOTI object:nil];
}

#pragma mark -添加好友成功通知
- (void) addFriendSuccess:(NSNotification *) noti
{
    NSInteger retCode = [noti.object integerValue];
    if (retCode == 0) { // 发送成功
        [AppD.window showHint:@"Send Success"];
        NSArray *finfAlls = [FriendModel bg_find:FRIEND_REQUEST_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue(self.userId),bg_sqlKey(@"owerId"),bg_sqlValue([UserConfig getShareObject].userId)]];
        
        NSString *msg = _msgTF.text?:@"";
        if (msg && ![msg isEmptyString]) {
            msg = [msg base64EncodedString];
        } else {
            msg = [NSString stringWithFormat:@"我是:%@",[UserConfig getShareObject].userName];
            msg = [msg base64EncodedString];
        }
        
        if (finfAlls && finfAlls.count > 0) {
            FriendModel *model = finfAlls[0];
            model.requestTime = [NSDate date];
            model.dealStaus = 3;
            model.msg = msg;
            [model bg_saveOrUpdate];
        } else {
            FriendModel *model = [[FriendModel alloc] init];
            model.bg_tableName = FRIEND_REQUEST_TABNAME;
            model.requestTime = [NSDate date];
            model.owerId = [UserConfig getShareObject].userId;
            model.userId = self.userId;
            model.msg = msg;
            model.username = [self.userName base64DecodedString];
            model.dealStaus = 3;
            [model bg_saveOrUpdate];
        }
       
    } else if (retCode == 1) { // 添加失败
        [AppD.window showHint:@"Send Failure"];
    } else if (retCode == 2) { // 已经是好友关系
        [AppD.window showHint:@"Already a good friend"];
    }
    [self performSelector:@selector(backAction:) withObject:self afterDelay:1.5f];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end