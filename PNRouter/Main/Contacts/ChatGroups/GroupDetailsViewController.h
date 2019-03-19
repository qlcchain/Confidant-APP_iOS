//
//  GroupDetailsViewController.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/13.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"
@class GroupInfoModel;

NS_ASSUME_NONNULL_BEGIN

@interface GroupDetailsViewController : PNBaseViewController
- (instancetype) initWithGroupInfo:(GroupInfoModel *) model;
@end

NS_ASSUME_NONNULL_END
