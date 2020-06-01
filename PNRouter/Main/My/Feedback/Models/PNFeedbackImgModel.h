//
//  PNFeedbackImgModel.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/27.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <LibsodiumSDK/LibsodiumSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNFeedbackImgModel : BBaseModel
@property (nonatomic, strong) UIImage *img;
@property (nonatomic, strong) NSData *imgData;
@property (nonatomic, strong) NSString *imgName;
@end

NS_ASSUME_NONNULL_END
