//
//  BaseMsgModel.m
//  CDChatList_Example
//
//  Created by chdo on 2018/8/30.
//  Copyright © 2018年 chdo002. All rights reserved.
//

#import "BaseMsgModel.h"
#import <objc/runtime.h>
@implementation BaseMsgModel

@synthesize audioSufix;

@synthesize audioText;

@synthesize audioTime;

@synthesize bubbleWidth;

@synthesize cellHeight;

@synthesize chatConfig;

@synthesize createTime;

@synthesize ctDataconfig;

@synthesize isLeft;

@synthesize messageId;

@synthesize modalInfo;

@synthesize msg;

@synthesize msgState;

@synthesize msgType;

@synthesize reuseIdentifierForCustomeCell;

@synthesize textlayout;

@synthesize userName;

@synthesize userThumImage;

@synthesize userThumImageURL;

@synthesize willDisplayTime;

-(instancetype)init:(NSDictionary *)dic{
    self = [super init];
    
    
    if (dic) {
        unsigned int propertyCount = 0;
        objc_property_t *propertys = class_copyPropertyList([self class], &propertyCount);
        for (int i = 0; i < propertyCount; i ++) {
            objc_property_t property = propertys[i];
            
            // 字段名
            const char * propertyName = property_getName(property);
            NSString *name = [NSString stringWithUTF8String: propertyName];
            id val = dic[name];
            if ([val isKindOfClass:NSNumber.class]) {
                
            }
            if (val) {
                [self setValue:val forKey:name];
            }
        }
    }
    
    
    
    return self;
}

@end
