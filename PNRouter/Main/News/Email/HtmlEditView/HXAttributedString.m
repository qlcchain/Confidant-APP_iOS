//
//  HXAttributedString.m
//  Hxdd_qa
//
//  Created by  MAC on 14-9-29.
//  Copyright (c) 2014年 华夏大地教育. All rights reserved.
//

#import "HXAttributedString.h"

@implementation NSAttributedString (HXAttributedString)

+ (instancetype)attributedStringFromHTMLData:(NSData *)data {
    
    
    NSMutableAttributedString * mutAttributedStr = [[NSMutableAttributedString alloc] initWithAttributedString:[[self alloc] initWithData:data options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:NULL error:nil]];
    
    return mutAttributedStr;
}

+ (instancetype)attributedStringFromHTMLString:(NSString *)html{
    return [self attributedStringFromHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding]];
}

+ (instancetype)attributedStringFromHTMLString:(NSString *)html WithLineSpacing:(CGFloat)lineSpacing
{
    
    NSMutableAttributedString * mutAttributedStr = [self attributedStringFromHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSRange range = NSMakeRange(0, mutAttributedStr.length);
    
    [mutAttributedStr enumerateAttribute:NSParagraphStyleAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        //
        NSMutableParagraphStyle * pss = value;
        
        if (pss) {
            
            [pss setLineSpacing:lineSpacing];
        }
        
        //NSLog(@"%@",NSStringFromRange(range));
    }];
    
    return mutAttributedStr;
}

+ (instancetype)attributedStringFromHTMLString:(NSString *)html WithLineHeightMultiple:(CGFloat)heightMultiple
{
    
    NSMutableAttributedString * mutAttributedStr = [self attributedStringFromHTMLData:[html dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSRange range = NSMakeRange(0, mutAttributedStr.length);
    
    [mutAttributedStr enumerateAttribute:NSParagraphStyleAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        //
        NSMutableParagraphStyle * pss = value;
        
        if (pss) {
            
            [pss setLineHeightMultiple:heightMultiple];
        }
        
        //NSLog(@"%@",NSStringFromRange(range));
    }];
    
    return mutAttributedStr;
}


-(NSMutableAttributedString*)attributedStringWithFontSizeMultiple:(CGFloat)multiple
{
    NSMutableAttributedString * mutStr = [[NSMutableAttributedString alloc]initWithAttributedString:self];
    
    NSRange range = NSMakeRange(0, self.length);
    
    [self enumerateAttribute:NSFontAttributeName inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange range, BOOL *stop) {
        //
        UIFont * fo = value;
        
        UIFont * newFont = [fo fontWithSize:fo.pointSize*multiple];
        
        //NSLog(@"font %f -- %f",fo.pointSize,newFont.pointSize);
        
        [mutStr addAttribute:NSFontAttributeName value:newFont range:range];
        
    }];
    
    return mutStr;
}

@end
