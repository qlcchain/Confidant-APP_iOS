//
//  RSAModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/6.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface RSAModel : BBaseModel

@property (nonatomic ,strong) NSString *privateKey;
@property (nonatomic ,strong) NSString *publicKey;

+ (RSAModel *) getCurrentRASModel;
@end

NS_ASSUME_NONNULL_END
