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
#import "UserHeadUtil.h"

@interface FriendRequestViewController ()
@property (weak, nonatomic) IBOutlet UITextField *msgTF;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (nonatomic , strong) NSString *userName;
@property (nonatomic , strong) NSString *userId;
@property (nonatomic , strong) NSString *singPK;
@property (nonatomic, strong) NSString *fToxId;
@property (nonatomic, strong) NSString *codeType;
@property (nonatomic, assign) int logId;
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
    NSString *msg = _msgTF.text.trim?:@"";
    if (msg && msg.length>0) {
        msg = [msg base64EncodedString];
    } else {
        msg = [NSString stringWithFormat:@"I'm %@",[UserConfig getShareObject].userName];
        msg = [msg base64EncodedString];
    }
    if ([self.codeType isEqualToString:@"type_0"]) {
        [SendRequestUtil sendAddFriendWithFriendId:self.userId msg:msg showHud:YES];
    } else {
        [SendRequestUtil sendNewAddFriendWithFpk:self.singPK msg:msg toxid:self.fToxId showHud:YES];
    }
    
   _logId = [SendRequestUtil sendLogRequestWtihAction:ADDFRIENDREQ logid:0 type:0 result:0 info:@"send_add_friend_request"];
    
    [FIRAnalytics logEventWithName:kFIREventSelectContent
    parameters:@{
                 kFIRParameterItemID:FIR_CHAT_ADD_FRIEND,
                 kFIRParameterItemName:FIR_CHAT_ADD_FRIEND,
                 kFIRParameterContentType:FIR_CHAT_ADD_FRIEND
                 }];
    
}

- (instancetype) initWithNickname:(NSString *) nickName userId:(NSString *) userId signpk:(NSString *) signpk toxId:(NSString *) toxId codeType:(NSString *) type
{
    if (self = [super init]) {
        self.userName = nickName;
        self.userId = userId;
        self.singPK = signpk;
        self.fToxId = toxId;
        self.codeType = type;
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
    [[UserHeadUtil getUserHeadUtilShare] sendUpdateAvatarWithFid:self.userId md5:@"0" showHud:NO];
    
    int retCode = [noti.object intValue];
    if (retCode == 0) { // 发送成功
        [AppD.window showHint:Send_Success_Str];
        NSArray *finfAlls = [FriendModel bg_find:FRIEND_REQUEST_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue(self.userId),bg_sqlKey(@"owerId"),bg_sqlValue([UserConfig getShareObject].userId)]];
        
        NSString *msg = _msgTF.text?:@"";
        if (msg && ![msg isEmptyString]) {
            msg = [msg base64EncodedString];
        } else {
            msg = [NSString stringWithFormat:@"I'm %@",[UserConfig getShareObject].userName];
            msg = [msg base64EncodedString];
        }
        
        if (finfAlls && finfAlls.count > 0) {
            FriendModel *model = finfAlls[0];
            model.requestTime = [NSDate date];
            model.signPublicKey = self.singPK;
            model.dealStaus = 3;
            model.msg = msg;
            [model bg_saveOrUpdate];
        } else {
            FriendModel *model = [[FriendModel alloc] init];
            model.bg_tableName = FRIEND_REQUEST_TABNAME;
            model.isUnRead = YES;
            model.requestTime = [NSDate date];
            model.owerId = [UserConfig getShareObject].userId;
            model.userId = self.userId;
            model.signPublicKey = self.singPK;
            model.msg = msg;
            model.username = [self.userName base64DecodedString];
            model.dealStaus = 3;
            [model bg_saveOrUpdate];
        }
        // 日志打点
        [SendRequestUtil sendLogRequestWtihAction:ADDFRIENDREQ logid:_logId type:100 result:retCode info:@"send_add_friend_request_success"];
        
    } else if (retCode == 1) { // 添加失败
        [AppD.window showHint:Send_Faield];
        // 日志打点
        [SendRequestUtil sendLogRequestWtihAction:ADDFRIENDREQ logid:_logId type:0xFF result:retCode info:@"send_add_friend_request_failed"];
    } else if (retCode == 2) { // 已经是好友关系
        [AppD.window showHint:@"Already a circle contact"];
        // 日志打点
        [SendRequestUtil sendLogRequestWtihAction:ADDFRIENDREQ logid:_logId type:0xFF result:retCode info:@"send_add_friend_request_failed"];
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
