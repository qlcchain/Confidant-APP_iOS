//
//  AddFriendViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/13.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "AddFriendViewController.h"
#import "ContactsHeadView.h"
#import "QRViewController.h"
#import "SocketMessageUtil.h"
#import "UserModel.h"
#import "AddFriendCellTableViewCell.h"
#import "FriendModel.h"
#import "RSAModel.h"
#import "SystemUtil.h"
#import "FriendRequestViewController.h"
#import "UserHeaderModel.h"
#import "AESCipher.h"
#import "RouterModel.h"
//#import "NSString+Base64.h"

@interface AddFriendViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic ,strong) NSMutableArray *dataArray;

@property (nonatomic ,assign)  NSInteger currentRow;
@property (nonatomic ,assign)  NSInteger currentTag;
@end

@implementation AddFriendViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(realFriendNoti:) name:DEAL_FRIEND_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestAddFriendNoti:) name:FRIEND_ACCEPED_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userHeadDownloadSuccess:) name:USER_HEAD_DOWN_SUCCESS_NOTI object:nil];
}

#pragma -mark layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}

- (IBAction)rightAction:(id)sender {
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
                    [AppD.window showHint:@"QR code format is wrong."];
                } else {
                    NSString *nickName = @"";
                    if (codeValues.count>2) {
                        nickName = codeValues[2];
                    }
                    [weakSelf addFriendRequest:codeValue nickName:nickName signpk:codeValues[3] type:codeValue toxid:@""];
                }
            } else if ([[NSString getNotNullValue:codeValue] isEqualToString:@"type_5"]) { // 是好友码
                                                   
                NSString *aesCode = aesDecryptString(codeValues[1], AES_KEY)?:@"";
                if (aesCode.length > 0) {
                    NSArray *codeArr = [aesCode componentsSeparatedByString:@","];
                    if (codeArr && codeArr.count == 4) {
                        
                       NSString *signPK = [EntryModel getShareObject].signPublicKey;
                       // NSString *toxid = [RouterModel getConnectRouter].toxid;
                        //  && [codeArr[2] isEqualToString:toxid]
                        if ([codeArr[1] isEqualToString:signPK]) {
                            
                            [AppD.window showHint:@"You cannot add yourself as a friend."];
                            
                        } else {
                            
                             [weakSelf addFriendRequest:@"" nickName:codeArr[3] signpk:codeArr[1] type:codeValue toxid:codeArr[2]];
                        }
                    } else {
                        [AppD.window showHint:@"QR code format is wrong."];
                    }
                } else {
                    [AppD.window showHint:@"QR code format is wrong."];
                }
                                                         
            }  else {
                [weakSelf.view showHint:@"format error!"];
            }
        }
    }];
    [self presentModalVC:vc animated:YES];
}
#pragma mark -Operation-
- (void)addFriendRequest:(NSString *)friendId nickName:(NSString *) nickName signpk:(NSString *) signpk type:(NSString *) type toxid:(NSString *) toxid{
    FriendRequestViewController *vc = [[FriendRequestViewController alloc] initWithNickname:nickName userId:friendId signpk:signpk toxId:toxid codeType:type];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addObserve];
    
    _searchBackView.layer.cornerRadius = 3.0f;
    _searchBackView.layer.masksToBounds = YES;
    _searchTF.delegate = self;
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableV registerNib:[UINib nibWithNibName:AddFriendCellReuse bundle:nil] forCellReuseIdentifier:AddFriendCellReuse];
    [self checkData];
}

#pragma mark -查询好友请求数据库
- (void) checkData
{
    if (self.dataArray.count > 0) {
        [self.dataArray removeAllObjects];
    }
    NSArray *finfAlls = [FriendModel bg_find:FRIEND_REQUEST_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"owerId"),bg_sqlValue([UserModel getUserModel].userId)]];
    if (finfAlls && finfAlls.count > 0) {
        [self.dataArray addObjectsFromArray:finfAlls];
    }
     [_tableV reloadData];
}


#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return AddFriendCellHeight;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 64;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    backView.backgroundColor = [UIColor clearColor];
    ContactsHeadView *view = [ContactsHeadView loadContactsHeadView];
    view.lblTitle.text = @"Notifications";
    view.frame = backView.bounds;
    [backView addSubview:view];
    return backView;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    AddFriendCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AddFriendCellReuse];
    FriendModel *model = self.dataArray[indexPath.row];
    cell.tag = indexPath.row;
    [cell setFriendModel:model];
    @weakify_self
    [cell setRightBlcok:^(NSInteger tag, NSInteger row) {
        [weakSelf.view showHudInView:weakSelf.view hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
        [weakSelf sendAgreeFriendWithRow:row];
    }];
    
    return cell;
}

- (void) sendAgreeFriendWithRow:(NSInteger) row
{
    self.currentRow = row;
    FriendModel *models = self.dataArray[row];
    [SocketMessageUtil sendAgreedOrRefusedWithFriendMode:models withType:[NSString stringWithFormat:@"%d",0]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}


#pragma mark - NOTI
- (void) realFriendNoti:(NSNotification *) noti
{
    [self.view hideHud];
    NSString *statu = (NSString *)noti.object;
    FriendModel *friendModel = (FriendModel *)self.dataArray[self.currentRow];
    if ([statu isEqualToString:@"0"]) { // 服务器处理失败
        [AppD.window showHint:@"处理失败"];
    } else {
        friendModel.dealStaus = 1;
        [_tableV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.currentRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        if (_currentTag == 1) { // 同意
            // 保存到好友列表
//            FriendModel *model = [[FriendModel alloc] init];
//            model.bg_tableName = FRIEND_LIST_TABNAME;
//            model.username = friendModel.username;
//            model.userId = friendModel.userId;
//            [model bg_saveOrUpdateAsync:^(BOOL isSuccess) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [[NSNotificationCenter defaultCenter] postNotificationName:FRIEND_LIST_CHANGE_NOTI object:nil];
//
//                });
//            }];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:FRIEND_LIST_CHANGE_NOTI object:nil];
            
        } else { // 拒绝
            
        }
        [friendModel bg_saveOrUpdateAsync:nil];
    }
}
- (void) requestAddFriendNoti:(NSNotification *) noti
{
    NSString *userId = noti.object;
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *moodel = obj;
        if ([moodel.userId isEqualToString:userId]) {
            moodel.dealStaus = 1;
            *stop = YES;
        }
    }];
    [_tableV reloadData];
}

- (void)userHeadDownloadSuccess:(NSNotification *)noti {
//    UserHeaderModel *model = noti.object;
    [_tableV reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
