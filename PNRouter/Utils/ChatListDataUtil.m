//
//  ChatListDataUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/15.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ChatListDataUtil.h"
#import "ChatListModel.h"
#import "FriendModel.h"
#import "NSString+Base64.h"

@implementation ChatListDataUtil
+ (instancetype) getShareObject
{
    static ChatListDataUtil *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
        shareObject.dataArray = [NSMutableArray array];
        shareObject.friendArray = [NSMutableArray array];
    });
    return shareObject;
}

- (void) addFriendModel:(ChatListModel *) model
{
    [[ChatListDataUtil getShareObject].friendArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *friendModel = (FriendModel *)obj;
        if ([friendModel.userId isEqualToString:model.friendID]) {
            NSString *nickName = friendModel.username?:@"";
            nickName = [nickName base64DecodedString];
            if (nickName && ![nickName isEmptyString]) {
                 model.friendName = nickName;
            } else {
                 model.friendName = friendModel.username;
            }
           
            model.publicKey = friendModel.publicKey;
        }
    }];
    
   __block BOOL isExit = NO;
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChatListModel *chatModel = (ChatListModel *) obj;
        if ([chatModel.friendID isEqualToString:model.friendID]) {
            chatModel.lastMessage = model.lastMessage;
            chatModel.chatTime = model.chatTime;
            chatModel.friendName = model.friendName;
            chatModel.publicKey = model.publicKey;
            chatModel.isHD = model.isHD;
            isExit = YES;
            *stop = YES;
        }
    }];
    if (!isExit) {
        [self.dataArray insertObject:model atIndex:0];
    }
}

- (void) removeChatModelWithFriendID:(NSString *) friendID
{
    @weakify_self
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChatListModel *chatModel = (ChatListModel *) obj;
        if ([chatModel.friendID isEqualToString:friendID]) {
            [weakSelf.dataArray removeObject:chatModel];
            *stop = YES;
        }
    }];
}

- (void) cancelChatHDWithFriendid:(NSString *) friendid
{
    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ChatListModel *chatModel = (ChatListModel *) obj;
        if ([chatModel.friendID isEqualToString:friendid]) {
            chatModel.isHD = NO;
            *stop = YES;
        }
    }];
}
@end
