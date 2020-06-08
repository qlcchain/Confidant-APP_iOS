//
//  PNFeedbackDetailViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/20.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNFeedbackDetailViewController.h"
#import "PNFeedbackDeatilCell.h"
#import "PNFeedbackHeadCell.h"
#import "PNFeedbackSendViewController.h"
#import "PNFeedbackMoel.h"
#import "AFHTTPClientV2.h"
#import "UserModel.h"
#import "PNFeedbackStatusCell.h"
#import "NSDate+Category.h"
#import "PNFeedbackImgAlertView.h"
#import <YBImageBrowser/YBImageBrowser.h>

@interface PNFeedbackDetailViewController ()<UITableViewDataSource,UITableViewDelegate,YBImageBrowserDataSource>
{
    YBImageBrowser *browser;
}
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewH;
@property (weak, nonatomic) IBOutlet UILabel *lblMessage;
@property (weak, nonatomic) IBOutlet UILabel *lblTypeName;
@property (weak, nonatomic) IBOutlet UITableView *mainTabv;
@property (weak, nonatomic) IBOutlet UIButton *fineBtn;
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) PNFeedbackMoel *feedbackM;
@property (nonatomic, strong) PNFeedbackImgAlertView *imgAlertView;
@property (nonatomic, strong) NSArray *feedbackImgs;
@end

@implementation PNFeedbackDetailViewController
- (void)viewDidAppear:(BOOL)animated
{
    if (self.feedbackM.replayList && self.feedbackM.replayList.count > 0) {
        [_mainTabv reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    [super viewDidAppear:animated];
}
- (instancetype) initWithPNFeedbackModel:(PNFeedbackMoel *) model
{
    if (self = [super init]) {
        self.feedbackM = model;
    }
    return self;
}

- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)clickFineAction:(id)sender {
    [self sendFeedbackMarkedFixed];
}
- (IBAction)clickReplyAction:(id)sender {
    PNFeedbackSendViewController *vc = [[PNFeedbackSendViewController alloc] initWithFeedbackModel:self.feedbackM];
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
- (PNFeedbackImgAlertView *)imgAlertView
{
    if (!_imgAlertView) {
        _imgAlertView = [PNFeedbackImgAlertView loadPNFeedbackImgAlertView];
        @weakify_self
        [_imgAlertView setClickImgBlock:^(NSArray * _Nonnull imgs, NSInteger selRow) {
            [weakSelf showImgsWithImgs:imgs selRow:selRow];
        }];
    }
    return _imgAlertView;
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

    _lblMessage.text = self.feedbackM.scenario;
    _lblTypeName.text = self.feedbackM.type;
    

    [_mainTabv registerNib:[UINib nibWithNibName:PNFeedbackHeadCellResue bundle:nil] forCellReuseIdentifier:PNFeedbackHeadCellResue];
    [_mainTabv registerNib:[UINib nibWithNibName:PNFeedbackDeatilCellResue bundle:nil] forCellReuseIdentifier:PNFeedbackDeatilCellResue];
    [_mainTabv registerNib:[UINib nibWithNibName:PNFeedbackStatusCellResue bundle:nil] forCellReuseIdentifier:PNFeedbackStatusCellResue];
    NSLog(@"-------");
    
    if ([self.feedbackM.status isEqualToString:RESOLVED]) {
           _bottomViewH.constant = 0;
    }
}

#pragma mark --------标记为已解决
- (void) sendFeedbackMarkedFixed
{
    [self.view showHudInView:self.view hint:@""];
    @weakify_self
    [AFHTTPClientV2 requestConfidantWithBaseURLStr:Feedback_Marked_Url params:@{@"feedbackId":self.feedbackM.feedbackId,@"userId":[UserModel getUserModel].userId} httpMethod:HttpMethodPost userInfo:nil successBlock:^(NSURLSessionDataTask *dataTask, id responseObject) {
        [weakSelf.view hideHud];
        if ([responseObject[@"code"] intValue] == 0) {
            [weakSelf.view showSuccessHudInView:weakSelf.view hint:@"Successed"];
            weakSelf.feedbackM.status = RESOLVED;
            weakSelf.feedbackM.resolvedDate = responseObject[@"resolvedDate"];
            weakSelf.bottomViewH.constant = 0;
            [weakSelf.mainTabv reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [weakSelf.view showFaieldHudInView:weakSelf.view hint:Failed];
        }
    } failedBlock:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [weakSelf.view hideHud];
        [weakSelf.view showFaieldHudInView:weakSelf.view hint:Failed];
    }];
}

#pragma mark ---------tableview 代理方法
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    if (self.feedbackM.replayList && ![self.feedbackM.status isEqualToString:NOT_SOLVED]) {
//        return 3;
//    } else if (self.feedbackM.replayList) {
//        return 2;
//    }
//    return 1;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }else if (section == 1) {
        if (self.feedbackM.replayList) {
            return self.feedbackM.replayList.count;
        }
        return 0;
    } else {
        if([self.feedbackM.status isEqualToString:NOT_SOLVED]){
            return 0;
        }
        return 1;
    }
   
}
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 150;
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 2) {
        
        PNFeedbackStatusCell *cell = [tableView dequeueReusableCellWithIdentifier:PNFeedbackStatusCellResue];
        if ([self.feedbackM.status isEqualToString:ANSWERED]) {
            cell.lblContent.text = @"Marked as Answered";
        } else {
            cell.lblContent.text = @"Marked as Fixed";
        }
        cell.lblTime.text = @"";
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
        if (self.feedbackM.resolvedDate.length > 0) {
            NSDate *startDate = [dateFormatter dateFromString:self.feedbackM.resolvedDate?:@""];
            cell.lblTime.text = [startDate minuteDescription];
        }
        return cell;
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            PNFeedbackHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:PNFeedbackHeadCellResue];
            cell.lblNo.text = self.feedbackM.number;
            return cell;
        }
    }
    PNFeedbackDeatilCell *cell = [tableView dequeueReusableCellWithIdentifier:PNFeedbackDeatilCellResue];
    if (indexPath.section == 0) {
        [cell setFeedReplyModel:self.feedbackM];
    } else {
        [cell setFeedReplyModel:self.feedbackM.replayList[indexPath.row]];
    }
    
    @weakify_self
    [cell setClickImgBlock:^(NSArray *imgs) {
        if (imgs && imgs.count>0) {
            [weakSelf.imgAlertView showPNFeedbackImgAlertViewWithArray:imgs];
        }
        
    }];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// 显示图片vs
- (void) showImgsWithImgs:(NSArray *) array selRow:(NSInteger) row
{
    self.feedbackImgs = array?:@[];
    browser = [YBImageBrowser new];;
    browser.dataSource = self;
    [browser setCurrentIndex:row];
    [browser showFromController:self];
}

#pragma mark -----YBImageBrowser代理
- (NSUInteger)yb_numberOfCellForImageBrowserView:(YBImageBrowserView *)imageBrowserView
{
    return self.feedbackImgs.count;
}

- (id<YBImageBrowserCellDataProtocol>)yb_imageBrowserView:(YBImageBrowserView *)imageBrowserView dataForCellAtIndex:(NSUInteger)index
{
    YBImageBrowseCellData *cellData = [YBImageBrowseCellData new];
    cellData.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",Feedback_Img_BaseUrl,self.feedbackImgs[index]]];
    return cellData;
}
@end
