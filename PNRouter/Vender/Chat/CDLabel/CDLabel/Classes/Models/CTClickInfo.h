//
//  ChatListInfo.h
//  CDLabel
//
//  Created by chdo on 2017/11/23.
//

#import <Foundation/Foundation.h>
#import "CDLabel.h"
#import "CDLabelMacro.h"


typedef enum : NSUInteger {
    CTClickEventTypeTEXT, // 文本点击
    CTClickEventTypeIMAGE, // 图片点击
} CTClickEventType;

/**
 点击事件
 */
@interface CTClickInfo: NSObject

@property (nonatomic, strong) id msgModel;
/**
 事件类型
 */
@property (nonatomic, assign) CTClickEventType eventType;

/**
 全部消息字符
 */
@property (nonatomic, copy, nonnull) NSString *msgText;

/**
 文字视图容器
 */
@property (nonatomic, strong, nullable) UIView *containerView;


/*-------文本类型-------*/
/**
 被点击文本
 */
@property (nonatomic, copy, nullable) NSString *clickedText;

/**
 点击文字range
 */
@property (nonatomic, assign) NSRange range;

/**
 被点击文本的隐藏信息
 */
@property (nonatomic, copy, nullable) NSString *clickedTextContent;


/*-------图片-------*/
/**
 图片
 */
@property (nonatomic, strong, nullable) UIImage *image;

/**
 图片在容器中的位置
 */
@property (nonatomic, assign) CGRect imageRect;

+(CTClickInfo *_Nullable)info:(CTClickEventType)type
                      msgText:(NSString *_Nullable)msgText
                containerView:(UIView *_Nullable)view
                  clickedText:(NSString *_Nullable)clickedTitle
                     textRang:(NSRange)rang
           clickedTextContent:(NSString *_Nullable)clickedTextContent
                        image:(UIImage *_Nullable)image
                    imageRect:(CGRect) rect;


@end

