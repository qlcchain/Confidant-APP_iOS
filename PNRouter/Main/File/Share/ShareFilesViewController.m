//
//  ShareFilesViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "ShareFilesViewController.h"
#import "MyFilesCell.h"

@interface ShareFilesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;

@end

@implementation ShareFilesViewController

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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [UIView new];
    headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    
    UILabel *titleLab = [UILabel new];
    titleLab.frame = CGRectMake(16, 10, 200, 20);
    NSString *title = @"";
    if (section == 0) {
        title = [NSString stringWithFormat:@"Ongoing (%@)",@"1"];
    } else if (section == 1) {
        title = [NSString stringWithFormat:@"Completed (%@)",@"1"];
    }
    titleLab.text = title;
    titleLab.textColor = UIColorFromRGB(0x2c2c2c);
    titleLab.font = [UIFont systemFontOfSize:14];
    [headerView addSubview:titleLab];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [UIView new];
    footerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 10);
    footerView.backgroundColor = [UIColor clearColor];
    
    return footerView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
