//
//  PNFileViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/20.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNFileViewController.h"
#import "EnMainCell.h"
#import "EnContactCell.h"
#import "PNPhotoViewController.h"
#import "PNMessageViewController.h"
#import "UploadFileManager.h"
#import "FingerprintVerificationUtil.h"
#import "PNContactViewController.h"
#import "SystemUtil.h"
#import <Contacts/Contacts.h>

@interface PNFileViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *mainTabView;
@property (nonatomic, assign) BOOL isPermissionContacts;
@property (nonatomic, strong) NSString *nodeContactCount;
@property (nonatomic, strong) NSString *nodeContactPath;
@property (nonatomic, strong) NSString *nodeContactKey;
@property (nonatomic, assign) NSInteger localContactCount;
@end

@implementation PNFileViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    // 获取通讯录权限
    [self getContactsPermissions];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    self.nodeContactCount = @"0";
    // 开启手势
    [FingerprintVerificationUtil checkFloderShow];
    
    // 开启上传文件监听单例
    [UploadFileManager getShareObject];
    
    _mainTabView.delegate = self;
    _mainTabView.dataSource = self;
    _mainTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_mainTabView registerNib:[UINib nibWithNibName:EnMainCellResue bundle:nil] forCellReuseIdentifier:EnMainCellResue];
    [_mainTabView registerNib:[UINib nibWithNibName:EnContactCellResue bundle:nil] forCellReuseIdentifier:EnContactCellResue];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullBookInfoNoti:) name:Pull_BookInfo_Success_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocalContactsNoti:) name:Update_Loacl_Contact_Count_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendCheckNodeContactCountRequest) name:SWITCH_CIRCLE_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateLocalCount) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [self sendCheckNodeContactCountRequest];
}
- (void) sendCheckNodeContactCountRequest
{
    [SendRequestUtil sendPullBookInfoWithFileId:0 showHud:NO];
}
- (void) updateLocalCount
{
    [_mainTabView reloadData];
}
- (void) getContactsPermissions
{
    CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
    if (status == CNAuthorizationStatusNotDetermined) {
        CNContactStore *store = [[CNContactStore alloc] init];
        @weakify_self
        [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError*  _Nullable error) {
            if (error) {
                NSLog(@"授权失败");
            }else {
                NSLog(@"成功授权");
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (!weakSelf.isPermissionContacts) {
                        weakSelf.isPermissionContacts = YES;
                        [weakSelf.mainTabView reloadData];
                    }
                });
            }
        }];
    }
    else if(status == CNAuthorizationStatusRestricted)
    {
        NSLog(@"用户拒绝");
       
    }
    else if (status == CNAuthorizationStatusDenied)
    {
        NSLog(@"用户拒绝");
       
    }
    else if (status == CNAuthorizationStatusAuthorized)//已经授权
    {
        //有通讯录权限-- 进行下一步操作
        self.isPermissionContacts = YES;
        [self.mainTabView reloadData];
    }
}
#pragma mark -----------------tableview deleate ---------------------
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return EnMainCellHeight;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        EnMainCell *myCell = [tableView dequeueReusableCellWithIdentifier:EnMainCellResue];
        return myCell;
    } else {
        EnContactCell *myCell = [tableView dequeueReusableCellWithIdentifier:EnContactCellResue];
        self.localContactCount = 0;
        if (_isPermissionContacts) {
            self.localContactCount = [SystemUtil getLoacContactCount];
        }
        myCell.lblLocalCount.text = [NSString stringWithFormat:@"%ld",self.localContactCount];
        myCell.lblNodeCount.text = self.nodeContactCount;
        return myCell;
    }
    
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) { // 加密相册
        PNPhotoViewController *vc = [[PNPhotoViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (indexPath.row == 1) { // 通讯录
        PNContactViewController *vc = [[PNContactViewController alloc] initWithNodePath:self.nodeContactPath nodeKey:self.nodeContactKey nodeCount:self.nodeContactCount isPermission:self.isPermissionContacts loaclContactCount:self.localContactCount];
        [self.navigationController pushViewController:vc animated:YES];
    }
   
}

#pragma mark ----------请求通知回调
- (void) pullBookInfoNoti:(NSNotification *) noti
{
    NSDictionary *parames = noti.object;
    self.nodeContactCount = [NSString stringWithFormat:@"%@",parames[@"Num"]?:@(0)];
    self.nodeContactPath = parames[@"Fpath"];
    self.nodeContactKey = parames[@"Fkey"];
    if (self.nodeContactCount > 0) {
        [self.mainTabView reloadData];
    }
}
- (void) updateLocalContactsNoti:(NSNotification *) noti
{
    NSArray *resultArr = noti.object;
    if (resultArr && resultArr.count == 3) {
        self.nodeContactPath = resultArr[0];
        self.nodeContactKey = resultArr[1];
        self.nodeContactCount = resultArr[2];
    }
   // [self.mainTabView reloadData];
}
@end
