//
//  ChatListInfo.h
//  CDChatList
//
//  Created by chdo on 2017/11/23.
//

#import <Foundation/Foundation.h>
#import "CDChatList.h"
#import "CTClickInfo.h"
#import "CDChatListProtocols.h"

typedef enum : NSUInteger {
    ChatClickEventTypeTEXT,
    ChatClickEventTypeIMAGE,
} ChatClickEventType;

/**
 点击事件
 */
@interface ChatListInfo: NSObject

@property (nonatomic) CDChatMessage msgModel;
/**
 事件类型
 */
@property (nonatomic, assign) ChatClickEventType eventType;

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
 链接文本
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


+(ChatListInfo *_Nullable)info:(ChatClickEventType)type
                       msgText:(NSString *_Nullable)msgText
                 containerView:(UIView *_Nullable)view

                   clickedText:(NSString *_Nullable)clickedTitle
                      textRang:(NSRange)rang
            clickedTextContent:(NSString *_Nullable)clickedTextContent

                         image:(UIImage *_Nullable)image
                     imageRect:(CGRect) rect;

+(ChatListInfo *_Nullable)eventFromChatListInfo:(CTClickInfo *_Nullable)info;

@end
