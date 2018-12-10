//
//  ChatListInfo.m
//  CDLabel
//
//  Created by chdo on 2017/11/23.
//

#import "CTClickInfo.h"


@implementation CTClickInfo

+(CTClickInfo *)info:(CTClickEventType)type
             msgText:(NSString *)msgText
       containerView:(UIView *)view
         clickedText:(NSString *)clickedTitle
            textRang:(NSRange)rang
  clickedTextContent:(NSString *)clickedTextContent
               image:(UIImage *)image
           imageRect:(CGRect)rect{
    CTClickInfo *info = [[CTClickInfo alloc] init];
    info.eventType = type;
    info.msgText = msgText;
    info.containerView = view;
    info.clickedText = clickedTitle;
    info.range = rang;
    info.clickedTextContent = clickedTextContent;
    info.image = image;
    info.imageRect = rect;
    return info;
}

@end

