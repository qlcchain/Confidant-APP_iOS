//
//  CDCTData.m
//  CDLabel
//
//  Created by chdo on 2017/12/1.
//

#import "CTData.h"
#import "CDTextParser.h"
#import "CDLabelMacro.h"
#import "CTHelper.h"

NSString *CTDataConfigIdentity(CTDataConfig config){
    
    NSUInteger num = CGColorGetNumberOfComponents(config.textColor);
    const CGFloat *colorComponents = CGColorGetComponents(config.textColor);
    
    NSMutableString *str = [NSMutableString string];
    for (int i = 0; i < num; ++i) {
        [str appendFormat:@"%.3f",colorComponents[i]];
    }
    return [str copy];
}


@implementation CTImageData
@end

@implementation CTLinkData
@end

@implementation CTData


+(CTDataConfig)defaultConfig{
    CTDataConfig config;
    config.textColor = [UIColor blackColor].CGColor;
    config.hilightColor = [UIColor lightGrayColor].CGColor;
    config.backGroundColor = [UIColor clearColor].CGColor;
    config.clickStrColor = [UIColor blueColor].CGColor;
    config.lineSpace = 2;
    config.textSize = 16;
    config.lineBreakMode = NSLineBreakByWordWrapping;
    config.willUpdateFrame = YES;
    config.matchLink = YES;
    config.matchEmail = YES;
    config.matchEmoji = YES;
    config.matchPhone = YES;
    return config;
}

+(CTData *)dataWithStr:(NSString *)msgString
     containerWithSize: (CGSize)size{
    return [self dataWithStr:msgString containerWithSize:size configuration:[self defaultConfig]];
}

+(CTData *)dataWithStr:(NSString *)msgString containerWithSize:(CGSize)size configuration:(CTDataConfig)config{
    
    CTData *data = [[CTData alloc] init];
    data.config = config;
    NSString *originStr = msgString ? [msgString copy] : @"";
    
    originStr = [originStr stringByReplacingOccurrencesOfString:@"</span>" withString:@""];
    originStr = [originStr stringByReplacingOccurrencesOfString:@"<br/>" withString:@"\n"];
    originStr = [originStr stringByReplacingOccurrencesOfString:@"\\r" withString:@"\n"];
    originStr = [originStr stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    originStr = [originStr stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    
    NSRegularExpression *replaceReg = [NSRegularExpression regularExpressionWithPattern:@"<(?!a)(?!/a).*?>" options:0 error:nil];
    NSString *cleanStr = [replaceReg stringByReplacingMatchesInString:originStr options:0 range: NSMakeRange(0, originStr.length) withTemplate:@""];
    data.msgString = cleanStr;
    
    // 构建富文本
    UIFont *font = [UIFont systemFontOfSize:config.textSize];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = config.lineSpace;
    paragraphStyle.lineBreakMode = config.lineBreakMode;
    
    NSDictionary *dic = @{
                          NSFontAttributeName: font,
                          NSForegroundColorAttributeName: [UIColor colorWithCGColor:config.textColor],
                          NSBackgroundColorAttributeName:[UIColor colorWithCGColor:config.backGroundColor],
                          NSParagraphStyleAttributeName: paragraphStyle
                          };
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:data.msgString attributes:dic];
    
    
    /*
     ===========================================================================
     各种匹配
     ===========================================================================
     */
    
    NSMutableArray <CTImageData *>*imageDataArr = [NSMutableArray array];
    if (config.matchEmoji) {
        // 匹配图片(主要是表情) 并返回图片
        imageDataArr = [CDTextParser matchImage:attString configuration:config];
        
    }
    
    //
    NSMutableArray <CTLinkData *> *linkDataArr = [NSMutableArray array];
    if (config.matchEmail) {
        // 匹配邮箱
        [linkDataArr addObjectsFromArray:[CDTextParser matchEmail:attString configuration:config currentMatch:linkDataArr]];
    }
    if (config.matchLink) {
        // 匹配链接
        [linkDataArr addObjectsFromArray:[CDTextParser matchLink:attString configuration:config currentMatch:linkDataArr]];
    }
    
    if (config.matchPhone) {
        // 匹配号码
        [linkDataArr addObjectsFromArray:[CDTextParser matchPhone:attString configuration:config currentMatch:linkDataArr]];
    }
    
    /*
     ===========================================================================
     构建CTFrame
     ===========================================================================
     */
    
    // 创建framesetter
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
    // 设置绘制范围
    // -- 计算内容范围
    CGSize caSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,attString.length), nil, size, nil);
    // -- 创建显示范围
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, caSize.width, caSize.height), NULL);
    // 创建显示frame
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                CFRangeMake(0, [attString length]), path, NULL);
    
    CFRelease(framesetter);
    CFRelease(path);
    
    
    //渲染展示内容
    UIGraphicsBeginImageContextWithOptions(caSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, caSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CTFrameDraw(frame, context);
    
    data.ctFrameLength = [attString length];
    data.width = caSize.width;
    data.height = caSize.height;
    data.ctFrame = frame;
    data.imageArray = imageDataArr;
    data.linkArray = linkDataArr;
    data.content = attString;
    
    for (CTImageData * imageData in data.imageArray) {
        UIImage *image = CTHelper.share.emojDic[imageData.name];
        if (image) {
            CGContextDrawImage(context, imageData.imagePosition, image.CGImage);
        }
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    data.contents = image;
    
    return data;
}

+(CTData *)dataWithAttriStr:(NSAttributedString *)attString containerWithSize:(CGSize)size
{
    CTData *data = [[CTData alloc] init];
    /*
     ===========================================================================
     构建CTFrame
     ===========================================================================
     */
    // 创建framesetter
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
    // 设置绘制范围
    // -- 计算内容范围
    CGSize caSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0,attString.length), nil, size, nil);
    // -- 创建显示范围
    CGPathRef path = CGPathCreateWithRect(CGRectMake(0, 0, caSize.width, caSize.height), NULL);
    // 创建显示frame
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter,
                                                CFRangeMake(0, [attString length]), path, NULL);
    
    CFRelease(framesetter);
    CFRelease(path);
    
    //渲染展示内容
    UIGraphicsBeginImageContextWithOptions(caSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, caSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CTFrameDraw(frame, context);
    
    data.ctFrameLength = [attString length];
    data.width = caSize.width;
    data.height = caSize.height;
    data.ctFrame = frame;
    
//    [NSMutableAttributedString alloc] initWithString:attString.string attributes:attString.
    data.content = attString;
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    data.contents = image;
    
    return data;
}


//-(NSAttributedString *)content{
//    if (_content) {
//        return _content;
//    }
//
//    // 构建富文本
//    UIFont *font = [UIFont systemFontOfSize:_config.textSize];
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.lineSpacing = 0;
//    paragraphStyle.lineBreakMode = _config.lineBreakMode;
//
//    NSDictionary *dic = @{
//                          NSFontAttributeName: font,
//                          NSForegroundColorAttributeName: [UIColor colorWithCGColor:_config.textColor],
//                          NSBackgroundColorAttributeName:[UIColor colorWithCGColor:_config.backGroundColor],
//                          NSParagraphStyleAttributeName: paragraphStyle
//                          };
//
//    _content = [[NSMutableAttributedString alloc] initWithString:_msgString attributes:dic];
//    [CDTextParser matchEmoj:_content configuration:_config];
//
//    return _content;
//}

- (void)setImageArray:(NSArray *)imageArray {
    _imageArray = imageArray;
    [self fillImagePosition];
}


// 计算图片位置
- (void)fillImagePosition {
    
    if (self.imageArray.count == 0) {
        return;
    }
    
    // CTLineRef
    NSArray *lines = (NSArray *)CTFrameGetLines(self.ctFrame);
    
    // 总共几行文本
    NSUInteger lineCount = [lines count];
    
    // 每行的原点坐标
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(self.ctFrame, CFRangeMake(0, 0), lineOrigins);
    
    int imgIndex = 0;
    CTImageData * imageData = self.imageArray[0];
    
    for (int i = 0; i < lineCount; ++i) {
        if (imageData == nil) {
            // 没有图片需要计算，则结束
            break;
        }
        CTLineRef line = (__bridge CTLineRef)lines[i];
        NSArray * runObjArray = (NSArray *)CTLineGetGlyphRuns(line);
        for (id runObj in runObjArray) {
            CTRunRef run = (__bridge CTRunRef)runObj;
            NSDictionary *runAttributes = (NSDictionary *)CTRunGetAttributes(run);
            CTRunDelegateRef delegate = (__bridge CTRunDelegateRef)[runAttributes valueForKey:(id)kCTRunDelegateAttributeName];
            // 不是图片
            if (delegate == nil) {
                continue;
            }
            
            NSDictionary * metaDic = CTRunDelegateGetRefCon(delegate);
            if (![metaDic isKindOfClass:[NSDictionary class]]) {
                continue;
            }
            
            CGRect runBounds;
            CGFloat ascent;
            CGFloat descent;
            CGFloat leading;
            // 字形
            runBounds.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &ascent, &descent, &leading);
            runBounds.size.height = ascent - descent;
            CGFloat xOffset = CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL);
            runBounds.origin.x = lineOrigins[i].x + xOffset;
            runBounds.origin.y = lineOrigins[i].y;
            runBounds.origin.y += descent;
            
            //
            CGPathRef pathRef = CTFrameGetPath(self.ctFrame);
            
            //
            CGRect colRect = CGPathGetBoundingBox(pathRef);
            // 最终图片位置
            CGRect delegateBounds = CGRectOffset(runBounds, colRect.origin.x, colRect.origin.y);
            
            imageData.imagePosition = delegateBounds;
            
            imgIndex++;
            if (imgIndex == self.imageArray.count) {
                imageData = nil;
                break;
            } else {
                imageData = self.imageArray[imgIndex];
            }
        }
    }
}

@end
