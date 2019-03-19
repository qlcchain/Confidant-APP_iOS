//
//  ChooseContactViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/21.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

@class FriendModel;

typedef enum : NSUInteger {
    AddGroupMemberTypeToCreate, // 添加成员来创建群组
    AddGroupMemberTypeJustAdd, // 仅添加成员
} AddGroupMemberType;

@interface AddGroupMemberViewController : PNBaseViewController

- (instancetype)initWithMemberArr:(NSArray<FriendModel *> *)arr type:(AddGroupMemberType)type;

@end
