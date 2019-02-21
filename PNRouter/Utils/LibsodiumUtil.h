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
// char[] 田转字符串
+ (NSMutableString *) charsToString:(unsigned char[]) chars length:(int) length;
+ (void) changeUserPrivater:(NSString *) privater;
+ (EntryModel *) getPrivatekeyAndPublickey;
// 生成对称密钥
+ (NSString *) getSymmetryWithPrivate:(NSString *) privateKey publicKey:(NSString *) publicKey;
//  加密消息
+ (NSString *) encryMsgPairWithSymmetry:(NSString *) symmetryKey enMsg:(NSString *) enMsg nonce:(NSString *) nonce;
//  解密消息
+ (NSString *) decryMsgPairWithSymmetry:(NSString *) symmetryKey enMsg:(NSString *) deMsg nonce:(NSString *) nonce;
// 签名私钥签名临时公钥
+ (NSString *) getOwenrSignPrivateKeySignOwenrTempPublickKey;
// 签名私钥签名字符串
+ (NSString *) getOwenrSignTemp:(NSString *) temptime;
+ (BOOL)verifySign:(NSString *)sign withSignPublickey:(NSString *) signPublickey timestamp:(NSString *)timestamp;
// 签名验证
+ (NSString *) verifySignWithSignPublickey:(NSString *) signPublickey verifyMsg:(NSString *) verifyMsg;
// 公钥加密对称密钥 -非对称加密方式
+ (NSString *) asymmetricEncryptionWithSymmetry:(NSString *) symmetryKey enPK:(NSString *) enpk;
// 私钥解密对称密钥 -非对称解密
+ (NSString *) asymmetricDecryptionWithSymmetry:(NSString *) symmetryKey;
// 签名公钥转加密公钥
+ (NSString *) getFriendEnPublickkeyWithFriendSignPublicKey:(NSString *) friendSignPublicKey;
// 得到生成对称密钥nonce
+ (NSString *) getGenterSysmetryNonce;
// 加密文件
+ (NSData *) encryMsgPairWithSymmetry:(NSString *) symmetryKey enFileData:(NSData *) fileData;
+ (NSData *) decryMsgPairWithSymmetry:(NSString *) symmetryKey enFileData:(NSData *) fileData;

@end


NS_ASSUME_NONNULL_END
