//
//  ChooseContactViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/21.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

@class FriendModel;

@interface RemoveGroupMemberViewController : PNBaseViewController

- (instancetype)initWithMemberArr:(NSArray<FriendModel *> *)arr;

@end
