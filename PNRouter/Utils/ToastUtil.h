//
//  ToastUtil.h
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/12.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ToastTypeNone,
    ToastTypeConnect,
    ToastTypeLogin,
    ToastTypeDeleteFriend,
} ToastType;

@interface ToastUtil : NSObject

singleton_interface(ToastUtil)

+ (void)makeToast:(ToastType)type;
+ (void)hideToast:(ToastType)type;

@end
