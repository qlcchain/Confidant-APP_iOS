//
//  ChatHelpr.h
//  CDChatList
//
//  Created by chdo on 2017/11/17.
//

#import <Foundation/Foundation.h>
#import "ChatConfiguration.h"

@interface ChatHelpr : NSObject


@property(class, nonatomic, strong, readonly) ChatHelpr *share;
#pragma mark 环境
/**
 环境  // 0 调试 1 生产
 */
@property(nonatomic, assign) int environment;
@property(nonatomic, strong) ChatConfiguration *config;
@property(nonatomic, strong) NSDictionary<NSString*, UIImage *> *emojDic;
@property(nonatomic, strong) NSDictionary<NSString*, UIImage *> *imageDic;

/**
 CDMessageType : @"" : CDMessageCellType
 */
@property(nonatomic, strong) NSArray<Class> *customMsgCell; //自定义消息cell

@end
