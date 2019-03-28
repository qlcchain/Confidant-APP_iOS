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
#import "PNRouter-Swift.h"
#import "SocketManageUtil.h"
#import "FileDownUtil.h"
#import "ChatListDataUtil.h"
#import "SendCacheChatUtil.h"
#import "ReviceRadio.h"
#import "UserModel.h"
#import "UserHeadUtil.h"

@interface ChooseCircleViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    BOOL isFindRequest;
    BOOL isLoginRequest;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight; // 44
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *leaveBtn;

@property (nonatomic) BOOL isEdit;
@property (nonatomic ,strong) NSMutableArray *circleArr;

@end

@implementation ChooseCircleViewController
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [super viewWillAppear:animated];
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
//        NSArray *selectArr = [self getSelectCircles];
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
        if (weakSelf.isEdit) { // 多选点击cell
            tempM.isSelect = YES;
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
    [self.view showHudInView:self.view hint:Connect_Cricle];
    RouterModel *selectRouterModel = model.routerM;
    // 发送退出请求
    [SendRequestUtil sendLogOut];
    // 停止当前心目跳
    [HeartBeatUtil stop];
    AppD.isLogOut = YES;
    AppD.inLogin = NO;
    
    if ([SystemUtil isSocketConnect]) {
        AppD.isSwitch = YES;
        // 取消当前socket 连接
         [[SocketUtil shareInstance] disconnect];
        // 停止缓存发送
        [[SendCacheChatUtil getSendCacheChatUtilShare] stop];
        // 清除所有正在发送文件
        [[SocketManageUtil getShareObject] clearAllConnectSocket];
        // 清除所有正在下载文件
        [[FileDownUtil getShareObject] removeAllTask];
        
        [RouterConfig getRouterConfig].currentRouterIp = @"";
        [RouterConfig getRouterConfig].currentRouterSn = selectRouterModel.userSn;
        [RouterConfig getRouterConfig].currentRouterToxid = selectRouterModel.toxid;
        
        [[ReviceRadio getReviceRadio] startListenAndNewThreadWithRouterid:[RouterConfig getRouterConfig].currentRouterToxid];
        
    } else {
        AppD.isConnect = NO;
        // [self logOutTox];
        [[NSNotificationCenter defaultCenter] postNotificationName:TOX_CONNECT_STATUS_NOTI object:nil];
    }
    [[ChatListDataUtil getShareObject].dataArray removeAllObjects];
}

#pragma mark -连接socket_tox
- (void) connectSocketWithIsShowHud:(BOOL) isShow
{
    // 当前是在局域网
    if (![[NSString getNotNullValue:[RouterConfig getRouterConfig].currentRouterIp] isEmptyString])
    {
        AppD.manager = nil;
        NSString *connectURL = [SystemUtil connectUrl];
        [SocketUtil.shareInstance connectWithUrl:connectURL];
        
    } else {
        if (AppD.manager) {
           // [self addRouterFriend];
        } else {
            [self loginTox];
        }
    }
}
- (void) findOrLogin
{
//    if (isFind) {
//        isFind = NO;
//        [SendRequestUtil sendUserFindWithToxid:[RouterConfig getRouterConfig].currentRouterToxid usesn:[RouterConfig getRouterConfig].currentRouterSn];
//    } else if (isLogin) {
//        isLogin = NO;
//        sendCount = 0;
//        [self sendLoginRequestWithUserid:self.selectRouther.userid usersn:@""];
//    }
}



#pragma mark -- 切换失败
- (void) switchCircleFaieldWithHintString:(NSString *) hitStr
{
    [self.view hideHud];
    AppD.isSwitch = NO;
    [AppD setRootLoginWithType:RouterType];
    [AppD.window showHint:hitStr];
}
// 检测find请求10秒内是否有返回
- (void) checkFindRequstOutTime
{
    if (!isFindRequest) {
        [self.view hideHud];
        [self switchCircleFaieldWithHintString:@"Circle connection failed."];
    }
}
// 检测登录请求10秒内是否有返回
- (void) checkLoginRequstOutTime
{
    if (!isLoginRequest) {
        [self.view hideHud];
        [self switchCircleFaieldWithHintString:@"Circle connection failed."];
    }
}

#pragma mark ---通知回调
- (void) gbFinashNoti:(NSNotification *) noti
{
    [self connectSocketWithIsShowHud:NO];
}
- (void)socketOnConnect:(NSNotification *)noti {
  // 走find5
    isFindRequest = NO;
   [SendRequestUtil sendUserFindWithToxid:[RouterConfig getRouterConfig].currentRouterToxid usesn:[RouterConfig getRouterConfig].currentRouterSn];
    [self performSelector:@selector(checkFindRequstOutTime) withObject:self afterDelay:10];
}

- (void)socketOnDisconnect:(NSNotification *)noti {

    [self.view hideHud];
    [self switchCircleFaieldWithHintString:@"Circle connection failed."];
   
}
// find5 通知回调
- (void) recivceUserFind:(NSNotification *) noti
{
    isFindRequest = YES;
    NSDictionary *receiveDic = (NSDictionary *)noti.object;
    if (receiveDic) {
        NSInteger retCode = [receiveDic[@"params"][@"RetCode"] integerValue];
       // NSString *routherid = receiveDic[@"params"][@"RouteId"];
        NSString *usesn = receiveDic[@"params"][@"UserSn"];
        NSString *userid = receiveDic[@"params"][@"UserId"];
       // NSString *userName = receiveDic[@"params"][@"NickName"];
       
        if (retCode == 0) { //已激活
            isLoginRequest = NO;
            [SendRequestUtil sendUserLoginWithPass:usesn userid:userid showHud:NO];
            [self performSelector:@selector(checkLoginRequstOutTime) withObject:self afterDelay:10];
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
        // 发送获取好友列表和群组列表通知
        [[NSNotificationCenter defaultCenter] postNotificationName:GET_FRIEND_GROUP_LIST_NOTI object:nil];
         [[NSNotificationCenter defaultCenter] postNotificationName:SWITCH_CIRCLE_SUCCESS_NOTI object:nil];
        [self updateUserHead];
        AppD.isLogOut = NO;
        AppD.inLogin = YES;
        AppD.isSwitch = NO;
        [self leftNavBarItemPressedWithPop:NO];
        [AppD.window showHint:@"Successful circle switching."];
        
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
