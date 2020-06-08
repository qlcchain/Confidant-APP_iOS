//
//  PNFeedbackReplayModel.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/6/2.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <LibsodiumSDK/LibsodiumSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNFeedbackReplayModel : BBaseModel

@property (nonatomic, strong) NSString *createDate;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, assign) BOOL noReply;
@property (nonatomic, strong) NSArray<NSString *> *imageList;

@end

NS_ASSUME_NONNULL_END
