//
//  SocketCountUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/15.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketCountUtil : NSObject
@property (nonatomic , assign) NSInteger reConnectCount;
@property (nonatomic , assign) int fileIDCount;
// 当前通话好友ID
@property (nonatomic , strong) NSString *chatToId;
@property (nonatomic , strong) NSString *groupChatId;
+ (instancetype) getShareObject;
@end
