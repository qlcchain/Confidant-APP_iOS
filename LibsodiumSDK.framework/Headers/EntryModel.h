//
//  EntryModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/1/17.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface EntryModel : BBaseModel

@property (nonatomic ,strong) NSString *privateKey;
@property (nonatomic ,strong) NSString *publicKey;

@property (nonatomic ,strong) NSString *signPrivateKey;
@property (nonatomic ,strong) NSString *signPublicKey;

@property (nonatomic ,strong) NSString *tempPrivateKey;
@property (nonatomic ,strong) NSString *tempPublicKey;


+ (instancetype) getShareObject;

@end

NS_ASSUME_NONNULL_END
