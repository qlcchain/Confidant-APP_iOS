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
#import "UnitUtil.h"
#import "DiskAlertView.h"
#import "DiskManagementMMCCell.h"

typedef enum : NSUInteger {
    DiskStatusTypeMMC,
    DiskStatusTypeA,
    DiskStatusTypeB,
    DiskStatusTypeAB,
} DiskStatusType;

@interface DiskManagerViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (weak, nonatomic) IBOutlet UIProgressView *progressV;
@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (nonatomic, strong) GetDiskTotalInfoModel *getDiskTotalInfoM;
@property (weak, nonatomic) IBOutlet UILabel *storageLab;
@property (weak, nonatomic) IBOutlet UILabel *spaceLab;
@property (weak, nonatomic) IBOutlet UILabel *modeLab;
@property (weak, nonatomic) IBOutlet UIImageView *diskIcon;
@property (nonatomic) DiskStatusType diskStatusType;

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
    
    [_mainTable registerNib:[UINib nibWithNibName:DiskManagementMMCCellReuse bundle:nil] forCellReuseIdentifier:DiskManagementMMCCellReuse];
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
    
    CGFloat useDigital = [UnitUtil getDigitalOfM:_getDiskTotalInfoM.UsedCapacity];
    CGFloat totalDigital = [UnitUtil getDigitalOfM:_getDiskTotalInfoM.TotalCapacity];
    CGFloat usePercent = useDigital/totalDigital;
    _spaceLab.text = [NSString stringWithFormat:@"Used Sapce：%@ / %@ （%.1f%@）",_getDiskTotalInfoM.UsedCapacity?:@"",_getDiskTotalInfoM.TotalCapacity?:@"",usePercent*100,@"%"];
    _modeLab.text = [_getDiskTotalInfoM.Mode integerValue] == 0?@"Not configured":[_getDiskTotalInfoM.Mode integerValue] == 1?@"BASIC":[_getDiskTotalInfoM.Mode integerValue] == 2?@"RAID1":@"";
    _progressV.progress = usePercent;
    
    [_sourceArr removeAllObjects];
    // 添加mmc信息
    if (_getDiskTotalInfoM.Count <= 0) { // 有磁盘 默认灰
        GetDiskTotalInfo *mmcInfo = [[GetDiskTotalInfo alloc] init];
        mmcInfo.Status = @(2);
        mmcInfo.Capacity = _getDiskTotalInfoM.TotalCapacity;
        [_sourceArr addObject:mmcInfo];
    }
    // 添加磁盘信息
    [_sourceArr addObjectsFromArray:_getDiskTotalInfoM.Info];

    [_mainTable reloadData];
    
    if (_getDiskTotalInfoM.Count <= 0) { // 无磁盘
        _diskStatusType = DiskStatusTypeMMC;
    } else {
        __block BOOL aOK = NO;
        __block BOOL bOK = NO;
        [_getDiskTotalInfoM.Info enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GetDiskTotalInfo *info = obj;
            if ([info.Slot integerValue] == 0) { // A盘
                aOK = [info.Status integerValue] == 2?YES:NO;
            } else if ([info.Slot integerValue] == 1) { // B盘
                bOK = [info.Status integerValue] == 2?YES:NO;
            }
        }];
        if (aOK) {
            if (bOK) {
                _diskStatusType = DiskStatusTypeAB;
            } else {
                _diskStatusType = DiskStatusTypeA;
            }
        } else {
            if (bOK) {
                _diskStatusType = DiskStatusTypeB;
            } else {
                _diskStatusType = DiskStatusTypeMMC;
            }
        }
    }
    if (_diskStatusType == DiskStatusTypeMMC) {
        _diskIcon.image = [UIImage imageNamed:@"icon_disk_mmc"];
    } else if (_diskStatusType == DiskStatusTypeA) {
        _diskIcon.image = [UIImage imageNamed:@"icon_disk_a"];
    } else if (_diskStatusType == DiskStatusTypeB) {
        _diskIcon.image = [UIImage imageNamed:@"icon_disk_b"];
    } else if (_diskStatusType == DiskStatusTypeAB) {
        _diskIcon.image = [UIImage imageNamed:@"icon_disk_ab"];
    }
   
}

- (void)showNoDiskAlertView {
    DiskAlertView *view = [DiskAlertView getInstance];
    view.okBlock = ^{
    };
    [view showWithTitle:@"Disk can not be found" tip:@"Please install the disk to configure its settings" click:@"Cancel"];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)configDiskAction:(id)sender {
    if ([_getDiskTotalInfoM.Count integerValue] <= 0) {
        [self showNoDiskAlertView];
    } else {
        [self jumpToConfigDisk];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    GetDiskTotalInfo *model = _sourceArr[indexPath.row];
    if ([model.Slot integerValue] == 0 || [model.Slot integerValue] == 1) {
        return DiskManagementCell_Height;
    } else  {
        return DiskManagementMMCCell_Height;
    }
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    GetDiskTotalInfo *model = _sourceArr[indexPath.row];
    
    if ([model.Slot integerValue] == 0 || [model.Slot integerValue] == 1) {
        DiskManagementCell *cell = [tableView dequeueReusableCellWithIdentifier:DiskManagementCellReuse];
        [cell configCellWithModel:model];
        return cell;
    } else {
        DiskManagementMMCCell *cell = [tableView dequeueReusableCellWithIdentifier:DiskManagementMMCCellReuse];
        [cell configCellWithModel:model];
        return cell;
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    GetDiskTotalInfo *model = _sourceArr[indexPath.row];
    
    if ([model.Slot integerValue] == 0 || [model.Slot integerValue] == 1) {
        GetDiskTotalInfo *model = _sourceArr[indexPath.row];
        [self jumpToDiskDetail:model];
    }
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
