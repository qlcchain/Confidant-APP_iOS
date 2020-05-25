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

@interface PNFeedbackListViewController ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTab;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation PNFeedbackListViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
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
}


/// 拉取意见反馈列表
- (void) pullFeedbackList
{
    
}



#pragma mark--------emptyDataSetSource---emptyDataDelegate

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"当前您还没有提交意见反馈。真诚的邀请您提交意见反馈，以便给您跟好的体验.";
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
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


@end
