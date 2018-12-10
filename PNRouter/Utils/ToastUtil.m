//
//  ToastUtil.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/12.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ToastUtil.h"

@interface ToastUtil ()

@property (nonatomic) ToastType toastType;

@end

@implementation ToastUtil

singleton_implementation(ToastUtil)

- (instancetype)init {
    if (self = [super init]) {
        self.toastType = ToastTypeNone;
    }
    return self;
}

+ (void)makeToast:(ToastType)type {
    if (ToastUtil.sharedToastUtil.toastType == ToastTypeNone) {
        ToastUtil.sharedToastUtil.toastType = type;
        [AppD.window showHudInView:AppD.window hint:@""];
    }
}

+ (void)hideToast:(ToastType)type {
    if (ToastUtil.sharedToastUtil.toastType == type) {
        ToastUtil.sharedToastUtil.toastType = ToastTypeNone;
        [AppD.window hideHud];
    }
}

@end
