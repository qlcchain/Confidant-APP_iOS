//
//  BaseMsgModel.h
//  CDChatList_Example
//
//  Created by chdo on 2018/8/30.
//  Copyright © 2018年 chdo002. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDChatList.h"

@interface BaseMsgModel : NSObject<MessageModalProtocal>

@property(nonatomic, strong) id cacheGif;

-(instancetype)init:(NSDictionary *)dic;
@end
