//
//  ENMessageUtil.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/2/14.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ENMessageUtil : NSObject

+ (NSString *) enMessageStr:(NSString *) messageStr enType:(NSString *) enType qlcAccount:(NSString *) qlcAccount tokenNum:(NSString *) tokenNum tokenType:(NSString *) tokenType enNonce:(NSString *) enNonce;
+ (NSString *) deMessageStr:(NSString *) messageStr;
@end

NS_ASSUME_NONNULL_END
