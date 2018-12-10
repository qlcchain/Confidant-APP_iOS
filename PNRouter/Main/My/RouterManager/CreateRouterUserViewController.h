//
//  CreateRouterUserViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/26.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"


NS_ASSUME_NONNULL_BEGIN

@interface CreateRouterUserViewController : PNBaseViewController
- (instancetype) initWithRid:(NSString *) rid;
@property (nonatomic , assign) NSInteger userType;
@end

NS_ASSUME_NONNULL_END
