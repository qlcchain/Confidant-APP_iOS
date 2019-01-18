//
//  LibsodiumUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/1/15.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>
@class EntryModel;

NS_ASSUME_NONNULL_BEGIN

@interface LibsodiumUtil : NSObject
+ (NSMutableString *) charsToString:(unsigned char[]) chars length:(int) length;

+ (EntryModel *) getPrivatekeyAndPublickey;
// 生成对称密钥
+ (NSString *) getSymmetryWithPrivate:(NSString *) privateKey publicKey:(NSString *) publicKey;

//  加密消息
+ (NSString *) encryMsgPairWithSymmetry:(NSString *) symmetryKey enMsg:(NSString *) enMsg nonce:(NSString *) nonce;
//  解密消息
+ (NSString *) decryMsgPairWithSymmetry:(NSString *) symmetryKey enMsg:(NSString *) deMsg nonce:(NSString *) nonce;
+ (NSData *) getPrivateKeyData:(NSString *) privateKey;
// 签名私钥签名临时公钥
+ (NSString *) getOwenrSignPrivateKeySignOwenrTempPublickKey;
// 签名验证
+ (BOOL) verifySignWithSignPublickey:(NSString *) signPublickey tempPublic:(NSString *) tempPublicKey verifyMsg:(NSString *) verifyMsg;
// 公钥加密对称密钥 -非对称加密方式
+ (NSString *) asymmetricEncryptionWithSymmetry:(NSString *) symmetryKey;
// 私钥解密对称密钥 -非对称解密
+ (NSString *) asymmetricDecryptionWithSymmetry:(NSString *) symmetryKey;
@end


NS_ASSUME_NONNULL_END
