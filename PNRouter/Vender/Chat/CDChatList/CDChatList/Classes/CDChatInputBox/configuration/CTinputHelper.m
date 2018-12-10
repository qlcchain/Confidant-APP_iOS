//
//  CTinputHelper.m
//  CDChatList
//
//  Created by chdo on 2017/12/12.
//

#import "CTinputHelper.h"
#import "CTInputConfiguration.h"
#import "CTInputBoxDrawer.h"


@implementation CTinputHelper

+(instancetype)share{
    
    static dispatch_once_t onceToken;
    static CTinputHelper *helper;
    
    dispatch_once(&onceToken, ^{
        helper = [[CTinputHelper alloc] init];
        helper->_config = [CTInputConfiguration defaultConfig];
        helper->_imageDic = [CTInputBoxDrawer defaultImageDic];
    });
    return helper;
}

@end
