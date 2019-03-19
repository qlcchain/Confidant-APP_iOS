//
//  ChooseContactViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/21.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

@class FriendModel;

typedef void(^AddGroupMemberCompleteBlock)(NSArray *addArr);

typedef enum : NSUInteger {
    AddGroupMemberTypeBeforeCreate, // 添加成员来创建群组
    AddGroupMemberTypeInCreate, // 在创建群组里面来添加成员
    AddGroupMemberTypeJustAdd, // 仅添加成员
} AddGroupMemberType;

@interface AddGroupMemberViewController : PNBaseViewController

@property (nonatomic, copy) AddGroupMemberCompleteBlock addCompleteB;

- (instancetype)initWithMemberArr:(NSArray<FriendModel *> *)memberArr originArr:(NSArray<FriendModel *> *)originArr type:(AddGroupMemberType)type;

@end
