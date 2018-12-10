//
//  CTInputConfiguration.m
//  CDChatList
//
//  Created by chdo on 2017/12/12.
//

#import "CTInputConfiguration.h"
#import "CTInPutMacro.h"
@interface CTInputConfiguration()
{
    BOOL hasVoice;
    BOOL hasEmoji;
    BOOL hasMore;
    CGFloat inset; // 内边距
    CGSize buttongSize; // 按钮大小
    CGFloat CTInputViewWidth;
    NSDictionary<NSString *,UIImage *> *moreInfo;
}
@end

@implementation CTInputConfiguration


+(instancetype)share{
    
    static dispatch_once_t onceToken;
    static CTInputConfiguration *helper;
    dispatch_once(&onceToken, ^{
        helper = [[CTInputConfiguration alloc] init];
    });
    return helper;
}

-(instancetype)init{
    self = [super init];
    inset = 7.0f;
    hasVoice = NO;
    hasEmoji = NO;;
    hasMore = NO;;
    buttongSize = CGSizeMake(30, 30);
    CTInputViewWidth = ScreenWidth;
    self.messageTextDefaultFontSize = 16;
    return self;
}

-(UIFont *)stringFont{
    UIFont *font = [UIFont systemFontOfSize:self.messageTextDefaultFontSize];
    return font;
}

// 输入框配置
+(CTInputConfiguration*)defaultConfig{
    return [CTInputConfiguration share];
}


/**
 语音按钮位置
 */
-(CGRect)voiceButtonRect{
    CGFloat top = inset;
    CGFloat left = inset;
    CGFloat bottom = inset;
    return CGRectMake(left, top, hasVoice ? buttongSize.width : 0, CTInputViewHeight - top - bottom);
}

/**
 获得输入框位置
 */
-(CGRect)inputViewRect{
    
    CGFloat top = inset;
    CGFloat left = hasVoice ? inset * 2 + buttongSize.width : inset;
    CGFloat bottom = inset;
    CGFloat right = inset + (hasEmoji ? buttongSize.width + inset : 0) + + (hasMore ? buttongSize.width + inset : 0);
    
    return CGRectMake(left, top, CTInputViewWidth - left - right, CTInputViewHeight - top - bottom);
}


/**
 表情按钮位置
 依赖输入框rect
 */
-(CGRect)emojiButtonRect{
    CGFloat top = inset;
    CGFloat left = self.inputViewRect.origin.x + self.inputViewRect.size.width + inset;
    CGFloat bottom = inset;
    return CGRectMake(left, top, hasEmoji ? buttongSize.width : 0, CTInputViewHeight - top - bottom);
}


/**
 ’更多‘ 按钮位置
  依赖输入框rect
 */
-(CGRect)moreButtonRect{
    CGFloat top = inset;
    CGFloat left = self.inputViewRect.origin.x + self.inputViewRect.size.width + (hasEmoji ? inset * 2 + buttongSize.width: inset);
    CGFloat bottom = inset;
    return CGRectMake(left, top, hasMore ? buttongSize.width : 0, CTInputViewHeight - top - bottom);
}

// 添加输入语音功能
-(void)addVoice{
    hasVoice = YES;
}

// 添加输入表情功能
-(void)addEmoji{
    hasEmoji = YES;
}

// 添加更多功能

/**
 // 添加更多功能

 @param info 命令 及  图片
 */
-(void)addExtra:(NSDictionary<NSString *,UIImage *> *)info{
    
    if (!info) return;
    moreInfo = info;
    hasMore = YES;
}

-(NSDictionary<NSString *,UIImage *> *)extraInfo{
    return moreInfo;
}

@end
