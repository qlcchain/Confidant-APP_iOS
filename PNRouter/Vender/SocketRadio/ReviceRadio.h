//
//  ReviceRadio.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/12.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@interface ReviceRadio : NSObject
+ (instancetype) getReviceRadio;
- (void) reviceRadionMessage;
-(void)startListenAndNewThreadWithRouterid:(NSString *) routerid;
- (void) sendRadionMessageWithRouterid:(NSString *) routerid;
@end

NS_ASSUME_NONNULL_END
