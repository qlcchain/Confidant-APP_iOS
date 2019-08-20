//
//  PNEmailEncrypedViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/8/19.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNEmailEncrypedViewController.h"
#import "EmailEncrypedCell.h"

@interface PNEmailEncrypedViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, assign) int connectType;
@property (weak, nonatomic) IBOutlet UITableView *mainTabView;

@end

@implementation PNEmailEncrypedViewController

- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}
- (instancetype)initWithConnectType:(int)connectType
{
    if (self = [super init]) {
        self.connectType = connectType;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    
    _mainTabView.delegate = self;
    _mainTabView.dataSource = self;
    _mainTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_mainTabView registerNib:[UINib nibWithNibName:EmailEncrypedCellResue bundle:nil] forCellReuseIdentifier:EmailEncrypedCellResue];
}
- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = @[@"None",@"SSL/TLS",@"STARTTLS"];
    }
    return _dataArray;
}

#pragma mark -----------------tableview deleate ---------------------
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return EmailEncrypedCellHeight;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmailEncrypedCell *myCell = [tableView dequeueReusableCellWithIdentifier:EmailEncrypedCellResue];
    myCell.selImgView.hidden = YES;
    if (self.connectType == 1 && indexPath.row == 0) {
        myCell.selImgView.hidden = NO;
    } else if (self.connectType == 4 && indexPath.row == 1) {
        myCell.selImgView.hidden = NO;
    } else if (self.connectType == 2 && indexPath.row == 2){
         myCell.selImgView.hidden = NO;
    }
    myCell.lblContent.text = self.dataArray[indexPath.row];
    return myCell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        self.connectType = 1;
    } else if (indexPath.row == 1) {
        self.connectType = 4;
    } else {
        self.connectType = 2;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:EMAIL_ENTRYPED_CHOOSE_NOTI object:@(self.connectType)];
    [self leftNavBarItemPressedWithPop:NO];
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
