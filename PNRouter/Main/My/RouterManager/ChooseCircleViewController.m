//
//  ChooseContactViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/21.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ChooseCircleViewController.h"
#import "NSString+Base64.h"
#import "RouterModel.h"
#import "ChooseCircleCell.h"

@interface ChooseCircleViewController ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight; // 44
@property (weak, nonatomic) IBOutlet UITableView *tableV;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;
@property (weak, nonatomic) IBOutlet UIButton *leaveBtn;

@property (nonatomic) BOOL isEdit;
@property (nonatomic ,strong) NSMutableArray *circleArr;

@end

@implementation ChooseCircleViewController

- (void)viewWillAppear:(BOOL)animated {
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [super viewWillAppear:animated];
}

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self dataInit];
    [self viewInit];
}

#pragma mark - Operation
- (void)dataInit {
    _circleArr = [NSMutableArray array];
    NSArray *localRouters = [RouterModel getLocalRouters];
    @weakify_self
    [localRouters enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChooseCircleShowModel *model = [ChooseCircleShowModel new];
        model.showSelect = NO;
        model.isSelect = NO;
        model.routerM = obj;
        [weakSelf.circleArr addObject:model];
    }];
}

- (void)viewInit {
    _bottomHeight.constant = 0;
    [_tableV registerNib:[UINib nibWithNibName:ChooseCircleCellReuse bundle:nil] forCellReuseIdentifier:ChooseCircleCellReuse];
}

- (NSMutableArray *)getSelectCircles {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [_circleArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChooseCircleShowModel *showModel = obj;
        if (showModel.isSelect) {
            [array addObject:showModel];
        }
    }];
    return array;
}

#pragma mark - Action
- (IBAction)backAction:(id)sender {
    if (_isEdit) {
        _isEdit = NO;
        _rightBtn.hidden = NO;
        _bottomHeight.constant = 0;
        
        [_circleArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChooseCircleShowModel *model = obj;
            model.isSelect = NO;
            model.showSelect = NO;
        }];
        [_tableV reloadData];
    } else {
        [self backVC];
    }
}

- (void)backVC {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    
}
- (IBAction)rightAction:(id)sender {
    _isEdit = !_isEdit;
    if (_isEdit) {
        _rightBtn.hidden = YES;
//        NSArray *selectArr = [self getSelectCircles];
        _bottomHeight.constant = 44;
        [_circleArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ChooseCircleShowModel *model = obj;
            model.showSelect = YES;
            model.isSelect = NO;
        }];
        [_tableV reloadData];
    }
    
    [_tableV reloadData];
}

- (IBAction)leaveAction:(id)sender {
    NSArray *selectArr = [self getSelectCircles];
    
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _circleArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ChooseCircleCell_Height;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    ChooseCircleCell *cell = [tableView dequeueReusableCellWithIdentifier:ChooseCircleCellReuse];
    cell.tableRow = indexPath.row;
    ChooseCircleShowModel *model = _circleArr[indexPath.row];
    [cell configCellWithModel:model];
    @weakify_self
    cell.selectB = ^(NSInteger tableRow) {
        ChooseCircleShowModel *tempM = weakSelf.circleArr[tableRow];
        if (weakSelf.isEdit) { // 多选点击cell
            tempM.isSelect = YES;
            [weakSelf.tableV reloadData];
        } else { // 切换Cirlce
            
        }
    };
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!tableView.isEditing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
