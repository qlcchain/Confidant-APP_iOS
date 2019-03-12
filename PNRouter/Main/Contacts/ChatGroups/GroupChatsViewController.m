//
//  GroupChatsViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "GroupChatsViewController.h"
#import "AddGroupMenuViewController.h"

@interface GroupChatsViewController ()<UITextFieldDelegate>
{
    BOOL isSearch;
}
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (weak, nonatomic) IBOutlet UIView *searchBackView;
@property (weak, nonatomic) IBOutlet UITableView *mainTab;
@property (nonatomic ,strong) NSMutableArray *dataArray;
@property (nonatomic ,strong) NSMutableArray *searchDataArray;

@end

@implementation GroupChatsViewController
#pragma -mark Action

- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)rightAction:(id)sender {
    AddGroupMenuViewController *vc = [[AddGroupMenuViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
#pragma -mark layz
- (NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}
- (NSMutableArray *)searchDataArray
{
    if (!_searchDataArray) {
        _searchDataArray = [NSMutableArray array];
    }
    return _searchDataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _searchBackView.layer.cornerRadius = 3.0f;
    _searchBackView.layer.masksToBounds = YES;
    _searchTF.delegate = self;
    _searchTF.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    _searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addTargetMethod];
}

#pragma mark - 直接添加监听方法
-(void)addTargetMethod{
    [_searchTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
}
- (void) textFieldTextChange:(UITextField *) tf
{
    if ([tf.text.trim isEmptyString]) {
        isSearch = NO;
    } else {
        isSearch = YES;
        [self.searchDataArray removeAllObjects];
        @weakify_self
        [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            ChatListModel *model = obj;
//            NSString *userName = [model.friendName lowercaseString];
//            if ([userName containsString:[tf.text.trim lowercaseString]]) {
//                [weakSelf.searchDataArray addObject:model];
//            }
        }];
    }
  //  [_tableV reloadData];
}

#pragma textfeild delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    NSLog(@"textFieldShouldReturn");
    return YES;
}

@end
