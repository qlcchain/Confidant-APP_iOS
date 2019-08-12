//
//  PNEmailMoveViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/19.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNEmailMoveViewController.h"
#import "EmailMoveCell.h"
#import "EmailOptionUtil.h"

@interface PNEmailMoveViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger selRow;
}
@property (weak, nonatomic) IBOutlet UITableView *mainTableV;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSString *floderPath;
@property (nonatomic ,assign) NSInteger uid;
@end

@implementation PNEmailMoveViewController

- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}
- (IBAction)clickConfirmAction:(id)sender {
    NSString *floderName = self.dataArray[selRow];
    @weakify_self
    [self.view showHudInView:self.view hint:@""];
    [EmailOptionUtil copyEmailToFloderWithFloderPath:_floderPath toFloderName:floderName uid:_uid isDel:YES complete:^(BOOL success) {
        [weakSelf.view hideHud];
        if (success) {
            if (weakSelf.moveBlock) {
                weakSelf.moveBlock();
            }
            [weakSelf leftNavBarItemPressedWithPop:NO];
        } else {
            [weakSelf.view showFaieldHudInView:weakSelf.view hint:@"Failure."];
        }
    }];
}

#pragma mark ----layz-----------
- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = @[Sent,Spam,Trash];
    }
    return _dataArray;
}

- (instancetype) initWithFloderPath:(NSString *) floderPath uid:(NSInteger) uid
{
    if (self = [super init]) {
        self.floderPath = floderPath;
        self.uid = uid;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    selRow = 0;
    _mainTableV.delegate = self;
    _mainTableV.dataSource = self;
    _mainTableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _mainTableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_mainTableV registerNib:[UINib nibWithNibName:EmailMoveCellResue bundle:nil] forCellReuseIdentifier:EmailMoveCellResue];
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return EmailMoveCellHeight;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmailMoveCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailMoveCellResue];
    cell.lblContent.text = self.dataArray[indexPath.row];
    cell.headImgView.image = [UIImage imageNamed:self.dataArray[indexPath.row]];
    if (indexPath.row == selRow) {
        cell.selImgView.hidden = NO;
    } else {
        cell.selImgView.hidden = YES;
    }
    return cell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (selRow == indexPath.row) {
        return;
    }
    selRow = indexPath.row;
    [tableView reloadData];
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
