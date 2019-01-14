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
#import "SystemUtil.h"
#import "UserConfig.h"

@implementation ChatListDataUtil
+ (instancetype) getShareObject
{
    static ChatListDataUtil *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
        shareObject.dataArray = [NSMutableArray array];
        shareObject.friendArray = [NSMutableArray array];
        if (![SystemUtil isSocketConnect]) {
            shareObject.fileParames = [NSMutableDictionary dictionary];
            shareObject.fileNameParames = [NSMutableDictionary dictionary];
            shareObject.pullTimerDic = [NSMutableDictionary dictionary];
            shareObject.fileCancelParames = [NSMutableDictionary dictionary];
        }
       
    });
    return shareObject;
}

- (void) addFriendModel:(ChatListModel *) model
{
    
    @synchronized (self) {
        // 加锁操作
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
                *stop = YES;
            }
        }];
        
        NSArray *friends = [ChatListModel bg_find:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"friendID"),bg_sqlValue(model.friendID),bg_sqlKey(@"myID"),bg_sqlValue(model.myID)]];
        if (friends && friends.count > 0) {
            ChatListModel *model1 = friends[0];
            model1.lastMessage = model.lastMessage;
            model1.friendName = model.friendName;
            model1.chatTime = model.chatTime;
            model1.isHD = model.isHD;
            [model1 bg_saveOrUpdate];
        } else {
            model.bg_tableName = FRIEND_CHAT_TABNAME;
            if (model.publicKey && ![model.publicKey isEmptyString]) {
                [model bg_save];
            }
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:ADD_MESSAGE_NOTI object:nil];
    }
    
    
//   __block BOOL isExit = NO;
//    [self.dataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        ChatListModel *chatModel = (ChatListModel *) obj;
//        if ([chatModel.friendID isEqualToString:model.friendID]) {
//            chatModel.lastMessage = model.lastMessage;
//            chatModel.chatTime = model.chatTime;
//            chatModel.friendName = model.friendName;
//            chatModel.publicKey = model.publicKey;
//            chatModel.isHD = model.isHD;
//            isExit = YES;
//            *stop = YES;
//        }
//    }];
//    if (!isExit) {
//        if (model.publicKey && ![model.publicKey isEmptyString]) {
//            [self.dataArray insertObject:model atIndex:0];
//        }
//        
//    }
}

- (void) removeChatModelWithFriendID:(NSString *) friendID
{
    [ChatListModel bg_delete:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"friendID"),bg_sqlValue(friendID?:@""),bg_sqlKey(@"myID"),bg_sqlValue([UserConfig getShareObject].userId)]];
    [[NSNotificationCenter defaultCenter] postNotificationName:ADD_MESSAGE_NOTI object:nil];
}

- (void) cancelChatHDWithFriendid:(NSString *) friendid
{
    NSArray *friends = [ChatListModel bg_find:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"friendID"),bg_sqlValue(friendid),bg_sqlKey(@"myID"),bg_sqlValue([UserConfig getShareObject].userId)]];
    if (friends && friends.count > 0) {
        ChatListModel *model1 = friends[0];
        model1.isHD = NO;
        [model1 bg_saveOrUpdate];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ADD_MESSAGE_NOTI object:nil];
}
@end
