//
//  RegiterViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/13.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

typedef enum : NSUInteger {
    AccountSupper,
    AccountOrdinary,
    AccountTemp,
} AccountType;

NS_ASSUME_NONNULL_BEGIN

@interface RegiterViewController : PNBaseViewController
@property (nonatomic , assign) AccountType accountType;
- (instancetype) initWithAccountType:(AccountType) type;

@end

NS_ASSUME_NONNULL_END
