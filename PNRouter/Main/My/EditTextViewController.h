//
//  EditTextViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/15.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

typedef enum : NSUInteger {
    EditName,
    EditCompany,
    EditPosition,
    EditLocation,
    EditAlis
} EditType;

@class RouterModel;

@interface EditTextViewController : PNBaseViewController

@property (nonatomic, strong) RouterModel *routerM;
@property (nonatomic ,assign) EditType editType;

- (instancetype) initWithType:(EditType) type;

@end
