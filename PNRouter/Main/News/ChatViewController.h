//
//  ChatViewController.h
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/5.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"
@class FriendModel;

@interface ChatViewController : PNBaseViewController

- (instancetype) initWihtFriendMode:(FriendModel *) model;

@end
