//
//  PNFeedbackDetailViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/20.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNFeedbackDetailViewController.h"
#import "PNFeedbackDeatilCell.h"
#import "PNFeedbackDeatilHeadView.h"
#import "PNFeedbackSendViewController.h"

@interface PNFeedbackDetailViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblTypeName;
@property (weak, nonatomic) IBOutlet UITableView *mainTabv;
@property (weak, nonatomic) IBOutlet UIButton *fineBtn;
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation PNFeedbackDetailViewController
- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)clickFineAction:(id)sender {
}
- (IBAction)clickReplyAction:(id)sender {
    PNFeedbackSendViewController *vc = [[PNFeedbackSendViewController alloc] init];
    [self presentModalVC:vc animated:YES];
}
#pragma mark---------layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _fineBtn.layer.borderColor = MAIN_PURPLE_COLOR.CGColor;
    _fineBtn.layer.borderWidth = 1.0f;
    _fineBtn.layer.cornerRadius = 8.0f;
    _replyBtn.layer.cornerRadius = 8.0f;
    _mainTabv.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _mainTabv.delegate = self;
    _mainTabv.dataSource = self;
    _mainTabv.estimatedRowHeight = 49;
    _mainTabv.rowHeight=UITableViewAutomaticDimension;
    _mainTabv.tableHeaderView = [PNFeedbackDeatilHeadView loadPNFeedbackDeatilHeadView];
    _mainTabv.tableHeaderView.height = 60;
    [_mainTabv registerNib:[UINib nibWithNibName:PNFeedbackDeatilCellResue bundle:nil] forCellReuseIdentifier:PNFeedbackDeatilCellResue];
    NSLog(@"-------");
}

#pragma mark ---------tableview 代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;//self.dataArray.count;
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 150;
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PNFeedbackDeatilCell *cell = [tableView dequeueReusableCellWithIdentifier:PNFeedbackDeatilCellResue];
    cell.lblContent.text = @"PNFeedbackChatCellResue-PNFeedbackChatCellResue-PNFeedbackChatCellResue-PNFeedbackChatCellResue-PNFeedbackChatCellResue-PNFeedbackChatCellResue-PNFeedbackChatCellResue-PNFeedbackChatCellResue";
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
