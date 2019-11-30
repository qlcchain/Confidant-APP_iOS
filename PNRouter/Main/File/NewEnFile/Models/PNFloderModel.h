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

@interface PNFloderModel : BBaseModel<BGProtocol>

@property (assign, nonatomic) NSInteger fId;
@property (strong, nonatomic) NSString *PathName;
@property (assign, nonatomic) NSInteger FilesNum;
@property (assign, nonatomic) NSInteger LastModify;

@end

NS_ASSUME_NONNULL_END
