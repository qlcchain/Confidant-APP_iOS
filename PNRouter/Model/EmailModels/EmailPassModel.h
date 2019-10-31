//
//  EmailPassModel.h
//  MyConfidant
//
//  Created by 旷自辉 on 2019/10/28.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <LibsodiumSDK/LibsodiumSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmailPassModel : BBaseModel
@property (nonatomic ,strong) NSString *passStr;
@property (nonatomic ,strong) NSString *depassStr;
@property (nonatomic ,strong) NSString *hintStr;
@property (nonatomic ,assign) BOOL isSet;
@end

NS_ASSUME_NONNULL_END
