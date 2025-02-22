//
//  ChatListDataUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/15.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ChatListModel;
@class FriendModel;

@interface ChatListDataUtil : NSObject

@property (nonatomic , strong) NSMutableArray *dataArray;
@property (nonatomic , strong) NSMutableArray *friendArray;
@property (nonatomic , strong) NSMutableArray *groupArray;
@property (nonatomic, assign) NSInteger tempMsgId;
// tox文件发送 filenumber为key
@property (nonatomic , strong) NSMutableDictionary *fileParames;
// tox接收文件 filenumber为key
@property (nonatomic , strong) NSMutableDictionary *fileNameParames;
// 检测接收失败的定时器类
@property (nonatomic , strong) NSMutableDictionary *pullTimerDic;
// tox取消发送文件
@property (nonatomic , strong) NSMutableDictionary *fileCancelParames;
// tox fileid 绑定 filenumber
@property (nonatomic , strong) NSMutableDictionary *fileNumberParames;

+ (instancetype) getShareObject;
- (void) addFriendModel:(ChatListModel *) model;
- (void) removeChatModelWithFriendID:(NSString *) friendID;
- (void) removeGroupChatModelWithGID:(NSString *) gID;
- (void) cancelChatHDWithFriendid:(NSString *) friendid;
- (NSString *) getFriendSignPublickeyWithFriendid:(NSString *) fid;
- (FriendModel *) getFriendWithUserid:(NSString *) fid;
- (NSString *) getFriendUserKeyWithEmailAddress:(NSString *) email;
@end
