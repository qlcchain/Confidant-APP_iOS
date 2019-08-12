//
//  EmailDataBaseUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EmailDataBaseUtil.h"
#import "EmailContactModel.h"
#import "EmailListInfo.h"
#import "EmailAccountModel.h"

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

+ (void) addEmialStarWithEmialInfo:(EmailListInfo *) emailInfo
{
    if (emailInfo) {
        EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
        emailInfo.bg_tableName = EMAIL_STAR_TABNAME;
        emailInfo.emailAddress = accountM.User;
        [emailInfo bg_saveAsync:^(BOOL isSuccess) {
            
        }];
    }
}

+ (void) delEmialStarWithEmialInfo:(EmailListInfo *) emailInfo
{
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
     NSString *whereSql = [NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"emailAddress"),bg_sqlValue(accountM.User),bg_sqlKey(@"uid"),bg_sqlValue(@(emailInfo.uid))];
    [EmailListInfo bg_delete:EMAIL_STAR_TABNAME where:whereSql];
}

+ (NSInteger) getStartCount
{
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    NSString *sql  = [NSString stringWithFormat:@"select %@ from %@ where %@=%@",bg_sqlKey(@"uid"),EMAIL_STAR_TABNAME,bg_sqlKey(@"emailAddress"),bg_sqlValue(accountM.User)];
    NSArray *results = bg_executeSql(sql, FILE_STATUS_TABNAME,[EmailListInfo class]);
    return results?results.count:0;
}
@end
