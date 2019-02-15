//
//  DiskManagerViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "DiskManagerViewController.h"
#import "DiskManagementCell.h"
#import "GetDiskTotalInfoModel.h"
#import "DiskDetailViewController.h"
#import "ConfigDiskViewController.h"

@interface DiskManagerViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (weak, nonatomic) IBOutlet UIProgressView *progressV;
@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (nonatomic, strong) GetDiskTotalInfoModel *getDiskTotalInfoM;
@property (weak, nonatomic) IBOutlet UILabel *storageLab;
@property (weak, nonatomic) IBOutlet UILabel *spaceLab;
@property (weak, nonatomic) IBOutlet UILabel *modeLab;


@end

@implementation DiskManagerViewController

- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDiskTotalInfoSuccessNoti:) name:GetDiskTotalInfo_Noti object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addObserve];
    [self viewInit];
    [self dataInit];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self sendGetDiskTotalInfo];
}

#pragma mark - Operation
- (void)dataInit  {
    _sourceArr = [NSMutableArray array];
    [_mainTable registerNib:[UINib nibWithNibName:DiskManagementCellReuse bundle:nil] forCellReuseIdentifier:DiskManagementCellReuse];
}

- (void)viewInit {
//    _progressV.transform  = CGAffineTransformMakeScale(1.0, 5.0);
}

- (void)sendGetDiskTotalInfo {
    [SendRequestUtil sendGetDiskTotalInfoWithShowHud:YES];
}

- (void)refreshView {
    if (_getDiskTotalInfoM == nil) {
        return;
    }
    
    NSString *storageStr = @"Storage：";
    NSString *storageValStr = [storageStr stringByAppendingString:_getDiskTotalInfoM.TotalCapacity?:@""];
    NSRange storageRange = [storageValStr rangeOfString:storageStr];
    NSMutableAttributedString *strAtt_Temp = [[NSMutableAttributedString alloc] initWithString:storageValStr];
    [strAtt_Temp setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:20],NSForegroundColorAttributeName:UIColorFromRGB(0x2b2b2b)} range:NSMakeRange(0, storageValStr.length)];
    [strAtt_Temp setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12],NSForegroundColorAttributeName:UIColorFromRGB(0x2b2b2b)} range:storageRange];
    _storageLab.attributedText = strAtt_Temp;
    
    NSString *useLast = [_getDiskTotalInfoM.UsedCapacity substringFromIndex:_getDiskTotalInfoM.UsedCapacity.length - 1];
    CGFloat useDigital = [useLast isEqualToString:@"M"]?[[_getDiskTotalInfoM.UsedCapacity substringToIndex:_getDiskTotalInfoM.UsedCapacity.length - 1] floatValue]:[[_getDiskTotalInfoM.UsedCapacity substringToIndex:_getDiskTotalInfoM.UsedCapacity.length - 1] floatValue]*1024;
    NSString *totalLast = [_getDiskTotalInfoM.TotalCapacity substringFromIndex:_getDiskTotalInfoM.TotalCapacity.length - 1];
    CGFloat totalDigital = [totalLast isEqualToString:@"M"]?[[_getDiskTotalInfoM.TotalCapacity substringToIndex:_getDiskTotalInfoM.TotalCapacity.length - 1] floatValue]:[[_getDiskTotalInfoM.TotalCapacity substringToIndex:_getDiskTotalInfoM.TotalCapacity.length - 1] floatValue]*1024;
    CGFloat usePercent = useDigital/totalDigital;
    _spaceLab.text = [NSString stringWithFormat:@"Used Sapce：%@ / %@ （%.1f%@）",_getDiskTotalInfoM.UsedCapacity?:@"",_getDiskTotalInfoM.TotalCapacity?:@"",usePercent*100,@"%"];
    _modeLab.text = [_getDiskTotalInfoM.Mode integerValue] == 0?@"Not configured":[_getDiskTotalInfoM.Mode integerValue] == 1?@"BASIC":[_getDiskTotalInfoM.Mode integerValue] == 2?@"RAID1":@"";
    _progressV.progress = usePercent;
    
    [_sourceArr removeAllObjects];
    [_sourceArr addObjectsFromArray:_getDiskTotalInfoM.Info];
    [_mainTable reloadData];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)configDiskAction:(id)sender {
    [self jumpToConfigDisk];
}

#pragma mark - UITableViewDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DiskManagementCell_Height;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DiskManagementCell *cell = [tableView dequeueReusableCellWithIdentifier:DiskManagementCellReuse];
    
    GetDiskTotalInfo *model = _sourceArr[indexPath.row];
    [cell configCellWithModel:model];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GetDiskTotalInfo *model = _sourceArr[indexPath.row];
    [self jumpToDiskDetail:model];
}

#pragma mark - Transition
- (void)jumpToDiskDetail:(GetDiskTotalInfo *)model {
    DiskDetailViewController *vc = [[DiskDetailViewController alloc] init];
    vc.getDiskTotalInfo = model;
    vc.titleStr = [model.Slot integerValue] == 0?@"Disk A":@"Disk B";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToConfigDisk {
    ConfigDiskViewController *vc = [[ConfigDiskViewController alloc] init];
    vc.currentMode = _getDiskTotalInfoM.Mode;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Noti
- (void)getDiskTotalInfoSuccessNoti:(NSNotification *)noti {
    NSDictionary *receiveDic = noti.object;
    NSDictionary *paramsDic = receiveDic[@"params"];
    _getDiskTotalInfoM = [GetDiskTotalInfoModel getObjectWithKeyValues:paramsDic];
    DDLogDebug(@"---%@",_getDiskTotalInfoM);
    [self refreshView];
}

@end
