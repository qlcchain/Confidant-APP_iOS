//
//  PNCampaignModel.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/19.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <LibsodiumSDK/LibsodiumSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNCampaignModel : BBaseModel

@property(nonatomic, strong) NSString *content;
@property(nonatomic, strong) NSString *campaignId;
@property(nonatomic, strong) NSString *status;
@property(nonatomic, strong) NSString *digest;
@property (nonatomic, strong) NSString *createDate;
@property(nonatomic, strong) NSString *subject;
@property(nonatomic, assign) NSInteger *type;
@property (nonatomic, assign) CGFloat fontH;
@property (nonatomic, assign) CGFloat subjectH;
@property (nonatomic, assign) CGFloat contentH;
@property (nonatomic, assign) BOOL isMore;
@property (nonatomic, assign) BOOL isShow;
@end

NS_ASSUME_NONNULL_END
