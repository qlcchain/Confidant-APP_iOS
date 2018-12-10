//
//  CTEmojiKeyboard.h
//  CDChatList
//
//  Created by chdo on 2017/12/15.
//

#import <UIKit/UIKit.h>

@protocol CTEmojiKeyboardDelegare
-(void)emojiKeyboardSelectKey:(NSString *)key image:(UIImage *)img;
-(void)emojiKeyboardSelectDelete;
-(void)emojiKeyboardSelectSend;
@end

// 表情键盘
@interface CTEmojiKeyboard : UIView
+(CTEmojiKeyboard *)keyBoard;

@property(nonatomic, weak)id<CTEmojiKeyboardDelegare> emojiDelegate;
-(void)updateKeyBoard;
@end
