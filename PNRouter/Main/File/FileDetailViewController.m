//
//  FileDetailViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/11.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "FileDetailViewController.h"
#import "MyCell.h"
#import "FileDetailCell.h"

@interface FileDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (nonatomic ,strong) NSArray *dataArray;
@end

@implementation FileDetailViewController
- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)scanAction:(id)sender {
}
- (IBAction)downAction:(id)sender {
}

#pragma mark -layz
- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = @[@[@"File Type",@"Format",@"Created",@"File Size",@"File Name",@"Directory"],@[@"Forward to Contact"],@[@"Download to Phone"],@[@"Delete Permanently"]];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableV registerNib:[UINib nibWithNibName:MyCellReuse bundle:nil] forCellReuseIdentifier:MyCellReuse];
     [_tableV registerNib:[UINib nibWithNibName:FileDetailCellResue bundle:nil] forCellReuseIdentifier:FileDetailCellResue];
}
#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *rowArr = [self.dataArray objectAtIndex:section];
    return rowArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return MyCellReuse_Height;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 16;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 16)];
    backView.backgroundColor = [UIColor clearColor];
    return backView;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        MyCell *cell = [tableView dequeueReusableCellWithIdentifier:MyCellReuse];
        NSArray *rowArr = [self.dataArray objectAtIndex:indexPath.section];
        cell.lblContent.text = rowArr[indexPath.row];
        if (indexPath.row == 0) {
            cell.lblSubContent.hidden = YES;
            cell.rightJD.hidden = YES;
            cell.subBtn.hidden = NO;
            [cell.subBtn setImage:[UIImage imageNamed:@"icon_zip"] forState:UIControlStateNormal];
           
        } else if (indexPath.row == 1 || indexPath.row == 2 ) {
            
            cell.lblSubContent.hidden = NO;
            cell.rightJD.hidden = YES;
            cell.subBtn.hidden = YES;
            if (indexPath.row == 1) {
                cell.lblSubContent.text = @"txt";
            } else {
                cell.lblSubContent.text = @"2018-06-08 18:07";
            }
            
        } else{
            cell.lblSubContent.hidden = NO;
            cell.rightJD.hidden = NO;
            cell.subBtn.hidden = YES;
            if (indexPath.row == 3) {
                cell.lblSubContent.text = @"12kb";
            } else {
                cell.lblSubContent.text = @"Google project development essential information";
            }
        }
        return cell;
    } else {
        FileDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:FileDetailCellResue];
        NSArray *rowArr = [self.dataArray objectAtIndex:indexPath.section];
        cell.lblContent.text = rowArr[indexPath.row];
        return cell;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
