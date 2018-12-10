//
//  CoreTextUtils.h
//  CoreTextDemo
//
//  Created by TangQiao on 13-12-22.
//  Copyright (c) 2013年 TangQiao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTData.h"

typedef struct {
    CFIndex index;
    CGRect rect;
} CTLinkConfig;

@interface CoreTextUtils : NSObject

+ (CTLinkData *)touchLinkInView:(UIView *)view atPoint:(CGPoint)point data:(CTData *)data;

+ (CTLinkConfig)touchContentOffsetInView:(UIView *)view atPoint:(CGPoint)point data:(CTData *)data;

@end
