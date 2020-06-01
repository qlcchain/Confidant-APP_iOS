//
//  PNFeedbackTypeModel.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/26.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <LibsodiumSDK/LibsodiumSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNFeedbackTypeModel : BBaseModel
@property (nonatomic, strong) NSString *typeName;
@property (nonatomic, assign) NSInteger typeNo;
@end

NS_ASSUME_NONNULL_END
