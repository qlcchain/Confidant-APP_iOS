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
@property (nonatomic ,strong) NSArray *groupArray;
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
- (NSArray *)groupArray
{
    if (!_groupArray) {
        _groupArray = @[@"New Chat"];
    }
    return _groupArray;
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
    return 2;
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.groupArray.count;
    }
    return self.dataArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return GroupCellHeight;
    }
    return ChooseContactCellHeight;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 64;
    }
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 64)];
    backView.backgroundColor = [UIColor clearColor];
    ContactsHeadView *view = [ContactsHeadView loadContactsHeadView];
    view.lblTitle.text = @"Recent Chat";
    view.frame = backView.bounds;
    [backView addSubview:view];
    return backView;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        GroupCell *cell = [tableView dequeueReusableCellWithIdentifier:GroupCellReuse];
        cell.lblName.text = self.groupArray[indexPath.row];
        cell.hdBackView.hidden = YES;
        if (indexPath.row == 0) {
            if (AppD.showHD) {
                cell.hdBackView.hidden = NO;
            }
        }
        return cell;
    }
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
        if (indexPath.section == 1) {
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
                [[NSNotificationCenter defaultCenter] postNotificationName:CHOOSE_FRIEND_NOTI object:self.selectArray];
                [self backVC];
            }
           
        } else if (indexPath.section == 0) {
           
        }
    }
    
}

#pragma mark -uibutton_tag
- (void) comfirmBtnAction {
    [[NSNotificationCenter defaultCenter] postNotificationName:CHOOSE_FRIEND_NOTI object:self.selectArray];
    [self backVC];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
