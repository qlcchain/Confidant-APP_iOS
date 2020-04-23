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
#import "KeyBordHeadView.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "NSString+Trim.h"

@interface PNSelectFloderViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *createBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIView *bottomBackView;
@property (weak, nonatomic) IBOutlet UITableView *mainTabView;
@property (weak, nonatomic) IBOutlet UILabel *lblFlderName;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, assign) NSInteger selRow;
@property (nonatomic, strong) KeyBordHeadView *keyHeadView;

@end

@implementation PNSelectFloderViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
// 取消keyboard
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}
- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}
- (IBAction)createFloderAction:(id)sender {
    [AppD.window addSubview:self.keyHeadView];
    [self.keyHeadView.floderTF becomeFirstResponder];
}
- (IBAction)selectFloderAction:(id)sender {
    if (self.dataArray.count > 0) {
        PNFloderModel *floderM = self.dataArray[_selRow];
        [[NSNotificationCenter defaultCenter] postNotificationName:Photo_Select_Floder_Noti object:floderM];
        [self clickBackAction:nil];
    } else {
        [self.view showHint:@"Please select an album"];
    }
}
#pragma mark ---layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (KeyBordHeadView *)keyHeadView
{
    if (!_keyHeadView) {
        _keyHeadView = [KeyBordHeadView getKeyBordHeadView];
        _keyHeadView.floderTF.delegate = self;
    }
    return _keyHeadView;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(KeyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createFloderSuccessNoti:) name:Create_Floder_Success_Noti object:nil];
    
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



- (void) createFloderWithName:(NSString *) name
{
    NSString *fname = [Base58Util Base58EncodeWithCodeName:name];
    [SendRequestUtil sendUpdateloderWithFloderType:1 updateType:2 react:3 name:fname oldName:@"" fid:0 pathid:0 showHud:YES];
}

#pragma mark---------------请求通知
- (void) createFloderSuccessNoti:(NSNotification *) noti
{
    NSDictionary *responDic = noti.object?:@{};
    PNFloderModel *floderM = [[PNFloderModel alloc] init];
    floderM.PathName = responDic[@"Name"];
    floderM.fId = [responDic[@"PathId"] integerValue];
    [self.dataArray addObject:floderM];
    [self.mainTabView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark ---点击键盘done
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *floderName = [NSString trimWhitespace:textField.text];
    if (floderName.length == 0) {
        [AppD.window showMiddleHint:@"The name cannot be empty."];
        return NO;
    }
    textField.text = @"";
    [self createFloderWithName:floderName];
    return [self.keyHeadView.floderTF resignFirstResponder];
}

#pragma mark ----KeyboardWillShowNotification
- (void) KeyboardWillShowNotification:(NSNotification *) notification
{
    self.view.userInteractionEnabled = NO;
    NSDictionary *userInfo = [notification userInfo];
    CGFloat duration = [[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    CGRect rect = [[userInfo objectForKey:@"UIKeyboardFrameEndUserInfoKey"]CGRectValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.keyHeadView.frame = CGRectMake(0, rect.origin.y-163, SCREEN_WIDTH, 163);
    }];
}
- (void) KeyboardWillHideNotification:(NSNotification *) notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGFloat duration = [[userInfo objectForKey:@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        self.keyHeadView.frame = CGRectMake(0,SCREEN_HEIGHT, SCREEN_WIDTH, 163);
    } completion:^(BOOL finished) {
        self.view.userInteractionEnabled = YES;
        [self.keyHeadView removeFromSuperview];
    }];
}
@end
