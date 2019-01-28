//
//  DiskManagerViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "DiskManagerViewController.h"
#import "DiskManagementCell.h"

@interface DiskManagerViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (weak, nonatomic) IBOutlet UIProgressView *progressV;
@property (nonatomic, strong) NSMutableArray *sourceArr;

@end

@implementation DiskManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self viewInit];
    [self dataInit];
}

#pragma mark - Operation
- (void)dataInit  {
    _sourceArr = [NSMutableArray array];
    [_mainTable registerNib:[UINib nibWithNibName:DiskManagementCellReuse bundle:nil] forCellReuseIdentifier:DiskManagementCellReuse];
}

- (void)viewInit {
    _progressV.transform  = CGAffineTransformMakeScale(1.0, 10.0);
}


#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)configDiskAction:(id)sender {
    
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
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


@end
