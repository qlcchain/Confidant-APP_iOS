//
//  CDBaseMsgCell.h
//  CDChatList
//
//  Created by chdo on 2017/11/2.
//

#import <UIKit/UIKit.h>


#import "CDChatListView.h"


@interface CDBaseMsgCell : UITableViewCell<MessageCellProtocal>

@property(nonatomic,strong) UILabel *timeLabel; //消息时间视图
@property(nonatomic,strong) CDChatMessage msgModal;
@property(nonatomic,weak) CDChatListView *tableView;

// 左侧 消息内容视图
@property(nonatomic,strong) UIView *msgContent_left;                 // 消息载体视图 包括下面三个
@property(nonatomic,strong) UILabel *userName_left;             // 用户名视图
@property(nonatomic,strong) UIImageView *bubbleImage_left;           // 气泡视图
@property(nonatomic,strong) UIImageView *headImage_left;             // 头像视图
@property(nonatomic,strong) UIActivityIndicatorView *indicator_left; // loading视图
@property(nonatomic,strong) UILabel *failLabel_left;             // 消息失败转台视图
@property (nonatomic, strong) UIButton *chooseMsgBtn_left;    // 选择消息

// 右侧 消息内容视图
@property(nonatomic,strong) UIView *msgContent_right;                 // 消息载体视图 包括下面三个
@property(nonatomic,strong) UILabel *userName_right;             // 用户名视图
@property(nonatomic,strong) UIImageView *bubbleImage_right;           // 气泡视图
@property(nonatomic,strong) UIImageView *headImage_right;             // 头像视图
@property(nonatomic,strong) UIActivityIndicatorView *indicator_right; // loading视图
@property(nonatomic,strong) UILabel *failLabel_right;             // 消息失败转台视图
@property (nonatomic, strong) UIButton *chooseMsgBtn_right;    // 选择消息
@property (nonatomic ,strong) UIImageView *statuImgView_right; // 已读状态view
-(void)hidMenu;
-(void)showMenuWithItemX:(CGFloat) itemx;

- (void) selectWithdrawItem:(UIMenuController *) item;
- (void) selectForwardItem:(UIMenuController *) item;
@end
