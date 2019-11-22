//
//  PNFloderModel.h
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/21.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <LibsodiumSDK/LibsodiumSDK.h>
#import <BGFMDB/BGFMDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNFloderModel : BBaseModel

@property (strong, nonatomic) NSString *floderName;
@property (strong, nonatomic) NSString *userId;
@property (assign, nonatomic) NSInteger floderType;

@end

NS_ASSUME_NONNULL_END
