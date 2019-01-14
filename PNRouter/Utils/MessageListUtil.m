//
//  MessageListUtil.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/14.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "MessageListUtil.h"
#import "CDMessageModel.h"
#import "UserModel.h"
#import "UserConfig.h"

@interface MessageListUtil ()

@property (nonatomic, copy) NSMutableDictionary *allMessageDic;

@end

@implementation MessageListUtil

singleton_implementation(MessageListUtil)

- (instancetype)init {
    if (self = [super init]) {
        self.allMessageDic = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)addMessage:(CDMessageModel *)model {
    NSString *userId = [UserConfig getShareObject].userId;
    NSString *friendId = nil;
    if (![model.ToId isEqualToString:userId]) {
        friendId = model.ToId;
    } else if (![model.FromId isEqualToString:userId]) {
        friendId = model.FromId;
    }
    
    __block BOOL keyExist = NO;
    [_allMessageDic.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *key = obj;
        if ([friendId isEqualToString:key]) {
            keyExist = YES;
            *stop = YES;
        }
    }];
    if (keyExist) { // 此对象的聊天记录已存在
        NSMutableArray *tempArr = [NSMutableArray array];
        NSArray *valueArr = _allMessageDic[friendId];
        [tempArr addObjectsFromArray:valueArr];
        [tempArr addObject:model];
        [_allMessageDic setObject:tempArr forKey:friendId];
    } else { // 此对象的聊天记录不存在  需新加
        [_allMessageDic setObject:@[model] forKey:friendId];
    }
}

- (void)addMessages:(NSArray *)messageArr {
    [messageArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CDMessageModel *model = obj;
        [self addMessage:model];
    }];
}

- (NSArray *)getMessages:(NSString *)friendId {
    return _allMessageDic[friendId];
}

//- (MessageModel *)getLastMessage:(NSString *)friendId {
//    
//}

@end
