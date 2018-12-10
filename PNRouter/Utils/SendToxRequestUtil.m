//
//  SendToxRequestUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/29.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "SendToxRequestUtil.h"
#import "OCTSubmanagerChats.h"
#import "SocketMessageUtil.h"

@implementation SendToxRequestUtil
+ (void) sendTextMessageWithText:(NSString *) message manager:(id<OCTManager>) manage
{
    if (AppD.currentRouterNumber < 0) {
        [AppD.window hideHud];
        [AppD.window showHint:@"Failed to send message"];
        return;
    }
    NSLog(@"send text: %@",message);
    [manage.chats sendTextMessageWithfriendNumber:AppD.currentRouterNumber text:message messageType:OCTToxMessageTypeNormal successBlock:^(OCTToxMessageId megid) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}

@end
