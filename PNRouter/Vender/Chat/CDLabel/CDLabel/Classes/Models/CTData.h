//
//  CDCTData.h
//  CDLabel
//
//  Created by chdo on 2017/12/1.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import <UIKit/UIKit.h>

typedef struct {
    CGFloat textSize;   // 字号
    CGFloat lineSpace;  // 行间距
    CGColorRef textColor;  // 文本颜色
    CGColorRef clickStrColor;  // 可点击文本颜色
    CGColorRef backGroundColor;
    CGColorRef hilightColor;// 高亮文本颜色
    NSLineBreakMode lineBreakMode;
    BOOL willUpdateFrame; // 是否在计算完成后更新frame
    BOOL matchEmoji;
    BOOL matchLink;
    BOOL matchPhone;
    BOOL matchEmail;
    BOOL isOwner;
} CTDataConfig;


NSString *CTDataConfigIdentity(CTDataConfig config);

/**
 图片文本对象
 */
@interface CTImageData : NSObject
@property (strong, nonatomic) NSString * name; // 图片名称
@property (nonatomic) NSUInteger position;            // 图片在字符中的位置
@property (assign, nonatomic) NSRange range;
// 此坐标是 CoreText 的坐标系，而不是UIKit的坐标系
@property (nonatomic) CGRect imagePosition;
@end


@interface CTLinkData : NSObject
@property (strong, nonatomic) NSString * title;
@property (strong, nonatomic) NSString * url;
@property (assign, nonatomic) NSRange range;
@property (assign, nonatomic) CGRect rect;
@end




/**
 绘制文本对象
 */
@interface CTData : NSObject


@property (strong, nonatomic) NSString *msgString;
@property (strong, nonatomic) NSString *msgAttributeString;

/**
 绘制在label上的
 */
@property (assign, nonatomic) CTFrameRef ctFrame;
@property (assign, nonatomic) NSUInteger ctFrameLength;
@property(nonatomic, strong) UIImage *contents;

@property (assign, nonatomic) CGFloat width;   // 文本宽度
@property (assign, nonatomic) CGFloat height;  // 文本高度
@property (assign, nonatomic) CTDataConfig config;
@property (strong, nonatomic) NSArray<CTImageData *> *imageArray;
@property (strong, nonatomic) NSArray *linkArray;
@property (strong, nonatomic) NSAttributedString *content;

+(CTData *)dataWithStr:(NSString *)msgString
     containerWithSize:(CGSize)size;

+(CTDataConfig)defaultConfig;

/**
 构建plain文本对象,文本属性通过config配置

 @param msgString 纯文本
 @param size 渲染范围 定宽  不定高
 @param config 文本自定义配置
 @return 富文本对象
 */
+(CTData *)dataWithStr:(NSString *)msgString
     containerWithSize: (CGSize)size
         configuration:(CTDataConfig)config;


/**
 构建富文本对象

 @param attString 富文本
 @param size size description
 @return return value description
 */
+(CTData *)dataWithAttriStr:(NSAttributedString *)attString
          containerWithSize:(CGSize)size;
@end
