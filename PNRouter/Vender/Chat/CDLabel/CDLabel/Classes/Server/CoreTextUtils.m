//
//  CoreTextUtils.m
//  CoreTextDemo
//
//  Created by TangQiao on 13-12-22.
//  Copyright (c) 2013年 TangQiao. All rights reserved.
//

#import "CoreTextUtils.h"



@implementation CoreTextUtils

// 检测点击位置是否在链接上
+ (CTLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point data:(CTData *)data {
    CTLinkConfig config = [self touchContentOffsetInView:view atPoint:point data:data];
    if (config.index == -1) {
        return nil;
    }
    CTLinkData * foundLink = [self linkAtIndex:config.index linkArray:data.linkArray];
    foundLink.rect = config.rect;
    return foundLink;
}

// 将点击的位置转换成字符串的偏移量，如果没有找到，则返回-1
+ (CTLinkConfig)touchContentOffsetInView:(UIView *)view atPoint:(CGPoint)point data:(CTData *)data {
    CTFrameRef textFrame = data.ctFrame;
    CFArrayRef lines = CTFrameGetLines(textFrame);
    if (!lines) {
        CTLinkConfig config;
        config.index = -1;
        return config;
    }
    CFIndex count = CFArrayGetCount(lines);

    // 获得每一行的origin坐标
    CGPoint origins[count];
    CTFrameGetLineOrigins(textFrame, CFRangeMake(0,0), origins);

    // 翻转坐标系
    CGAffineTransform transform =  CGAffineTransformMakeTranslation(0, view.bounds.size.height);
    transform = CGAffineTransformScale(transform, 1.f, -1.f);

    CFIndex idx = -1;
    CGRect rect = CGRectNull;
    CGRect maxRect = CGRectZero;
    for (int i = 0; i < count; i++) {
        CGPoint linePoint = origins[i];
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        // 获得每一行的CGRect信息
        CGRect flippedRect = [self getLineBounds:line point:linePoint];
        CGRect lineRect = CGRectApplyAffineTransform(flippedRect, transform);
        
        maxRect.origin = lineRect.origin;
        if (lineRect.size.width > maxRect.size.width) {
            maxRect = lineRect;
        }
        if (CGRectContainsPoint(lineRect, point)) {
            // 将点击的坐标转换成相对于当前行的坐标
            CGPoint relativePoint = CGPointMake(point.x-CGRectGetMinX(lineRect),
                                                point.y-CGRectGetMinY(lineRect));
            // 获得当前点击坐标对应的字符串偏移
            idx = CTLineGetStringIndexForPosition(line, relativePoint);
            rect = lineRect;
            break;
        } else {
            if (i == count - 1) {
                if (CGRectContainsPoint(maxRect, point)) {
                    idx = data.ctFrameLength;
                    rect = lineRect;
                }
            }
        }
    }
    CTLinkConfig config;
    config.index = idx;
    config.rect = rect;
    return config;
}

+ (CGRect)getLineBounds:(CTLineRef)line point:(CGPoint)point {
    CGFloat ascent = 0.0f;
    CGFloat descent = 0.0f;
    CGFloat leading = 0.0f;
    CGFloat width = (CGFloat)CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
    CGFloat height = fabs(ascent) + fabs(descent);
    return CGRectMake(point.x, point.y - descent, width, height);
}

+ (CTLinkData *)linkAtIndex:(CFIndex)i linkArray:(NSArray *)linkArray {
    CTLinkData *link = nil;
    for (CTLinkData *data in linkArray) {
        if (NSLocationInRange(i, data.range)) {
            link = data;
            break;
        }
    }
    return link;
}

@end
