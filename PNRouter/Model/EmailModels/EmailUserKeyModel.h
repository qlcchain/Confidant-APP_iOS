//
//  EmailUserKeyModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/8/1.
//  Copyright © 2019 旷自辉. All rights reserved.
//



NS_ASSUME_NONNULL_BEGIN

@interface EmailUserKeyModel : BBaseModel
@property (nonatomic ,strong) NSString *User;
@property (nonatomic ,strong) NSString *PubKey;
@end

NS_ASSUME_NONNULL_END
