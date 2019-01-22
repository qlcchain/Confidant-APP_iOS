//
//  DetailInformationViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "DetailInformationViewController.h"
#import "DetailInformationCell.h"

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
    
    [_mainTable registerNib:[UINib nibWithNibName:DetailInformationCellReuse bundle:nil] forCellReuseIdentifier:DetailInformationCellReuse];
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

@end
