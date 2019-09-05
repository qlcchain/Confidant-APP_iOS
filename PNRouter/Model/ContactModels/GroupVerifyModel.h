//
//  GroupVerifyModel.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface GroupVerifyModel : BBaseModel

@property (nonatomic, strong) NSString *From;
@property (nonatomic, strong) NSString *To;
@property (nonatomic, strong) NSString *Aduit;
@property (nonatomic, strong) NSString *GId;
@property (nonatomic, strong) NSString *Msg;
@property (nonatomic, strong) NSString *UserPubKey; // 受邀人的签名公钥
@property (nonatomic, strong) NSString *UserGroupKey; // 受邀人的群密钥
@property (nonatomic, strong) NSString *FromName;
@property (nonatomic, strong) NSString *ToName;
@property (nonatomic, strong) NSString *Gname;

@property (nonatomic, strong) NSDate *requestTime; // 请求时间（判断是否过期）
@property (nonatomic, strong) NSString *userId; // 当前用户id
@property (nonatomic) NSInteger status; // 0：同意   1：已同意   2：等待   3：过期
@property (nonatomic) BOOL isUnRead; // 未读

@end

NS_ASSUME_NONNULL_END
