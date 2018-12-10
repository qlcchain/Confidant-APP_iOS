//
//  AATVoiceHudAlert.m
//  AATChatList
//
//  Created by chdo on 2018/1/10.
//  Copyright © 2018年 aat. All rights reserved.
//

#import "AATVoiceHudAlert.h"
#import "CTinputHelper.h"
#import "CTInPutMacro.h"

@interface SingleView:UIView
@property NSUInteger power;
-(void)updatePower:(NSInteger)power;
@end

@implementation SingleView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor clearColor];
    return self;
}

-(void)updatePower:(NSInteger)power{
    if (power < 1) {
        self.power = 1;
    } else if (power > 10){
        self.power = 10;
    } else {
        self.power = power;
    }
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect{
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat blockH = 4.0f;
    CGFloat blockGap = (self.frame.size.height - blockH * 10) * (1.0f/9.0f);

    for (NSUInteger i = 0 ; i < self.power; i++) {
        CGFloat blockY = (9 - i) * (blockGap +  blockH);
        CGFloat width =  ((i + 1.0f) / 10.0f) * self.frame.size.width * 0.4 + 10.0f;
        CGRect rec = CGRectMake(0, blockY, width, blockH);
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextAddRect(ctx,rec);//画方框
        CGContextFillRect(ctx, rec);
    }
    
}

@end
@interface AATVoiceHudAlert()

@property(nonatomic, strong) UIView *voicePower;
@property(nonatomic, strong) SingleView *sigView;
@property(nonatomic, strong) UIView *voiceRevocation;

@end

@implementation AATVoiceHudAlert

+(instancetype)share{
    
    static dispatch_once_t onceToken;
    static AATVoiceHudAlert *single;
    
    dispatch_once(&onceToken, ^{
        single = [[AATVoiceHudAlert alloc] initWithFrame:[UIScreen mainScreen].bounds];
    });
    return single;
}

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:CGRectMake(0, 0, ScreenWidth * 0.4, ScreenWidth * 0.4)];
    self.backgroundColor = [UIColor clearColor];
    self.center = CGPointMake(ScreenWidth * 0.5, ScreenHeight * 0.4);
    
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *efView = [[UIVisualEffectView alloc] initWithEffect:effect];
    efView.frame = self.bounds;
    [self addSubview:efView];
    self.layer.cornerRadius = 5.0f;
    self.clipsToBounds = YES;
    
    
    if(self) {
        self.userInteractionEnabled = NO;


        /// 音量视图
        UIView *power = [[UIView alloc] initWithFrame:self.bounds];
        // icon
        UIImageView *microphone = [[UIImageView alloc] initWithImage: CTinputHelper.share.imageDic[@"voice_microphone_alert"]];
        microphone.contentMode = UIViewContentModeScaleAspectFit;
        microphone.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height * 0.35);
        microphone.center = CGPointMake(self.bounds.size.width * 0.4, self.bounds.size.height * 0.45);
        [power addSubview:microphone];
        
        SingleView *sig = [[SingleView alloc] initWithFrame:CGRectMake(self.frame.size.width * 0.55, microphone.frame.origin.y,
                                                                       self.frame.size.width * 0.2, microphone.frame.size.height)];
        [power insertSubview:sig belowSubview:microphone];
        self.sigView = sig;

        // 标签
        UILabel *powerlabel = [[UILabel alloc] init];
        powerlabel.frame = CGRectMake(5, self.bounds.size.height - 35, self.bounds.size.width - 10, 30);
        powerlabel.text = @"手指上滑，取消发送";
        powerlabel.textColor = [UIColor whiteColor];
        powerlabel.textAlignment = NSTextAlignmentCenter;
        powerlabel.font = [UIFont systemFontOfSize:14];
        [power addSubview:powerlabel];
        self.voicePower = power;


        /// 松开手指提示 视图
        UIView *revoc = [[UIView alloc] initWithFrame: self.bounds];
        // icon
        UIImageView *revocation = [[UIImageView alloc] initWithImage: CTinputHelper.share.imageDic[@"voice_revocation_alert"]];
        revocation.contentMode = UIViewContentModeScaleAspectFit;
        revocation.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height * 0.35);
        revocation.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.45);
        [revoc addSubview:revocation];

        // 标签
        UILabel *revoclabel = [[UILabel alloc] init];
        revoclabel.frame = CGRectMake(5, self.bounds.size.height - 35, self.bounds.size.width - 10, 30);
        revoclabel.text = @"松开手指，取消发送";
        revoclabel.backgroundColor = HexColor(0x9D432C);
        revoclabel.textColor = [UIColor whiteColor];
        revoclabel.textAlignment = NSTextAlignmentCenter;
        revoclabel.font = [UIFont systemFontOfSize:14];
        [revoc addSubview:revoclabel];

        self.voiceRevocation = revoc;
        self.voiceRevocation.hidden = YES;


    }
    return self;
}

/**
 显示音量

 @param power [1...10]
 */
+(void)showPowerHud:(NSUInteger) power{
    dispatch_async(dispatch_get_main_queue(), ^{
        AATVoiceHudAlert *this = [AATVoiceHudAlert share];
        [this updateViewHierarchy:this.voicePower];
        [this.sigView updatePower:power];
    });
}

+(void)showRevocationHud{
    dispatch_async(dispatch_get_main_queue(), ^{
        AATVoiceHudAlert *this = [AATVoiceHudAlert share];
        [this updateViewHierarchy:this.voiceRevocation];
    });
}

+(void)hideHUD{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AATVoiceHudAlert share] removeFromSuperview];
    });
}

- (void)updateViewHierarchy:(UIView *)tagetView {
    
    if (!self.superview) {
        [self.frontWindow addSubview:self];
    } else {
        [self.superview bringSubviewToFront:self];
    }
    
    if (!tagetView.superview) {
        [self addSubview:tagetView];
    } else {
        [self bringSubviewToFront:tagetView];
    }
    
    if ([tagetView isEqual:self.voicePower]) {
        [self.voicePower setHidden:NO];
        [self.voiceRevocation setHidden:YES];
    } else {
        [self.voicePower setHidden:YES];
        [self.voiceRevocation setHidden:NO];
    }
}

- (UIWindow *)frontWindow {
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= UIWindowLevelNormal);
        BOOL windowKeyWindow = window.isKeyWindow;
        if(windowOnMainScreen && windowIsVisible && windowLevelSupported && windowKeyWindow) {
            return window;
        }
    }
    return nil;
}
@end
