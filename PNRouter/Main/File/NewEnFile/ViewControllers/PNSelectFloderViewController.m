//
//  PNSelectFloderViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/12/17.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNSelectFloderViewController.h"
#import "EnPhotoCell.h"
#import "PNFloderModel.h"
#import "MyConfidant-Swift.h"

@interface PNSelectFloderViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *createBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomBackView;
@property (weak, nonatomic) IBOutlet UITableView *mainTabView;
@property (weak, nonatomic) IBOutlet UILabel *lblFlderName;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger selRow;

@end

@implementation PNSelectFloderViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}
- (IBAction)createFloderAction:(id)sender {
    
}
- (IBAction)selectFloderAction:(id)sender {
    if (self.dataArray.count > 0) {
        PNFloderModel *floderM = self.dataArray[_selRow];
        [[NSNotificationCenter defaultCenter] postNotificationName:Photo_Select_Floder_Noti object:floderM];
        [self clickBackAction:nil];
    } else {
        [self.view showHint:@"Please select album."];
    }
}

- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, SCREEN_WIDTH, 174) byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(16,16)];//圆角大小
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, 174);//_backView.bounds;
    maskLayer.path = maskPath.CGPath;
    _bottomBackView.layer.mask = maskLayer;
    
    _createBtn.layer.cornerRadius = 8.0f;
    _createBtn.layer.borderColor = RGB(74, 78, 92).CGColor;
    _createBtn.layer.borderWidth = 1.0f;
    
    _selectBtn.layer.cornerRadius = 8.0f;
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    
    _mainTabView.delegate = self;
    _mainTabView.dataSource = self;
    _mainTabView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [_mainTabView registerNib:[UINib nibWithNibName:EnPhotoCellResue bundle:nil] forCellReuseIdentifier:EnPhotoCellResue];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullFloderListNoti:) name:Pull_Floder_List_Noti object:nil];
    
    [SendRequestUtil sendPullFloderListWithFloderType:1 showHud:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return EnPhotoCellHeight;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   EnPhotoCell *myCell = [tableView dequeueReusableCellWithIdentifier:EnPhotoCellResue];
   PNFloderModel *floderM = self.dataArray[indexPath.row];
    [myCell setFloderM:floderM isLocal:NO];
    myCell.rightImgV.hidden = YES;
    if (_selRow == indexPath.row) {
        myCell.rightImgV.hidden = NO;
        [myCell.rightImgV setImage:[UIImage imageNamed:@"tabbar_hook"]];
        _lblFlderName.text = [Base58Util Base58DecodeWithCodeName:floderM.PathName];
    }
   return myCell;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selRow = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}



#pragma makr-------------请求通知
- (void) pullFloderListNoti:(NSNotification *) noti
{
    NSDictionary *responDic = noti.object?:@{};
    NSString *jsonStr = responDic[@"Payload"]?:@"";
    NSArray *floderArr = [PNFloderModel mj_objectArrayWithKeyValuesArray:jsonStr.mj_JSONObject]?:nil;
    if (floderArr) {
        [self.dataArray addObjectsFromArray:floderArr];
        [_mainTabView reloadData];
    }
}

@end
