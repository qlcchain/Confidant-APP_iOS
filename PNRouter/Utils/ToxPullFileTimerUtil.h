//
//  ToxPullFileTimerUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/12/14.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToxPullFileTimerUtil : NSObject
@property (nonatomic , strong) NSTimer *timer;
@property (nonatomic , strong) NSDate *date;
@property (nonatomic , strong) NSString *fileKey;
@end

NS_ASSUME_NONNULL_END
