//
//  ChatListModel.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/15.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ChatListModel.h"

@implementation ChatListModel

- (NSString *)groupShowName {
    if (_groupAlias && _groupAlias.length > 0) {
        return _groupAlias;
    }
    return _groupName;
}

/**
 设置不需要存储的属性, 在模型.m文件中实现该函数.
 */
+(NSArray *)bg_ignoreKeys{
    return @[@"isOwerClearAtYour"];
}

@end
