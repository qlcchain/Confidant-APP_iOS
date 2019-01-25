//
//  ChooseContactViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/21.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ChooseShareContactViewController.h"
#import "GroupCell.h"
#import "ChooseContactCell.h"
#import "ContactsHeadView.h"
#import "ChooseDownView.h"
#import "ChatListDataUtil.h"


@interface ChooseShareContactViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
{
    BOOL isMutable;
}

@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (nonatomic, strong) ChooseDownView *downView;

@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) NSMutableArray *selectArray;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;

@end

@implementation ChooseShareContactViewController

- (IBAction)backAction:(id)sender {
    if (isMutable) {
        isMutable = NO;
        [_tableV reloadData];
        _rightBtn.hidden = NO;
        if (self.downView.frame.origin.y == SCREEN_HEIGHT-Tab_BAR_HEIGHT) {
            [UIView animateWithDuration:0.3f animations:^{
                self.downView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, Tab_BAR_HEIGHT);
            }];
        }
    } else {
         [self backVC];
    }
}
- (void) backVC
{
    [self.selectArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        model.isSelect = NO;
    }];
    [self leftNavBarItemPressedWithPop:NO];
}
- (IBAction)rightAction:(id)sender {
    isMutable = !isMutable;
    if (isMutable) {
        _rightBtn.hidden = YES;
        if (self.selectArray.count > 0) {
            [UIView animateWithDuration:0.3f animations:^{
                self.downView.frame = CGRectMake(0, SCREEN_HEIGHT-Tab_BAR_HEIGHT, SCREEN_WIDTH, Tab_BAR_HEIGHT);
            }];
        }
    }
    [_tableV reloadData];
}
#pragma mark -layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[ChatListDataUtil getShareObject].friendArray mutableCopy];
    }
    return _dataArray;
}

- (NSMutableArray *)selectArray
{
    if (!_selectArray) {
        _selectArray = [NSMutableArray array];
    }
    return _selectArray;
}
- (ChooseDownView *)downView
{
    if (!_downView) {
        _downView = [ChooseDownView loadChooseDownView];
        _downView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, Tab_BAR_HEIGHT);
        [_downView.comfirmBtn addTarget:self action:@selector(comfirmBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downView;
}
#pragma textfeild delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@"textFieldShouldReturn");
    return YES;
}
#pragma mark -viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    _searchBackView.layer.cornerRadius = 3.0f;
    _searchBackView.layer.masksToBounds = YES;
    _searchTF.delegate = self;
    _tableV.delegate = self;
    _tableV.dataSource = self;
    _tableV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableV registerNib:[UINib nibWithNibName:GroupCellReuse bundle:nil] forCellReuseIdentifier:GroupCellReuse];
    [_tableV registerNib:[UINib nibWithNibName:ChooseContactCellReuse bundle:nil] forCellReuseIdentifier:ChooseContactCellReuse];
    [self.view addSubview:self.downView];
}


#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ChooseContactCellHeight;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 64;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    backView.backgroundColor = [UIColor clearColor];
    ContactsHeadView *view = [ContactsHeadView loadContactsHeadView];
    view.lblTitle.text = @"Share Contact";
    view.frame = backView.bounds;
    [backView addSubview:view];
    return backView;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    ChooseContactCell *cell = [tableView dequeueReusableCellWithIdentifier:ChooseContactCellReuse];
    FriendModel *model = self.dataArray[indexPath.row];
    CGFloat leftV = 0;
    if (isMutable) {
        leftV = 38;
    }
    [cell setModeWithModel:model withLeftContraintV:leftV];
    cell.tag = indexPath.row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        FriendModel *model = self.dataArray[indexPath.row];
        if (isMutable) {
            if (model.isSelect) {
                [self.selectArray removeObject:model];
            } else {
                 [self.selectArray addObject:model];
            }
            model.isSelect = !model.isSelect;
            [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            if (self.selectArray.count > 0) {
                if (!_downView) {
                    self.downView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, Tab_BAR_HEIGHT);
                    [self.view addSubview:_downView];
                }
                if (self.downView.frame.origin.y == SCREEN_HEIGHT) {
                    [UIView animateWithDuration:0.3f animations:^{
                        self.downView.frame = CGRectMake(0, SCREEN_HEIGHT-Tab_BAR_HEIGHT, SCREEN_WIDTH, Tab_BAR_HEIGHT);
                    }];
                }
                self.downView.lblContent.text = [NSString stringWithFormat:@"Selected: %lu persons, %d groups",(unsigned long)self.selectArray.count,0];

            } else {
                [UIView animateWithDuration:0.3f animations:^{
                    self.downView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, Tab_BAR_HEIGHT);
                }];
            }
        } else {
            [self.selectArray addObject:model];
            [[NSNotificationCenter defaultCenter] postNotificationName:CHOOSE_Share_FRIEND_NOTI object:self.selectArray];
            [self backVC];
        }
    }
    
}

#pragma mark -uibutton_tag
- (void) comfirmBtnAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:CHOOSE_Share_FRIEND_NOTI object:self.selectArray];
    [self backVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
