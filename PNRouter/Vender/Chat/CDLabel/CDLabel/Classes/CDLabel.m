//
//  CDLabel.m
//  CDLabel
//
//  Created by chdo on 2017/12/1.
//

#import "CDLabel.h"
#import "MagnifiterView.h"
#import "CTHelper.h"
#import "CDLabelMacro.h"
#import "CoreTextUtils.h"
#import "CTClickInfo.h"
#import "CDCalculator.h"

@interface SelectionAnchor: UIImageView
+(SelectionAnchor *)anchor:(BOOL)isTop lineHeight:(CGFloat) lineHeight;
@end

@implementation SelectionAnchor

+(SelectionAnchor *)anchor:(BOOL)isTop lineHeight:(CGFloat) lineHeight{
    
    SelectionAnchor *anc = [[SelectionAnchor alloc] initWithFrame:CGRectMake(0, 0, 10, lineHeight + 10)];
    UIImage *img = [anc cursorWithFontHeight:lineHeight isTop:isTop];
    anc.image = img;
    anc.contentMode = UIViewContentModeScaleAspectFit;
    return anc;
}

- (UIImage *)cursorWithFontHeight:(CGFloat)height isTop:(BOOL)top {
    
    CGFloat pinWidth = 10.0f;
    // 22
    CGRect rect = CGRectMake(0, 0, pinWidth, height + pinWidth);
    UIColor *color = RGB(28, 107, 222);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    // draw point
    if (top) {
        CGContextAddEllipseInRect(context, CGRectMake(0, 0, pinWidth, pinWidth));
    } else {
        CGContextAddEllipseInRect(context, CGRectMake(0, height, pinWidth, pinWidth));
    }
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillPath(context);
    // draw line
    [color set];
    CGContextSetLineWidth(context, 2);
    CGContextMoveToPoint(context, pinWidth * 0.5, 0);
    CGContextAddLineToPoint(context, pinWidth * 0.5, height + pinWidth);
    CGContextStrokePath(context);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end

typedef enum CTDisplayViewState : NSInteger {
    CTDisplayViewStateNormal,       // 普通状态
    CTDisplayViewStateSelecting,    // 拖动中，  隐藏菜单
    CTDisplayViewStateSelected      // 拖动完成，需要弹出复制菜单
}CTDisplayViewState;

#define ANCHOR_TARGET_TAG 1

@interface CDLabel()<UIGestureRecognizerDelegate>
{
    BOOL isLeftAncherSelecting;
    BOOL isRightAncherSelecting;
    
    CFStringRef currentMode;
}

@property(nonatomic, strong) CDCalculator *textCalcator;

// 下标
@property (nonatomic) NSInteger selectionStartPosition; // 下标  选择起点
@property (nonatomic) NSInteger selectionEndPosition;   // 下标  选择终点

// 状态
@property (nonatomic) CTDisplayViewState state;

// 视图
@property (strong, nonatomic) SelectionAnchor *leftSelectionAnchor;
@property (strong, nonatomic) SelectionAnchor *rightSelectionAnchor;

// 放大镜
@property (strong, nonatomic) MagnifiterView *magnifierView;


@property(nonatomic, strong) UIGestureRecognizer *tapRecognizer;
@property(nonatomic, strong) UIGestureRecognizer *longPressRecognizer;
@property(nonatomic, strong) UIGestureRecognizer *panRecognizer;

@end

@implementation CDLabel

#pragma mark -------------------------初始化-------------------------

- (id)init {
    [self setupGestures];
    _selectionStartPosition = 0;
    _selectionEndPosition = 0;
    return [self initWithFrame:CGRectZero];
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    
    currentMode = CFRunLoopCopyCurrentMode(CFRunLoopGetMain());
    
    self.backgroundColor = [UIColor clearColor];
    _selectionStartPosition = 5;
    _selectionEndPosition = 1;
    [self setupGestures];
    
    __weak typeof(self) weakS = self;
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        if (weakS) {
            __strong typeof(weakS) strongS = weakS;
            CFComparisonResult rest = CFStringCompare(strongS->currentMode, CFRunLoopCopyCurrentMode(CFRunLoopGetMain()), kCFCompareBackwards);
            if (rest != kCFCompareEqualTo) {
                strongS->currentMode = CFRunLoopCopyCurrentMode(CFRunLoopGetMain());
                if ((NSString *)CFBridgingRelease(strongS->currentMode) == UITrackingRunLoopMode) {
                    [strongS scrollDidScroll];
                }
            }
        }
    });

    CFRunLoopAddObserver(CFRunLoopGetMain(), observer, kCFRunLoopCommonModes);
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receivedNotification:) name:UIMenuControllerWillHideMenuNotification object:nil];
    
    return self;
}

-(void)receivedNotification:(NSNotification *)noti{
    if ([noti.name isEqualToString:UIMenuControllerWillHideMenuNotification]) {
        if (self.state != CTDisplayViewStateSelecting) {
            [self scrollDidScroll];
        }
    }
}

- (MagnifiterView *)magnifierView {
    if (_magnifierView == nil) {
        _magnifierView = [[MagnifiterView alloc] init];
        _magnifierView.viewToMagnify = self;
    }
    return _magnifierView;
}

-(UIImageView *)leftSelectionAnchor{
    if (!_leftSelectionAnchor) {
        _leftSelectionAnchor = [SelectionAnchor anchor:YES lineHeight:[UIFont systemFontOfSize:self.data.config.textSize].lineHeight];
    }
    if (!_leftSelectionAnchor.superview) {// 若没有在父视图上，则默认在起点位置
        [self addSubview:_leftSelectionAnchor];
    }
    CGRect rec = _leftSelectionAnchor.frame;
    if (rec.size.height < 20) {
        rec.size = CGSizeMake(10, 30);
    }
    _leftSelectionAnchor.frame = rec;
    return _leftSelectionAnchor;
}

-(UIImageView *)rightSelectionAnchor{
    if (!_rightSelectionAnchor) {
        _rightSelectionAnchor = [SelectionAnchor anchor:NO lineHeight:[UIFont systemFontOfSize:self.data.config.textSize].lineHeight];
    }
    if (!_rightSelectionAnchor.superview) {
        [self addSubview:_rightSelectionAnchor];
    }
    CGRect rec = _rightSelectionAnchor.frame;
    if (rec.size.height < 20) {
        rec.size = CGSizeMake(10, 30);
    }
    _rightSelectionAnchor.frame = rec;
    return _rightSelectionAnchor;
}

- (void)setupGestures {
    
    _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapGestureDetected:)];
    [self addGestureRecognizer:_tapRecognizer];
    _tapRecognizer.delegate = self;
    
    
    _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(userLongPressedGuestureDetected:)];
    [self addGestureRecognizer:_longPressRecognizer];
    _longPressRecognizer.delegate = self;
    
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(userPanGuestureDetected:)];
    [self addGestureRecognizer:_panRecognizer];
    _panRecognizer.delegate = self;
    
    
    self.userInteractionEnabled = YES;
}



#pragma mark -------------------------数据源变动-------------------------

- (void)setData:(CTData *)data {
    _data = data;
    self.layer.contents = (__bridge id)data.contents.CGImage;
    self.state = CTDisplayViewStateNormal;
    self.selectionStartPosition = 0;
    self.selectionEndPosition = 0;
    [self setNeedsDisplay];
}

-(void)setText:(NSString *)text{
    _text = text;
    
    // 取消旧任务的回调
    self.textCalcator.label = nil;
    self.layer.contents = nil;
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.textCalcator.calComplete = nil;
    
    
    // 建立新的任务
    self.textCalcator = [[CDCalculator alloc] init];
    self.textCalcator.label = self;
    __weak typeof(self) ws = self;
    
    // 选择渲染配置
    CTDataConfig config = (self.config.textSize != 0.00f) ? self.config : [CTData defaultConfig];
    // 渲染完成
    self.textCalcator.calComplete = ^(CTData *data) {
        [ws safeThread:^{
            if (ws) {
                __strong typeof(ws) ss = ws;
                ss.data = data;
                CGRect frame = ss.frame;
                frame.size = CGSizeMake(ss->_data.width, ss->_data.height);
                if (config.willUpdateFrame) {
                    ss.frame = frame;
                }
            }
        }];
    };
    // 渲染
    [self.textCalcator calcuate:text
                            and:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)
                            and:config];
  
}

-(void)setAttributedText:(NSAttributedString *)attributedText{
    _attributedText = attributedText;
    
    // 取消旧任务的回调
    self.textCalcator.label = nil;
    self.layer.contents = nil;
    self.textCalcator.calComplete = nil;
    
    
    // 建立新的任务
    self.textCalcator = [[CDCalculator alloc] init];
    self.textCalcator.label = self;
    __weak typeof(self) ws = self;
    
    
    // 渲染完成
    self.textCalcator.calComplete = ^(CTData *data) {
        [ws safeThread:^{
            if (ws) {
                __strong typeof(ws) ss = ws;
                ss.data = data;
                CGRect frame = ss.frame;
                frame.size = CGSizeMake(ss->_data.width, ss->_data.height);
//                ss.frame = frame;
                ss.layer.frame = frame;
            }
        }];
    };
    
    // 渲染
    [self.textCalcator calcuate:attributedText and:CGSizeMake(self.frame.size.width, CGFLOAT_MAX)];
}

- (void)setState:(CTDisplayViewState)state {
    if (_state == state) {
        return;
    }
    _state = state;
    
    if (_state == CTDisplayViewStateNormal) {
        [self hidMenu];
    } else if (_state == CTDisplayViewStateSelected) {
        [self showMenu];
    } else {
        [self hidMenu];
    }
}

-(void)showMenu{
    if ([self canBecomeFirstResponder]) {
        [self becomeFirstResponder];
    }
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
//    UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:@"Save" action:@selector(clickSaveItem:)];
    UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:@"Copy" action:@selector(copycontent:)];
    UIMenuItem *item3 = [[UIMenuItem alloc] initWithTitle:@"All Select" action:@selector(selectAllContent:)];
    UIMenuItem *item4 = [[UIMenuItem alloc] initWithTitle:@"Forward" action:@selector(clickForwardItem:)];
     UIMenuItem *item5 = [[UIMenuItem alloc] initWithTitle:@"Withdraw" action:@selector(clickWithdrawItem:)];
    if (self.isOwer) {
       
        [menu setMenuItems:@[item2,item3,item4,item5]];
    } else {
        if (self.isAdmin == GROUP_IDF) {
             [menu setMenuItems:@[item2,item3,item4,item5]];
        } else {
            [menu setMenuItems:@[item2,item3,item4]];
        }
        
    }
    
    CGRect rec = CGRectMake(self.frame.size.width * 0.5, self.leftSelectionAnchor.frame.origin.y, 10, 10);
    [menu setTargetRect:rec inView:self];
    [menu setMenuVisible:YES animated:YES];
    
}
- (void) clickSaveItem:(UIMenuController *) item
{
    if ([_labelDelegate respondsToSelector:@selector(selectMenuWithTag:)]) {
        [_labelDelegate selectMenuWithTag:@"Save"];
    }
    
}
- (void) clickForwardItem:(UIMenuController *) item
{
    if ([_labelDelegate respondsToSelector:@selector(selectMenuWithTag:)]) {
        [_labelDelegate selectMenuWithTag:@"Forward"];
    }
    
}
- (void) clickWithdrawItem:(UIMenuController *) item
{
    if ([_labelDelegate respondsToSelector:@selector(selectMenuWithTag:)]) {
        [_labelDelegate selectMenuWithTag:@"Withdraw"];
    }
}

-(void)hidMenu{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuVisible:NO animated:YES];
}

-(void)scrollDidScroll {
    self.state = CTDisplayViewStateNormal;
    self.selectionStartPosition = 0;
    self.selectionEndPosition = 0;
    [self.leftSelectionAnchor removeFromSuperview];
    [self.rightSelectionAnchor removeFromSuperview];
    [self setNeedsDisplay];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
    if ([gestureRecognizer isKindOfClass:UITapGestureRecognizer.class]) {
        return YES;
    }
    
    if ([gestureRecognizer isKindOfClass:UILongPressGestureRecognizer.class]) {
        return YES;
    }
    
    if ([gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
        
        if (self.state == CTDisplayViewStateNormal){
            return NO;
        }
        
        if (self.state == CTDisplayViewStateSelected){
            
            CGPoint loc = [touch locationInView:self];
            
            CGRect leftRect = CGRectMake(self.leftSelectionAnchor.frame.origin.x - (60 - self.leftSelectionAnchor.frame.size.width) * 0.5,
                                         self.leftSelectionAnchor.frame.origin.y - 10,
                                         60,
                                         self.leftSelectionAnchor.frame.size.height + 10);
            isLeftAncherSelecting = CGRectContainsPoint(leftRect,loc);
            
            CGRect rightRect = CGRectMake(self.rightSelectionAnchor.frame.origin.x - (60 - self.rightSelectionAnchor.frame.size.width) * 0.5,
                                          self.rightSelectionAnchor.frame.origin.y,
                                          60,
                                          self.rightSelectionAnchor.frame.size.height + 10);
            isRightAncherSelecting = CGRectContainsPoint(rightRect, loc);
            if (isLeftAncherSelecting || isRightAncherSelecting) {
                //                NSLog(@"......");
                return YES;
            } else {
                //                NSLog(@"!!!!!!");
                return NO;
            }
        }
    }
    return NO;
}


-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    CGRect rec = CGRectMake(-10, -10, self.frame.size.width + 20, self.frame.size.height + 20);
    BOOL res = CGRectContainsPoint(rec, point);
    return res;
}

#pragma mark -------------------------绘图-------------------------

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    // 文字重新绘制
    [self.data.contents drawInRect:self.bounds];
    
    // 绘制选择区域
    [self drawSelectionArea];
}

#pragma mark 绘制填充区域
- (void)drawSelectionArea {
    
    [self.leftSelectionAnchor removeFromSuperview];
    [self.rightSelectionAnchor removeFromSuperview];
    
    // 没有文字被选择，则不绘制
    if (_selectionEndPosition <= 0) {
        return;
    }
    
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, self.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);
    
    CTFrameRef textFrame = self.data.ctFrame;
    CFArrayRef lines = CTFrameGetLines(self.data.ctFrame);
    
    if (!lines) {
        return;
    }
    
    CFIndex count = CFArrayGetCount(lines);
    // 获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), origins);
    
    for (int i = 0; i < count; i++) {
        // ------------------------画选中区域------------------------
        //每一行的origin
        CGPoint linePoint = origins[i];
        // CTLine
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        // 行信息
        CGFloat ascent, descent, leading, width, offset_left, offset_right;
        width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        // 当position不在line中时，offset为0
        offset_left = CTLineGetOffsetForStringIndex(line, _selectionStartPosition, NULL);
        offset_right = CTLineGetOffsetForStringIndex(line, _selectionEndPosition, NULL);
        
        CGFloat selectWidth = 0;
        if (offset_left == 0 && offset_right == 0) {
            selectWidth = 0;
        } else if (offset_left == 0 && offset_right != 0) {
            selectWidth = offset_right;
        } else if (offset_left != 0 && offset_right == 0) {
            selectWidth = width - offset_left;
        } else {
            selectWidth = offset_right - offset_left;
        }
        CGRect lineRect = CGRectMake(linePoint.x + offset_left,
                                     linePoint.y - descent,
                                     selectWidth,
                                     ascent + descent + self.data.config.lineSpace);
        
        lineRect = CGRectApplyAffineTransform(lineRect, transform);
        
        
        [self fillSelectionAreaInRect:lineRect];
        
        
        // ------------------------移动锚点------------------------
        
        CFRange rag = CTLineGetStringRange(line);
        
        if (_selectionStartPosition >= rag.location && _selectionStartPosition <= rag.location + rag.length) {
            CGRect leftFrame = self.leftSelectionAnchor.frame;
            leftFrame.origin = CGPointMake(offset_left - 5, linePoint.y - descent);
            leftFrame = CGRectApplyAffineTransform(leftFrame, transform);
            self.leftSelectionAnchor.frame = leftFrame;
        }
        
        if (_selectionEndPosition >= rag.location && _selectionEndPosition <= rag.location + rag.length) {
            CGRect leftFrame = self.rightSelectionAnchor.frame;
            leftFrame.origin = CGPointMake(offset_right - 5, linePoint.y - descent - 10);
            leftFrame = CGRectApplyAffineTransform(leftFrame, transform);
            self.rightSelectionAnchor.frame = leftFrame;
        }
    }
    
}

#pragma mark  ------------------------------手势 ------------------------------

#pragma mark 长按手势
- (void)userLongPressedGuestureDetected:(UILongPressGestureRecognizer *)recognizer {
    
    CGPoint curPoint = [recognizer locationInView:self];
    if (!CGRectContainsPoint(self.bounds, curPoint)){
        return;
    }
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.selectionStartPosition = 0;
            self.selectionEndPosition = self.data.ctFrameLength;
            [self setNeedsDisplay];
            self.state = CTDisplayViewStateSelected;
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            //            self.magnifierView.touchPoint = curPoint;
        }
            break;
        default:
        {
            //            [self.magnifierView removeFromSuperview];
        }
            break;
    }
}



#pragma mark 拖动手势
- (void)userPanGuestureDetected:(UIGestureRecognizer *)recognizer {
    //    NSLog(@"?????2");
    if (self.state == CTDisplayViewStateNormal) {
        //        NSLog(@"不在拖动态");
        return;
    }
    
    
    CGPoint loc = [recognizer locationInView:self];
    
    if (!CGRectContainsPoint(self.frame, loc)){
        [self.magnifierView removeFromSuperview];
        //        NSLog(@"在视图上");
    } else {
        //        NSLog(@"不在视图上");
    }
    
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            self.state = CTDisplayViewStateSelecting;
            
            // 获得文字的index
            CTLinkConfig config = [CoreTextUtils touchContentOffsetInView:self atPoint:loc data:self.data];
            
            if (config.index == -1) {
                return;
            }
            
            if (isLeftAncherSelecting) {
                if (config.index >= _selectionEndPosition) {
                    return;
                }
                _selectionStartPosition = config.index;
                self.magnifierView.touchPoint = loc;
            }
            
            
            if (isRightAncherSelecting) {
                if (config.index <= _selectionStartPosition) {
                    return;
                }
                _selectionEndPosition = config.index;
                self.magnifierView.touchPoint = loc;
            }
            
            [self setNeedsDisplay];
            
        }
            break;
        default:
        {
            self.state = CTDisplayViewStateSelected;
            [self.magnifierView removeFromSuperview];
        }
            break;
    }
    
}

#pragma mark 点击手势
- (void)userTapGestureDetected:(UIGestureRecognizer *)recognizer {
    if (self.state == CTDisplayViewStateNormal) {
        CGPoint loc = [recognizer locationInView:self];
        CTLinkData *link = [CoreTextUtils touchLinkInView:self atPoint:loc data:self.data];
        if (link) {
            if ([self.labelDelegate respondsToSelector:@selector(labelDidSelectText:)]) {
                [self.labelDelegate labelDidSelectText:link];
            }
        }
    }
}

#pragma mark  ------------------工具方法------------------

CGRect expangRectToRect(CGRect originR, CGSize target){
    CGFloat mdX = CGRectGetMidX(originR);
    CGFloat mdY = CGRectGetMidY(originR);
    return  CGRectMake(mdX - target.width * 0.5, mdY - target.height * 0.5, target.width, target.height);
}

#pragma mark 工具方法 填充context颜色
- (void)fillSelectionAreaInRect:(CGRect)rect {
    
    UIColor *bgColor = RGBA(81, 110, 222, 0.6);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
    CGContextFillRect(context, rect);
}

#pragma mark 菜单相关方法

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    if (action == @selector(copycontent:) || action == @selector(selectAllContent:)|| action == @selector(clickSaveItem:)|| action == @selector(clickForwardItem:)|| action == @selector(clickWithdrawItem:)) {
        return YES;
    }
    return NO;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)copycontent:(UIMenuController *)menu
{
    if (!self.data.msgString) return;
    // 选中的富文本
    NSRange selectedRange = NSMakeRange(self.selectionStartPosition, self.selectionEndPosition - self.selectionStartPosition);
    
    NSMutableAttributedString * sub = [[NSMutableAttributedString alloc] initWithAttributedString:[self.data.content attributedSubstringFromRange: selectedRange]];
    
    NSUInteger shift = 0;
    for (CTImageData *imgData in self.data.imageArray) {

        NSRange rang = NSMakeRange(imgData.position + shift, 1);
        if (rang.location < _selectionEndPosition + shift) {
            [sub replaceCharactersInRange:rang withString:imgData.name];
            shift += [imgData.name length] - 1;
        }
    }
    
    UIPasteboard * paste = [UIPasteboard generalPasteboard];
    paste.string = sub.string;
    
   // [self resignFirstResponder];
    [self scrollDidScroll];
}

- (void)selectAllContent:(UIMenuController *)menu
{
   // [self resignFirstResponder];
    [self scrollDidScroll];
    
    self.selectionStartPosition = 0;
    self.selectionEndPosition = self.data.ctFrameLength;
    [self setNeedsDisplay];
    self.state = CTDisplayViewStateSelected;
}

-(void)safeThread:(void(^)(void))block{
    dispatch_queue_t main = dispatch_get_main_queue();
    if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(main)) {
        block();
    } else {
        dispatch_async(main, block);
    }
}

@end

