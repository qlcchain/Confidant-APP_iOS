//
//  FriendModel.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/13.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "FriendModel.h"
#import "ChatListDataUtil.h"

@implementation FriendModel

// 实现这个方法的目的：告诉MJExtension框架模型中的属性名对应着字典的哪个key
+ (NSDictionary *)replacedKeyFromPropertyName{
    return @{
             @"username" : @"Name",
             @"remarks"  : @"Remarks",
              @"userId" : @"Id",
              @"signPublicKey" : @"UserKey",
              @"onLineStatu" : @"Status"
             };
}

+ (NSString *)getSignPublicKeyWithUserId:(NSString *)userId {
    __block NSString *signPublicKey = @"";
    [[ChatListDataUtil getShareObject].friendArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        if ([model.userId isEqualToString:userId]) {
            signPublicKey = model.signPublicKey;
            *stop = YES;
        }
    }];
    
    return signPublicKey;
}

@end
