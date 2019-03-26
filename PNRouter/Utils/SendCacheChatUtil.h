//
//  SendCacheChatUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/2/27.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CDMessageModel;

NS_ASSUME_NONNULL_BEGIN

@interface SendCacheChatUtil : NSObject

+ (instancetype) getSendCacheChatUtilShare;
- (void)start;
- (void)stop;
- (void) deleteCacheFileNollData;

@end

NS_ASSUME_NONNULL_END
