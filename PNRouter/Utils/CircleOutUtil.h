//
//  CircleOutUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/4/8.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CircleOutBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface CircleOutUtil : NSObject

@property (nonatomic , copy) CircleOutBlock circleOutBlock;

+ (instancetype) getCircleOutUtilShare;
- (void) circleOutProcessingWithRid:(NSString *) rid friendid:(NSString *) friendId;
                     //circleOutBlock:(CircleOutBlock) circleOutBlock;
@end

NS_ASSUME_NONNULL_END
