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
// 输入@
-(void)inputViewPopRemid; //
@end

/**
 !!!!! 此类的实例请不要命名为inputView
 https://stackoverflow.com/questions/26928849/error-when-try-becomefirstresponder-call-for-uimenucontroller
 */
@interface CTInputView : UIView
@property (nonatomic , strong) NSMutableArray *atStrings;
@property(nonatomic, weak) id<CTInputViewProtocol>delegate;
-(void)turnButtonOnAtIndex:(NSInteger)idx;
- (NSString *) getTextViewString;
- (void) setTextViewString:(NSString *) textString;
- (void) setTextUnmarkText;
- (NSAttributedString *) getTextViewAttributeString;
- (void) setTextViewAttributeString:(NSAttributedString *) attributeString;
- (BOOL) isFirstResponder;
- (NSRange) selectedRange;
- (void) setSelectedRange:(NSRange) range;
- (void) setTextViewString:(NSString *) textString delayTime:(CGFloat) delayTime;
@end
