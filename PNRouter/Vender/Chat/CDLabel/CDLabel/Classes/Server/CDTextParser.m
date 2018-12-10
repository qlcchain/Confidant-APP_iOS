//
//  CDTextParser.m
//  CDLabel
//
//  Created by chdo on 2017/12/1.
//

#import "CDTextParser.h"
#import <CoreText/CoreText.h>
#import "CDLabelMacro.h"
#import "CTHelper.h"

@implementation CDTextParser

#pragma mark  和表情相关

+(void)matchEmoj:(NSMutableAttributedString *)str configuration:(CTDataConfig)config{

    // 处理表情   将所有[呵呵]换成占位字符  并计算图片位置
    NSRegularExpression *regEmoji = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\[\\]]+?\\]"
                                                                              options:kNilOptions error:NULL];
    //
    NSArray<NSTextCheckingResult *> *emoticonResults = [regEmoji matchesInString:str.string
                                                                         options:kNilOptions
                                                                           range:NSMakeRange(0, str.string.length)];
    NSInteger shift = 0;

    UIFont *font = [UIFont systemFontOfSize:config.textSize];
    for (NSTextCheckingResult *emo in emoticonResults) {
        if (emo.range.location == NSNotFound && emo.range.length <= 1) continue;
        NSRange range = emo.range;
        range.location += shift;
        NSString *oldStr = [str attributedSubstringFromRange:range].string;
        BOOL ifContainEmoji = [CTHelper.share.emojDic.allKeys containsObject:oldStr];
        if (ifContainEmoji) {
            NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
            attachment.image = CTHelper.share.emojDic[oldStr];
            attachment.bounds = CGRectMake(0, font.descender, font.lineHeight, font.lineHeight);
            
            NSAttributedString *imageAttr = [NSMutableAttributedString attributedStringWithAttachment:attachment];
            [str replaceCharactersInRange:range withAttributedString:imageAttr];
            shift += imageAttr.length - oldStr.length;
        }
    }
}

+(NSMutableArray *)matchImage:(NSMutableAttributedString *)str configuration:(CTDataConfig)config{
    
    // 处理表情   将所有[呵呵]换成占位字符  并计算图片位置
    NSMutableArray *imageDataArrr = [NSMutableArray array];
    NSRegularExpression *regEmoji = [NSRegularExpression regularExpressionWithPattern:@"\\[[^\\[\\]]+?\\]"
                                                                              options:kNilOptions error:NULL];
    //
    
    
    NSArray<NSTextCheckingResult *> *emoticonResults = [regEmoji matchesInString:str.string
                                                                         options:kNilOptions
                                                                           range:NSMakeRange(0, str.string.length)];
    NSInteger shift = 0;
    for (NSTextCheckingResult *emo in emoticonResults) {
        
        if (emo.range.location == NSNotFound && emo.range.length <= 1) continue;
        NSRange range = emo.range;
        range.location += shift;
        NSString *oldStr = [str attributedSubstringFromRange:range].string;
        BOOL ifContainEmoji = [CTHelper.share.emojDic.allKeys containsObject:oldStr];
        if (ifContainEmoji) {
            NSMutableAttributedString *newStr = [self imagePlaceHolderStrFromConfiguration:config];
            [str replaceCharactersInRange:range withAttributedString:newStr];
            shift += newStr.length - oldStr.length;
            
            // 创建对应的图片
            CTImageData *imageData = [[CTImageData alloc] init];
            imageData.position = range.location;
            imageData.name = oldStr;
            imageData.range = range;
            [imageDataArrr addObject:imageData];
        }
    }
    return imageDataArrr;
}

static CGFloat ascentfunc(void *ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"ascent"] floatValue];
}

static CGFloat dscentfunc(void *ref){
    return [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"descent"] floatValue];
}

static CGFloat widthfunc(void *ref){
    CGFloat ascent = [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"ascent"] floatValue];
    CGFloat descnt = [(NSNumber*)[(__bridge NSDictionary*)ref objectForKey:@"descent"] floatValue];
    return ascent - descnt;
}

static void deallocfunc(void *ref){
    NSDictionary *self = (__bridge_transfer NSDictionary *)(ref);
    self = nil;
}


+(NSMutableAttributedString *)imagePlaceHolderStrFromConfiguration:(CTDataConfig)config{
    
    
    UIFont *font = [UIFont systemFontOfSize:config.textSize];
    
    NSDictionary *imgInfoDic = @{@"ascent":@(font.ascender),
                                 @"descent":@(font.descender),
                                 @"width":@(font.pointSize)
                                 };
    // 字形参数
    CTRunDelegateCallbacks callbacks;
    
    memset(&callbacks, 0, sizeof(CTRunDelegateCallbacks));
    callbacks.version = kCTRunDelegateCurrentVersion;
    callbacks.getAscent = ascentfunc;   // 顶边到基线
    callbacks.getDescent = dscentfunc; // 底边到基线
    callbacks.getWidth = widthfunc;     //
    callbacks.dealloc = deallocfunc;
    CTRunDelegateRef delegate = CTRunDelegateCreate(&callbacks, (__bridge_retained void *)(imgInfoDic));
    
    // 使用0xFFFC作为空白的占位符
    unichar objectReplacementChar = 0xFFFC;
    NSString * content = [NSString stringWithCharacters:&objectReplacementChar length:1];
    
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    para.lineSpacing = config.lineSpace;
    para.lineBreakMode = config.lineBreakMode;
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                      NSFontAttributeName : font,
                                                                                      NSBackgroundColorAttributeName:[UIColor colorWithCGColor:config.backGroundColor],
                                                                                      NSParagraphStyleAttributeName:para
                                                                                      }];
    NSMutableAttributedString * space = [[NSMutableAttributedString alloc] initWithString:content
                                                                               attributes:attributes];
    
    CFAttributedStringSetAttribute((CFMutableAttributedStringRef)space, CFRangeMake(0, 1),
                                   kCTRunDelegateAttributeName, delegate);
    CFRelease(delegate);
    
    return space;
}

#pragma mark 匹配链接


+(NSMutableArray *)matchLink:(NSMutableAttributedString *)str configuration:(CTDataConfig)config currentMatch:(NSMutableArray<CTLinkData *> *)matchArr{
    NSRegularExpression *regUrl = [NSRegularExpression regularExpressionWithPattern:@"((((((H|h){1}(T|t){2}(P|p){1})(S|s)?|ftp)://)(([a-zA-Z0-9_-]+\\.?)+|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3})|((([a-zA-Z_-]+\\.)|[\\d]+\\.)+[a-zA-Z0-9#_-]+))|((((H|h){1}(T|t){2}(P|p){1})(S|s)?|ftp)://)?(((([a-zA-Z_-]+\\.)|[\\d]+\\.)+[a-zA-Z0-9#_-]+)|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]+)?)(:[0-9]+)?(/[a-zA-Z0-9\\&%_\\./-~-#]*)?)" options:kNilOptions error:NULL];
    return [self matchFixStr:str configuration:config reg:regUrl currentMatch:matchArr];
}


+(NSMutableArray *)matchEmail:(NSMutableAttributedString *)str configuration:(CTDataConfig)config currentMatch:(NSMutableArray<CTLinkData *> *)matchArr{
    NSRegularExpression *regEmail = [NSRegularExpression regularExpressionWithPattern:@"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}" options:kNilOptions error:NULL];
    return [self matchFixStr:str configuration:config reg:regEmail currentMatch:matchArr];
}

+(NSMutableArray *)matchPhone:(NSMutableAttributedString *)str configuration:(CTDataConfig)config currentMatch:(NSMutableArray<CTLinkData *> *)matchArr{
    NSRegularExpression *regPhone = [NSRegularExpression regularExpressionWithPattern:@"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[0-9]+\\d{5,10}|\\d{8}|\\d{7}\\d{6}" options:kNilOptions error:NULL];
    return [self matchFixStr:str configuration:config reg:regPhone currentMatch:matchArr];
}

+(NSMutableArray *)matchFixStr:(NSMutableAttributedString *)str configuration:(CTDataConfig)config reg:(NSRegularExpression *)regEx currentMatch:(NSMutableArray<CTLinkData *> *)matchArr{
    
    NSArray<NSTextCheckingResult *> *regResults = [regEx matchesInString: str.string
                                                                  options: kNilOptions
                                                                    range: NSMakeRange(0, str.string.length)];
    NSMutableArray *linkArr = [NSMutableArray array];
    for (int i = 0; i < regResults.count; i++) {
        NSTextCheckingResult *rest = regResults[i];
        if (rest.range.location == NSNotFound && rest.range.length <= 1) continue;
        NSRange range = rest.range;
        
        // 这里还需要做 rang重复检查
        BOOL willContinue = NO;
        for (CTLinkData *data in matchArr) {
            if (!NSEqualRanges(NSIntersectionRange(data.range, range), NSMakeRange(0, 0))){
                willContinue = YES;
                break;
            }
        }
        if (willContinue) {
            continue;
        }
        
        NSString *targetStr = [str.string substringWithRange:range];
        
        UIFont *font = [UIFont systemFontOfSize:config.textSize];
        NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
        para.lineBreakMode = config.lineBreakMode;
        para.lineSpacing = config.lineSpace;
        
        UIColor *linkColor = [UIColor colorWithCGColor:config.clickStrColor];
        
        NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                          NSForegroundColorAttributeName: linkColor,
                                                                                          NSFontAttributeName : font,
                                                                                          NSParagraphStyleAttributeName:para
                                                                                          }];
        NSMutableAttributedString *targetString = [[NSMutableAttributedString alloc] initWithString:targetStr
                                                                                         attributes:attributes];
        [str replaceCharactersInRange:range withAttributedString:targetString];
        //        构建链接对象
        CTLinkData *linkData = [[CTLinkData alloc] init];
        linkData.title = targetStr;
        linkData.url = targetStr;
        linkData.range = range;
        [linkArr addObject:linkData];
    }
    return linkArr;
}


@end
