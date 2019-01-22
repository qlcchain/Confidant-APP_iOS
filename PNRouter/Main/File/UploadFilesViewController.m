//
//  UploadFilesViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "UploadFilesViewController.h"
#import "UploadFilesCell.h"
#import "UploadFilesHeaderView.h"

@interface UploadFilesShowModel : NSObject

@property (nonatomic) BOOL isSelect;
@property (nonatomic) BOOL showArrow;
@property (nonatomic) BOOL showCell;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *detail;
@property (nonatomic, strong) NSMutableArray *cellArr;

@end

@implementation UploadFilesShowModel

@end

@interface UploadFilesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;

@end

@implementation UploadFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self dataInit];
}

#pragma mark - Operation
- (void)dataInit {
    _sourceArr = [NSMutableArray array];
    UploadFilesShowModel *model = [[UploadFilesShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = NO;
    model.showCell = NO;
    model.title = @"Private Files";
    model.detail = @"Just me";
    model.cellArr = nil;
    [_sourceArr addObject:model];
    
    model = [[UploadFilesShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = NO;
    model.showCell = NO;
    model.title = @"Public Files";
    model.detail = @"Share with all friends";
    model.cellArr = nil;
    [_sourceArr addObject:model];
    
    model = [[UploadFilesShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = NO;
    model.showCell = NO;
    model.title = @"Share to";
    model.detail = @"Selected friends";
    model.cellArr = [NSMutableArray array];
    [_sourceArr addObject:model];
    
    model = [[UploadFilesShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = NO;
    model.showCell = NO;
    model.title = @"Don't share to";
    model.detail = @"Exclude selected friends";
    model.cellArr = [NSMutableArray array];
    [_sourceArr addObject:model];
    
    [_mainTable registerNib:[UINib nibWithNibName:UploadFilesCellReuse bundle:nil] forCellReuseIdentifier:UploadFilesCellReuse];
    [_mainTable registerNib:[UINib nibWithNibName:UploadFilesHeaderViewReuse bundle:nil] forHeaderFooterViewReuseIdentifier:UploadFilesHeaderViewReuse];
}

#pragma mark - Action

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _sourceArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    UploadFilesShowModel *model = _sourceArr[section];
    if (model.showCell) {
        return model.cellArr.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UploadFilesCell *cell = [tableView dequeueReusableCellWithIdentifier:UploadFilesCellReuse];
    
    UploadFilesShowModel *model = _sourceArr[indexPath.section];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UploadFilesCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return UploadFilesHeaderViewHeight;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UploadFilesShowModel *model = _sourceArr[section];
    
    UploadFilesHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:UploadFilesHeaderViewReuse];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UploadFilesShowModel *model = _sourceArr[indexPath.section];
}

@end
