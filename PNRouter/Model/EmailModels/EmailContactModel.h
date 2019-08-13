//
//  EmailContactModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "BBaseModel.h"
#import <BGFMDB/BGFMDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmailContactModel : BBaseModel

@property (nonatomic ,strong) NSString *user;
@property (nonatomic ,strong) NSString *userName;
@property (nonatomic ,strong) NSString *userAddress;
@property (nonatomic ,assign) NSInteger revDate;
@property (nonatomic ,assign) BOOL isSel;

@end

NS_ASSUME_NONNULL_END
