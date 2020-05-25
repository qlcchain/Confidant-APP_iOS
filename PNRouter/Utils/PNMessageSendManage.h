//
//  PNMessageSendManage.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/4/26.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNMessageSendManage : NSObject

+(void) sendMessageWithContacts:(NSMutableArray *) contactArray fileUrl:(NSURL *) fileURL;
+(void) sendMessageWithContacts:(NSArray *) contactArray messageStr:(NSString *) messageStr;

@end

NS_ASSUME_NONNULL_END
