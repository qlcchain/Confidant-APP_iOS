//
//  EmailFloderConfig.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/17.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmailFloderConfig : NSObject
singleton_interface(EmailFloderConfig)
+ (NSDictionary *) getFloderConfigWithEmailType:(int) type;
@end

NS_ASSUME_NONNULL_END
