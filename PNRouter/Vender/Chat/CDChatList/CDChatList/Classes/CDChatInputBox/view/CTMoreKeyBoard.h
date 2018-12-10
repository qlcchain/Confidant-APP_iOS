//
//  CTMoreKeyBoard.h
//  CDChatList
//
//  Created by chdo on 2017/12/15.
//

#import <UIKit/UIKit.h>
@protocol CTMoreKeyBoardDelegare
-(void)moreKeyBoardSelectKey:(NSString *)key image:(UIImage *)img;
@end
// 更多键盘
@interface CTMoreKeyBoard : UIView
@property(nonatomic, weak)id<CTMoreKeyBoardDelegare> moreKeyDelegate;
+(CTMoreKeyBoard *)keyBoard;
@end
