//
//  ChatConfiguration.m
//  CDChatList
//
//  Created by chdo on 2017/12/5.
//

#import "ChatConfiguration.h"
#import "ChatHelpr.h"
#import "UITool.h"

@implementation ChatConfiguration

-(instancetype)init{
    
    self = [super init];
    
    self.environment = 1;
    
    self.msgBackGroundColor = CDHexColor(0xEBEBEB);
    self.msgContentBackGroundColor = CDHexColor(0xEBEBEB);
    self.headBackGroundColor = CDHexColor(0xEBEBEB);
    self.msgTextContentBackGroundColor_right = CDHexColor(0x06C0B5);
    self.msgTextContentBackGroundColor_left = CDHexColor(0xF5F7FA);
//    self.msgBackGroundColor = [UIColor RandomColor];
//    self.msgContentBackGroundColor = [UIColor RandomColor];
//    self.headBackGroundColor = [UIColor RandomColor];
//    self.msgTextContentBackGroundColor_right = [UIColor RandomColor];
//    self.msgTextContentBackGroundColor_left = [UIColor RandomColor];
    
    self.msgTimeH = 25.0f;
    self.sysInfoMessageMaxWidth = cd_ScreenW() * 0.64f;
    self.headSideLength = 40.0f;
    self.sysInfoPadding = 8.0f;
    
    self.bubbleRoundAnglehorizInset = 10.0f;
    self.bubbleShareAngleWidth = 6.0f;
    self.messageMarginBottom = 16.0f;
//    self.messageMargin = 10.0f;
    self.messageMarginTop = 16.f;
    self.headMargin = 8.0f;
    self.bubbleMaxWidth = cd_ScreenW() * 0.64f;
    self.bubbleSharpAngleHeighInset = 25.0f;
    self.nickNameHeight = 25.0f;
    
    self.messageTextDefaultFontSize = 16;
    self.messageTextDefaultFont = [UIFont systemFontOfSize: self.messageTextDefaultFontSize];
    self.sysInfoMessageFont = [UIFont systemFontOfSize:14];
    
    self.left_box = @"left_box";
    self.right_box = @"right_box";
    self.bg_mask_right = @"bg_mask_right";
    self.bg_mask_left = @"bg_mask_left";
    self.icon_head = @"icon_head";
    self.msgImagePlaceHolder = @"msgImagePlaceHolder";
    self.voice_right_1 = @"voice_right_1";
    self.voice_right_2 = @"voice_right_2";
    self.voice_right_3 = @"voice_right_3";
    self.voice_left_1 = @"voice_left_1";
    self.voice_left_2 = @"voice_left_2";
    self.voice_left_3 = @"voice_left_3";
    CTDataConfig config;
    
    config = [CTData defaultConfig];
    self.ctDataconfig = config;
    
    return self;
}

-(BOOL)isDebug{
    return self.environment == 0;
}

// 颜色

-(UIColor *)msgBackGroundColor{
    if ([self isDebug]) {
        return CDHexColor(0xB5E7E1);
    } else {
        return _msgBackGroundColor;
    }
}

-(UIColor *)msgContentBackGroundColor{
    if ([self isDebug]) {
        return CDHexColor(0x9E7777);
    } else {
        return _msgContentBackGroundColor;
    }
}

-(UIColor *)headBackGroundColor {
    if ([self isDebug]) {
        return [UIColor redColor];
    } else {
        return _headBackGroundColor;
    }
}
#pragma mark -右聊天气泡背景色
-(UIColor *)msgTextContentBackGroundColor_right{
//    if ([self isDebug]) {
//        return [UIColor cyanColor];
//    } else {
//        return _msgTextContentBackGroundColor_right;
//    }
    return [UIColor colorWithRed:204/255.0f green:234/255.0f blue:255/255.0f alpha:1];
}
#pragma mark -左聊天气泡背景色
-(UIColor *)msgTextContentBackGroundColor_left{
//    if ([self isDebug]) {
//        return [UIColor magentaColor];
//    } else {
//        return _msgTextContentBackGroundColor_left;
//    }
    return [UIColor whiteColor];
}

-(CGFloat)messageContentH{
//    CGFloat top = data.willDisplayTime?data.chatConfig.messageMarginTop:0;
    return self.messageMarginBottom + self.messageMarginTop +  self.headSideLength;
}

-(CGFloat)bubbleSharpAnglehorizInset{
    return self.bubbleRoundAnglehorizInset + self.bubbleShareAngleWidth;
}

@end
