//
//  PNEmailContactViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNEmailContactViewController.h"
#import "EmailContactModel.h"
#import "EmailAccountModel.h"
#import "NSString+HexStr.h"
#import "EmailContactCell.h"

@interface PNEmailContactViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *mainTabV;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (nonatomic, strong) NSMutableArray *selArray;
@property (nonatomic ,strong) NSMutableDictionary *dataDic;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UIView *searBackView;
@property (weak, nonatomic) IBOutlet UITextField *searchTF;
@property (nonatomic) BOOL isSearch;
@property (nonatomic, strong) NSMutableArray *searchDataArray;
    
@property (nonatomic, strong) NSMutableArray *emailContacts;

@end

@implementation PNEmailContactViewController
- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}
- (IBAction)clickNextAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:EMIAL_CONTACT_SEL_NOTI object:self.selArray];
    [self leftNavBarItemPressedWithPop:NO];
}
- (NSMutableDictionary *)dataDic
{
    if (!_dataDic) {
        _dataDic = [NSMutableDictionary dictionary];
    }
    return _dataDic;
}
- (NSMutableArray *)searchDataArray
{
    if (!_searchDataArray) {
        _searchDataArray = [NSMutableArray array];
    }
    return _searchDataArray;
}
- (NSMutableArray *) emailContacts
{
    if (!_emailContacts) {
        _emailContacts = [NSMutableArray array];
    }
    return _emailContacts;
}
- (NSMutableArray *)selArray
{
    if (!_selArray) {
        _selArray = [NSMutableArray array];
    }
    return _selArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    _nextBtn.enabled = NO;
    [self loadData];
    
    _searBackView.layer.cornerRadius = 5.0f;
    _searBackView.layer.masksToBounds = YES;
    _searchTF.delegate = self;
    _searchTF.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    _searchTF.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self addTargetMethod];
    
    _mainTabV.delegate = self;
    _mainTabV.dataSource = self;
    _mainTabV.sectionFooterHeight = 0.1;
    _mainTabV.sectionHeaderHeight = 0.1;
    _mainTabV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _mainTabV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_mainTabV registerNib:[UINib nibWithNibName:EmailContactCellResue bundle:nil] forCellReuseIdentifier:EmailContactCellResue];
    
}
- (void) loadData
{
    //[EmailContactModel bg_drop:EMAIL_CONTACT_TABNAME];
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    NSArray *finfAlls = [EmailContactModel bg_find:EMAIL_CONTACT_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"user"),bg_sqlValue(accountM.User)]];
    if (finfAlls) {
        [self.emailContacts addObjectsFromArray:finfAlls];
        @weakify_self
        [finfAlls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EmailContactModel *model = obj;
            NSString *nameKey = [NSString firstCharactor:model.userName];
            NSArray *keys = [weakSelf.dataDic allKeys];
            if ([keys containsObject:nameKey]) {
                NSMutableArray *array = weakSelf.dataDic[nameKey];
                [array addObject:model];
            } else {
                NSMutableArray *array = [NSMutableArray arrayWithObjects:model, nil];
                [weakSelf.dataDic setValue:array forKey:nameKey];
            }
        }];
    }
    
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_isSearch) {
        return 1;
    }
    return self.dataDic.count;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_isSearch) {
        return self.searchDataArray.count;
    }
    NSArray *keys = [[self.dataDic allKeys]  sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    return [self.dataDic[keys[section]] count];
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_isSearch) {
        return @"";
    }
     NSArray *keys = [[self.dataDic allKeys]  sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    return [keys objectAtIndex:section];
}
//返回每组标题索引
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (_isSearch) {
        return nil;
    }
    NSArray *keys = [[self.dataDic allKeys]  sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    return keys;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_isSearch) {
        return 0.1;
    }
    return 28;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return EmailContactCellHeight;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmailContactCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailContactCellResue];
    if (_isSearch) {
        EmailContactModel *model = self.searchDataArray[indexPath.row];
        [cell setEmailContactModel:model];
        return cell;
    }
    NSArray *keys = [[self.dataDic allKeys]  sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSArray *models = self.dataDic[keys[indexPath.section]];
    EmailContactModel *model = models[indexPath.row];
    [cell setEmailContactModel:model];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_isSearch) {
        EmailContactModel *model = self.searchDataArray[indexPath.row];
        model.isSel = !model.isSel;
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        if ([self.selArray containsObject:model]) {
            [self.selArray removeObject:model];
        } else {
            [self.selArray addObject:model];
        }
        
        if (self.selArray.count > 0) {
            [_nextBtn setTitleColor:MAIN_PURPLE_COLOR forState:UIControlStateNormal];
            _nextBtn.enabled = YES;
        } else {
            [_nextBtn setTitleColor:RGB(148, 150, 161) forState:UIControlStateNormal];
            _nextBtn.enabled = NO;
        }
        return;
    }
    
    NSArray *keys = [[self.dataDic allKeys]  sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    NSArray *models = self.dataDic[keys[indexPath.section]];
    EmailContactModel *model = models[indexPath.row];
    model.isSel = !model.isSel;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    if ([self.selArray containsObject:model]) {
        [self.selArray removeObject:model];
    } else {
        [self.selArray addObject:model];
    }
    
    if (self.selArray.count > 0) {
        [_nextBtn setTitleColor:MAIN_PURPLE_COLOR forState:UIControlStateNormal];
        _nextBtn.enabled = YES;
    } else {
        [_nextBtn setTitleColor:RGB(148, 150, 161) forState:UIControlStateNormal];
        _nextBtn.enabled = NO;
    }
}
    
    
    
    
    
    
    
#pragma mark - 直接添加监听方法
-(void)addTargetMethod{
    [_searchTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
}
- (void) textFieldTextChange:(UITextField *) tf
    {
        if ([tf.text.trim isEmptyString]) {
            _isSearch = NO;
        } else {
            _isSearch = YES;
            [self.searchDataArray removeAllObjects];
            @weakify_self
            [self.emailContacts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                EmailContactModel *model = obj;
                NSString *userName = [model.userName lowercaseString];
                NSString *userAddress = [model.userAddress lowercaseString];
                
                if ([userName containsString:[tf.text.trim lowercaseString]] || [userAddress containsString:[tf.text.trim lowercaseString]]) {
                    [weakSelf.searchDataArray addObject:model];
                }
            }];
        }
        [_mainTabV reloadData];
}
@end
