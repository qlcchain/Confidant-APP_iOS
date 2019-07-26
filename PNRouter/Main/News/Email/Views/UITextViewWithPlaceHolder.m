//
//  UITextViewWithPlaceHolder.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "UITextViewWithPlaceHolder.h"

@implementation UITextViewWithPlaceHolder

- (instancetype)initWithCoder:(NSCoder*)coder
{
    self= [super initWithCoder:coder];
    if(self) {
        [self addNofity];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self= [super initWithFrame:frame];
    if(self) {
        [self addNofity];
    }
    return self;
}
- (void)addNofity{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textChange:)name:UITextViewTextDidChangeNotification object:self];
}
- (void)removeNotify{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    self.textContainerInset=UIEdgeInsetsMake(8,0,0,0);//这里自定义
    UIEdgeInsets insets =self.textContainerInset;
    if(self.text.length==0 && self.placeHolder) {
        CGRect r = CGRectMake(rect.origin.x+ insets.left+6, rect.origin.y+ insets.top, rect.size.width-insets.left-insets.right, rect.size.height-insets.top-insets.bottom);
        if(self.placeHolderFont==nil) {
            self.placeHolderFont=self.font;
        }
        if(self.placeHolderColor==nil) {
            self.placeHolderColor= [UIColor lightGrayColor];
        }
        [self.placeHolder drawInRect:r withAttributes:@{NSForegroundColorAttributeName:self.placeHolderColor,NSFontAttributeName:self.placeHolderFont}];
        return;
    }
    [super drawRect:rect];
}
- (void)textChange:(NSNotification*)notify{
    [self setNeedsDisplay];
}
- (void)dealloc{
    [self removeNotify];
}

@end

