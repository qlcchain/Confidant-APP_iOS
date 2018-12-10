//
//  UITool.m
//  Utility
//
//  Created by chdo on 2017/12/8.
//

#import "UITool.h"

double CDDeviceSystemVersion(void) {
    static double version;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        version = [UIDevice currentDevice].systemVersion.doubleValue;
    });
    return version;
}


CGSize CDScreenSize(void) {
    
    static CGSize size;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        size = [UIScreen mainScreen].bounds.size;
        if (size.height <= size.width) {
            CGFloat tmp = size.height;
            size.height = size.width;
            size.width = tmp;
        }
    });
    return size;
}


UIColor *CDHexColor(int hexColor){
    UIColor *color = [UIColor colorWithRed:((float)((hexColor & 0xFF0000) >> 16))/255.0 green:((float)((hexColor & 0xFF00) >> 8))/255.0 blue:((float)(hexColor & 0xFF))/255.0 alpha:1];
    return color;
}


CGFloat cd_NaviH(void){
    return 44 + [[UIApplication sharedApplication] statusBarFrame].size.height;
}

CGFloat cd_ScreenW(void){
    return [UIScreen mainScreen].bounds.size.width;
}
CGFloat cd_ScreenH(void){
    return [UIScreen mainScreen].bounds.size.height;
}

CGFloat cd_StatusH(void){
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

@implementation UIView (CD)


- (UIViewController *)cd_viewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (CGFloat)cd_left {
    return self.frame.origin.x;
}

- (void)setCd_left:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)cd_top {
    return self.frame.origin.y;
}

- (void)setCd_top:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)cd_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setCd_right:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)cd_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setCd_bottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)cd_width {
    return self.frame.size.width;
}

- (void)setCd_width:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)cd_height {
    return self.frame.size.height;
}

- (void)setCd_height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGSize)cd_size {
    return self.frame.size;
}

- (void)setCd_size:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}


@end






