//
//  CTInputView.h
//  CDChatList
//
//  Created by chdo on 2017/12/12.
//

#import <UIKit/UIKit.h>
#import "CTInputHeaders.h"

@protocol CTInputViewProtocol <NSObject>

-(void)inputViewWillUpdateFrame:(CGRect)newFrame animateDuration:(double)duration animateOption:(NSInteger)opti;
// 输出文字
-(void)inputViewPopSttring:(NSString *)string; //
// 输出命令
-(void)inputViewPopCommand:(NSString *)string; //
// 输出音频
-(void)inputViewPopAudioath:(NSURL *)path; //

@end

/**
 !!!!! 此类的实例请不要命名为inputView
 https://stackoverflow.com/questions/26928849/error-when-try-becomefirstresponder-call-for-uimenucontroller
 */
@interface CTInputView : UIView
@property(nonatomic, weak) id<CTInputViewProtocol>delegate;
-(void)turnButtonOnAtIndex:(NSInteger)idx;
@end
