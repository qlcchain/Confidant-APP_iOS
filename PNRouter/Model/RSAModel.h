//
//  RSAModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/6.
//  Copyright © 2018 旷自辉. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN

@interface RSAModel : BBaseModel

@property (nonatomic ,strong) NSString *privateKey;
@property (nonatomic ,strong) NSString *publicKey;

@property (nonatomic ,strong) NSString *signPrivateKey;
@property (nonatomic ,strong) NSString *signPublicKey;

@property (nonatomic ,strong) NSString *tempPrivateKey;
@property (nonatomic ,strong) NSString *tempPublicKey;


+ (RSAModel *) getCurrentRASModel;
+ (void) getRSAModel;
+ (instancetype) getShareObject;
@end

NS_ASSUME_NONNULL_END
