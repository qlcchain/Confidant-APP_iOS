//
//  UserPrivateKeyUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/9/5.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "UserPrivateKeyUtil.h"
#import "KeyCUtil.h"

@implementation UserPrivateKeyUtil

+ (void)changeUserPrivateKeyWithPrivateKey:(NSString *) privatekey
{
    EntryModel *entryM = [LibsodiumUtil changeUserPrivater:privatekey];
    [KeyCUtil saveStringToKeyWithString:entryM.mj_JSONString key:libkey];
}

@end
