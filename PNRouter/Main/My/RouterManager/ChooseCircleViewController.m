//
//  ChooseContactViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/21.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ChooseCircleViewController.h"
#import "NSString+Base64.h"
#import "RouterModel.h"
#import "ChooseCircleCell.h"
#import "HeartBeatUtil.h"
#import "SystemUtil.h"
#import "RouterConfig.h"
#import "MyConfidant-Swift.h"
#import "SocketManageUtil.h"
#import "FileDownUtil.h"
#import "ChatListDataUtil.h"
#import "SendCacheChatUtil.h"
#import "ReviceRadio.h"
#import "UserModel.h"
#import "UserHeadUtil.h"

#import "ConnectView.h"
#import "OCTSubmanagerUser.h"
#import "OCTSubmanagerFriends.h"


@interface ChooseCircleViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,OCTSubmanagerUserDelegate>
{
    BOOL isFindRequest;
    BOOL isLoginRequest;
    NSString *currentURL;
    int socketDisCount;
    int toxSuccessCount;
    BOOL isSwitchCircle;
    int requestTime;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight; // 44
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *leaveBtn;
@property (nonatomic ,strong) ConnectView *connectView;

@property (nonatomic) BOOL isEdit;
@property (nonatomic ,strong) NSMutableArray *circleArr;

@end

@implementation ChooseCircleViewController
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNoti];
    [self dataInit];
    [self viewInit];
}
#pragma makr ---添加通知
- (void) addNoti {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gbFinashNoti:) name:GB_FINASH_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnConnect:) name:SOCKET_ON_CONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(socketOnDisconnect:) name:SOCKET_ON_DISCONNECT_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recivceUserFind:) name:USER_FIND_RECEVIE_NOTI object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSuccess:) name:SOCKET_LOGIN_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toxAddRoterSuccess:) name:TOX_ADD_ROUTER_SUCCESS_NOTI object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerPushNoti:) name:REGISTER_PUSH_NOTI object:nil];
}
#pragma mark - Operation
- (void)dataInit {
    _circleArr = [NSMutableArray array];
    NSArray *localRouters = [RouterModel getLocalRouters];
    @weakify_self
    [localRouters enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChooseCircleShowModel *model = [ChooseCircleShowModel new];
        model.showSelect = NO;
        model.isSelect = NO;
        model.routerM = obj;
        [weakSelf.circleArr addObject:model];
    }];
}

- (void)viewInit {
    _bottomHeight.constant = 0;
    [_tableV registerNib:[UINib nibWithNibName:ChooseCircleCellReuse bundle:nil] forCellReuseIdentifier:ChooseCircleCellReuse];
}

- (NSMutableArray *)getSelectCircles {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [_circleArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChooseCircleShowModel *showModel = obj;
        if (showModel.isSelect) {
            [array addObject:showModel];
        }
    }];
    return array;
}

- (void)refreshLeaveBtn {
    NSArray *selectArr = [self getSelectCircles];
    [_leaveBtn setTitle:[NSString stringWithFormat:@"Leave the Circle(%@)",@(selectArr.count)] forState:UIControlStateNormal];
}

#pragma mark - Action
- (IBAction)backAction:(id)sender {
    if (_isEdit) {
        _isEdit = NO;
        _rightBtn.hidden = NO;
        _bottomHeight.constant = 0;
        
        [_circleArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChooseCircleShowModel *model = obj;
            model.isSelect = NO;
            model.showSelect = NO;
        }];
        [_tableV reloadData];
    } else {
        [self backVC];
    }
}

- (void)backVC {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (IBAction)rightAction:(id)sender {
    _isEdit = !_isEdit;
    if (_isEdit) {
        _rightBtn.hidden = YES;
        [self refreshLeaveBtn];
        _bottomHeight.constant = 44;
        [_circleArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChooseCircleShowModel *model = obj;
            model.showSelect = YES;
            model.isSelect = NO;
        }];
        [_tableV reloadData];
    }
    
    [_tableV reloadData];
}

#pragma mark ---更新头像
- (void)updateUserHead {
    NSString *Fid = [UserModel getUserModel].userId?:@"";
    NSString *Md5 = @"0";
    [[UserHeadUtil getUserHeadUtilShare] sendUpdateAvatarWithFid:Fid md5:Md5 showHud:NO];
    
}

- (IBAction)leaveAction:(id)sender {
    NSArray *selectArr = [self getSelectCircles];
    [selectArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChooseCircleShowModel *model = obj;
        [RouterModel deleteRouterWithUsersn:model.routerM.userSn];
    }];
    
    [self dataInit];
    [_tableV reloadData];
    
    _isEdit = NO;
    _rightBtn.hidden = NO;
    _bottomHeight.constant = 0;
    
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _circleArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ChooseCircleCell_Height;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    ChooseCircleCell *cell = [tableView dequeueReusableCellWithIdentifier:ChooseCircleCellReuse];
    cell.tableRow = indexPath.row;
    ChooseCircleShowModel *model = _circleArr[indexPath.row];
    [cell configCellWithModel:model];
    @weakify_self
    cell.selectB = ^(NSInteger tableRow) {
        ChooseCircleShowModel *tempM = weakSelf.circleArr[tableRow];
        if (tempM.routerM.isConnected) {
            return;
        }
        if (weakSelf.isEdit) { // 多选点击cell
            tempM.isSelect = !tempM.isSelect;
            [weakSelf refreshLeaveBtn];
            [weakSelf.tableV reloadData];
        } else { // 切换Cirlce
            [weakSelf SwitchCircleWithModel:tempM];
        }
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark ---切换圈子
- (void) SwitchCircleWithModel:(ChooseCircleShowModel *) model
{
    if (model.routerM.isConnected) {
        return;
    }
    isSwitchCircle = YES;
    [self.view showHudInView:self.view hint:Switch_Cricle];
    RouterModel *selectRouterModel = model.routerM;
    // 发送退出请求
    [SendRequestUtil sendLogOut];
    // 停止当前心目跳
    [HeartBeatUtil stop];
    AppD.isLogOut = YES;
    AppD.inLogin = NO;
    
    if ([SystemUtil isSocketConnect]) {
        currentURL = [SystemUtil connectUrl];
        AppD.isSwitch = YES;
        // 取消当前socket 连接
         [[SocketUtil shareInstance] disconnect];
        // 停止缓存发送
        [[SendCacheChatUtil getSendCacheChatUtilShare] stop];
        // 清除所有正在发送文件
        [[SocketManageUtil getShareObject] clearAllConnectSocket];
        // 清除所有正在下载文件
        [[FileDownUtil getShareObject] removeAllTask];
        
    } else {
        AppD.isConnect = NO;
        AppD.currentRouterNumber = -1;
        [[NSNotificationCenter defaultCenter] postNotificationName:TOX_CONNECT_STATUS_NOTI object:nil];
    }
    [[ChatListDataUtil getShareObject].dataArray removeAllObjects];
    
    [RouterConfig getRouterConfig].currentRouterIp = @"";
    [RouterConfig getRouterConfig].currentRouterSn = selectRouterModel.userSn;
    [RouterConfig getRouterConfig].currentRouterToxid = selectRouterModel.toxid;
    
    [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RouterConfig getRouterConfig].currentRouterToxid];
}

#pragma mark -连接socket_tox
- (void) connectSocketWithIsShowHud:(BOOL) isShow
{
    // 当前是在局域网
    if (![[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterIp] isEmptyString])
    {
        requestTime = 10;
        //AppD.manager = nil; tox_stop
        AppD.currentRouterNumber = -1;
        NSString *connectURL = [SystemUtil connectUrl];
        [SocketUtil.shareInstance connectWithUrl:connectURL];
        
    } else {
        requestTime = 15;
        if (AppD.manager) {
            [self addRouterFriend];
        } else {
            [self loginToxWithShowHud:NO];
        }
    }
}

// 添加tox好友
- (void) addRouterFriend
{
    if (![AppD.manager.friends friendIsExitWithFriend:[RouterConfig getRouterConfig].currentRouterToxid]) {
        // 隐藏连接圈子提示
         [self.view hideHud];
        // 显示p2p连接
        [self showConnectServerLoad];
        // 添加好友
        BOOL result = [AppD.manager.friends sendFriendRequestToAddress:[RouterConfig getRouterConfig].currentRouterToxid message:@"" error:nil];
        if (!result) { // 添加好友失败
            dispatch_async(dispatch_get_main_queue(), ^{
                [self hideConnectServerLoad];
                [self switchCircleFaieldWithHintString:@"Circle connection failed."];
            });
        }
        
    } else { // 好友已存在并且在线
        if ([AppD.manager.friends getFriendConnectStatuWithFriendNumber:AppD.currentRouterNumber] > 0) {
            // 走 find 请求
            [self toxConnectSuccessSendFindRequest];
            
        } else {
            // 隐藏连接圈子提示
            [self.view hideHud];
            [self showConnectServerLoad];
        }
    }
}
// tox 连接成功后 调用find 请求
- (void) toxConnectSuccessSendFindRequest
{
    toxSuccessCount +=1;
    if (toxSuccessCount == 1) {
        isFindRequest = NO;
        [SendRequestUtil sendUserFindWithToxid:[RouterConfig getRouterConfig].currentRouterToxid usesn:[RouterConfig getRouterConfig].currentRouterSn showHud:NO];
        [self performSelector:@selector(checkFindRequstOutTime) withObject:self afterDelay:requestTime];
    }
    
}
// 显示连接p2p提示层
- (void) showConnectServerLoad
{
    if (!_connectView) {
        _connectView = [ConnectView loadConnectView];
        @weakify_self
        [_connectView setClickCancelBlock:^{
            [weakSelf switchCircleFaieldWithHintString:@"Circle connection failed."];
        }];
    }
    [_connectView showConnectView];
}
- (void) hideConnectServerLoad
{
    [_connectView hiddenConnectView];
}

#pragma mark -tox 登陆成功
- (void) toxLoginSuccessWithManager:(id<OCTManager>)manager
{
    if (manager) {
         [self addRouterFriend];
    } else {
        [self switchCircleFaieldWithHintString:@"Circle connection failed."];
    }
   
}


#pragma mark -- 切换失败
- (void) switchCircleFaieldWithHintString:(NSString *) hitStr
{
    [self.view hideHud];
    [AppD.window showFaieldHudInView:AppD.window hint:Switch_Cricle_Failed];
    
    AppD.currentRouterNumber = -1;
    AppD.isSwitch = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [RouterConfig getRouterConfig].currentRouterIp = @"";
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
       
        [AppD setRootLoginWithType:RouterType];
    });
}
#pragma mark- --切换成功
- (void) switchCircleSuccess
{
    if (![SystemUtil isSocketConnect]) {
        if (AppD.currentRouterNumber < 0) {
            return;
        }
    }
    
    [AppD.window showSuccessHudInView:AppD.window hint:@"Switched"];
    
    // 发送获取好友列表和群组列表通知
    [[NSNotificationCenter defaultCenter] postNotificationName:GET_FRIEND_GROUP_LIST_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:SWITCH_CIRCLE_SUCCESS_NOTI object:nil];
    // 取消红点
    AppD.showNewFriendAddRequestRedDot = NO;
    AppD.showNewGroupAddRequestRedDot = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_CONTACT_HD_NOTI object:nil];
    [self updateUserHead];
    AppD.isLogOut = NO;
    AppD.inLogin = YES;
    AppD.isSwitch = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    @weakify_self
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [weakSelf leftNavBarItemPressedWithPop:NO];
    });
    
}
// 检测find请求10秒内是否有返回
- (void) checkFindRequstOutTime
{
    if (!isFindRequest) {
        if (toxSuccessCount == 2) {
            isFindRequest = NO;
            [SendRequestUtil sendUserFindWithToxid:[RouterConfig getRouterConfig].currentRouterToxid usesn:[RouterConfig getRouterConfig].currentRouterSn showHud:NO];
            [self performSelector:@selector(checkFindRequstOutTime) withObject:self afterDelay:requestTime];
        } else {
            [self switchCircleFaieldWithHintString:@"Circle connection failed."];
        }
    }
}
// 检测登录请求10秒内是否有返回
- (void) checkLoginRequstOutTime
{
    if (!isLoginRequest) {
        [self switchCircleFaieldWithHintString:@"Circle connection failed."];
    }
}

#pragma mark ---通知回调
- (void) gbFinashNoti:(NSNotification *) noti
{
    [self connectSocketWithIsShowHud:NO];
}
- (void)socketOnConnect:(NSNotification *)noti {
    if (isSwitchCircle) {
        // 走find5
        isFindRequest = NO;
        [SendRequestUtil sendUserFindWithToxid:[RouterConfig getRouterConfig].currentRouterToxid usesn:[RouterConfig getRouterConfig].currentRouterSn showHud:NO];
        [self performSelector:@selector(checkFindRequstOutTime) withObject:self afterDelay:requestTime];
    }
  
}

- (void)socketOnDisconnect:(NSNotification *)noti {
    
    if (isSwitchCircle) {
        NSString *url = noti.object;
        if ([url isEqualToString:currentURL]) {
            return;
        }
        [self.view hideHud];
        [self switchCircleFaieldWithHintString:@"Circle connection failed."];
    }
    
   
}
// find5 通知回调
- (void) recivceUserFind:(NSNotification *) noti
{
    isFindRequest = YES;
    NSDictionary *receiveDic = (NSDictionary *)noti.object;
    if (receiveDic) {
        NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
        
        NSString *routherid = receiveDic[@"params"][@"RouteId"];
        NSString *usesn = receiveDic[@"params"][@"UserSn"];
        NSString *userid = receiveDic[@"params"][@"UserId"];
       // NSString *userName = receiveDic[@"params"][@"NickName"];
       
        if (![[NSString getNotNullValue:routherid] isEmptyString]) {
            [RouterConfig getRouterConfig].currentRouterToxid = routherid;
        }
        if (![[NSString getNotNullValue:usesn] isEmptyString]) {
            [RouterConfig getRouterConfig].currentRouterSn = usesn;
        }
        
        if (retCode == 0) { //已激活
            isLoginRequest = NO;
            [SendRequestUtil sendUserLoginWithPass:usesn userid:userid showHud:NO];
            [self performSelector:@selector(checkLoginRequstOutTime) withObject:self afterDelay:requestTime];
        } else { // 未激活 或者日临时帐户
           // [self sendRegisterRequestWithShowHud:YES];
            [self switchCircleFaieldWithHintString:@"Circle inactive."];
        }
    }
}

#pragma mark -登陆成功
- (void) loginSuccess:(NSNotification *) noti
{
    isLoginRequest = YES;
    [self.view hideHud];
    NSInteger retCode = [noti.object integerValue];
    if (retCode == 0) {
        [self switchCircleSuccess];
    } else if (retCode == 2) { // routeid不对
        [self switchCircleFaieldWithHintString:@"Routeid wrong."];
    } else if (retCode == 1) { //需要验证
        [self switchCircleFaieldWithHintString:@"Need to verify."];
    } else if (retCode == 3) { //uid错误
        [self switchCircleFaieldWithHintString:@"uid wrong."];
    } else if (retCode == 4) { //登陆密码错误
        [self switchCircleFaieldWithHintString:@"Login failed, verification failed."];
    } else if (retCode == 5) { //验证码错误
        [self switchCircleFaieldWithHintString:@"Verification code error."];
    } else { // 其它错误
        [self switchCircleFaieldWithHintString:@"Login failed Other error."];
    }
}
#pragma mark --- 注册推送
- (void) registerPushNoti:(NSNotification *) noti
{
    [SendRequestUtil sendRegidReqeust];
}

 #pragma mark -加router好友成功
- (void) toxAddRoterSuccess:(NSNotification *) noti
{
    if (isSwitchCircle) {
        NSLog(@"thread = %@",[NSThread currentThread]);
        NSLog(@"加router好友成功----switch circle");
        [self hideConnectServerLoad];
        [self.view showHudInView:self.view hint:Connect_Cricle];
        [self toxConnectSuccessSendFindRequest];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
