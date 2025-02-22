//
//  CTInputView.m
//  CDChatList
//
//  Created by chdo on 2017/12/12.
//

#import "CTInputView.h"
#import "CTTextView.h"
#import "CTEmojiKeyboard.h"
#import "AATVoiceHudAlert.h"
#import "CTInputConfiguration.h"
#import "AATAudioTool.h"
#import "SystemUtil.h"
#import "AtUserModel.h"
#import "NSString+RegexCategory.h"
#import "NSString+HexStr.h"
#import "NSString+Trim.h"

static CGFloat reactH = 35;

@interface EmojiTextAttachment : NSTextAttachment
@property(strong, nonatomic) NSString *emojiTag;
+ (NSString *)getPlainString:(NSAttributedString *)attributString;
@end

@implementation EmojiTextAttachment


+ (NSString *)getPlainString:(NSAttributedString *)attributString {
    
    NSMutableString *plainString = [NSMutableString stringWithString:attributString.string];
    __block NSUInteger base = 0;
    
    [attributString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, attributString.length)
                               options:0
                            usingBlock:^(id value, NSRange range, BOOL *stop) {
                                if (value && [value isKindOfClass:[EmojiTextAttachment class]]) {
                                    [plainString replaceCharactersInRange:NSMakeRange(range.location + base, range.length)
                                                               withString:((EmojiTextAttachment *) value).emojiTag];
                                    base += ((EmojiTextAttachment *) value).emojiTag.length - 1;
                                }
                            }];
    return plainString;
}
@end


@interface CTInputView()<CTEmojiKeyboardDelegare,CTMoreKeyBoardDelegare,UITextViewDelegate,AATAudioToolProtocol>
{
    CGRect originRect;   // 根据键盘是否弹起，整个值有可能是底部的是在底部的rect  也可能是上面的rect
    
    CGFloat tempTextViewHeight; // 在多行文字切换到语音功能时，需要临时保存textview的高度
    
    CTEmojiKeyboard *emojiKeyboard;
    CTMoreKeyBoard *moreKeyboard;
}
@property (nonatomic, strong) CTTextView *textView;
@property (nonatomic, strong) UIView *textBackView;
@property (nonatomic, strong) UIButton *voiceBut;
@property BOOL isRecordTouchingOutSide; // 手指是否在输入栏内部
@property (nonatomic, strong) UIButton *recordBut;
@property (nonatomic, strong) UIButton *emojiBut;
@property (nonatomic, strong) UIButton *moreBut;
@property (nonatomic, strong) UIButton *reactBut;
@property (nonatomic, strong) NSArray *buttons;

// 容器视图  包含除输入框外的所有视图
@property (nonatomic, strong) UIView *containerView;


@end

@implementation CTInputView
static UIColor *InputHexColor(int hexColor){
    UIColor *color = [UIColor colorWithRed:((float)((hexColor & 0xFF0000) >> 16))/255.0 green:((float)((hexColor & 0xFF00) >> 8))/255.0 blue:((float)(hexColor & 0xFF))/255.0 alpha:1];
    return color;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    self.backgroundColor = InputHexColor(0xF5F5F7);
    originRect = frame;
    
    // 三个按钮容器
    self.containerView = [[UIView alloc] initWithFrame:self.bounds];
    self.containerView.backgroundColor = self.backgroundColor;
    [self addSubview:self.containerView];
    
    // 图片资源
    
    UIImage *emojIcon = CTinputHelper.share.imageDic[@"emojIcon"];
    UIImage *moreIcon = CTinputHelper.share.imageDic[@"addIcon"];
    UIImage *keyboardIcon = CTinputHelper.share.imageDic[@"keyboard"];
    UIImage *voice = CTinputHelper.share.imageDic[@"voice"];
    
    // 配置
    CTInputConfiguration *config = CTinputHelper.share.config;
    
    
    // 语音按钮
    UIButton *v1 = [[UIButton alloc] initWithFrame:config.voiceButtonRect];
    [v1 setImage:voice forState:UIControlStateNormal];
    [v1 setImage:keyboardIcon forState:UIControlStateSelected];
    v1.tag = 0;
    [v1 addTarget:self action:@selector(tagbut:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:v1];
    self.voiceBut = v1;
    
    
    
    // 输入框
   
    
//    textView.contentOffset = CGPointMake(0, -2);
//    textView.contentSize = CGSizeMake(textView.contentSize.width,textView.contentSize.height - 4);

    _textBackView = [[UIView alloc] initWithFrame:config.inputViewRect];
    _textBackView.backgroundColor = [UIColor whiteColor];
    _textBackView.layer.cornerRadius = 3.0f;
    _textBackView.layer.masksToBounds = YES;
    _textBackView.clipsToBounds = YES;
    _textBackView.layer.borderWidth = 0.5f;
    _textBackView.layer.borderColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0].CGColor;
    
    // 回复but内容
    _reactBut = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, _textBackView.frame.size.width-10, 0)];
    _reactBut.backgroundColor = RGB(245, 245, 245);
    _reactBut.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _reactBut.contentEdgeInsets = UIEdgeInsetsMake(0,3, 0, 3);
    _reactBut.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [_reactBut setTitleColor:RGB(128, 128, 128) forState:UIControlStateNormal];
    _reactBut.titleLabel.font = config.stringFont;
    _reactBut.layer.cornerRadius = 3.0f;
    
    
    CTTextView *textView = [[CTTextView alloc] initWithFrame:CGRectMake(3, CGRectGetMaxY(_reactBut.frame),CGRectGetWidth(_reactBut.frame), config.inputViewRect.size.height)];
    textView.font = config.stringFont;
    self.textView = textView;
    self.textView.maxNumberOfLines = 5;
    self.textView.cornerRadius = 0.0f;
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.delegate = self;
    
    [_textBackView addSubview:_reactBut];
    [_textBackView addSubview:textView];
    [self addSubview:_textBackView];
    __weak __typeof__ (self) wself = self;
    [textView textValueDidChanged:^(NSString *text, CGFloat textHeight) {
        __strong __typeof (wself) sself = wself;
        [sself updateLayout:textHeight];
    }];
    
    // 按住说话按钮
    UIView *v2 = [[UIView alloc] initWithFrame:config.inputViewRect];
    UILabel *labl = [[UILabel alloc] initWithFrame:v2.bounds];
    [v2 addSubview:labl];
    labl.textAlignment = NSTextAlignmentCenter;
    labl.text = @"Hold to record";
    labl.font = [UIFont systemFontOfSize:16];
    labl.textColor = InputHexColor(0x555555);
    v2.layer.borderColor = InputHexColor(0xC1C2C6).CGColor;
    v2.layer.borderWidth = 1;
    v2.layer.cornerRadius = 5;
    v2.backgroundColor = InputHexColor(0xF6F6F8);
    [self.containerView addSubview:v2];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesAction:)];
    longPress.minimumPressDuration = 0.1;
    [v2 addGestureRecognizer:longPress];
    
    // 表情按钮
    UIButton *v3 = [[UIButton alloc] initWithFrame:config.emojiButtonRect];
    [v3 setImage:emojIcon forState:UIControlStateNormal];
    [v3 setImage:keyboardIcon forState:UIControlStateSelected];
    v3.selected = NO;
    v3.tag = 1;
    [v3 addTarget:self action:@selector(tagbut:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:v3];
    self.emojiBut = v3;
    
    // '更多'按钮
    UIButton *v4 = [[UIButton alloc] initWithFrame:config.moreButtonRect];
    [v4 setImage:moreIcon forState:UIControlStateNormal];
    [v4 setImage:keyboardIcon forState:UIControlStateSelected];
    v4.tag = 2;
    [v4 addTarget:self action:@selector(tagbut:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:v4];
    self.moreBut = v4;
    
    // 键盘注释
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveNoitfication:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    emojiKeyboard = [CTEmojiKeyboard keyBoard];
    emojiKeyboard.emojiDelegate = self;
    
    moreKeyboard = [CTMoreKeyBoard keyBoard];
    moreKeyboard.moreKeyDelegate = self;
    
    return self;
}

-(void)didMoveToWindow{
    [super didMoveToWindow];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
    });
}

-(BOOL)isFirstResponder{
    return [self.textView isFirstResponder];
}

-(NSArray *)buttons{
    return @[self.voiceBut, self.emojiBut, self.moreBut];
}
- (void) setReactString:(NSString *) reactString
{
    
    // 替换中文表情显示
    if (reactString.length > 0) {
        // 处理表情   将所有[呵呵]换成占位字符  并计算图片位置
        NSRegularExpression *regEmoji = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\[\\]]+?\\]"
                                                                                  options:kNilOptions error:NULL];
        //
        NSArray<NSTextCheckingResult *> *emoticonResults = [regEmoji matchesInString:reactString
                                                                             options:kNilOptions
                                                                               range:NSMakeRange(0, reactString.length)];
        if (emoticonResults && emoticonResults.count >0) {
            
            NSMutableArray *emjStrs = [NSMutableArray arrayWithCapacity:emoticonResults.count];
            
            for (NSTextCheckingResult *checkM in emoticonResults) {
                NSString *emjStr = [reactString substringWithRange:checkM.range]?:@"";
                [emjStrs addObject:emjStr];
            }
            for (NSString *enjCH in emjStrs) {
                NSString *emjEnStr = CTinputHelper.share.emojEnDic[enjCH]?:@"";
                if (emjEnStr.length > 0) {
                    reactString = [reactString stringByReplacingOccurrencesOfString:enjCH withString:emjEnStr];
                }
            }
        }
        
    }
    
    [_reactBut setTitle:reactString forState:UIControlStateNormal];
}
- (void)setIsReact:(BOOL)isReact
{
    if (isReact) {
        if (_isReact) {
            [self performSelector:@selector(textBecomeFirstResponder) withObject:self afterDelay:0.3];
            return;
        }
         _isReact = isReact;
        CGRect selfRect = self.frame;
        selfRect.size.height += reactH;
        selfRect.origin.y -= reactH;
        
        CGRect textBacktRect = _textBackView.frame;
        textBacktRect.size.height += reactH;
        
        CGRect reactRect = _reactBut.frame;
        reactRect.origin.y = 5;
        reactRect.size.height = reactH-5;
        
        CGRect textRect = _textView.frame;
        textRect.origin.y = CGRectGetMaxY(reactRect);
        
//        if ([self.delegate respondsToSelector:@selector(inputViewWillUpdateFrame:animateDuration:animateOption:)]){
//            [self.delegate inputViewWillUpdateFrame:selfRect animateDuration:0.25 animateOption:7];
//        }
       // [UIView animateWithDuration:0.25f delay:0 options:7 animations:^{
            self.frame = selfRect;
            self.textBackView.frame = textBacktRect;
            self.reactBut.frame = reactRect;
            self.textView.frame = textRect;
            if (self.textView.frame.size.height <= textRect.size.height) {
                [self.textView contentToVerticalCenter];
            }
     //   } completion:^(BOOL finished) {
            
            
     //   }];
        
        [self performSelector:@selector(textBecomeFirstResponder) withObject:self afterDelay:0.3];
        
    } else {
        
        _isReact = isReact;
        [_reactBut setTitle:@"" forState:UIControlStateNormal];
        CGRect selfRect = self.frame;
        selfRect.size.height -= reactH;
        selfRect.origin.y += reactH;
        
        CGRect textBacktRect = _textBackView.frame;
        textBacktRect.size.height -= reactH;
        
        CGRect reactRect = _reactBut.frame;
        reactRect.origin.y = 0;
        reactRect.size.height = 0;
        
        CGRect textRect = _textView.frame;
        textRect.origin.y = CGRectGetMaxY(reactRect);
        
//        if ([self.delegate respondsToSelector:@selector(inputViewWillUpdateFrame:animateDuration:animateOption:)]){
//            [self.delegate inputViewWillUpdateFrame:selfRect animateDuration:0.25 animateOption:7];
//        }
      //  [UIView animateWithDuration:0.25f delay:0 options:7 animations:^{
            self.frame = selfRect;
            self.textBackView.frame = textBacktRect;
            self.reactBut.frame = reactRect;
            self.textView.frame = textRect;
            if (self.textView.frame.size.height <= textRect.size.height) {
                [self.textView contentToVerticalCenter];
            }
      //  } completion:^(BOOL finished) {
            
            
       // }];
    }
    
   
}
#pragma mark 声音，表情  更多  按钮点击
-(void)tagbut:(UIButton *)but{
    // 切换按钮icon
    [self turnButtonOnAtIndex:(int)but.tag];
    
    if (but.tag == 0) {
        // 语音
        if (self.voiceBut.isSelected) {
            [AATAudioTool checkCameraAuthorizationGrand:^{
                
            } withNoPermission:^{
                
            }];
            tempTextViewHeight = self.textView.frame.size.height;
            [self updateLayout:CTinputHelper.share.config.emojiButtonRect.size.height];
            [self.textView resignFirstResponder];
           // [self.textView setHidden:YES];
            [self.textBackView setHidden:YES];
        } else {
            [self updateLayout:tempTextViewHeight];
            [self changeKeyBoard:nil];
           // [self.textView setHidden:NO];
            [self.textBackView setHidden:NO];
        }
    } else if (but.tag == 1) {
        // 表情
        if (self.emojiBut.isSelected) {
            if (tempTextViewHeight > 0 && self.frame.size.height == 56) {
                 [self updateLayout:tempTextViewHeight];
                tempTextViewHeight = 0;
            }
           
            [emojiKeyboard updateKeyBoard];
            [self changeKeyBoard:emojiKeyboard];
        } else {
           
            [self changeKeyBoard:nil];
        }
        
    } else if (but.tag == 2) {
        // 更多
        if (self.moreBut.isSelected) {
            if (tempTextViewHeight > 0 && self.frame.size.height == 56) {
                [self updateLayout:tempTextViewHeight];
                tempTextViewHeight = 0;
            }
            [self changeKeyBoard:[CTMoreKeyBoard keyBoard]];
        } else {
            [self changeKeyBoard:nil];
        }
    }
}

-(void)changeKeyBoard:(UIView *)keyboard{
    //[self.textView setHidden:NO];
    [self.textBackView setHidden:NO];
    self.textView.inputView = keyboard;
    [self.textView reloadInputViews];
    [self.textView becomeFirstResponder];
}

#pragma mark 语音相关

-(void)longPressGesAction:(UILongPressGestureRecognizer *)ges{
    
    switch (ges.state) {
        case  UIGestureRecognizerStatePossible:
            
            break;
        case UIGestureRecognizerStateBegan:
        {
            if (AppD.window.windowLevel != UIWindowLevelNormal) {
                AppD.window.windowLevel = UIWindowLevelNormal;
            }
            
            //    开始录音
            [AATAudioTool checkCameraAuthorizationGrand:^{
                [[AATAudioTool share] startRecord];
                [AATVoiceHudAlert showPowerHud:1];
                self.isRecordTouchingOutSide = NO;
                [AATAudioTool share].delegate = self;
            } withNoPermission:^{
                
            }];
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint loca = [ges locationInView:ges.view];
            BOOL bol = CGRectContainsPoint(ges.view.bounds, loca);
            if (bol) {
                // 拖拽到内部，如果在录音，则恢复正常显示，否则什么都不做
                if ([AATAudioTool share].isRecorderRecording) {
                    self.isRecordTouchingOutSide = NO;
                }
            } else {
                self.isRecordTouchingOutSide = YES;
            }
        }
            break;
        case  UIGestureRecognizerStateEnded:
        {
            CGPoint loca = [ges locationInView:ges.view];
            BOOL bol = CGRectContainsPoint(ges.view.bounds, loca);
            if (bol) {
                //    结束录音
                [[AATAudioTool share] stopRecord];
                [AATVoiceHudAlert hideHUD];
            } else {
                //    外部抬起，取消录音
                [[AATAudioTool share] intertrptRecord];
                [AATVoiceHudAlert hideHUD];
            }
        }
            break;
        case  UIGestureRecognizerStateCancelled:
            
            break;
        case  UIGestureRecognizerStateFailed:
            
            break;
        default:
            break;
    }
}
// 开始录音回调
-(void)aatAudioToolDidStartRecord:(NSTimeInterval)currentTime{
    [AATVoiceHudAlert showPowerHud:1];
}

-(void)aatAudioToolUpdateCurrentTime:(NSTimeInterval)currentTime
                            fromTime:(NSTimeInterval)startTime
                               power:(float)power{
    
    if (self.isRecordTouchingOutSide){
        [AATVoiceHudAlert showRevocationHud];
    } else {
        [AATVoiceHudAlert showPowerHud:ceil(power * 10)];
    }
}

-(void)aatAudioToolDidStopRecord:(NSURL *)dataPath
                       startTime:(NSTimeInterval)start
                         endTime:(NSTimeInterval)end
                       errorInfo:(NSString *)info{
    if (info) {
//        [AATHUD showInfo:info andDismissAfter:0.5];
    } else {
        [self.delegate inputViewPopAudioath:dataPath];
    }
    [AATAudioTool share].delegate = nil;
}
//
-(void)aatAudioToolDidSInterrupted{
    [AATAudioTool share].delegate = nil;
    [AATVoiceHudAlert showRevocationHud];
}

#pragma mark 文本 UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [self emojiKeyboardSelectSend];
        return NO;
    }
    NSString *textViewString = textView.text?:@"";
    if ([textViewString charactorNumber] >= fontMax) {
        if (range.length == 1 && text.length == 0) {
            return YES;
        }
       // textView.text = [textView.text substringToIndex:245];
        return NO;
    }
    
    if ([text isEqualToString:@"@"]) {
        if (self.atStrings.count == 5) {
            [AppD.window showMiddleHint:@"You can mention up to 5 contacts in the group at once."];
            return YES;
        }
        if (textView.text.length > 0) {
            NSString *endStr = [textView.text substringWithRange:NSMakeRange(textView.text.length-1, 1)];
            if ([endStr isValidLettersAndNumbers]) {
                return YES;
            }
        }
        if ([self.delegate respondsToSelector:@selector(inputViewPopRemid)]) {
            [self.delegate inputViewPopRemid];
           // textView.text = [textView.text stringByAppendingString:@"@"];
        }
        return YES;
    }
//    if (range.length == 1 && text.length == 0) {
//        return YES;
//    } else
    
    if ([text isEqualToString:@""]) {
        if (_textView.text.length == 0) { // 删除回复
            if (_isReact) {
                [self setIsReact:NO];
            }
        }
        NSRange selectRange = _textView.selectedRange;
        if (selectRange.length > 0)
        {
            //用户长按选择文本时不处理
            return YES;
        }
        if (self.atStrings.count == 0) {
            return YES;
        }
        // 判断删除的是一个@中间的字符就整体删除
        NSMutableString *string = [NSMutableString stringWithString:_textView.text];
        BOOL inAt = NO;
        NSInteger index = range.location;
        
        for (AtUserModel *atModel in self.atStrings) {
            // 找到所有@位置
            NSArray *atValues = [self rangeOfSubString:atModel.atName inString:string];
            
            for (NSValue *valueRange in atValues) {
                NSRange matchMange = [valueRange rangeValue];
                NSRange newRange = NSMakeRange(matchMange.location + 1, matchMange.length - 1);
                
                if (NSLocationInRange(range.location, newRange))
                {
                    inAt = YES;
                    index = matchMange.location;
                    [string replaceCharactersInRange:matchMange withString:@""];
                    [self.atStrings removeObject:atModel];
                    break;
                }
            }
            
            if (inAt) {
                break;
            }
            
        }
       // NSArray *matches = [SystemUtil findAllAtWithString:string];
       
//        for (NSTextCheckingResult *match in matches)
//        {
//            NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
//            if (NSLocationInRange(range.location, newRange))
//            {
//                inAt = YES;
//                index = match.range.location;
//                [string replaceCharactersInRange:match.range withString:@""];
//                break;
//            }
//        }
        
        if (inAt)
        {
            _textView.text = string;
            [_textView textDidChange];
            _textView.selectedRange = NSMakeRange(index, 0);
            return NO;
        }
    }
    return YES;
}

- (NSArray*) rangeOfSubString:(NSString*)subStr inString:(NSString*)string {
    
    NSMutableArray *rangeArray = [NSMutableArray array];
    NSString*string1 = [string stringByAppendingString:subStr?:@""];
    NSString *temp;
    for(int i =0; i < string.length; i++) {
        temp = [string1 substringWithRange:NSMakeRange(i, subStr.length)];
        if ([temp isEqualToString:subStr]) {
             NSRange range = {i,subStr.length};
             [rangeArray addObject: [NSValue valueWithRange:range]];
        }
    }
     return rangeArray;
}



- (void)textViewDidChangeSelection:(UITextView *)textView
{
    // 光标不能点落在@词中间
    NSRange range = _textView.selectedRange;
    if (range.length > 0)
    {
        // 选择文本时可以
        return;
    }
    
    NSMutableString *string = [NSMutableString stringWithString:_textView.text];
    for (AtUserModel *atModel in self.atStrings) {
        NSRange matchMange = [string rangeOfString:atModel.atName];
        NSRange newRange = NSMakeRange(matchMange.location + 1, matchMange.length - 1);
        
        if (NSLocationInRange(range.location, newRange))
        {
            _textView.selectedRange = NSMakeRange(matchMange.location + matchMange.length, 0);
            break;
        }
    }
    
//    NSArray *matches = [SystemUtil findAllAtWithString:_textView.text];
//
//    for (NSTextCheckingResult *match in matches)
//    {
//        NSRange newRange = NSMakeRange(match.range.location + 1, match.range.length - 1);
//        if (NSLocationInRange(range.location, newRange))
//        {
//            _textView.selectedRange = NSMakeRange(match.range.location + match.range.length, 0);
//            break;
//        }
//    }
}

- (NSMutableArray *)atStrings
{
    if (!_atStrings) {
        _atStrings = [NSMutableArray array];
    }
    return _atStrings;
}

#pragma mark 表情 CTEmojiKeyboardDelegare

-(void)emojiKeyboardSelectKey:(NSString *)key image:(UIImage *)img{
    
    EmojiTextAttachment *attachment = [[EmojiTextAttachment alloc] init];
    attachment.emojiTag = key;
    attachment.image = img;
    attachment.bounds = CGRectMake(0,
                                   CTinputHelper.share.config.stringFont.descender,
                                   CTinputHelper.share.config.stringFont.lineHeight,
                                   CTinputHelper.share.config.stringFont.lineHeight);
    
    NSMutableAttributedString *textAttr = [[NSMutableAttributedString alloc] initWithAttributedString:self.textView.attributedText];
    NSAttributedString *imageAttr = [NSMutableAttributedString attributedStringWithAttachment:attachment];
    [textAttr replaceCharactersInRange:self.textView.selectedRange withAttributedString:imageAttr];
    [textAttr addAttributes:@{NSFontAttributeName : self.textView.font} range:NSMakeRange(self.textView.selectedRange.location, 1)];
    self.textView.attributedText = textAttr;
    [self.textView textDidChange];
}

-(void)emojiKeyboardSelectDelete{
    [self.textView deleteBackward];
}

-(void)emojiKeyboardSelectSend{
    NSString *plainStr = [EmojiTextAttachment getPlainString: [self.textView.attributedText copy]];
    // 去掉前后空格和换行符
    plainStr = [NSString trimWhitespaceAndNewline:plainStr];
    if (plainStr && ![plainStr isEmptyString]) {
        if ([self.delegate respondsToSelector:@selector(inputViewPopSttring:)]) {
            [self.delegate inputViewPopSttring:plainStr];
        }
        self.textView.text = @"";
        if (_isReact) {
            [self setIsReact:NO];
        }
        [self.textView textDidChange];
    }
    
}

- (NSString *) getTextViewString
{
    NSString *plainStr = [EmojiTextAttachment getPlainString: [self.textView.attributedText copy]];
    return plainStr;
}
- (NSRange) selectedRange
{
    return self.textView.selectedRange;
}
- (void) setSelectedRange:(NSRange) range
{
    self.textView.selectedRange = range;
}
- (void) setTextUnmarkText
{
    [self.textView unmarkText];
}
- (void) setTextViewString:(NSString *) textString
{
    self.textView.text = textString;
  
    [self performSelector:@selector(textBecomeFirstResponder) withObject:self afterDelay:0.7];
}

- (void) setTextViewString:(NSString *) textString delayTime:(CGFloat) delayTime
{
    self.textView.text = textString;
    [self performSelector:@selector(textBecomeFirstResponder) withObject:self afterDelay:0.5];
}

- (NSAttributedString *) getTextViewAttributeString
{
    return self.textView.attributedText;
}
- (void) setTextViewAttributeString:(NSAttributedString *) attributeString
{
    self.textView.attributedText = attributeString;
    [self.textView becomeFirstResponder];
}

- (void) textBecomeFirstResponder
{
    [self.textView textDidChange];
    [self.textView becomeFirstResponder];
}

#pragma mark 更多 CTMoreKeyBoardDelegare
-(void)moreKeyBoardSelectKey:(NSString *)key image:(UIImage *)img{
    [self.delegate inputViewPopCommand:key];
}

#pragma mark 键盘通知
-(void)receiveNoitfication:(NSNotification *)noti{
    if ([noti.name isEqualToString:UIKeyboardWillChangeFrameNotification]) {
        NSDictionary *dic = noti.userInfo;
        NSNumber *curv = dic[UIKeyboardAnimationCurveUserInfoKey];
        NSNumber *duration = dic[UIKeyboardAnimationDurationUserInfoKey];
        // 键盘Rect
        CGRect keyBoardEndFrmae = ((NSValue * )dic[UIKeyboardFrameEndUserInfoKey]).CGRectValue;
        
        
        
        CGRect selfNewFrame = CGRectMake(self.frame.origin.x,
                                         keyBoardEndFrmae.origin.y - self.frame.size.height,
                                         self.frame.size.width, self.frame.size.height);
        
        if (IS_iPhoneX) {
            
            if (keyBoardEndFrmae.origin.y == SCREEN_HEIGHT) {
                selfNewFrame.origin.y -= [[UIApplication sharedApplication] statusBarFrame].size.height;
            }
        }
        
        originRect.origin.y = selfNewFrame.origin.y - (originRect.size.height - selfNewFrame.size.height);
        
        if ([self.delegate respondsToSelector:@selector(inputViewWillUpdateFrame:animateDuration:animateOption:)]){
            [self.delegate inputViewWillUpdateFrame:selfNewFrame animateDuration:duration.doubleValue animateOption:curv.integerValue];
        }
        
        [UIView animateWithDuration:duration.doubleValue delay:0 options:curv.integerValue animations:^{
            self.frame = selfNewFrame;
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark 适应输入框高度变化
-(void)updateLayout:(CGFloat)newTextViewHight{
    
   newTextViewHight = newTextViewHight < CTInputView_Height ? CTInputView_Height:newTextViewHight;
    
    // 输入框默认位置
    CTInputConfiguration *config = CTinputHelper.share.config;
    
    // 更新后的输入框的位置
    CGRect newTextViewRect = self.textView.frame;
    newTextViewRect.size.height = newTextViewHight;
    
    // 输入框的高度变化
    CGFloat delta = config.inputViewRect.size.height - newTextViewHight;
    
    // 根据输入框的变化修改整个视图的位置
    if (_isReact) {
        if (originRect.size.height == 56) {
            originRect.origin.y -= reactH;
            originRect.size.height += reactH;
        }
    } else {
        if (originRect.size.height == 56+reactH) {
            originRect.origin.y += reactH;
            originRect.size.height -= reactH;
        }
    }
    CGRect newRect = CGRectOffset(originRect, 0, delta);
    newRect.size.height = newRect.size.height - delta;
    
    CGRect textViewBackRect = _textBackView.frame;
    textViewBackRect.size.height = newRect.size.height - 16;
    
    
    
    
    if ([self.delegate respondsToSelector:@selector(inputViewWillUpdateFrame:animateDuration:animateOption:)]){
        [self.delegate inputViewWillUpdateFrame:newRect animateDuration:0.25 animateOption:7];
    }
    [UIView animateWithDuration:0.25f delay:0 options:7 animations:^{
        self.frame = newRect;
        self.textBackView.frame = textViewBackRect;
        self.textView.frame = newTextViewRect;
        if (self.textView.frame.size.height <= newTextViewRect.size.height) {
             [self.textView contentToVerticalCenter];
        }
       
        
        
    } completion:^(BOOL finished) {
       
        
    }];
}

#pragma mark 让输入框变成第一响应
-(BOOL)becomeFirstResponder{
    self.textView.inputView = nil;
    [self.textView becomeFirstResponder];
    [self turnButtonOnAtIndex:-1];
    [self changeKeyBoard:nil];
    return [super becomeFirstResponder];
}

-(BOOL)resignFirstResponder{
    
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSLog(@"pasteboard.string = %@",pasteboard.string);
    
    self.textView.inputView = nil;
    [self.textView resignFirstResponder];
    
    self.emojiBut.selected = NO;
    self.moreBut.selected = NO;
    return [super resignFirstResponder];
}

-(void)turnButtonOnAtIndex:(NSInteger)idx{
    [self.voiceBut setSelected:(idx == 0) ? !self.voiceBut.isSelected : NO];
    [self.emojiBut setSelected:(idx == 1) ? !self.emojiBut.isSelected : NO];
    [self.moreBut setSelected:(idx == 2) ? !self.moreBut.isSelected : NO];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
