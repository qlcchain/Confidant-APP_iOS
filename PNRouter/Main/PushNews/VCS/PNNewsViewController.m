//
//  PNNewsViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/14.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNNewsViewController.h"
#import "PNBindQLCAddressView.h"
#import "PNRecevieQLCAddressView.h"
//#import "PNPushNewsHeadView.h"
#import "PNNewsCell.h"
#import "AFHTTPClientV2.h"
#import "SystemUtil.h"
#import "PNCampaignModel.h"
#import <MJRefresh.h>


@interface PNNewsViewController ()<UITableViewDelegate,UITableViewDataSource,CAAnimationDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tabView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) UIImageView *headView;
@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) PNBindQLCAddressView *addressView;
@property (nonatomic, strong) PNRecevieQLCAddressView *recevieaAddressView;
@property (nonatomic, strong) NSString *qlcWalletAddress;
@property (nonatomic, strong) NSString *neoWalletAddress;
@property (nonatomic, assign) BOOL isGetWalletFinsh;
@property (nonatomic, strong) UIView *animationView;
@end

@implementation PNNewsViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}
- (IBAction)nextAction:(id)sender {
}
#pragma mark-------通知定义
- (void) addNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bindWalletAddressNoti:) name:BakWalletAccount_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getWalletAddressNoti:) name:GetWalletAccount_Noti object:nil];
}
#pragma mark-------layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (PNBindQLCAddressView *)addressView
{
    if (!_addressView) {
        _addressView = [PNBindQLCAddressView loadPNBindQLCAddressView];
         @weakify_self
        [_addressView setCloseBlock:^{
            [UIView animateWithDuration:0.4 animations:^{
                weakSelf.addBtn.alpha = 1.0f;
            }];
        }];
    }
    return _addressView;
}
- (PNRecevieQLCAddressView *)recevieaAddressView
{
    if (!_recevieaAddressView) {
        _recevieaAddressView = [PNRecevieQLCAddressView loadPNRecevieQLCAddressView];
        
        @weakify_self
        [_recevieaAddressView setEditBlock:^(NSInteger tag){
            [[weakSelf addressView] showPNBindQLCAddressView:weakSelf.view];
            weakSelf.addressView.qlcTF.text = weakSelf.qlcWalletAddress;
            weakSelf.addressView.neoTF.text = weakSelf.neoWalletAddress;
        }];
        [_recevieaAddressView setCloseBlock:^{
            [UIView animateWithDuration:0.4 animations:^{
                weakSelf.addBtn.alpha = 1.0f;
            }];
        }];
    }
    _recevieaAddressView.lblqlcAddress.text = self.qlcWalletAddress?:@"";
    _recevieaAddressView.lblneoAddress.text = self.neoWalletAddress?:@"";
    return _recevieaAddressView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    
    UIImageView *headView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background_push"]];
    headView.contentMode =UIViewContentModeScaleAspectFit;
    headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 180);
    _headView = headView;

    UIView *back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 180)];
    [back addSubview:_headView];
    
     _tabView.tableHeaderView = back;
    _tabView.delegate = self;
    _tabView.dataSource = self;
    _tabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tabView registerNib:[UINib nibWithNibName:PNNewsCellResue bundle:nil] forCellReuseIdentifier:PNNewsCellResue];
    // 创建悬浮按钮
    [self createButton];
    // 创建通知
    [self addNoti];
    // 查询活动列表
    _tabView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(sendCampaignListRequest)];
    // Hide the time
    ((MJRefreshStateHeader *)_tabView.mj_header).lastUpdatedTimeLabel.hidden = YES;
    // Hide the status
    ((MJRefreshStateHeader *)_tabView.mj_header).stateLabel.hidden = YES;
    [_tabView.mj_header beginRefreshing];

    // 查询绑定钱包地址
    [SendRequestUtil sendGetWalletAccountWithWalletType:0 showHud:NO];
    
    // 埋点
    [FIRAnalytics logEventWithName:kFIREventSelectContent
    parameters:@{
                 kFIRParameterItemID:FIR_CHECK_CAMPAIGN,
                 kFIRParameterItemName:FIR_CHECK_CAMPAIGN,
                 kFIRParameterContentType:FIR_CHECK_CAMPAIGN
                 }];
    
   // PNPushNewsHeadView *headView = [PNPushNewsHeadView loadPNPushNewsHeadView];
   // _tabView.tableHeaderView = headView;
    // @"http://192.168.0.190:8080/capi/msg/list.json";//
   
    
}

#pragma mark--------发送活动列表请求方法
- (void) sendCampaignListRequest
{
     //[self.view showHudInView:self.view hint:Loading_Str];
     NSDictionary *parames = @{@"orType":@"",@"page":@"0",@"size":@"50"};
     @weakify_self
     [AFHTTPClientV2 requestConfidantWithBaseURLStr:Campaign_List_Url params:parames httpMethod:HttpMethodPost userInfo:nil successBlock:^(NSURLSessionDataTask *dataTask, id responseObject) {
        // [weakSelf.view hideHud];
         AppD.campaignUnReadCount = 0;
         [weakSelf.tabView.mj_header endRefreshing];
         NSArray *resultArray = responseObject[@"messageList"]?:@[];
         if (weakSelf.dataArray.count > 0) {
             [weakSelf.dataArray removeAllObjects];
         }
         [weakSelf.dataArray addObjectsFromArray:[PNCampaignModel mj_objectArrayWithKeyValuesArray:resultArray]];
         [weakSelf.tabView reloadData];
         
         [weakSelf saveCampaignIdToLocal];
         
     } failedBlock:^(NSURLSessionDataTask *dataTask, NSError *error) {
        // [weakSelf.view hideHud];
        [weakSelf.tabView.mj_header endRefreshing];
         [weakSelf.view showHint:Failed];
     }];
}
#pragma mark---------保存活动消息id到本地
- (void) saveCampaignIdToLocal
{
    NSMutableArray *campaignIds = [NSMutableArray array];
    @weakify_self
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weakSelf.dataArray enumerateObjectsUsingBlock:^(PNCampaignModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [campaignIds addObject:obj.campaignId];
        }];
        if (campaignIds.count > 0) {
            NSString *ids = [campaignIds componentsJoinedByString:@","];
            [HWUserdefault updateObject:ids withKey:Campaing_ids_key];
        }
    });
}

#pragma mark --------tableview delegate-----------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat width = SCREEN_WIDTH;
    CGFloat yOffset = scrollView.contentOffset.y  ;
    if (yOffset < 0) {
        CGFloat totalOffset = 185 + ABS(yOffset);
        CGFloat f = totalOffset / 185;
        _headView.frame = CGRectMake(- (width * f - width) / 2, yOffset, width * f, totalOffset);
    } else if (yOffset == 0) {
        _headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 180);
    }
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PNCampaignModel *model = [self.dataArray objectAtIndex:indexPath.row];
    if (model.fontH == 0) {
        model.subjectH = [SystemUtil heightForString:model.subject font:[UIFont fontWithName:@"Helvetica Neue" size:16.0] andWidth:SCREEN_WIDTH-92];
        model.contentH = [SystemUtil heightForString:model.content font:[UIFont fontWithName:@"Helvetica Neue" size:14.0] andWidth:SCREEN_WIDTH-92];
        if (model.contentH>68) {
            model.isMore = YES;
        }
    }
    
    if (model.contentH>68 && !model.isShow) {
         model.fontH = model.subjectH+68;
    } else {
        model.fontH = model.subjectH+model.contentH;
    }
   
    return PNNewsHeight+model.fontH;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PNNewsCell *cell = [tableView dequeueReusableCellWithIdentifier:PNNewsCellResue];
    if (indexPath.row +1 <10) {
        cell.lblSort.text = [NSString stringWithFormat:@"0%ld",indexPath.row+1];
    } else {
        cell.lblSort.text = [NSString stringWithFormat:@"%ld",indexPath.row+1];
    }
    PNCampaignModel *model = [self.dataArray objectAtIndex:indexPath.row];
    cell.lblContent.text = model.subject;
    cell.lblDesc.text = model.content;
    cell.lblTime.text = model.createDate;
    cell.row = indexPath.row;
    if (model.subjectH == 0) {
        model.subjectH = [SystemUtil heightForString:model.subject font:[UIFont fontWithName:@"Helvetica Neue" size:16.0] andWidth:SCREEN_WIDTH-92];
    }
    if (model.contentH == 0) {
        model.contentH = [SystemUtil heightForString:model.content font:[UIFont fontWithName:@"Helvetica Neue" size:14.0] andWidth:SCREEN_WIDTH-92];
    }
    
    cell.contentH.constant = model.subjectH;
    if (model.contentH>68 && !model.isShow) {
        cell.descH.constant = 68;
    } else {
        cell.descH.constant = model.contentH;
    }
    
    
    @weakify_self
    [cell setDescBlock:^(NSInteger row) {
        if (model.isMore) {
            PNCampaignModel *model = [weakSelf.dataArray objectAtIndex:indexPath.row];
            model.isShow = !model.isShow;
            [weakSelf.tabView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }
        
    }];
   
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark-------点击绑定钱包
- (void) clickAddAction:(UIButton *) btn
{
    if (_isGetWalletFinsh) {
        _animationView.hidden = NO;
        [self startClickAnimation];
    }
    
}

#pragma mark-------通知回调
- (void) bindWalletAddressNoti:(NSNotification *) noti
{
    [self.view showHint:@"Added successfully!"];
    NSDictionary *resultDic = noti.object;
    NSString *addressS = resultDic[@"Address"]?:@"";
    NSString *typeS = resultDic[@"WalletType"]?:@"";
    NSArray *addressArray = [addressS componentsSeparatedByString:@","];
    NSArray *typeArray = [typeS componentsSeparatedByString:@","];
    if (addressArray && typeArray && addressArray.count >= 2 && typeArray.count >= 2) {
        _isGetWalletFinsh = YES;
        if ([typeArray[0] integerValue] == 2) {
            self.qlcWalletAddress = addressArray[0];
            self.neoWalletAddress = addressArray[1];
        } else {
            self.qlcWalletAddress = addressArray[1];
            self.neoWalletAddress = addressArray[0];
        }
    }
    
    [self.addressView hidePNBindQLCAddressView];
}
- (void) getWalletAddressNoti:(NSNotification *) noti
{
    _isGetWalletFinsh = YES;
    NSDictionary *resultDic = noti.object;
    NSArray *wallets = resultDic[@"Payload"];
    if (wallets && wallets.count >=2) {
        resultDic = wallets[0];
        if ([resultDic[@"WalletType"] integerValue] == 2) {
            self.qlcWalletAddress = resultDic[@"Address"];
            self.neoWalletAddress = wallets[1][@"Address"];
        } else {
            self.qlcWalletAddress = wallets[1][@"Address"];
            self.neoWalletAddress = resultDic[@"Address"];
        }
    }

}







#pragma mark - 创建悬浮的按钮
- (void)createButton{

    _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addBtn setImage:[UIImage imageNamed:@"push_button_a"] forState:UIControlStateNormal];
    _addBtn.frame = CGRectMake(SCREEN_WIDTH - 90, SCREEN_HEIGHT - 90, 70, 70);
    [_addBtn addTarget:self action:@selector(clickAddAction:) forControlEvents:UIControlEventTouchUpInside];
    
    _animationView = [[UIView alloc] initWithFrame:_addBtn.frame];
    _animationView.backgroundColor = RGB(151, 159, 208);
    _animationView.layer.cornerRadius = 35.0f;
    _animationView.hidden = YES;
    _animationView.alpha = 0.3;
    [self.view addSubview:_animationView];

    [self.view addSubview:_addBtn];

    //放一个拖动手势，用来改变控件的位置
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(changePostion:)];
    [_addBtn addGestureRecognizer:pan];

}

- (void) startClickAnimation
{
    CABasicAnimation *animation=[CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.fromValue=[NSNumber numberWithFloat:1.0];
    animation.toValue=[NSNumber numberWithFloat:30];
    animation.duration= 0.5;
    animation.autoreverses=NO;
    animation.repeatCount=0;
    animation.removedOnCompletion=NO;
    animation.fillMode=kCAFillModeForwards;
    animation.delegate = self;
    [self.animationView.layer addAnimation:animation forKey:@"zoom"];
    
    [UIView animateWithDuration:0.5 animations:^{
        self.addBtn.alpha = 0.0f;
    }];

    [self performSelector:@selector(showWalletAddressView) withObject:self afterDelay:0.2];
    
}

- (void) showWalletAddressView {
    
    if (_isGetWalletFinsh) {
        if (self.qlcWalletAddress && self.qlcWalletAddress.length>0) {
            [self.recevieaAddressView showPNRecevieQLCAddressView];
        } else {
            [self.addressView showPNBindQLCAddressView:self.view];
        }
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag) {
        self.animationView.hidden = YES;
    }
}


//手势事件 －－ 改变位置
-(void)changePostion:(UIPanGestureRecognizer *)pan{

    CGPoint point = [pan translationInView:_addBtn];

    CGFloat width = [UIScreen mainScreen].bounds.size.width;

    CGFloat height = [UIScreen mainScreen].bounds.size.height;

    CGRect originalFrame = _addBtn.frame;

    if (originalFrame.origin.x >= 0 && originalFrame.origin.x+originalFrame.size.width <= width) {
        originalFrame.origin.x += point.x;
    }
    
    if (originalFrame.origin.y >= 0 && originalFrame.origin.y+originalFrame.size.height <= height) {
        originalFrame.origin.y += point.y;
    }

    _addBtn.frame = originalFrame;

    [pan setTranslation:CGPointZero inView:_addBtn];

    if (pan.state == UIGestureRecognizerStateBegan) {

        _addBtn.enabled = NO;

    }else if (pan.state == UIGestureRecognizerStateChanged){

    } else {

        CGRect frame = _addBtn.frame;

        //是否越界

        BOOL isOver = NO;

        if (frame.origin.x < 0) {

            frame.origin.x = 0;

            isOver = YES;

        } else if (frame.origin.x+frame.size.width > width) {

            frame.origin.x = width - frame.size.width;

            isOver = YES;

        }if (frame.origin.y < 0) {

            frame.origin.y = 0;

            isOver = YES;

        } else if (frame.origin.y+frame.size.height > height) {

            frame.origin.y = height - frame.size.height;

            isOver = YES;

        }if (isOver) {
            @weakify_self
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.addBtn.frame = frame;
            }];

        }
        _addBtn.enabled = YES;
    }
    _animationView.frame = _addBtn.frame;
}
@end
