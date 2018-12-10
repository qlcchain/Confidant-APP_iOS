//
//  ChatImageDrawer.m
//  CDChatList
//
//  Created by chdo on 2017/12/7.
//

#import "ChatImageDrawer.h"
#import "ChatMacros.h"
#import "ChatHelpr.h"
#import "UITool.h"
/**
 
 --------------------
 |                | 5|  bubbleCornerRadius
 |                |10|  bubbleUppereight
 |                    \ bubbleAngleHeight  10 |_
 |                    / bubbleAngleWidth       6
 |                |10|  bubbleUppereight
 |                | 5|  bubbleCornerRadius
 --------------------
 
 */
@interface ChatImageDrawer()
{
    CGPathRef lpath;
    CGPathRef rpath;
    CGSize  imgSize;
    
    CGFloat bubbleCornerRadius;  // 圆角半径
    
    CGFloat bubbleUppereight; // 垂直距离
    CGFloat bubbleAngleWidth; // 尖角宽度
    CGFloat bubbleAngleHeight; // 尖角高度

}

@property(nonatomic, strong) NSMutableDictionary<NSString *,UIImage *> * imageDic;

@end
@implementation ChatImageDrawer

+(instancetype)share{
    
    static dispatch_once_t onceToken;
    static ChatImageDrawer *helper;
    
    dispatch_once(&onceToken, ^{
        helper = [[ChatImageDrawer alloc] init];
        helper->bubbleCornerRadius = 5;
        helper->bubbleUppereight = 10;
        helper->bubbleAngleWidth = ChatHelpr.share.config.bubbleShareAngleWidth;
        helper->bubbleAngleHeight = 10;
    });
    return helper;
}

+(NSMutableDictionary<NSString *,UIImage *> *)defaultImageDic{
    if ([ChatImageDrawer share].imageDic) {
        return [ChatImageDrawer share].imageDic;
    }
    NSArray<NSValue *> *insets = [[ChatImageDrawer share] insetsForImages];
    
    UIImage *leftBubble = [[ChatImageDrawer share] leftBubbleImage];
    leftBubble = [leftBubble resizableImageWithCapInsets:[insets[0] UIEdgeInsetsValue] resizingMode:UIImageResizingModeStretch];
    
    UIImage *rightBubble = [[ChatImageDrawer share] rightBubble];
    rightBubble = [rightBubble resizableImageWithCapInsets:[insets[1] UIEdgeInsetsValue] resizingMode:UIImageResizingModeStretch];
    UIImage *left_mask = [[ChatImageDrawer share] left_mask];
    left_mask = [left_mask resizableImageWithCapInsets:[insets[2] UIEdgeInsetsValue] resizingMode:UIImageResizingModeStretch];
    UIImage *right_mask = [[ChatImageDrawer share] right_mask];
    right_mask = [right_mask resizableImageWithCapInsets:[insets[3] UIEdgeInsetsValue] resizingMode:UIImageResizingModeStretch];
    
    [ChatImageDrawer share].imageDic =
    [NSMutableDictionary dictionaryWithDictionary:@{
                                                    @"left_box": leftBubble,
                                                    @"right_box": rightBubble,
                                                    @"bg_mask_right":right_mask,
                                                    @"bg_mask_left":left_mask,
                                                    @"icon_head":[[ChatImageDrawer share] icon_head],
                                                    }];
    
    return [ChatImageDrawer share].imageDic;
}

-(NSArray<NSValue *> *)insetsForImages{
    
    UIEdgeInsets bubble_left = UIEdgeInsetsMake(bubbleCornerRadius + bubbleUppereight + bubbleAngleHeight,
                                               bubbleAngleWidth + bubbleCornerRadius,
                                               bubbleCornerRadius,
                                               bubbleCornerRadius);
    UIEdgeInsets bubble_right = UIEdgeInsetsMake(bubbleCornerRadius + bubbleUppereight + bubbleAngleHeight,
                                               bubbleCornerRadius,
                                               bubbleCornerRadius,
                                               bubbleAngleWidth + bubbleCornerRadius);
    UIEdgeInsets mask_right = bubble_left;
    UIEdgeInsets mask_left = bubble_right;
    
    return @[[NSValue valueWithUIEdgeInsets:bubble_left],
             [NSValue valueWithUIEdgeInsets:bubble_right],
             [NSValue valueWithUIEdgeInsets:mask_right],
             [NSValue valueWithUIEdgeInsets:mask_left]];
}

#pragma mark 气泡图片
-(UIImage *)leftBubbleImage{
    
    // 描绘路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat gap = bubbleUppereight;
    CGFloat leftX = bubbleAngleWidth;
    [self pathMoveToPoint:   path point: leftX pointy: bubbleCornerRadius]; // 1
    [self pathAddLineToPoint:path point: leftX pointy: bubbleCornerRadius + bubbleUppereight]; // 2
    
    
    {// 尖角
        [self pathAddLineToPoint:path point:1 pointy:bubbleCornerRadius + bubbleUppereight + 3]; // 3
        CGPathAddQuadCurveToPoint(path, NULL, 0, bubbleCornerRadius + bubbleUppereight + 5, // 4
                              1, bubbleCornerRadius + bubbleUppereight + 6);
    }
    
    [self pathAddLineToPoint:path point: leftX pointy: bubbleCornerRadius + bubbleUppereight + bubbleAngleHeight];  // 5
    CGFloat y6 = bubbleCornerRadius + bubbleUppereight + bubbleAngleHeight + gap;
    [self pathAddLineToPoint:path point: leftX pointy: y6];  // 6
    [self pathAddArcToPoint:path x: leftX + bubbleCornerRadius y: y6 rad:bubbleCornerRadius sA:-M_PI eA:-(M_PI + M_PI_2) dir:1]; // 7
    CGFloat x8 = bubbleAngleWidth + bubbleCornerRadius + gap;
    [self pathAddLineToPoint:path point:x8 pointy:y6 + bubbleCornerRadius]; // 8
    [self pathAddArcToPoint:path x:x8 y:y6 rad:bubbleCornerRadius sA:-(M_PI + M_PI_2) eA:0 dir:1]; // 9
    CGFloat rightX = bubbleAngleWidth + bubbleCornerRadius * 2 + gap;
    [self pathAddLineToPoint:path point: rightX pointy: bubbleCornerRadius]; // 10
    [self pathAddArcToPoint:path x:x8 y:bubbleCornerRadius rad:bubbleCornerRadius sA:0 eA:-M_PI_2 dir:1]; //11
    [self pathAddLineToPoint:path point:leftX + bubbleCornerRadius pointy:0]; // 12
    [self pathAddArcToPoint:path x:leftX + bubbleCornerRadius y:bubbleCornerRadius rad:bubbleCornerRadius sA:-M_PI_2 eA:-M_PI dir:1]; //1
    
    // 图片大小
    CGSize size = CGSizeMake(bubbleAngleWidth + bubbleCornerRadius + gap + bubbleCornerRadius,
                             bubbleCornerRadius + bubbleUppereight + bubbleAngleHeight + gap + bubbleCornerRadius);
    
    // 准备绘图
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 填充路径
    CGContextAddPath(context, path);
    
    // 设置填充色
    CGContextSetFillColorWithColor(context, ChatHelpr.share.config.msgTextContentBackGroundColor_left.CGColor);//填充色
    
    // 设置边框
    CGContextSetStrokeColorWithColor(context, CDHexColor(0xD1CECE).CGColor);
    CGContextSetLineWidth(context, 0.5);
    // 画边框
    CGContextDrawPath(context, kCGPathFillStroke);
    
    // 获取图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 保存图片大小
    imgSize = size;
    lpath = path;
    CGAffineTransform trans = CGAffineTransformTranslate(CGAffineTransformMakeRotation(-M_PI), -size.width, -size.height);
    CGPathRef newPath = CGPathCreateCopyByTransformingPath(path, &trans);
    rpath = newPath;
    
    
    return image;
}


-(UIImage*)rightBubble{
    
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddPath(context, rpath);
    
    // 设置填充色
    CGContextSetFillColorWithColor(context, ChatHelpr.share.config.msgTextContentBackGroundColor_right.CGColor);//填充色
    
    // 设置边框
    CGContextSetStrokeColorWithColor(context, CDHexColor(0xD1CECE).CGColor);
    CGContextSetLineWidth(context, 0.5);
    // 画边框
    CGContextDrawPath(context, kCGPathFillStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


-(UIImage*)left_mask{
    
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 背景
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
    CGContextAddPath(context, [path CGPath]);
    
    // 设置填充色
    CGContextSetFillColorWithColor(context, ChatHelpr.share.config.msgBackGroundColor.CGColor);//填充色
    CGContextFillPath(context);
    
    // 绘制透明区域
    CGContextSetStrokeColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextAddPath(context, lpath);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


-(UIImage*)right_mask{
    
    UIGraphicsBeginImageContextWithOptions(imgSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 背景
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
    CGContextAddPath(context, [path CGPath]);
    
    // 设置填充色
    CGContextSetFillColorWithColor(context, ChatHelpr.share.config.msgBackGroundColor.CGColor);//填充色
    CGContextFillPath(context);
    
    // 绘制透明区域
    CGContextSetStrokeColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
    CGContextSetBlendMode(context, kCGBlendModeClear);
    CGContextAddPath(context, rpath);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


-(UIImage *)icon_head{
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(40, 40), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextAddRect(context, CGRectMake(0, 0, 40, 40));
    CGContextSetFillColorWithColor(context, CDHexColor(0xE8EEF5).CGColor);//填充色
    CGContextFillPath(context);
    
    CGContextAddArc(context, 20, 10, 8, 0, M_PI * 2, 0);
    CGContextSetFillColorWithColor(context, CDHexColor(0xC8CEDB).CGColor);//填充色
    CGContextFillPath(context);
    
    CGContextAddEllipseInRect(context, CGRectMake(5, 18, 30, 16));
    CGContextSetFillColorWithColor(context, CDHexColor(0xC8CEDB).CGColor);//填充色
    CGContextFillPath(context);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//// path
-(void)pathMoveToPoint:(CGMutablePathRef)path point:(CGFloat)x pointy: (CGFloat) y{
    CGPathMoveToPoint(path, NULL, x, y);
}

-(void)pathAddLineToPoint:(CGMutablePathRef)path point:(CGFloat)x pointy: (CGFloat) y{
    CGPathAddLineToPoint(path, NULL, x, y);
}

-(void)pathAddArcToPoint:(CGMutablePathRef)path x:(CGFloat)x y:(CGFloat)y rad:(CGFloat)radius sA:(CGFloat)startAngle eA:(CGFloat)endAngle dir:(int)clockWise{
    CGPathAddArc(path, NULL, x, y, radius, startAngle, endAngle, clockWise);
}


@end
