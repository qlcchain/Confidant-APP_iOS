//
//  ChatListDataUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/15.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ChatListModel;

@interface ChatListDataUtil : NSObject
@property (nonatomic , strong) NSMutableArray *dataArray;
@property (nonatomic , strong) NSMutableArray *friendArray;
@property (nonatomic, assign) NSInteger tempMsgId;
+ (instancetype) getShareObject;
- (void) addFriendModel:(ChatListModel *) model;
- (void) removeChatModelWithFriendID:(NSString *) friendID;
- (void) cancelChatHDWithFriendid:(NSString *) friendid;
@end
