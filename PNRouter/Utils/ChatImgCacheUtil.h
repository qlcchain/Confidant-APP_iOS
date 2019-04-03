//
//  ChatImgCacheUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/4/2.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChatImgCacheUtil : NSObject
@property (nonatomic , strong) NSMutableDictionary *imgCacheDic;
+ (instancetype) getChatImgCacheUtilShare;
@end

NS_ASSUME_NONNULL_END
