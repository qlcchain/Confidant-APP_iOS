//
//  RSAUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/6.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "RSAUtil.h"
#import "DDRSAWrapper.h"
#import "KeyCUtil.h"
#import "RSAModel.h"
#import "DDRSAWrapper+openssl.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"

@implementation RSAUtil

+ (RSAModel *) genterRSAPrivateKeyAndPublicKey
{
    RSA *publicKey;
    RSA *privateKey;
    RSAModel *model = nil;
    if ([DDRSAWrapper generateRSAKeyPairWithKeySize:1024 publicKey:&publicKey privateKey:&privateKey]) {
        model = [[RSAModel alloc] init];
        model.publicKey = [DDRSAWrapper base64EncodedStringPublicKey:publicKey];
        model.privateKey = [DDRSAWrapper base64EncodedStringPrivateKey:privateKey];
        NSLog(@"%@",model.publicKey);
        NSLog(@"%@",model.privateKey);
    }
    return model;
}
#pragma mark -公钥加密
+ (NSString *) pubcliKeyEncryptValue:(NSString *) msgValue
{
    RSAModel *model = [RSAModel getCurrentRASModel];
    RSA *publicKey = [DDRSAWrapper openssl_publicKeyFromBase64:model.publicKey];
    NSData *plainData = [msgValue dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [DDRSAWrapper openssl_encryptWithPublicKey:publicKey
                                                          plainData:plainData
                                                        padding:RSA_PKCS1_PADDING];
   // NSString *enstr = [cipherData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *enstr = [cipherData base64EncodedString];
    
    return enstr;
}
#pragma mark -私钥解密
+ (NSString *) privateKeyDecryptValue:(NSString *) msgValue
{
    RSAModel *model = [RSAModel getCurrentRASModel];
    RSA *privateKey = [DDRSAWrapper openssl_privateKeyFromBase64:model.privateKey];
    
   NSData *cipherData = [msgValue base64DecodedData];
   // NSData *cipherData = [[NSData alloc] initWithBase64EncodedString:msgValue options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    NSData *plainData = [DDRSAWrapper openssl_decryptWithPrivateKey:privateKey
                                                         cipherData:cipherData
                                                            padding:RSA_PKCS1_PADDING];
    
    return  [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
}
#pragma mark -私钥加密
+ (NSString *) privateKeyEncryptValue:(NSString *) msgValue
{
    RSAModel *model = [RSAModel getCurrentRASModel];
    RSA *privateKey = [DDRSAWrapper openssl_privateKeyFromBase64:model.privateKey];
    NSData *plainData = [msgValue dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [DDRSAWrapper openssl_encryptWithPrivateRSA:privateKey
                                                           plainData:plainData
                                                             padding:RSA_PKCS1_PADDING];
    
    return [cipherData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}
#pragma makr -公钥解密
+ (NSString *) publicKeyDecryptValue:(NSString *) msgValue
{
    RSAModel *model = [RSAModel getCurrentRASModel];
    RSA *publicKey = [DDRSAWrapper openssl_publicKeyFromBase64:model.publicKey];
    NSData *cipherData = [[NSData alloc] initWithBase64EncodedString:msgValue options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    NSData *plainData = [DDRSAWrapper openssl_decryptWithPublicKey:publicKey
                                                        cipherData:cipherData
                                                           padding:RSA_PKCS1_PADDING];
    
    return [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
}

#pragma mark -对方公钥加密
+ (NSString *) publicEncrypt:(NSString *) pubKey msgValue:(NSString *) msgValue
{
    RSA *publicKey = [DDRSAWrapper openssl_publicKeyFromBase64:pubKey];
    NSData *plainData = [msgValue dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherData = [DDRSAWrapper openssl_encryptWithPublicKey:publicKey
                                                          plainData:plainData
                                                            padding:RSA_PKCS1_PADDING];
     NSString *enstr = [cipherData base64EncodedString];
    return enstr;
   // return  [cipherData base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}
@end
