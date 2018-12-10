//
//  RSAUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/6.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RSAModel;


NS_ASSUME_NONNULL_BEGIN

@interface RSAUtil : NSObject

+ (RSAModel *) genterRSAPrivateKeyAndPublicKey;
+ (NSString *) pubcliKeyEncryptValue:(NSString *) msgValue;
#pragma mark -私钥解密
+ (NSString *) privateKeyDecryptValue:(NSString *) msgValue;
#pragma mark -私钥加密
+ (NSString *) privateKeyEncryptValue:(NSString *) msgValue;
#pragma makr -公钥解密
+ (NSString *) publicKeyDecryptValue:(NSString *) msgValue;
#pragma mark -对方公钥加密
+ (NSString *) publicEncrypt:(NSString *) pubKey msgValue:(NSString *) msgValue;
@end

NS_ASSUME_NONNULL_END
