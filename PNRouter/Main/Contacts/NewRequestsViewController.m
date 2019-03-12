//
//  NewRequestsViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "NewRequestsViewController.h"
#import "SocketMessageUtil.h"
#import "UserModel.h"
#import "AddFriendCellTableViewCell.h"
#import "FriendModel.h"
#import "RSAModel.h"
#import "SystemUtil.h"
#import "FriendRequestViewController.h"
#import "UserHeaderModel.h"
#import <WZLBadge/WZLBadgeImport.h>

//typedef enum : NSUInteger {
//    NewRequestsTypeAddContacts,
//    NewRequestsTypeGroupChats,
//} NewRequestsType;

@interface NewRequestsViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *menuBack;
@property (weak, nonatomic) IBOutlet UIView *sliderV;
@property (weak, nonatomic) IBOutlet UIButton *addContactsBtn;
@property (weak, nonatomic) IBOutlet UIButton *groupChatsBtn;
//@property (nonatomic) NewRequestsType newRequestsType;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollContentWidth;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScroll;
@property (weak, nonatomic) IBOutlet UITableView *addContactsTable;
@property (weak, nonatomic) IBOutlet UITableView *groupChatsTable;
@property (nonatomic ,strong) NSMutableArray *addContactsSource;
@property (nonatomic ,strong) NSMutableArray *groupChatsSource;

@property (nonatomic ,assign)  NSInteger currentRow;
@property (nonatomic ,assign)  NSInteger currentTag;
@property (nonatomic) BOOL scrollIsManual;

@end

@implementation NewRequestsViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(realFriendNoti:) name:DEAL_FRIEND_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestAddFriendNoti:) name:FRIEND_ACCEPED_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userHeadDownloadSuccess:) name:USER_HEAD_DOWN_SUCCESS_NOTI object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addObserve];
    [self viewInit];
    [self dataInit];
}

#pragma mark - Operation
- (void)dataInit {
    [self checkDataOfAddContacts];
}

- (void)viewInit {
    [_addContactsTable registerNib:[UINib nibWithNibName:AddFriendCellReuse bundle:nil] forCellReuseIdentifier:AddFriendCellReuse];
    [_groupChatsTable registerNib:[UINib nibWithNibName:AddFriendCellReuse bundle:nil] forCellReuseIdentifier:AddFriendCellReuse];
    
    _scrollContentWidth.constant = SCREEN_WIDTH*2;
    _sliderV.frame = CGRectMake(0, 42, 96, 2);
    _sliderV.centerX = SCREEN_WIDTH/4;
    
    _addContactsBtn.selected = YES;
    _groupChatsBtn.selected = NO;
}

- (void)menuSelectOperation:(UIButton *)sender {
    if (sender.selected) {
        return;
    }
//    [self showUnreadWithBtn:sender];
    _scrollIsManual = YES;
    _addContactsBtn.selected = _addContactsBtn==sender?YES:NO;
    _groupChatsBtn.selected = _groupChatsBtn==sender?YES:NO;
    CGPoint offset = _addContactsBtn==sender?CGPointMake(0, 0):CGPointMake(SCREEN_WIDTH, 0);
    @weakify_self
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        CGPoint point = [sender convertPoint:CGPointMake(sender.centerX, sender.height) toView:weakSelf.menuBack];
        weakSelf.sliderV.centerX = point.x;
        [weakSelf.mainScroll setContentOffset:offset animated:YES];
    } completion:^(BOOL finished) {
    }];
}

- (void)showUnreadWithBtn:(UIButton *)sender {
    sender.badgeCenterOffset = CGPointMake(-(SCREEN_WIDTH/2.0-90)/2.0, 16);
    sender.badgeBgColor = UIColorFromRGB(0xFB633F);
    [sender showBadgeWithStyle:WBadgeStyleRedDot value:0 animationType:WBadgeAnimTypeNone];
}

- (void)hideUnreadWithBtn:(UIButton *)sender {
    [sender clearBadge];
}

#pragma mark - Request
#pragma mark -查询好友请求数据库
- (void)checkDataOfAddContacts {
    if (self.addContactsSource.count > 0) {
        [self.addContactsSource removeAllObjects];
    }
    NSArray *finfAlls = [FriendModel bg_find:FRIEND_REQUEST_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"owerId"),bg_sqlValue([UserModel getUserModel].userId)]];
    if (finfAlls && finfAlls.count > 0) {
        [self.addContactsSource addObjectsFromArray:finfAlls];
    }
    [_addContactsTable reloadData];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)moreAction:(id)sender {
    
}

- (IBAction)addContactsAction:(id)sender {
    [self menuSelectOperation:_addContactsBtn];
}

- (IBAction)groupChatsAction:(id)sender {
    [self menuSelectOperation:_groupChatsBtn];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == _mainScroll) {
        if (_scrollIsManual == NO) {
            CGPoint offset = scrollView.contentOffset;
            _sliderV.centerX = offset.x/2+SCREEN_WIDTH/4;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == _mainScroll) {
        CGPoint offset = scrollView.contentOffset;
//        NSLog(@"offset = %@",NSStringFromCGPoint(offset));
        if (offset.x >= SCREEN_WIDTH) {
            [self menuSelectOperation:_groupChatsBtn];
        } else {
            [self menuSelectOperation:_addContactsBtn];
        }
        _scrollIsManual = NO;
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (scrollView == _mainScroll) {
        _scrollIsManual = NO;
    }
}

#pragma mark - tableviewDataSourceDelegate
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == _addContactsTable) {
        return self.addContactsSource.count;
    } else if (tableView == _groupChatsTable) {
        return self.groupChatsSource.count;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == _addContactsTable) {
        return AddFriendCellHeight;
    } else if (tableView == _groupChatsTable) {
        return AddFriendCellHeight;
    }
    return 0;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (tableView == _addContactsTable) {
        AddFriendCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AddFriendCellReuse];
        FriendModel *model = self.addContactsSource[indexPath.row];
        cell.tag = indexPath.row;
        [cell setFriendModel:model];
        @weakify_self
        [cell setRightBlcok:^(NSInteger tag, NSInteger row) {
            [weakSelf.view showHudInView:weakSelf.view hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
            [weakSelf sendAgreeFriendWithRow:row];
        }];
        
        return cell;
    } else if (tableView == _groupChatsTable) {
        AddFriendCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AddFriendCellReuse];
        FriendModel *model = self.groupChatsSource[indexPath.row];
        cell.tag = indexPath.row;
        [cell setFriendModel:model];
        @weakify_self
        [cell setRightBlcok:^(NSInteger tag, NSInteger row) {
            [weakSelf.view showHudInView:weakSelf.view hint:@"" userInteractionEnabled:NO hideTime:REQEUST_TIME];
            [weakSelf sendAgreeFriendWithRow:row];
        }];
        
        return cell;
    }
    
    return [UITableViewCell new];
}

- (void) sendAgreeFriendWithRow:(NSInteger) row {
    self.currentRow = row;
    FriendModel *models = self.addContactsSource[row];
    [SocketMessageUtil sendAgreedOrRefusedWithFriendMode:models withType:[NSString stringWithFormat:@"%d",0]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (tableView == _addContactsTable) {
        
    } else if (tableView == _groupChatsTable) {
        
    }
}

#pragma mark - NOTI
- (void) realFriendNoti:(NSNotification *) noti {
    [self.view hideHud];
    NSString *statu = (NSString *)noti.object;
    FriendModel *friendModel = (FriendModel *)self.addContactsSource[self.currentRow];
    if ([statu isEqualToString:@"0"]) { // 服务器处理失败
        [AppD.window showHint:@"处理失败"];
    } else {
        friendModel.dealStaus = 1;
        [_addContactsTable reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.currentRow inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        if (_currentTag == 1) { // 同意
            [[NSNotificationCenter defaultCenter] postNotificationName:FRIEND_LIST_CHANGE_NOTI object:nil];
        } else { // 拒绝
            
        }
        [friendModel bg_saveOrUpdateAsync:nil];
    }
}

- (void) requestAddFriendNoti:(NSNotification *) noti {
    NSString *userId = noti.object;
    [self.addContactsSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *moodel = obj;
        if ([moodel.userId isEqualToString:userId]) {
            moodel.dealStaus = 1;
            *stop = YES;
        }
    }];
    [_addContactsTable reloadData];
}

- (void)userHeadDownloadSuccess:(NSNotification *)noti {
//    UserHeaderModel *model = noti.object;
    [_addContactsTable reloadData];
}

#pragma -mark layz
- (NSMutableArray *)addContactsSource {
    if (!_addContactsSource) {
        _addContactsSource = [NSMutableArray array];
    }
    return _addContactsSource;
}

- (NSMutableArray *)groupChatsSource {
    if (!_groupChatsSource) {
        _groupChatsSource = [NSMutableArray array];
    }
    return _groupChatsSource;
}

@end
