//
//  FriendRequestViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/12/29.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FriendRequestViewController : PNBaseViewController

- (instancetype) initWithNickname:(NSString *) nickName userId:(NSString *) userId signpk:(NSString *) signpk toxId:(NSString *) toxId codeType:(NSString *) type;

@end

NS_ASSUME_NONNULL_END
