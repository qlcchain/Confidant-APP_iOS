//
//  ChatConfiguration.h
//  CDChatList
//
//  Created by chdo on 2017/12/5.
//

#import <Foundation/Foundation.h>
#import "CTData.h"
#import "ChatMacros.h"

@interface ChatConfiguration : NSObject

#pragma mark 环境
/**
 环境  // 0 调试 1 生产
 */
@property (assign, nonatomic) int environment;

/**
 是否一直显示消息时间
 */
@property (assign, nonatomic) BOOL alwaysShowMsgTime;

#pragma mark 所有视图的颜色定义
/**
 cell背景色
 */
@property (nonatomic, strong) UIColor *msgBackGroundColor;
/**
 消息容器背景色
 */
@property (nonatomic, strong) UIColor *msgContentBackGroundColor;
/**
 头像背景色
 */
@property (nonatomic, strong) UIColor *headBackGroundColor;
/**
 文字背景色
 */
@property (nonatomic, strong) UIColor *msgTextContentBackGroundColor_right;

/**
 <#Description#>
 */
@property (nonatomic, strong) UIColor *msgTextContentBackGroundColor_left;


#pragma mark 所有视图的尺寸自定义
/**
 cell中消息中时间视图的高度（如果显示）
 */
@property (nonatomic, assign) CGFloat msgTimeH;

/**
 系统消息最大边长
 */
@property (nonatomic, assign) CGFloat sysInfoMessageMaxWidth;

/**
 头像边长
 */
@property (nonatomic, assign) CGFloat headSideLength;

/**
 文字消息内容在只有一行时的高度 不包括时间label
 */
@property (nonatomic, assign) CGFloat messageContentH;

/**
 系统消息内边距
 */
@property (nonatomic, assign) CGFloat sysInfoPadding;

/**
 昵称高度
 */
@property (nonatomic, assign) CGFloat nickNameHeight;

/**
 昵称颜色
 */
@property (nonatomic, strong) UIColor *nickNameColor;

#pragma mark 所有图片的名称，在 ChatHelperdefaultImageDic中获取图片
/**
 气泡右侧遮罩图片
 */
@property (nonatomic, strong) NSString *bg_mask_right;

/**
 气泡遮罩图片
 */
@property (nonatomic, strong) NSString *bg_mask_left;
@property (nonatomic, strong) NSString *left_box;
@property (nonatomic, strong) NSString *right_box;

/**
 语音相关图片
 */
@property (nonatomic, strong) NSString *voice_right_1;
@property (nonatomic, strong) NSString *voice_right_2;
@property (nonatomic, strong) NSString *voice_right_3;
@property (nonatomic, strong) NSString *voice_left_1;
@property (nonatomic, strong) NSString *voice_left_2;
@property (nonatomic, strong) NSString *voice_left_3;

/**
 头像，不区分左右 占位图
 */
@property (nonatomic, strong) NSString *icon_head;

/**
 图片消息占位图，不分左右
 */
@property (nonatomic, strong) NSString *msgImagePlaceHolder;

#pragma mark 气泡的的边距尺寸
/**
 气泡圆角半径
 */
@property (nonatomic, assign) CGFloat bubbleRoundAnglehorizInset;
/**
 气泡尖角宽度
 */
@property (nonatomic, assign) CGFloat bubbleShareAngleWidth;
/**
 头像外边距
 */
@property (nonatomic, assign) CGFloat messageMargin;
// 消息上边距
@property (nonatomic, assign) CGFloat messageMarginTop;
// 头像边距
@property (nonatomic, assign) CGFloat headMargin;
/**
 气泡最大边长   从尖角到另一边
 */
@property (nonatomic, assign) CGFloat bubbleMaxWidth;
/**
 尖角外部到文字边缘的水平距离
 */
@property (nonatomic, assign) CGFloat bubbleSharpAnglehorizInset;
/**
 气泡顶部到尖角底部的距离
 */
@property (nonatomic, assign) CGFloat bubbleSharpAngleHeighInset;


#pragma mark 字体相关设置

/**
 消息默认字号
 */
@property(nonatomic, assign) CGFloat messageTextDefaultFontSize;
/**
 默认文字消息字体
 */
@property(nonatomic, strong) UIFont *messageTextDefaultFont;
/**
 系统消息字体
 */
@property(nonatomic, strong) UIFont *sysInfoMessageFont;

#pragma mark CDLabel 相关设置

@property (nonatomic, assign) CTDataConfig ctDataconfig;


/**
 组件环境  0 调试 1 生产
 */
-(BOOL)isDebug;

@end
