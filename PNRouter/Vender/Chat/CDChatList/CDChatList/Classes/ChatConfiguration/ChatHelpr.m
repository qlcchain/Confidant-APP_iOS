//
//  ChatHelpr.m
//  CDChatList
//
//  Created by chdo on 2017/11/17.
//

#import "ChatHelpr.h"
#import "CTHelper.h"
#import "ChatImageDrawer.h"
#import "CTinputHelper.h"

@interface Test:NSObject

@end

@implementation Test


@end

@implementation ChatHelpr

+(instancetype)share{
    
    static dispatch_once_t onceToken;
    static ChatHelpr *helper;
    
    dispatch_once(&onceToken, ^{
        helper = [[ChatHelpr alloc] init];
        helper.environment = 1;
        helper->_config = [[ChatConfiguration alloc] init];
    });
    return helper;
}

-(void)setEnvironment:(int)environment{
    CTHelper.share.environment = environment;
    _environment = environment;
}


@end
