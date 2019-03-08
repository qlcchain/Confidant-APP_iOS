//
//  UserHeaderModel.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/7.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserHeaderModel : BBaseModel

@property (nonatomic, strong) NSString *UserKey;
@property (nonatomic, strong) NSString *UserHeaderImg64Str;

//+ (void)saveOrUpdateWithUserKey:(NSString *)UserKey UserHeaderImg64Str:(NSString *)UserHeaderImg64Str;
+ (void)saveOrUpdate:(UserHeaderModel *)model;
+ (NSString *)getUserHeaderImg64StrWithKey:(NSString *)userKey;

@end

NS_ASSUME_NONNULL_END
