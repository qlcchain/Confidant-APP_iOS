//
//  PNEmailLoginViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/10.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    LoginEmail,
    ConfigEmail
} EmailOptionType;

@interface PNEmailLoginViewController : PNBaseViewController
@property (nonatomic, assign) EmailOptionType optionType;
- (instancetype) initWithEmailType:(int) type optionType:(EmailOptionType) optionType;
@end

NS_ASSUME_NONNULL_END
