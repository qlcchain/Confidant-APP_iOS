//
//  PNEmailMoveViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/19.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^MoveSuccessBlock)(void);

@interface PNEmailMoveViewController : PNBaseViewController
@property (nonatomic, copy) MoveSuccessBlock moveBlock;
- (instancetype) initWithFloderPath:(NSString *) floderPath uid:(NSInteger) uid;
@end

NS_ASSUME_NONNULL_END
