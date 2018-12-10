//
//  MessageListUtil.h
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/14.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CDMessageModel;

@interface MessageListUtil : NSObject

singleton_interface(MessageListUtil)

- (void)addMessage:(CDMessageModel *)model;
- (void)addMessages:(NSArray *)messageArr;
- (NSArray *)getMessages:(NSString *)friendId;

@end
