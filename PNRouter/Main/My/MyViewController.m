//
//  MyViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "MyViewController.h"
#import "MyHeadView.h"
#import "MyCell.h"
#import "MyDetailViewController.h"
#import "UserModel.h"
#import "KeyCUtil.h"
#import "FriendModel.h"
#import "SocketMessageUtil.h"
#import <WZLBadge/WZLBadgeImport.h>
#import "PNRouter-Swift.h"
#import "RouterManagerViewController.h"
#import "SystemUtil.h"
#import "OCTSubmanagerUser.h"
#import "PersonCodeViewController.h"
#import "RMDownloadIndicator.h"
#import "LibsodiumUtil.h"
//#import <toxcore/crypto_core.h>
#import "crypto_core.h"
#import <libsodium/crypto_box.h>


struct ResultFile {

    char sendMsg[100];
};

@interface MyViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableString *pairKey;
    NSArray *publicArr;
    struct ResultFile filemsg;
}
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic , strong) NSMutableArray *dataArray;
@property (nonatomic , strong) MyHeadView *myHeadView;

@property (nonatomic , assign) CGFloat downloadedBytes;
@property (strong, nonatomic) RMDownloadIndicator *filedIndicator_left;
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;
@end

@implementation MyViewController

#pragma mark - Observe
- (void)observe {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userHeadChangeNoti:) name:USER_HEAD_CHANGE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ownerOnLine:) name:OWNER_ONLINE_NOTI object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray arrayWithObjects:@[@"Router management"],@[@"Share QRCode"],@[@"Settings"], nil];
    }
    return _dataArray;
}
- (MyHeadView *)myHeadView
{
    if (!_myHeadView) {
        _myHeadView = [MyHeadView loadMyHeadView];
        _myHeadView.lblName.text = [UserModel getUserModel].username;
        _myHeadView.isMyHead = YES;
        [_myHeadView setUserNameFirstWithName:[StringUtil getUserNameFirstWithName:[UserModel getUserModel].username]];
        _myHeadView.lblContent.text = @"Add to my status";
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(jumpDetailvc)];
        _myHeadView.userInteractionEnabled = YES;
        [_myHeadView addGestureRecognizer:gesture];
    }
    return _myHeadView;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    self.myHeadView.lblName.text = [UserModel getUserModel].username;
    [self.myHeadView setUserNameFirstWithName:[StringUtil getUserNameFirstWithName:[UserModel getUserModel].username]];
    
    UserModel *userM = [UserModel getUserModel];
    [SocketMessageUtil sendUserIsOnLine:userM.userId?:@""];
    [self updateOnlineStatus:NO];
    [_tableV reloadSections:[NSIndexSet indexSetWithIndex:self.dataArray.count-1] withRowAnimation:UITableViewRowAnimationNone];
    
    
}


- (void)updateView:(CGFloat)val
{
    self.downloadedBytes+=val;
    [self.filedIndicator_left updateWithTotalBytes:100 downloadedBytes:self.downloadedBytes];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    //[self updateView:10.0f];
   

}

- (void) entryText
{
    unsigned char pk[32];
    unsigned char sk[32];
    char *seed = "123456";
    crypto_box_seed_keypair(pk,sk,seed);
    
    NSMutableString *pkstr =  [LibsodiumUtil charsToString:pk];
    
    NSLog(@"pkstr = %@",pkstr);
    
   
    
    //dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
        [LibsodiumUtil getPrivatekeyAndPublickey];
        pairKey = [LibsodiumUtil getSymmetricKeyPair];
    
        unsigned char parkey[32];
        unsigned char mCode;
        publicArr = [pairKey componentsSeparatedByString:@" "];
        for (int i = 0; i < publicArr.count ; ++i) {
            sscanf([[publicArr objectAtIndex:i] UTF8String], "%x", &mCode);
            parkey[i] = mCode;
        }
        uint8_t nonce[CRYPTO_NONCE_SIZE];
        random_nonce(nonce);
    
    NSString *TempString = @"sevensoft os good 好的";
    TempString = [Base58Util Base58EncodeWithCodeName:TempString];
    char css[1024];
    
    memcpy(css, [TempString cStringUsingEncoding:NSASCIIStringEncoding], 2*[TempString length]);
    
    NSLog(@"css====%s ",css);
        
        //[LibsodiumUtil encrypt_data_symmetric:str chararr:parkey];
    
        char enstr[sizeof(css)+crypto_box_BOXZEROBYTES];
        const int encrypted_length = encrypt_data_symmetric(parkey, nonce, css,sizeof(css), enstr);
        if (encrypted_length) {
            NSLog(@"---%s",enstr);
        }

        char destr[sizeof(enstr)+crypto_box_ZEROBYTES];
       const int decrypted_length = decrypt_data_symmetric(parkey, nonce, enstr,sizeof(enstr), destr);
    NSString *destrsss = [NSString stringWithCString:destr encoding:NSUTF8StringEncoding];
        if (decrypted_length) {
            NSLog(@"---%@",destrsss);
        }

        int32_t decrypt_data_symmetric(const uint8_t *shared_key, const uint8_t *nonce, const uint8_t *encrypted, size_t length,
                                       uint8_t *plain);
    
        
 //   });
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self observe];
    
    _lblVersion.text = [NSString stringWithFormat:@"V:%@ (Build %@)",APP_Version,APP_Build];
    
    _tableV.delegate = self;
    _tableV.dataSource = self;
    UIView *headBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 135)];
    [headBackView addSubview:self.myHeadView];
    _tableV.tableHeaderView = headBackView;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableV registerNib:[UINib nibWithNibName:MyCellReuse bundle:nil] forCellReuseIdentifier:MyCellReuse];
    
     [self.view addSubview:self.filedIndicator_left];
    
//    [self entryText];
    
}

- (void)updateOnlineStatus:(BOOL)onLine {
//    [self.myHeadView.lblName showBadge];
//    self.myHeadView.lblName.badgeBgColor = onLine?[UIColor greenColor]:RGB(230, 230, 230);
}

#pragma mark - Transition
- (void) jumpDetailvc {
    MyDetailViewController *vc = [[MyDetailViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToRouterManagement {
    RouterManagerViewController *vc = [[RouterManagerViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rowArray = self.dataArray[section];
    return rowArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MyCellReuse_Height;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 16;
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MyCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCellReuse];
     NSArray *rowArray = self.dataArray[indexPath.section];
    cell.lblContent.text = rowArray[indexPath.row];
    cell.iconImageView.image = [UIImage imageNamed:rowArray[indexPath.row]];
    cell.lblSubContent.hidden = YES;
    if (indexPath.section == self.dataArray.count-1) {
        cell.lblSubContent.hidden = NO;
        if ([SystemUtil isSocketConnect]) {
            if ([SocketUtil.shareInstance getSocketConnectStatus] == socketConnectStatusConnected) {
                cell.lblSubContent.text = @"OnLine";
            } else {
                cell.lblSubContent.text = @"OffLine";
            }
        } else {
           OCTToxConnectionStatus connectStatus = [AppD.manager.user connectionStatus];
            if (connectStatus > 0) {
                cell.lblSubContent.text = @"OnLine";
            } else {
                cell.lblSubContent.text = @"OffLine";
            }
        }
        
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self jumpToRouterManagement];
        }
    }
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
           // [KeyCUtil deleteAllKey];
          //  [FriendModel bg_drop:FRIEND_LIST_TABNAME];
           // [FriendModel bg_drop:FRIEND_REQUEST_TABNAME];
           // exit(0);
            PersonCodeViewController *vc = [[PersonCodeViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - 通知
- (void) userHeadChangeNoti:(NSNotification *) noti
{
    [_myHeadView setUserNameFirstWithName:[StringUtil getUserNameFirstWithName:[UserModel getUserModel].username]];
}

- (void)ownerOnLine:(NSNotification *)noti {
    // 0：离线 1：在线 2：隐身 3：忙碌
    NSInteger status = [noti.object integerValue];
    BOOL online = NO;
    if (status == 1) {
        online = YES;
    }
    [self updateOnlineStatus:online];
}

@end
