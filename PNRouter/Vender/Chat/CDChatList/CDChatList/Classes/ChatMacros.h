//
//  CDChatMacro.h
//  Pods
//
//  Created by chdo on 2017/10/26.
//


#import "CDChatListProtocols.h"
#import "ChatConfiguration.h"

#ifndef CDChatMacro_h
#define CDChatMacro_h

// 0 调试 1 生产
#define Environment ChatHelpr.share.config.environment
#define isChatListDebug [ChatHelpr.share.config isDebug]


#endif /* CDChatMacro_h */

