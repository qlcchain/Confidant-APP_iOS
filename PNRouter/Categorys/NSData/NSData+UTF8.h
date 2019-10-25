//
//  NSData+UTF8.h
//  MyConfidant
//
//  Created by 旷自辉 on 2019/10/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (UTF8)
/**
 NSData转化成string
 
 @return 返回nil的解决方案
 */
- (NSString *)convertedToUtf8String;
@end

NS_ASSUME_NONNULL_END
