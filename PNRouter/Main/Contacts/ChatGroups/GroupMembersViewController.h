//
//  ChooseContactViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/21.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

typedef enum : NSUInteger {
    RemindType,
    CheckType
} OptionType;

@class GroupInfoModel;

@interface GroupMembersViewController : PNBaseViewController

@property (nonatomic, strong) GroupInfoModel *groupInfoM;
@property (nonatomic , assign) OptionType optionType;
@end
