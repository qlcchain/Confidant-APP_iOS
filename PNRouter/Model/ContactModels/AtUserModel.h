//
//  AtUserModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/5/5.
//  Copyright © 2019 旷自辉. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface AtUserModel : BBaseModel
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *atName;
@end

NS_ASSUME_NONNULL_END
