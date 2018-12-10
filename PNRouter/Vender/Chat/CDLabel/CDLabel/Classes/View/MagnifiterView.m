//
//  MagnifiterView.m
//  CoreTextDemo
//
//  Created by tangqiao on 5/8/14.
//  Copyright (c) 2014 TangQiao. All rights reserved.
//

#import "MagnifiterView.h"

@implementation MagnifiterView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:CGRectMake(0, 0, 80, 80)]) {
        self.layer.borderColor = [[UIColor lightGrayColor] CGColor];
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 40;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setTouchPoint:(CGPoint)touchPoint {
    _touchPoint = touchPoint;
    [self updateViewHierarchy];
    CGPoint pointInWindow = [self.viewToMagnify convertPoint:touchPoint toView:[self frontWindow]];
    self.center = CGPointMake(pointInWindow.x, pointInWindow.y - 70);
    [self setNeedsDisplay];
    
}



- (void)drawRect:(CGRect)rect {
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextTranslateCTM(context, self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    CGContextScaleCTM(context, 1.5, 1.5);
    
    CGPoint pointInWindow = [self.viewToMagnify convertPoint: self.touchPoint toView: [self frontWindow]];
    CGContextTranslateCTM(context, -pointInWindow.x, -pointInWindow.y);
    
    [[self frontWindow].layer renderInContext:context];
    
}


-(void)updateViewHierarchy{
    if (!self.superview) {
        [self.frontWindow addSubview:self];
    } else {
        [self.superview bringSubviewToFront:self];
    }
}


- (UIWindow *)frontWindow {
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= UIWindowLevelNormal);
        BOOL windowKeyWindow = window.isKeyWindow;
        if(windowOnMainScreen && windowIsVisible && windowLevelSupported && windowKeyWindow) {
            return window;
        }
    }
    return nil;
}
@end

