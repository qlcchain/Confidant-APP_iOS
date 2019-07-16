//
//  PNEmailOptionEnumView.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/16.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNEmailOptionEnumView.h"
#import "EmailOptionCell.h"

@interface PNEmailOptionEnumView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic ,strong) NSArray *dataArray;
@end

@implementation PNEmailOptionEnumView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = @[@[@"sheet_mark",@"Mark Unread"],@[@"tabbar_stars_unselected_h",@"Star"],@[@"statusbar_download_node",@"Node back up"],@[@"sheet_move",@"Move to"],@[@"statusbar_delete",@"Delete"]];
    }
    return _dataArray;
}

+ (instancetype) loadPNEmailOptionEnumView
{
    PNEmailOptionEnumView *view = [[[NSBundle mainBundle] loadNibNamed:@"PNEmailOptionEnumView" owner:self options:nil] lastObject];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    view.backContraintBottom.constant = -315;
    
    view.mainTabView.delegate = view;
    view.mainTabView.dataSource = view;
    view.mainTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    view.mainTabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [view.mainTabView registerNib:[UINib nibWithNibName:EmailOptionCellResue bundle:nil] forCellReuseIdentifier:EmailOptionCellResue];
    
    return view;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}
- (IBAction)clickBackAction:(id)sender {
    [self hideEmailOptionEnumView];
}

- (void) showEmailOptionEnumView
{
    [AppD.window addSubview:self];
    _backContraintBottom.constant = 0;
    @weakify_self
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf layoutIfNeeded];
    }];
}

- (void) hideEmailOptionEnumView
{
    _backContraintBottom.constant = -315;
    @weakify_self
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}

#pragma mark ----tableview delegate---------
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return EmailOptionCellHeight;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmailOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailOptionCellResue];
    NSString *imgName = self.dataArray[indexPath.row][0];
    NSString *content = self.dataArray[indexPath.row][1];
    cell.headImgView.image = [UIImage imageNamed:imgName];
    cell.lblName.text = content;
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self hideEmailOptionEnumView];
    if (_emumBlock) {
        _emumBlock(indexPath.row);
    }
}
@end
