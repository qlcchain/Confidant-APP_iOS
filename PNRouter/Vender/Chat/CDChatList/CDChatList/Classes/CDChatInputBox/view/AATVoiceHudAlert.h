//
//  AATVoiceHudAlert.h
//  AATChatList
//
//  Created by chdo on 2018/1/10.
//  Copyright © 2018年 aat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AATVoiceHudAlert : UIView

+(void)showPowerHud:(NSUInteger) power;
+(void)showRevocationHud;
+(void)hideHUD;
@end
