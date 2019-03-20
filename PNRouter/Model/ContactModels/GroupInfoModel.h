//
//  GroupInfoModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupInfoModel : BBaseModel

@property (nonatomic, strong) NSString *GAdmin;
@property (nonatomic, assign) int UserType;
@property (nonatomic, strong) NSString *GId;
@property (nonatomic, strong) NSString *GName;
@property (nonatomic, strong) NSString *Remark;
@property (nonatomic, strong) NSString *UserKey;

@property (nonatomic) BOOL isOwner;

@end

NS_ASSUME_NONNULL_END
