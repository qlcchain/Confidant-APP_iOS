//
//  CreateGroupChatViewController.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/13.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

typedef enum : NSUInteger {
    ChatCreateGroup,
    GroupsCreateGroup,
    AddCreateGroup,
} GroupPage;

NS_ASSUME_NONNULL_BEGIN

@interface CreateGroupChatViewController : PNBaseViewController

- (instancetype) initWithContacts:(NSArray *) contacts groupPage:(GroupPage) newPage;

@end

NS_ASSUME_NONNULL_END
