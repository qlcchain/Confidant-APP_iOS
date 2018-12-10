//
//  CDChatList.h
//  CDChatList
//
//  Created by chdo on 2017/10/25.
//

#import <UIKit/UIKit.h>
#import "CDChatListProtocols.h"

/**
 聊天视图
 */
@interface CDChatListView : UITableView

/**
 列表代理
 */
@property(weak, nonatomic) id<ChatListProtocol> msgDelegate;

@property (nonatomic , assign) BOOL isDelete;
/**
 消息数组
 */
@property(nonatomic, copy) CDChatMessageArray msgArr;

/**
 是否可以点击顶部返回列表顶部
 */
//@property(nonatomic, assign) BOOL tapStatusBarToTop;

/**
 添加新的数据到底部

 @param newBottomMsgArr 新的消息数组
 */
-(void)addMessagesToBottom: (CDChatMessageArray)newBottomMsgArr;

/**
 更新数据源中的某条消息

 @param message 消息
 */
-(void)updateMessage:(CDChatMessage)message;


/**
 将table滚动到底部

 @param animated 是否动画
 */
-(void)relayoutTable:(BOOL)animated;

- (void)startRefresh;
- (void)stopRefresh;

@end
