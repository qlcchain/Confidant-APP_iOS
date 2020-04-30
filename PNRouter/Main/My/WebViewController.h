//
//  WebViewController.h
//  Qlink
//
//  Created by 旷自辉 on 2018/5/30.
//  Copyright © 2018年 pan. All rights reserved.
//

#import "PNBaseViewController.h"

typedef enum : NSUInteger {
    WebFromTypeHelpCenter,
    WebFromTypeShareFriend,
    WebFromTypeCreateCircle,
    WebFromTypeJoinCircle,
    WebFromTypeImportCircle
} WebFromType;

@interface WebViewController : PNBaseViewController

@property (nonatomic) WebFromType fromType;

@end
