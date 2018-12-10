//
//  ChatImageDrawer.h
//  CDChatList
//
//  Created by chdo on 2017/12/7.
//

#import <UIKit/UIKit.h>

@interface ChatImageDrawer : NSObject
/*
 @"left_box": leftBubble,
 @"right_box": rightBubble,
 @"bg_mask_right":right_mask,
 @"bg_mask_left":left_mask,
 @"icon_head":[[ChatImageDrawer share] icon_head],
 */
+(NSMutableDictionary<NSString *, UIImage *>*)defaultImageDic;


@end
