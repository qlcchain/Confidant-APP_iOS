//
//  PNFeedbackListViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/20.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNFeedbackListViewController.h"
#import <MJRefresh.h>
#import "PNFeedbackListCell.h"
#import "UIScrollView+EmptyDataSet.h"
#import "PNFeedCreateViewController.h"
#import "PNFeedbackDetailViewController.h"
#import "AFHTTPClientV2.h"
#import "PNFeedbackMoel.h"
#import "UserConfig.h"

@interface PNFeedbackListViewController ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTab;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger page;
@property (nonatomic, assign) NSInteger size;
@end

@implementation PNFeedbackListViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark--------layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)clickAddAction:(id)sender {
    PNFeedCreateViewController *vc = [[PNFeedCreateViewController alloc] init];
    [self presentModalVC:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _page = 0;
    _size = 10;
    _mainTab.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _mainTab.delegate = self;
    _mainTab.dataSource = self;
    _mainTab.emptyDataSetSource = self;
    _mainTab.emptyDataSetDelegate = self;
    [_mainTab registerNib:[UINib nibWithNibName:PNFeedbackListCellResue bundle:nil] forCellReuseIdentifier:PNFeedbackListCellResue];
    _mainTab.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(pullFeedbackList)];
    // Hide the time
    ((MJRefreshStateHeader *)_mainTab.mj_header).lastUpdatedTimeLabel.hidden = YES;
    // Hide the status
    ((MJRefreshStateHeader *)_mainTab.mj_header).stateLabel.hidden = YES;
    [_mainTab.mj_header beginRefreshing];
    
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
       @weakify_self
       _mainTab.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
           [weakSelf sendFeedbackListWithIsRefreshing:NO];
       }];
       MJRefreshAutoNormalFooter *footerView = (MJRefreshAutoNormalFooter *)_mainTab.mj_footer;
       [footerView setRefreshingTitleHidden:YES];
       [footerView setTitle:@"" forState:MJRefreshStateIdle];
        self.mainTab.mj_footer.hidden = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullFeedbackList) name:Feedback_Add_Success_Noti object:nil];
}

- (void) pullFeedbackList
{
    [self sendFeedbackListWithIsRefreshing:YES];
}

/// 拉取意见反馈列表
- (void) sendFeedbackListWithIsRefreshing:(BOOL) isRefreshing
{
    if (isRefreshing) {
        _page = 0;
        _size = 10;
    }
    NSDictionary *params = @{@"userId":[UserConfig getShareObject].userId?:@"",@"page":@(_page),@"size":@(_size)};
    @weakify_self
    [AFHTTPClientV2 requestConfidantWithBaseURLStr:Feedback_List_Url params:params httpMethod:HttpMethodPost userInfo:nil successBlock:^(NSURLSessionDataTask *dataTask, id responseObject) {
        
        if ([responseObject[@"code"] intValue] == 0) {
            NSArray *resultArry = responseObject[@"feedbackList"]?:@[];
               weakSelf.page++;
              if (isRefreshing) {
                  [weakSelf.mainTab.mj_header endRefreshing];
                  if (weakSelf.dataArray.count > 0) {
                      [weakSelf.dataArray removeAllObjects];
                  }
                  if (resultArry.count < weakSelf.size) {
                      weakSelf.mainTab.mj_footer.hidden = YES;
                  } else {
                       weakSelf.mainTab.mj_footer.hidden = NO;
                  }
              } else {
                  [weakSelf.mainTab.mj_footer endRefreshing];
                  if (resultArry.count < weakSelf.size) {
                      weakSelf.mainTab.mj_footer.hidden = YES;
                  }
              }
            
              [weakSelf.dataArray addObjectsFromArray:[PNFeedbackMoel mj_objectArrayWithKeyValuesArray:resultArry]];
              [weakSelf.mainTab reloadData];
        } else {
             [weakSelf.view showHint:Failed];
        }
        
    } failedBlock:^(NSURLSessionDataTask *dataTask, NSError *error) {
        if (isRefreshing) {
            [weakSelf.mainTab.mj_header endRefreshing];
        } else {
            [weakSelf.mainTab.mj_footer endRefreshing];
        }
        [weakSelf.view showHint:Failed];
    }];
   
}



#pragma mark--------emptyDataSetSource---emptyDataDelegate

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No feedback yet.";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                 NSForegroundColorAttributeName:RGB(150, 150, 150)};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}
#pragma mark ---------tableview 代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PNFeedbackListCellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PNFeedbackListCell *cell = [tableView dequeueReusableCellWithIdentifier:PNFeedbackListCellResue];
    [cell setFeedbackModel:self.dataArray[indexPath.row]];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PNFeedbackDetailViewController *vc = [[PNFeedbackDetailViewController alloc] initWithPNFeedbackModel:self.dataArray[indexPath.row]];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
