//
//  UserHeaderModel.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/7.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "UserHeaderModel.h"
#import <BGFMDB/BGFMDB.h>

@implementation UserHeaderModel

/**
 自定义“联合主键” ,这里指定 name和age 为“联合主键”.
 */
+(NSArray *)bg_unionPrimaryKeys{
    return @[@"UserKey"];
}

/**
 设置不需要存储的属性, 在模型.m文件中实现该函数.
 */
+(NSArray *)bg_ignoreKeys{
    return @[];
}

+ (void)saveOrUpdate:(UserHeaderModel *)model {
    if (model.bg_tableName == nil) {
        model.bg_tableName = UserHeader_Table;
    }
    [model bg_saveOrUpdate];
//    [model bg_saveOrUpdateAsync:^(BOOL isSuccess) {
//        NSLog(@"------------UserHeader_Table bg_saveOrUpdateAsync %@",@(isSuccess));
//    }];
}

+ (NSString *)getUserHeaderImg64StrWithKey:(NSString *)userKey {
//    NSArray *findAll = [UserHeaderModel bg_findAll:UserHeader_Table];
    NSArray *finfAlls = [UserHeaderModel bg_find:UserHeader_Table where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"UserKey"),bg_sqlValue(userKey)]];
    UserHeaderModel *model = finfAlls.firstObject;
    return model?model.UserHeaderImg64Str:nil;
}

//+ (void)saveOrUpdateWithUserKey:(NSString *)UserKey UserHeaderImg64Str:(NSString *)UserHeaderImg64Str {
//    UserHeaderModel *model = [UserHeaderModel new];
//    model.UserKey = UserKey;
//    model.UserHeaderImg64Str = UserHeaderImg64Str;
//    [UserHeaderModel saveOrUpdate:model];
//}

@end
