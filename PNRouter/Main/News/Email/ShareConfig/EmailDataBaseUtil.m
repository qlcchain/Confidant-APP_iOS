//
//  EmailDataBaseUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EmailDataBaseUtil.h"
#import "EmailContactModel.h"

@implementation EmailDataBaseUtil

+ (void) insertDataWithUser:(NSString *) user userName:(NSString *) userName  userAddress:(NSString *) userAddress
{
    NSString *whereSql = [NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"user"),bg_sqlValue(user),bg_sqlKey(@"userAddress"),bg_sqlValue(userAddress)];
    
    NSArray *array = [EmailContactModel bg_find:EMAIL_CONTACT_TABNAME where:whereSql];
    if (!array || array.count == 0) {
        EmailContactModel *model = [[EmailContactModel alloc] init];
        model.bg_tableName = EMAIL_CONTACT_TABNAME;
        model.user = user;
        model.userName = userName;
        model.userAddress = userAddress;
        [model bg_save];
    }
//    [EmailContactModel bg_findAsync:EMAIL_CONTACT_TABNAME where:whereSql complete:^(NSArray * _Nullable array) {
//
//    }];
}
@end
