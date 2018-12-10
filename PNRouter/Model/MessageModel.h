//
//  MessageModel.h
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/14.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

@interface MessageModel : BBaseModel

@property (nonatomic, copy) NSString *fromId;
@property (nonatomic, copy) NSString *toId;
@property (nonatomic) NSInteger msgId;
@property (nonatomic, copy) NSString *msg;

@end
