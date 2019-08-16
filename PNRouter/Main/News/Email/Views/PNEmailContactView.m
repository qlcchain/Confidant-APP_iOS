//
//  PNEmailContactView.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/8/15.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNEmailContactView.h"
#import "EmailContactCell.h"

@interface PNEmailContactView ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) NSMutableArray *dataArray;

@end

@implementation PNEmailContactView
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (void) setLoadDataArray:(NSMutableArray *) arr
{
    if (self.dataArray.count > 0) {
        [self.dataArray removeAllObjects];
    }
    [self.dataArray addObjectsFromArray:arr];
    [_mainTabView reloadData];
}
+ (instancetype) loadPNEmailContactView
{
    PNEmailContactView *view = [[[NSBundle mainBundle] loadNibNamed:@"PNEmailContactView" owner:self options:nil] lastObject];
    view.frame = CGRectMake(0, 50+NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-50-NAVIGATION_BAR_HEIGHT);
    [view setTabViewDelegate];
    return view;
}

- (void) setTabViewDelegate
{
    _mainTabView.delegate = self;
    _mainTabView.dataSource = self;
    _mainTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_mainTabView registerNib:[UINib nibWithNibName:EmailContactCellResue bundle:nil] forCellReuseIdentifier:EmailContactCellResue];
}

#pragma mark--------------UITableViewDelegate----------------

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
   return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return EmailContactCellHeight;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    EmailContactCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailContactCellResue];
    EmailContactModel *model = self.dataArray[indexPath.row];
    cell.selImgView.hidden = YES;
    [cell setEmailContactModel:model];
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EmailContactModel *model = self.dataArray[indexPath.row];
    if (_contactBlock) {
        _contactBlock(model);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
