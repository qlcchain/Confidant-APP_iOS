//
//  GoogleUserModel.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/10/14.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "GoogleUserModel.h"
#import "KeyCUtil.h"

@implementation GoogleUserModel

+ (void) addGoogleUserWithUser:(GoogleUserModel *) userModel
{
    [KeyCUtil saveStringToKeyWithString:userModel.mj_JSONString key:userModel.email];
}
+ (GoogleUserModel *) getCurrentUserModel:(NSString *) email
{
    NSString *userJosn = [KeyCUtil getKeyValueWithKey:email];
    if (userJosn && userJosn.length > 0) {
        GoogleUserModel *model = [GoogleUserModel getObjectWithKeyValues:[userJosn mj_keyValues]];
        return model;
    }
    return nil;
}
@end
