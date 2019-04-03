//
//  CTMoreKeyBoard.m
//  CDChatList
//
//  Created by chdo on 2017/12/15.
//

#import "CTMoreKeyBoard.h"
#import "CTInputConfiguration.h"
#import "CTInPutMacro.h"
@interface MoreKeyBoardButton: UIButton

@end

@implementation MoreKeyBoardButton
//- (CGRect)titleRectForContentRect:(CGRect)contentRect{
//    CGRect newRect = CGRectMake(0,
//                                contentRect.size.height - contentRect.size.height * 0.5,
//                                contentRect.size.width,
//                                contentRect.size.height * 0.5);
//    return newRect;
//}
//- (CGRect)imageRectForContentRect:(CGRect)contentRect{
//    CGRect newRect = CGRectInset(contentRect, contentRect.size.width * 0.2, contentRect.size.width * 0.2);
//    newRect.size.height = newRect.size.width;
//    return newRect;
//}

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGRect newRect = CGRectMake(0,
                                contentRect.size.height - 29,
                                contentRect.size.width,
                                15);
    return newRect;
}
- (CGRect)imageRectForContentRect:(CGRect)contentRect{
//    CGRect newRect = CGRectInset(contentRect, contentRect.size.width, contentRect.size.width * 0.2);
//    newRect.size.height = newRect.size.width;
    if (self.tag == 0) {
        return CGRectMake((contentRect.size.width-60)/2+5, 10, 60, 60);
    }
    if (self.tag == 3) {
        return CGRectMake((contentRect.size.width-60)/2-5, 10, 60, 60);
    }
    return CGRectMake((contentRect.size.width-60)/2, 10, 60, 60);
}
@end

@interface CTMoreKeyBoard()<UIScrollViewDelegate>
{
    UIScrollView *containerView;
    UIPageControl *segmentC;
    NSArray *allKeyNames;
    NSArray *allKeyImages;
}
@end

@implementation CTMoreKeyBoard

+(instancetype)share{
    
    static dispatch_once_t onceToken;
    static CTMoreKeyBoard *single;
    
    dispatch_once(&onceToken, ^{
        single = [[CTMoreKeyBoard alloc] init];
       
        single.frame = CGRectMake(0, 0, ScreenWidth, (ScreenWidth-125)/4+10+32);
        dispatch_async(dispatch_get_main_queue(), ^{
           [single initUI];
        });
    });
    return single;
}

-(void)initUI{
    
    containerView = [[UIScrollView alloc] initWithFrame: self.bounds];
    containerView.backgroundColor = RGB(246, 246, 246);
    containerView.pagingEnabled = YES;
    containerView.delegate = self;
    containerView.showsHorizontalScrollIndicator = NO;
    [self addSubview:containerView];
    
    
    NSDictionary<NSString *,UIImage *> * dic = [CTInputConfiguration defaultConfig].extraInfo;
    
    NSUInteger emojiPages = (dic.allKeys.count % 8 != 0 ? 1 : 0) + dic.allKeys.count / 8;
    containerView.contentSize = CGSizeMake(containerView.frame.size.width * emojiPages, 0);
    
//    CGFloat butW = containerView.frame.size.width * 0.232;
//    CGFloat butH = containerView.frame.size.height * 0.46;
//    CGFloat inset_Hori = (ScreenWidth - (4 * butW)) * 0.5;
    CGFloat butW = (ScreenWidth)/4;
    CGFloat butH = (ScreenWidth-125)/4+42;
    CGFloat inset_Hori = 0;
    
    allKeyNames = @[@"Album",@"Camera",@"Short Video",@"File"];//dic.allKeys;
    allKeyImages = @[dic[@"Album"],dic[@"Camera"],dic[@"Short Video"],dic[@"File"]]; // dic.allValues
    for (int i = 0; i < dic.allKeys.count; i++) {
    
        NSInteger currentPage = i / 8;
        CGRect butRect = CGRectMake((i % 8 % 4) *inset_Hori + (i % 8 % 4) * butW + currentPage * containerView.frame.size.width,
                                    (i % 8 / 4) * butH+ (i % 8 / 4) *inset_Hori,
                                    butW,
                                    butH);
        
        MoreKeyBoardButton *butt = [[MoreKeyBoardButton alloc] initWithFrame:butRect];
         butt.tag = i;
        butt.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [butt setImage:allKeyImages[i] forState:UIControlStateNormal];
        [butt setTitle:allKeyNames[i] forState:UIControlStateNormal];
        [butt addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        butt.titleLabel.textAlignment = NSTextAlignmentCenter;
        butt.titleLabel.font = [UIFont systemFontOfSize:12];
        butt.titleLabel.numberOfLines = 2;
        [butt setTitleColor:MAIN_PURPLE_COLOR forState:UIControlStateNormal];
        [containerView addSubview:butt];
    }
    
    CALayer *lineLayer = [CALayer layer];
    lineLayer.frame = CGRectMake(0,-2, CGRectGetWidth(self.bounds), 2);
    lineLayer.backgroundColor = RGB(246, 246, 246).CGColor;
    [self.layer addSublayer:lineLayer];
    
    
//    segmentC = [[UIPageControl alloc] initWithFrame:CGRectMake(0, butH * 2, containerView.frame.size.width, containerView.frame.size.height - butH * 2)];
//    segmentC.backgroundColor = HexColor(0xF5F5F7);
//    segmentC.numberOfPages = emojiPages;
//    segmentC.pageIndicatorTintColor = [UIColor lightGrayColor];
//    segmentC.currentPageIndicatorTintColor = [UIColor blackColor];
//    [self addSubview:segmentC];
    
}

-(void)buttonTapped:(UIButton *)but{
    [self.moreKeyDelegate moreKeyBoardSelectKey:allKeyNames[but.tag] image:allKeyImages[but.tag]];
}

- (void)scrollViewDidScroll: (UIScrollView *) aScrollView
{
    CGPoint offset = aScrollView.contentOffset;
    NSUInteger idx =  offset.x / aScrollView.frame.size.width;
    segmentC.currentPage = idx;
}

+(CTMoreKeyBoard *)keyBoard{
    return [CTMoreKeyBoard share];
}



@end
