//
//  MyFilesViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "MyFilesViewController.h"
#import "MyFilesCell.h"

@interface MyFilesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;

@end

@implementation MyFilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self dataInit];
}

#pragma mark - Operation
- (void)dataInit {
    _sourceArr = [NSMutableArray array];
    
    [_mainTable registerNib:[UINib nibWithNibName:MyFilesCellReuse bundle:nil] forCellReuseIdentifier:MyFilesCellReuse];
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _sourceArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MyFilesCellHeight;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    MyFilesCell *cell = [tableView dequeueReusableCellWithIdentifier:MyFilesCellReuse];
    
    //    [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:65.f];
    //    cell.delegate = (id)self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
