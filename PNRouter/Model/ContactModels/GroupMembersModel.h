//
//  GroupMembersModel.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/19.
//  Copyright © 2019 旷自辉. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface GroupMembersModel : BBaseModel

@property (nonatomic, strong) NSNumber *Id;
@property (nonatomic, strong) NSString *ToxId;
@property (nonatomic, strong) NSNumber *Type; // 0：群主  1：管理员   2：普通群友
@property (nonatomic, strong) NSNumber *Local; // 0：本地用户   1：跨路由用户
@property (nonatomic, strong) NSString *RId;
@property (nonatomic, strong) NSString *Nickname;
@property (nonatomic, strong) NSString *Remarks;
@property (nonatomic, strong) NSString *UserKey;
@property (nonatomic, strong) NSString *showName;

@end

NS_ASSUME_NONNULL_END
