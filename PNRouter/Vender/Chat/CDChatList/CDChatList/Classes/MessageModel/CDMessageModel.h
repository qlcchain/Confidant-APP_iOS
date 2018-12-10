//
//  CDMessageModel.h
//  CDChatList
//
//  Created by chdo on 2018/3/20.
//

#import "CDChatListProtocols.h"

@interface CDMessageModel : NSObject<MessageModalProtocal>

-(instancetype)init:(NSDictionary *)dic;

@end
