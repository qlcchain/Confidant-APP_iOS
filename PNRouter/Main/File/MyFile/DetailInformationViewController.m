//
//  DetailInformationViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "DetailInformationViewController.h"
#import "DetailInformationCell.h"
#import "SharedSettingsViewController.h"

@interface DetailInformationShowModel : NSObject

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *val;
@property (nonatomic) BOOL showArrow;

@end

@implementation DetailInformationShowModel

@end

@interface DetailInformationViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (nonatomic, strong) IBOutlet UITableView *mainTable;

@end

@implementation DetailInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self dataInit];
}

#pragma mark - Operation
- (void)dataInit {
    _sourceArr = [NSMutableArray array];
    
    DetailInformationShowModel *model = [[DetailInformationShowModel alloc] init];
    model.key = @"File Source";
    model.val = @"AUTODESK 3DSMAX MAGNiTUDE";
    model.showArrow = YES;
    [_sourceArr addObject:model];
    model = [[DetailInformationShowModel alloc] init];
    model.key = @"File Type";
    model.val = @"ZIP";
    model.showArrow = NO;
    [_sourceArr addObject:model];
    model = [[DetailInformationShowModel alloc] init];
    model.key = @"Modification time";
    model.val = @"2018/08/09 13:00";
    model.showArrow = NO;
    [_sourceArr addObject:model];
    model = [[DetailInformationShowModel alloc] init];
    model.key = @"File Size";
    model.val = @"21 K";
    model.showArrow = NO;
    [_sourceArr addObject:model];
    model = [[DetailInformationShowModel alloc] init];
    model.key = @"File Source";
    model.val = @"ChenKai Upload";
    model.showArrow = NO;
    [_sourceArr addObject:model];
    model = [[DetailInformationShowModel alloc] init];
    model.key = @"File Assignment";
    model.val = @"ChenKai";
    model.showArrow = NO;
    [_sourceArr addObject:model];
    model = [[DetailInformationShowModel alloc] init];
    model.key = @"Shared Settings";
    model.val = @"Private files";
    model.showArrow = YES;
    [_sourceArr addObject:model];
    
    [_mainTable registerNib:[UINib nibWithNibName:DetailInformationCellReuse bundle:nil] forCellReuseIdentifier:DetailInformationCellReuse];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return DetailInformationCellHeight;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    DetailInformationCell *cell = [tableView dequeueReusableCellWithIdentifier:DetailInformationCellReuse];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

#pragma mark - Transition
- (void)jumpToSharedSettings {
    SharedSettingsViewController *vc = [[SharedSettingsViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
