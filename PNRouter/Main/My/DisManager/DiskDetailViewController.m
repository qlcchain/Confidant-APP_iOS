//
//  DiskDetailViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/28.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "DiskDetailViewController.h"
#import "DiskDetailCell.h"
#import "ConfigDiskViewController.h"
#import "GetDiskTotalInfoModel.h"
#import "GetDiskDetailInfoModel.h"

@interface DiskDetailShowModel : NSObject

@property (nonatomic, strong) NSString *showKey;
@property (nonatomic, strong) NSString *showVal;

@end

@implementation DiskDetailShowModel

@end

@interface DiskDetailViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (nonatomic, strong) NSMutableArray *sourceArr;

@end

@implementation DiskDetailViewController

- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getDiskDetailInfoSuccessNoti:) name:GetDiskDetailInfo_Noti object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addObserve];
    [self dataInit];
    [self sendGetDiskDetailInfo];
}

#pragma mark - Operation
- (void)dataInit  {
    _sourceArr = [NSMutableArray array];
    [_mainTable registerNib:[UINib nibWithNibName:DiskDetailCellReuse bundle:nil] forCellReuseIdentifier:DiskDetailCellReuse];
    
    _titleLab.text = _titleStr;
}

- (void)sendGetDiskDetailInfo {
    [SendRequestUtil sendGetDiskDetailInfoWithSlot:_getDiskTotalInfo.Slot?:(0) showHud:YES];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UITableViewDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DiskDetailCell_Height;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DiskDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:DiskDetailCellReuse];
    
    DiskDetailShowModel *model = _sourceArr[indexPath.row];
    [cell configCellWithKey:model.showKey val:model.showVal];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Transition
- (void)jumpToConfigDisk {
    ConfigDiskViewController *vc = [ConfigDiskViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Noti
- (void)getDiskDetailInfoSuccessNoti:(NSNotification *)noti {
    NSDictionary *receiveDic = noti.object;
    NSDictionary *paramsDic = receiveDic[@"params"];
    GetDiskDetailInfoModel *getDiskDetailInfoM = [GetDiskDetailInfoModel getObjectWithKeyValues:paramsDic];
    
    [_sourceArr removeAllObjects];
    DiskDetailShowModel *model = [[DiskDetailShowModel alloc] init];
//    model.showKey = @"/DEV/SDA";
    model.showKey = getDiskDetailInfoM.Name;
    model.showVal = [getDiskDetailInfoM.Status integerValue]==0?@"Not Found":[getDiskDetailInfoM.Status integerValue]==1?@"Not Configured":@"Configured";
    [_sourceArr addObject:model];
    model = [[DiskDetailShowModel alloc] init];
    model.showKey = @"ATA Version is ";
    model.showVal = [getDiskDetailInfoM.Status integerValue]==2?getDiskDetailInfoM.ATAVersion:@"";
    [_sourceArr addObject:model];
    model = [[DiskDetailShowModel alloc] init];
    model.showKey = @"Device Model ";
    model.showVal = [getDiskDetailInfoM.Status integerValue]==2?getDiskDetailInfoM.Device:@"";
    [_sourceArr addObject:model];
    model = [[DiskDetailShowModel alloc] init];
    model.showKey = @"Firmware Version ";
    model.showVal = [getDiskDetailInfoM.Status integerValue]==2?getDiskDetailInfoM.Firmware:@"";
    [_sourceArr addObject:model];
    model = [[DiskDetailShowModel alloc] init];
    model.showKey = @"Form Factor ";
    model.showVal = [getDiskDetailInfoM.Status integerValue]==2?getDiskDetailInfoM.FormFactor:@"";
    [_sourceArr addObject:model];
    model = [[DiskDetailShowModel alloc] init];
    model.showKey = @"LU WWN Device Id ";
    model.showVal = [getDiskDetailInfoM.Status integerValue]==2?getDiskDetailInfoM.LUWWNDeviceId:@"";
    [_sourceArr addObject:model];
    model = [[DiskDetailShowModel alloc] init];
    model.showKey = @"Model Family ";
    model.showVal = [getDiskDetailInfoM.Status integerValue]==2?getDiskDetailInfoM.ModelFamily:@"";
    [_sourceArr addObject:model];
    model = [[DiskDetailShowModel alloc] init];
    model.showKey = @"Rotation Rate ";
    model.showVal = [getDiskDetailInfoM.Status integerValue]==2?getDiskDetailInfoM.RotationRate:@"";
    [_sourceArr addObject:model];
    model = [[DiskDetailShowModel alloc] init];
    model.showKey = @"SATA Version is ";
    model.showVal = [getDiskDetailInfoM.Status integerValue]==2?getDiskDetailInfoM.SATAVersion:@"";
    [_sourceArr addObject:model];
    model = [[DiskDetailShowModel alloc] init];
    model.showKey = @"SMART support is";
    model.showVal = [getDiskDetailInfoM.Status integerValue]==2?getDiskDetailInfoM.SMARTsupport:@"";
    [_sourceArr addObject:model];
    model = [[DiskDetailShowModel alloc] init];
    model.showKey = @"Serial Number";
    model.showVal = [getDiskDetailInfoM.Status integerValue]==2?getDiskDetailInfoM.Serial:@"";
    [_sourceArr addObject:model];
    model = [[DiskDetailShowModel alloc] init];
    model.showKey = @"User Capacity";
    model.showVal = [getDiskDetailInfoM.Status integerValue]==2?getDiskDetailInfoM.Capacity:@"";
    [_sourceArr addObject:model];
    model = [[DiskDetailShowModel alloc] init];
    model.showKey = @"Sector Sizes";
    model.showVal = [getDiskDetailInfoM.Status integerValue]==2?getDiskDetailInfoM.SectorSizes:@"";
    [_sourceArr addObject:model];
    
    [_mainTable reloadData];
}

@end
