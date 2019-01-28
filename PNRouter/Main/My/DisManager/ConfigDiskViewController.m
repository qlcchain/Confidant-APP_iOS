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
    [_mainTable registerNib:[UINib nibWithNibName:ConfigDiskCellReuse bundle:nil] forCellReuseIdentifier:ConfigDiskCellReuse];
    [_mainTable registerNib:[UINib nibWithNibName:ConfigDiskHeaderViewReuse bundle:nil] forHeaderFooterViewReuseIdentifier:ConfigDiskHeaderViewReuse];
}

#pragma mark - Action

- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)confirmAction:(id)sender {
    
}


#pragma mark - UITableViewDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ConfigDiskCell_Height;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ConfigDiskCell *cell = [tableView dequeueReusableCellWithIdentifier:ConfigDiskCellReuse];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

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

@end
