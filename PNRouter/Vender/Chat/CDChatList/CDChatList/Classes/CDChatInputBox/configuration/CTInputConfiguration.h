//
//  CTInputConfiguration.h
//  CDChatList
//
//  Created by chdo on 2017/12/12.
//

#import <Foundation/Foundation.h>
#import "CTInPutMacro.h"
#import <UIKit/UIKit.h>

static CGFloat CTInputViewHeight = 50.0f;

@interface CTInputConfiguration : NSObject


/**
 文本框位置
 */
@property(nonatomic,assign) CGRect inputViewRect;


/**
 语音按钮位置
 */
@property(nonatomic,assign) CGRect voiceButtonRect;


/**
 emoji按钮位置
 */
@property(nonatomic,assign) CGRect emojiButtonRect;

/**
 ‘更多’按钮位置
 */
@property(nonatomic,assign) CGRect moreButtonRect;


/**
 消息默认字号
 */
@property(nonatomic, assign) CGFloat messageTextDefaultFontSize;

@property(nonatomic, strong) UIFont *stringFont;

@property(nonatomic, assign) NSDictionary<NSString *,UIImage *> *extraInfo;

// 默认配置只有输入框
+(CTInputConfiguration*)defaultConfig;

// 添加输入语音功能
-(void)addVoice;

// 添加输入表情功能
-(void)addEmoji;

/**
 添加更多功能

 @param info 标题 对应图片
 */
-(void)addExtra:(NSDictionary<NSString *,UIImage *> *)info;

@end

