//
//  SendFileListViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/4/4.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "SendFileListViewController.h"
#import "SendFileHeadView.h"
#import "UserConfig.h"
#import "FileListModel.h"
#import "FileListCell.h"

@interface SendFileListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *mainTabV;
@property (nonatomic ,strong) SendFileHeadView *headView;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@end

@implementation SendFileListViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark ---layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (IBAction)cancelAction:(id)sender {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加通知
    [self addNotifcation];
    
    UIView *headBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 158)];
     self.headView = [SendFileHeadView getSendFileHeadView];
    [_headView.localFileBtn addTarget:self action:@selector(selectLocalFile:) forControlEvents:UIControlEventTouchUpInside];
    [headBackView addSubview:_headView];
    [self.headView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(headBackView).offset(0);
    }];
    [_mainTabV registerNib:[UINib nibWithNibName:FileListCellResue bundle:nil] forCellReuseIdentifier:FileListCellResue];
    _mainTabV.delegate = self;
    _mainTabV.dataSource = self;
    [_mainTabV setTableHeaderView:headBackView];
}
#pragma mark --添加通知
- (void) addNotifcation
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullFileListCompleteNoti:) name:PullFileList_Complete_Noti object:nil];
}

#pragma mark - Request
- (void)sendPullFileList {
    NSString *UserId = [UserConfig getShareObject].userId;
    NSNumber *MsgStartId = @(0);
    NSNumber *MsgNum = @(50);
    NSNumber *Category = @(0); // ALL
    NSNumber *FileType = @(0);
    
    [SendRequestUtil sendPullFileListWithUserId:UserId MsgStartId:MsgStartId MsgNum:MsgNum Category:Category FileType:FileType showHud:NO];
}

#pragma mark ---选择本地文件
- (void) selectLocalFile:(UIButton *) sender
{
    
}

#pragma mark --UITableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FileListCellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileListCell *myCell = [tableView dequeueReusableCellWithIdentifier:FileListCellResue];
    FileListModel *model = self.dataArray[indexPath.row];
    [myCell setFileModel:model];
    return myCell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark ---通知回调
- (void)pullFileListCompleteNoti:(NSNotification *)noti {
    
    NSDictionary *receiveDic = noti.object;
    NSString *Payload = receiveDic[@"params"][@"Payload"];
    NSArray *payloadArr = [FileListModel mj_objectArrayWithKeyValuesArray:Payload.mj_JSONObject];
    if (self.dataArray.count > 0) {
        [self.dataArray removeAllObjects];
    }
    [self.dataArray addObjectsFromArray:payloadArr];
    [_mainTabV reloadData];
}


@end
