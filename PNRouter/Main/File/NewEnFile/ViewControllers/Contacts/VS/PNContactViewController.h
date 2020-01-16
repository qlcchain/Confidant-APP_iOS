//
//  PNContactViewController.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/1/7.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface PNContactViewController : PNBaseViewController

- (instancetype) initWithNodePath:(NSString *) contactPath nodeKey:(NSString *) contactKey nodeCount:(NSString *) contactCount isPermission:(BOOL) isPerssion loaclContactCount:(NSInteger) localContactCount;

@end

NS_ASSUME_NONNULL_END
