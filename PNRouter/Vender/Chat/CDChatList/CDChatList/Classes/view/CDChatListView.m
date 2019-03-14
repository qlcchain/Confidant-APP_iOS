    //
//  CDChatList.m
//  CDChatList
//
//  Created by chdo on 2017/10/25.
//

#import "CDChatListView.h"
#import "CDTextTableViewCell.h"
#import "CDImageTableViewCell.h"
#import "CDSystemTableViewCell.h"
#import "CDAudioTableViewCell.h"
#import "CellCaculator.h"
#import "UITool.h"
#import "CTClickInfo.h"
#import "ChatHelpr.h"
#import "CDTextTableViewCell.h"
#import "CDChatListProtocols.h"
#import "CDFileTableViewCell.h"
#import "ChatListInfo.h"
#import <MJRefresh/MJRefresh.h>
#import <MJRefresh/MJRefreshStateHeader.h>
#import <MJRefresh/MJRefreshHeader.h>
#import "MediaTableViewCell.h"

//typedef enum : NSUInteger {
//    CDHeaderLoadStateInitializting, // 界面初始化中
//    CDHeaderLoadStateNoraml,        // 等待下拉加载
//    CDHeaderLoadStateLoading,       // 加载中
//    CDHeaderLoadStateFinished,      // 加载结束
//} CDHeaderLoadState;

#define LoadingH  50

@interface CDChatListView()<UITableViewDelegate, UITableViewDataSource>
{
    CGFloat originInset; // 导航栏遮住的高度，作为tableview的顶部内边距
//    CGFloat pullToLoadMark; // 下拉距离超过这个，则开始计入加载方法
}
//@property(assign, nonatomic) CDHeaderLoadState loadHeaderState;
//@property(weak,   nonatomic) UIActivityIndicatorView *indicatro;
@property(strong, nonatomic) CellCaculator *caculator;
@end

@implementation CDChatListView

#pragma mark 生命周期
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    self.delegate = self;
    self.dataSource = self;
    self.estimatedRowHeight = 0;
    self.estimatedSectionHeaderHeight = 0;
    self.estimatedSectionFooterHeight = 0;
    
    self.caculator = [[CellCaculator alloc] init];
    
    self.backgroundColor =  isChatListDebug ? CDHexColor(0xB5E7E1) : ChatHelpr.share.config.msgBackGroundColor;
    if (!isChatListDebug) {
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    self.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshHeaderAction)];
    // Hide the time
    ((MJRefreshStateHeader *)self.mj_header).lastUpdatedTimeLabel.hidden = YES;
    // Hide the status
    ((MJRefreshStateHeader *)self.mj_header).stateLabel.hidden = YES;
    
//    self.loadHeaderState = CDHeaderLoadStateInitializting;
    
    // 注册cell类
    [self registerClass:[CDTextTableViewCell class] forCellReuseIdentifier:@"textcell"];
    [self registerClass:[CDImageTableViewCell class] forCellReuseIdentifier:@"imagecell"];
    [self registerClass:[CDSystemTableViewCell class] forCellReuseIdentifier:@"syscell"];
    [self registerClass:[CDAudioTableViewCell class] forCellReuseIdentifier:@"audiocell"];
    [self registerClass:[CDFileTableViewCell class] forCellReuseIdentifier:@"filecell"];
    [self registerClass:[MediaTableViewCell class] forCellReuseIdentifier:@"mediacell"];
    
//    // 下拉loading视图
//    CGRect rect = CGRectMake(0, -LoadingH, cd_ScreenW(), LoadingH);
//    UIActivityIndicatorView *indicatr = [[UIActivityIndicatorView alloc] initWithFrame:rect];
//    indicatr.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
//    [self addSubview:indicatr];
//    [indicatr startAnimating];
//    self.indicatro = indicatr;
//    self.indicatro.hidesWhenStopped = YES;
    
    self.caculator = [[CellCaculator alloc] init];
    self.caculator.list = self;
    
    return self;
}

- (void)refreshHeaderAction {
    // 当前最旧消息传给代理，调用获取上一段旧消息的方法
    CDChatMessage lastMsg = self->_msgArr.firstObject;
    if (![self.msgDelegate respondsToSelector:@selector(chatlistLoadMoreMsg: callback:)]) {
        //           self.loadHeaderState = CDHeaderLoadStateNoraml;
        return;
    }
    
    [self.msgDelegate chatlistLoadMoreMsg:lastMsg callback:^(CDChatMessageArray newMessages, BOOL hasMore) {
        
        if (!self->_msgArr) {
            self->_msgArr = [NSMutableArray array];
        }
        
        if (!newMessages || newMessages.count == 0) {
            //               self.loadHeaderState = CDHeaderLoadStateFinished;
            return;
        }
        
        // 将旧消息加入当前消息数据中
        NSMutableArray *arr = [NSMutableArray arrayWithArray:newMessages];
        [arr addObjectsFromArray:self->_msgArr];
        // 计算消息高度
        [self.caculator caculatorAllCellHeight:arr callBackOnMainThread:^(CGFloat totalHeight)
         {
             // 全部消息重新赋值
             self->_msgArr = arr;
             
             // 记录刷新table前的contentoffset.y
             CGFloat oldOffsetY = self.contentOffset.y;
             
             //刷新table
             [self reloadData];
             
             // 新消息的总高度
             CGFloat newMessageTotalHeight = 0.0f;
             for (int i = 0; i < newMessages.count; i++) {
                 newMessageTotalHeight = newMessageTotalHeight + self->_msgArr[i].cellHeight;
             }
             
             // 重新回到当前看的消息位置(把loading过程中，table的offset计算在中)
             CGFloat newOffset = newMessageTotalHeight + oldOffsetY;
//             [self setContentOffset:CGPointMake(0, newOffset)];
             
             // 判断是否要结束下拉加载功能
             // 当新消息的数量小于10条时，则认为没有旧消息了
             if (newMessages.count < 10) {
//                 self.loadHeaderState = CDHeaderLoadStateFinished;
             } else {
//                 self.loadHeaderState = CDHeaderLoadStateNoraml;
             }
         }];
    }];
}

- (void)startRefresh {
    [self.mj_header beginRefreshing];
}

- (void)stopRefresh {
    [self.mj_header endRefreshing];
}

// 防止用户将scrollsToTop改为YES
-(void)setScrollsToTop:(BOOL)scrollsToTop{
    
}

//static UIWindow *topWindow_;

//-(void)didMoveToSuperview{
//    UIViewController *viewController =  self.cd_viewController;
//    if (self.cd_viewController) {
//        viewController.automaticallyAdjustsScrollViewInsets = NO;
//        //适配
//        if (@available(iOS 11, *)) {
//            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        }
//        pullToLoadMark = -LoadingH;
//        if (viewController.navigationController) {
//            originInset = cd_NaviH() - self.frame.origin.y;
//            self.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
//        } else {
//            originInset = 0;
//        }
//    }
//    if (!self.superview) {
//        return;
//    }
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        topWindow_ = [[UIWindow alloc] init];
//        topWindow_.windowLevel = UIWindowLevelAlert;
//        topWindow_.frame = [UIApplication sharedApplication].statusBarFrame;
//        topWindow_.backgroundColor = [UIColor clearColor];
//        topWindow_.hidden = NO;
//        [topWindow_ addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                 action:@selector(topWindowClick)]];
//    });
//}

//-(void)topWindowClick
//{
//    [self scrollRectToVisible:CGRectMake(0, originInset, 1, 1) animated:YES];
//}

-(void)setMsgDelegate:(id<ChatListProtocol>)msgDelegate{
    _msgDelegate = msgDelegate;
    if ([msgDelegate respondsToSelector:@selector(chatlistCustomeCellsAndClasses)]) {
        NSDictionary *idAndClsDic = [msgDelegate chatlistCustomeCellsAndClasses];
        for (NSString *reuseIdenty in idAndClsDic.allKeys) {
            [self registerClass:idAndClsDic[reuseIdenty] forCellReuseIdentifier:reuseIdenty];
        }
    }
}

#pragma mark 数据源变动

/**
 监听数据源改变
 
 @param msgArr 数据源
 */
-(void)setMsgArr:(CDChatMessageArray)msgArr{
    @weakify_self
    [self configTableData:msgArr completeBlock:^(CGFloat totalHeight){
//        CGFloat newTopInset = LoadingH + self->originInset;
//        CGFloat left = self.contentInset.left;
//        CGFloat right = self.contentInset.right;
//        CGFloat bottom = self.contentInset.bottom;
//        [self setContentInset:UIEdgeInsetsMake(newTopInset, left, right, bottom)];
        [weakSelf relayoutTable:NO];
//        if (totalHeight < self.frame.size.height - newTopInset - bottom) {
//            [self setContentOffset:CGPointZero];
//        }
//        self.loadHeaderState = CDHeaderLoadStateNoraml;
    }];
}


/**
 更新数据源中的某条消息
 
 @param message 消息
 */
-(void)updateMessage:(CDChatMessage)message{
    
    // 找到消息下标
    NSInteger msgIndex = -1;
    for (int i = 0; i < _msgArr.count; i++) {
        if ([message.messageId isEqualToString:_msgArr[i].messageId]) {
            msgIndex = i;
            break;
        }
    }
    if (msgIndex < 0) return;
    if (!_msgArr) return;
    
    // 更新数据源
    NSMutableArray *mutableMsgArr = [NSMutableArray arrayWithArray:_msgArr];
    [mutableMsgArr replaceObjectAtIndex:msgIndex withObject:message];
    _msgArr = [mutableMsgArr copy];
    
    // 若待更新的cell在屏幕上方，则可能造成屏幕抖动，需要手动调回contentoffset
    NSIndexPath *index = [NSIndexPath indexPathForRow:msgIndex inSection:0];
    CGRect rect_old = [self rectForRowAtIndexPath:index]; // cell所在位置
    CGFloat cellOffset = rect_old.origin.y + rect_old.size.height;
    CGPoint contentOffset = self.contentOffset;
    BOOL needAdjust = cellOffset < contentOffset.y;
    
    //[self reloadData];
    [self reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:msgIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
    if (needAdjust) {
        CGRect rect_new = [self rectForRowAtIndexPath:index]; // cell新的位置
        CGFloat adjust = rect_old.size.height - rect_new.size.height;
        [self setContentOffset:CGPointMake(0, self.contentOffset.y - adjust)];
    }
}

/**
 添加新的数据到底部
 */
-(void)addMessagesToBottom: (CDChatMessageArray)newBottomMsgArr{
    
    if (!_msgArr) {
        _msgArr = [NSMutableArray array];
    }
    
    NSMutableArray *arr = [NSMutableArray arrayWithArray:_msgArr];
    [arr addObjectsFromArray:newBottomMsgArr];
    _msgArr = arr;
    
    [self configTableData:arr completeBlock:^(CGFloat totalHeight){
        [self relayoutTable:NO];
    }];
    
}

/**
 所有table数据源修改，最终都会走这里
 更新tableData数据，计算所有cell高度，并reloadData

 @param msgArr 新的消息数组
 @param callBack 完成回调
 */
-(void)configTableData: (CDChatMessageArray)msgArr
         completeBlock: (void(^)(CGFloat))callBack{
    
    [self mainAsyQueue:^{
        
        if (msgArr.count == 0) {
            self->_msgArr = msgArr;
            //[self reloadData];
            callBack(0);
        } else {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{                
                [self.caculator caculatorAllCellHeight:msgArr callBackOnMainThread:^(CGFloat totalHeight) {
                    self->_msgArr = msgArr;
                   /// [self reloadData];
                    callBack(totalHeight);
                }];
            });
        }
    }];
}

//-(void)setLoadHeaderState:(CDHeaderLoadState)loadHeaderState{
//
//    if (loadHeaderState == CDHeaderLoadStateFinished) {
//        UIEdgeInsets inset = UIEdgeInsetsMake(originInset, 0, 0, 0);
//
//        [self.indicatro stopAnimating];
//
//        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseIn animations:^{
//            [self setContentInset:inset];
//        } completion:^(BOOL finished) {
//
//        }];
//    }else {
//        [self.indicatro startAnimating];
//    }
//    _loadHeaderState = loadHeaderState;
//}

#pragma mark UI变动

/**
 table滚动到底部

 @param animated 是否有动画
 */
-(void)relayoutTable:(BOOL)animated{
    [self reloadData];
    if (_msgArr.count == 0) {
        return;
    }
    //
    if (self.tracking) {
        return;
    }
    if (self.isDelete) {
        self.isDelete = NO;
        return;
    }
    
    // 异步让tableview滚到最底部
    NSInteger cellCount = [self numberOfRowsInSection:0];
    NSInteger num = cellCount - 1 > 0 ? cellCount - 1 : 0;
    NSIndexPath *index = [NSIndexPath indexPathForRow:num inSection:0];
    
   // [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    [self scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

- (void)justReload {
    [self reloadData];
}

//-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//
//    [[NSNotificationCenter defaultCenter] postNotificationName:CDChatListDidScroll object:nil];
//
//    if (scrollView.tracking) {
//        return;
//    }
//
//    CGFloat offsetY = self.contentOffset.y;
//    if (offsetY >= 0) {
//        return;
//    }
//
//    //  判断在普通状态，则进入加载更多方法
//    if (self.loadHeaderState == CDHeaderLoadStateNoraml) {
//        // 将当前状态设为加载中
//        self.loadHeaderState = CDHeaderLoadStateLoading;
//
//        // 当前最旧消息传给代理，调用获取上一段旧消息的方法
//        CDChatMessage lastMsg = _msgArr.firstObject;
//        if (![self.msgDelegate respondsToSelector:@selector(chatlistLoadMoreMsg: callback:)]) {
//            self.loadHeaderState = CDHeaderLoadStateNoraml;
//            return;
//        }
//
//        [self.msgDelegate chatlistLoadMoreMsg:lastMsg callback:^(CDChatMessageArray newMessages, BOOL hasMore) {
//
//            if (!self->_msgArr) {
//                self->_msgArr = [NSMutableArray array];
//            }
//
//            if (!newMessages || newMessages.count == 0) {
//                self.loadHeaderState = CDHeaderLoadStateFinished;
//                return;
//            }
//
//            // 将旧消息加入当前消息数据中
//            NSMutableArray *arr = [NSMutableArray arrayWithArray:newMessages];
//            [arr addObjectsFromArray:self->_msgArr];
//            // 计算消息高度
//            [self.caculator caculatorAllCellHeight:arr callBackOnMainThread:^(CGFloat totalHeight)
//            {
//                // 全部消息重新赋值
//                self->_msgArr = arr;
//
//                // 记录刷新table前的contentoffset.y
//                CGFloat oldOffsetY = self.contentOffset.y;
//
//                //刷新table
//                [self reloadData];
//
//                // 新消息的总高度
//                CGFloat newMessageTotalHeight = 0.0f;
//                for (int i = 0; i < newMessages.count; i++) {
//                    newMessageTotalHeight = newMessageTotalHeight + self->_msgArr[i].cellHeight;
//                }
//
//                // 重新回到当前看的消息位置(把loading过程中，table的offset计算在中)
//                CGFloat newOffset = newMessageTotalHeight + oldOffsetY;
//                [self setContentOffset:CGPointMake(0, newOffset)];
//
//                // 判断是否要结束下拉加载功能
//                // 当新消息的数量小于10条时，则认为没有旧消息了
//                if (newMessages.count < 10) {
//                    self.loadHeaderState = CDHeaderLoadStateFinished;
//                } else {
//                    self.loadHeaderState = CDHeaderLoadStateNoraml;
//                }
//            }];
//        }];
//    }
//}


-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    BOOL res = [super pointInside:point withEvent:event];
    if (res && [self.msgDelegate respondsToSelector:@selector(chatlistBecomeFirstResponder)]) {
        [self.msgDelegate chatlistBecomeFirstResponder];
    }
    
//    if (self.loadHeaderState == CDHeaderLoadStateInitializting) {
//        self.loadHeaderState = CDHeaderLoadStateNoraml;
//    }
    return res;
}


#pragma mark table 代理
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CDChatMessage data = _msgArr[indexPath.row];
    data.showSelectMsg = 0; // 配置是否显示选择消息
    NSString *cellType = @"textcell";
    switch (data.msgType) {
        case CDMessageTypeImage:
            cellType = @"imagecell";
            break;
        case CDMessageTypeSystemInfo:
            cellType = @"syscell";
            break;
        case CDMessageTypeAudio:
            cellType = @"audiocell";
            break;
        case CDMessageTypeMedia:
            cellType = @"mediacell";
            break;
        case CDMessageTypeFile:
            cellType = @"filecell";
            break;

        case CDMessageTypeCustome:
        {
            cellType = data.reuseIdentifierForCustomeCell;
            break;
        }
        default:
            cellType = @"textcell";
            break;
    }
    
    UITableViewCell<MessageCellProtocal> *cell = [tableView dequeueReusableCellWithIdentifier: cellType];
    [cell configCellByData:data table:self];
//    cell.backgroundColor = [UIColor RandomColor];
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _msgArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat height = [self.caculator fetchCellHeight:indexPath.row of:_msgArr];
    return height;
}


-(void)mainAsyQueue:(dispatch_block_t)block{
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
