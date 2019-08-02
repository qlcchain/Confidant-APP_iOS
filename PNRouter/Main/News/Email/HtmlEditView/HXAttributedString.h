//
//  HXAttributedString.h
//  Hxdd_qa
//
//  Created by  MAC on 14-9-29.
//  Copyright (c) 2014年 华夏大地教育. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface NSAttributedString (HXAttributedString)

/**
 *  Creates an attributed string from HTML data. Assumes `NSUTF8StringEncoding`.
 *
 *  @param data Data to be processed.
 *
 *  @return Returns a new instance of `NSAttributedString` or nil if given data was invalid.
 */
+ (instancetype)attributedStringFromHTMLData:(NSData *)data;

/**
 *  Creates an attributed string from HTML string with attributes.
 *
 *  @param html A string containing HTML.
 *
 *  @return Returns a new instance of `NSAttributedString` or nil if given data was invalid.
 */
+ (instancetype)attributedStringFromHTMLString:(NSString *)html;

/**
 *  @author wangxuanao, 15-02-03 13:02:02
 *
 *  将html字符串转换为NSAttributedString
 *
 *  @param html
 *  @param lineSpacing 设置行间距
 *
 *  @return Returns a new instance of `NSAttributedString` or nil if given data was invalid.
 */
+ (instancetype)attributedStringFromHTMLString:(NSString *)html WithLineSpacing:(CGFloat)lineSpacing;

/**
 *  @author wangxuanao, 15-02-13 11:02:17
 *
 *  将html字符串转换为NSAttributedString
 *
 *  @param html
 *  @param heightMultiple 行间距缩放系数
 *
 *  @return Returns a new instance of `NSAttributedString` or nil if given data was invalid.
 */
+ (instancetype)attributedStringFromHTMLString:(NSString *)html WithLineHeightMultiple:(CGFloat)heightMultiple;

/**
 *  @author wangxuanao, 15-02-03 13:02:49
 *
 *  缩放字体大小
 *
 *  @param multiple 缩放比例
 *
 *  @return Returns a new instance of `NSMutableAttributedString`
 */
-(NSMutableAttributedString*)attributedStringWithFontSizeMultiple:(CGFloat)multiple;
@end
