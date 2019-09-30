//
//  PNSysPushModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/9/23.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <LibsodiumSDK/LibsodiumSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNSysPushModel : BBaseModel
@property (nonatomic, strong) NSString *ToId;
@property (nonatomic, strong) NSString *UserId;
@property (nonatomic, strong) NSString *Name;
@property (nonatomic, strong) NSString *UserKey;
@property (nonatomic, assign) NSInteger Type;
@end

NS_ASSUME_NONNULL_END
