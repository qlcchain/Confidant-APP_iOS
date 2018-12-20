//
//  MutManagerUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/30.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MutManagerUtil : NSObject

@property (nonatomic ,copy) NSString *mutString;
@property (nonatomic ,assign) NSInteger msgId;
@property (nonatomic , strong) NSMutableDictionary *mutTempDic;

// filekey


+ (instancetype) getShareObject;

@end

NS_ASSUME_NONNULL_END
