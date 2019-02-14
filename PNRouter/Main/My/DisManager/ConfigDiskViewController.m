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

@interface ConfigDiskShowModel : NSObject

@property (nonatomic) BOOL isSelect;
@property (nonatomic) BOOL showArrow;
@property (nonatomic) BOOL showCell;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;
@property (nullable, nonatomic, strong) NSArray *cellArr;

@end

@implementation ConfigDiskShowModel

@end

@interface ConfigDiskViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (nonatomic, strong) NSMutableArray *sourceArr;

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
    model.isSelect = NO;
    model.showArrow = YES;
    model.showCell = NO;
    model.title = @"RAID 1";
    model.detail = @"Erase data and format";
    model.cellArr = @[@"The two hard disks are automatically mirrored. When any of the disks is damaged, it can be simply replaced by a new disk. It is the recommended ultimate mode for data security - Recommended."];
    [_sourceArr addObject:model];
    
    model = [[ConfigDiskShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = YES;
    model.showCell = NO;
    model.title = @"BASIC";
    model.detail = @"Erase data and format";
    model.cellArr = @[@"Master-slave mode, the slave disk is mounted to the public directory - Recommended. "];
    [_sourceArr addObject:model];
    
    model = [[ConfigDiskShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = YES;
    model.showCell = NO;
    model.title = @"RAID 0";
    model.detail = @"Erase data and format";
    model.cellArr = @[@"The two hard disks are virtually merged into one, the overall capacity doubles with fast access speed. BUT, if any of the disks is damaged, the data of the other disk will be lost. "];
    [_sourceArr addObject:model];
    
    model = [[ConfigDiskShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = YES;
    model.showCell = NO;
    model.title = @"LVM";
    model.detail = @"Erase data and format";
    model.cellArr = @[@"All hard disks are merged into one virtual disk, the overall capacity is the sum of that of the two disks. This way enables adding in a new disk without any changes to the directory structure. "];
    [_sourceArr addObject:model];
    
    model = [[ConfigDiskShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = NO;
    model.showCell = NO;
    model.title = @"Add to RAID 1";
    model.detail = @"Erase data and format";
    model.cellArr = nil;
    [_sourceArr addObject:model];
    
    model = [[ConfigDiskShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = NO;
    model.showCell = NO;
    model.title = @"Add to LVM";
    model.detail = @"Erase data and format";
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
    [self jumpToReconfigDisk];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // return _sourceArr.count;
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    ConfigDiskShowModel *model = _sourceArr[section];
    if (model.showCell) {
        return model.cellArr.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ConfigDiskCell *cell = [tableView dequeueReusableCellWithIdentifier:ConfigDiskCellReuse];
    
    ConfigDiskShowModel *model = _sourceArr[indexPath.section];
    if (indexPath.row == 0) {
        
    }
    
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
    UploadFilesShowModel *model = _sourceArr[section];
    
    ConfigDiskHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:ConfigDiskHeaderViewReuse];
    [headerView configHeaderWithModel:model];
    @weakify_self
//    [headerView setSelectB:^{
//        model.isSelect = !model.isSelect;
//        [weakSelf.mainTable reloadData];
//    }];
//    [headerView setShowCellB:^{
//        if (model.showArrow) {
//            model.showCell = !model.showCell;
//            [weakSelf.mainTable reloadData];
//        }
//    }];
    
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
    [self.navigationController pushViewController:vc animated:YES];
}

@end
