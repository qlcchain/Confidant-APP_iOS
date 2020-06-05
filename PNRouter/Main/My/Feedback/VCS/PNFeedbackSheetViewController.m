//
//  PNFeedbackSheetViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/20.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNFeedbackSheetViewController.h"
#import "PNFeedbackTypeCell.h"
#import "PNFeedbackTypeModel.h"
#import "AFHTTPClientV2.h"

@interface PNFeedbackSheetViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *mainTabV;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSString *selectStr;
@property (nonatomic, assign) NSInteger sheetType;


@end

@implementation PNFeedbackSheetViewController

- (IBAction)clickBackAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Feedback_Type_Select_Noti object:self.selectStr];
    [self leftNavBarItemPressedWithPop:NO];
}
#pragma mark --------layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
#pragma mark-------初始 init
- (instancetype) initWithSheetType:(NSInteger) sheetType dataArray:(NSMutableArray *) array selectStr:(NSString *) selStr;
{
    if (self = [super init]) {
        self.sheetType = sheetType;
        self.selectStr = selStr;
        [self.dataArray addObjectsFromArray:array];
        if (self.sheetType == 1) {
            self.lblTitle.text = @"Choose a scenario";
        } else {
            self.lblTitle.text = @"Choose a type";
        }
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _mainTabV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _mainTabV.delegate = self;
    _mainTabV.dataSource = self;
    [_mainTabV registerNib:[UINib nibWithNibName:PNFeedbackTypeCellResue bundle:nil] forCellReuseIdentifier:PNFeedbackTypeCellResue];
}

#pragma mark ---------tableview 代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return PNFeedbackTypeCellHeight;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PNFeedbackTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:PNFeedbackTypeCellResue];
    cell.lblName.text = self.dataArray[indexPath.row];
    if ([self.dataArray[indexPath.row] isEqualToString:self.selectStr]) {
        cell.selectImg.hidden = NO;
    } else {
        cell.selectImg.hidden = YES;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (![self.dataArray[indexPath.row] isEqualToString:self.selectStr]) {
        self.selectStr = self.dataArray[indexPath.row];
        [self clickBackAction:nil];
    }
    
}

@end
