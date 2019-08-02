//
//  PNEmailTypeSelectView.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/17.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNEmailTypeSelectView.h"
#import "EmailOptionCell.h"

@interface PNEmailTypeSelectView ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *mainTabView;
@property (nonatomic ,strong) NSArray *dataArray;
@end

@implementation PNEmailTypeSelectView
- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}
#pragma mark ----------layz---------------
- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = @[@[@"QQMAILBOX",@"1"],@[@"QQmail",@"2"],@[@"163mail",@"3"],@[@"Gmail",@"4"]];
    }
    return _dataArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    _mainTabView.delegate = self;
    _mainTabView.dataSource = self;
    _mainTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _mainTabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_mainTabView registerNib:[UINib nibWithNibName:EmailOptionCellResue bundle:nil] forCellReuseIdentifier:EmailOptionCellResue];
}

#pragma mark --------tableview delegate-----------
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return EmailOptionCellHeight2;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmailOptionCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailOptionCellResue];
    cell.lblName.text = self.dataArray[indexPath.row][0];
    cell.headImgView.image = [UIImage imageNamed:self.dataArray[indexPath.row][0]];
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *typeArr = self.dataArray[indexPath.row];
//    if (![typeArr[1] isEqualToString:@"4"]) {
//        if (_clickRowBlock) {
//            _clickRowBlock(self,typeArr);
//        }
//    }
    
    if (_clickRowBlock) {
        _clickRowBlock(self,typeArr);
    }
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
