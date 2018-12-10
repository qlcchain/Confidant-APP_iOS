//
//  CTInputBoxDrawer.m
//  CDChatList
//
//  Created by chdo on 2017/12/12.
//

#import "CTInputBoxDrawer.h"
#import "CTInPutMacro.h"

@interface CTInputBoxDrawer()
{
    CGSize butIconSize;
}
@property(nonatomic, strong) NSDictionary<NSString *,UIImage *> * imageDic;
@end

@implementation CTInputBoxDrawer

+(instancetype)share{
    
    static dispatch_once_t onceToken;
    static CTInputBoxDrawer *helper;
    
    dispatch_once(&onceToken, ^{
        helper = [[CTInputBoxDrawer alloc] init];
        helper->butIconSize = CGSizeMake(30, 30);
    });
    return helper;
}
    
+(NSDictionary<NSString *,UIImage *> *)defaultImageDic{
    
    if ([CTInputBoxDrawer share].imageDic) {
        return [CTInputBoxDrawer share].imageDic;
    }
    
    UIImage *emojButtonIcon = [[CTInputBoxDrawer share] emojButtonIcon];
    UIImage *addButtonIcon = [[CTInputBoxDrawer share] addButtonIcon];
    
    [CTInputBoxDrawer share].imageDic = @{@"emojIcon":emojButtonIcon,
                                          @"addIcon": addButtonIcon};
    return [CTInputBoxDrawer share].imageDic;
}
    
-(UIImage *)emojButtonIcon{
    UIGraphicsBeginImageContextWithOptions(butIconSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    // 外圆
    CGContextSetStrokeColorWithColor(context, HexColor(0x878A91).CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextAddArc(context, butIconSize.width * 0.5, butIconSize.height * 0.5, (butIconSize.width - 2) * 0.5, 0, M_PI * 2, 0);
    CGContextStrokePath(context);

    // 左眼
    CGContextAddEllipseInRect(context, CGRectMake(8, 8, 3, 4));
    CGContextSetFillColorWithColor(context, HexColor(0x878A91).CGColor);
    
    
    // 右眼
    CGContextAddEllipseInRect(context, CGRectMake(18, 8, 3, 4));
    CGContextSetFillColorWithColor(context, HexColor(0x878A91).CGColor);
    
    CGMutablePathRef path = CGPathCreateMutable();
    // 嘴
    [self pathMoveToPoint:path point:7 pointy:16];
    [self pathAddLineToPoint:path point:23 pointy:16];
    [self pathAddArcToPoint:path x:15 y:16 rad:8 sA:0 eA:M_PI dir:0];
    CGContextClosePath(context);
    // 填充路径
    CGContextAddPath(context, path);
    // 画边框
    CGContextDrawPath(context, kCGPathFillStroke);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIImage *)addButtonIcon{
    UIGraphicsBeginImageContextWithOptions(butIconSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 外圆
    CGContextSetStrokeColorWithColor(context, HexColor(0x878A91).CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextAddArc(context, butIconSize.width * 0.5, butIconSize.height * 0.5, (butIconSize.width - 2) * 0.5, 0, M_PI * 2, 0);
    CGContextStrokePath(context);
    
    
    CGContextSetLineWidth(context, 2);
    
    //竖
    CGContextMoveToPoint(context,   15, 6);
    CGContextAddLineToPoint(context, 15, 24);
    
    // 横
    CGContextMoveToPoint(context,   6, 15);
    CGContextAddLineToPoint(context, 24, 15);
    // 画边框
    CGContextDrawPath(context, kCGPathFillStroke);
    
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
