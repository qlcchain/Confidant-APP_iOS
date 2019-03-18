//
//  GroupChatViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"
@class GroupInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface GroupChatViewController : PNBaseViewController
- (instancetype) initWihtGroupMode:(GroupInfoModel *) model;
@end

NS_ASSUME_NONNULL_END
