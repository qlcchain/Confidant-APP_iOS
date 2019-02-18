//
//  ConfigDiskViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/28.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "ConfigDiskViewController.h"
#import "ConfigDiskHeaderView.h"
#import "ConfigDiskCell.h"
#import "ReconfigDiskViewController.h"

@implementation ConfigDiskShowModel

@end

@interface ConfigDiskViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (nullable, nonatomic, strong) NSString *selectMode;

@end

@implementation ConfigDiskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self dataInit];
}

#pragma mark - Operation
- (void)dataInit {
    _sourceArr = [NSMutableArray array];
    ConfigDiskShowModel *model = [[ConfigDiskShowModel alloc] init];
    if ([_currentMode integerValue] == 2) { // RAID 1
        model.isSelect = YES;
        _selectMode = @"RAID1";
    } else {
        model.isSelect = NO;
    }
    model.showArrow = YES;
    model.showCell = NO;
    model.title = @"RAID 1";
    model.detail = @"Erase data and format, with data protection";
    model.cellArr = @[@"The two hard disks are automatically mirrored. When any of the disks is damaged, it can be simply replaced by a new disk. It is the recommended ultimate mode for data security. "];
    [_sourceArr addObject:model];
    
    model = [[ConfigDiskShowModel alloc] init];
    if ([_currentMode integerValue] == 1) { // BASIC
        model.isSelect = YES;
        _selectMode = @"BASIC";
    } else {
        model.isSelect = NO;
    }
    model.showArrow = YES;
    model.showCell = NO;
    model.title = @"BASIC";
    model.detail = @"Erase data and format, no data protection";
    model.cellArr = @[@"Master-slave mode, the slave disk is mounted to the disk directory.  "];
    [_sourceArr addObject:model];
    
    model = [[ConfigDiskShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = YES;
    model.showCell = NO;
    model.title = @"RAID 0";
    model.detail = @"Erase data and format, no data protection";
    model.cellArr = @[@"The two hard disks are virtually merged into one, the overall capacity doubles with fast access speed. BUT, if any of the disks is damaged, the data of the other disk will be lost. "];
    [_sourceArr addObject:model];
    
    model = [[ConfigDiskShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = YES;
    model.showCell = NO;
    model.title = @"LVM";
    model.detail = @"Erase data and format, no data protection";
    model.cellArr = @[@"All hard disks are merged into one virtual disk, the overall capacity is the sum of that of the two disks. This way enables adding in a new disk without any changes to the directory structure. "];
    [_sourceArr addObject:model];
    
    model = [[ConfigDiskShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = NO;
    model.showCell = NO;
    model.title = @"Add to RAID 1";
    model.detail = @"Erase data and format, no data protection";
    model.cellArr = nil;
    [_sourceArr addObject:model];
    
    model = [[ConfigDiskShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = NO;
    model.showCell = NO;
    model.title = @"Add to LVM";
    model.detail = @"Erase data and format, no data protection";
    model.cellArr = nil;
    [_sourceArr addObject:model];
    
    [_mainTable registerNib:[UINib nibWithNibName:ConfigDiskCellReuse bundle:nil] forCellReuseIdentifier:ConfigDiskCellReuse];
    [_mainTable registerNib:[UINib nibWithNibName:ConfigDiskHeaderViewReuse bundle:nil] forHeaderFooterViewReuseIdentifier:ConfigDiskHeaderViewReuse];
    _mainTable.rowHeight = UITableViewAutomaticDimension;
    _mainTable.estimatedRowHeight = ConfigDiskCell_Height;
}

#pragma mark - Action

- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmAction:(id)sender {
    if (!_selectMode || _selectMode.length <= 0) {
        [AppD.window showHint:@"This mode is not supported"];
        return;
    }
    [self jumpToReconfigDisk];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sourceArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    ConfigDiskShowModel *model = _sourceArr[section];
    if (model.showCell) {
        return model.cellArr.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConfigDiskCell *cell = [tableView dequeueReusableCellWithIdentifier:ConfigDiskCellReuse];
    
    ConfigDiskShowModel *model = _sourceArr[indexPath.section];
    
    return cell;
}

#pragma mark - UITableViewDelegate
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UploadFilesCellHeight;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return ConfigDiskHeaderViewHeight;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    ConfigDiskShowModel *model = _sourceArr[section];
    
    ConfigDiskHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ConfigDiskHeaderViewReuse];
    headerView.headerSection = section;
    [headerView configHeaderWithModel:model];
    
    @weakify_self
    [headerView setSelectB:^(NSInteger headerSection) {
        if (!model.isSelect) {
            [weakSelf.sourceArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ConfigDiskShowModel *tempM = obj;
                tempM.isSelect = NO;
            }];
            model.isSelect = YES;
            [weakSelf.mainTable reloadData];
            
            if (headerSection == 0) { // RAID1
                weakSelf.selectMode = @"RAID1";
            } else if (headerSection == 1) { // BASIC
                weakSelf.selectMode = @"BASIC";
            } else if (headerSection == 2) { // RAID0
                weakSelf.selectMode = @"RAID0";
            } else {
                weakSelf.selectMode = @"";
            }
        }
    }];
    [headerView setShowCellB:^{
        if (model.showArrow) {
            model.showCell = !model.showCell;
            [weakSelf.mainTable reloadData];
        }
    }];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ConfigDiskShowModel *model = _sourceArr[indexPath.section];
}

#pragma mark - Transition
- (void)jumpToReconfigDisk {
    ReconfigDiskViewController *vc = [[ReconfigDiskViewController alloc] init];
    vc.selectMode = _selectMode;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
