//
//  PNFeedbackMoel.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/6/1.
//  Copyright © 2020 旷自辉. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN
@class PNFeedbackReplayModel;
@interface PNFeedbackMoel : BBaseModel

@property (nonatomic, strong) NSString *createDate;
@property (nonatomic, strong) NSString *resolvedDate;
@property (nonatomic, strong) NSString *feedbackId;
@property (nonatomic, strong) NSArray<NSString *> *imageList;
@property (nonatomic, strong) NSString *number;
@property (nonatomic, strong) NSString *question;
@property (nonatomic, strong) NSString *scenario;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSMutableArray <PNFeedbackReplayModel*>*replayList;
@end


NS_ASSUME_NONNULL_END
