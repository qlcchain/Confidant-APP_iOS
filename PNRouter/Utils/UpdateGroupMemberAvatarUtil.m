//
//  UpdateGroupMemberAvatarUtil.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/20.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "UpdateGroupMemberAvatarUtil.h"
#import "UserHeadUtil.h"

@implementation UpdateGroupMemberAvatarUtil

#pragma mark - 更新群主里面没有头像的用户头像
+ (void)updateAvatar:(NSArray *)userIdArr {
    [userIdArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *userId = obj;
        [UpdateGroupMemberAvatarUtil sendUpdateAvatar:userId];
    }];
}

+ (void)sendUpdateAvatar:(NSString *)userId {
    NSString *Fid = userId?:@"";
    NSString *Md5 = @"0";
    [[UserHeadUtil getUserHeadUtilShare] sendUpdateAvatarWithFid:Fid md5:Md5 showHud:NO];
}

@end
