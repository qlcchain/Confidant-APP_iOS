//
//  ChatListInfo.m
//  CDChatList
//
//  Created by chdo on 2017/11/23.
//

#import "ChatListInfo.h"
#import "ChatMacros.h"

@implementation ChatListInfo


+(ChatListInfo *)info:(ChatClickEventType)type msgText:(NSString *)msgText containerView:(UIView *)view clickedText:(NSString *)clickedTitle textRang:(NSRange)rang clickedTextContent:(NSString *)clickedTextContent image:(UIImage *)image imageRect:(CGRect)rect{
    ChatListInfo *info = [[ChatListInfo alloc] init];
    info.eventType = type;
    info.msgText = msgText;
    info.containerView = view;
    info.clickedText = clickedTitle;
    info.range = rang;
    info.clickedTextContent = clickedTextContent;
    return info;
}

+(ChatListInfo *)eventFromChatListInfo:(CTClickInfo *)info{
    ChatClickEventType type = ChatClickEventTypeTEXT;
    if (info.eventType == CTClickEventTypeIMAGE){
        return nil;
    }
    ChatListInfo *newInfo = [ChatListInfo info:type msgText:info.msgText containerView:info.containerView clickedText:info.clickedText textRang:info.range clickedTextContent:info.clickedTextContent image:info.image imageRect:info.imageRect];
    return newInfo;
}

@end
