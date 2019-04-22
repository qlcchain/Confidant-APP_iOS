//
//  LibsodiumUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/1/15.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "LibsodiumUtil.h"
#import "EntryModel.h"
#import <libsodium/crypto_box.h>
#import "KeyCUtil.h"
#import "crypto_core.h"
#import <libsodium/crypto_box.h>
#import <libsodium/crypto_sign.h>
#import "PNRouter-Swift.h"
#import "NSString+HexStr.h"
#import "ccompat.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"

#define libkey @"libkey"


@implementation LibsodiumUtil

+ (void) changeUserPrivater:(NSString *) privater
{
//    NSString *modelJson = [KeyCUtil getKeyValueWithKey:libkey];
//    EntryModel *model = [EntryModel getObjectWithKeyValues:[modelJson mj_keyValues]];
//    if (model) {
//
//        model.signPrivateKey = privater;
//        NSData *signskData = [privater base64DecodedData];
//        NSData *signpkData = [signskData subdataWithRange:NSMakeRange(32,32)];
//        model.signPublicKey = [signpkData base64EncodedString];
//
//        unsigned char pk[32];
//        unsigned char sk[32];
//        const unsigned char *signsk = [signskData bytes];
//        const unsigned char *signpk = [signpkData bytes];
//        // 签名转解密
//        int signResult = crypto_sign_ed25519_pk_to_curve25519(pk,signpk);
//        signResult = crypto_sign_ed25519_sk_to_curve25519(sk,signsk);
//
//        NSData *pkData = [NSData dataWithBytesNoCopy:pk length:32 freeWhenDone:NO];
//        NSData *skData = [NSData dataWithBytesNoCopy:sk length:32 freeWhenDone:NO];
//
//        model.publicKey = [pkData base64EncodedString];
//        model.privateKey = [skData base64EncodedString];
//
//        [KeyCUtil saveStringToKeyWithString:model.mj_JSONString key:libkey];
//
//        [EntryModel getShareObject].publicKey = model.publicKey;
//        [EntryModel getShareObject].privateKey = model.privateKey;
//        [EntryModel getShareObject].signPublicKey = model.signPublicKey;
//        [EntryModel getShareObject].signPrivateKey = model.signPrivateKey;
//    } else {
    
    EntryModel *model = [[EntryModel alloc] init];
    model.signPrivateKey = privater;
    NSData *signskData = [privater base64DecodedData];
    NSData *signpkData = [signskData subdataWithRange:NSMakeRange(32,32)];
    model.signPublicKey = [signpkData base64EncodedString];
    
    unsigned char pk[32];
    unsigned char sk[32];
    const unsigned char *signsk = [signskData bytes];
    const unsigned char *signpk = [signpkData bytes];
    // 签名转解密
    int signResult = crypto_sign_ed25519_pk_to_curve25519(pk,signpk);
    signResult = crypto_sign_ed25519_sk_to_curve25519(sk,signsk);
    
    NSData *pkData = [NSData dataWithBytesNoCopy:pk length:32 freeWhenDone:NO];
    NSData *skData = [NSData dataWithBytesNoCopy:sk length:32 freeWhenDone:NO];
    
    model.publicKey = [pkData base64EncodedString];
    model.privateKey = [skData base64EncodedString];
    
    [KeyCUtil saveStringToKeyWithString:model.mj_JSONString key:libkey];
    
    [EntryModel getShareObject].publicKey = model.publicKey;
    [EntryModel getShareObject].privateKey = model.privateKey;
    [EntryModel getShareObject].signPublicKey = model.signPublicKey;
    [EntryModel getShareObject].signPrivateKey = model.signPrivateKey;
    
    // 生成临时公私钥对
    unsigned char temppk[32];
    unsigned char tempsk[32];
    crypto_box_keypair(temppk, tempsk);
    
    
    NSData *temppkdata = [NSData dataWithBytesNoCopy:temppk length:32 freeWhenDone:NO];
    NSData *tempskdata = [NSData dataWithBytesNoCopy:tempsk length:32 freeWhenDone:NO];
    
    // 将临时公私钥对转成nsstring 并以空格隔开
    NSString *tempPublicString = [temppkdata base64EncodedString];
    NSString *tempPrivateString = [tempskdata base64EncodedString];
    
    model.tempPublicKey = tempPublicString;
    model.tempPrivateKey = tempPrivateString;
    [EntryModel getShareObject].publicKey = model.publicKey;
    [EntryModel getShareObject].privateKey = model.privateKey;
    [EntryModel getShareObject].signPublicKey = model.signPublicKey;
    [EntryModel getShareObject].signPrivateKey = model.signPrivateKey;
    [EntryModel getShareObject].tempPublicKey = tempPublicString;
    [EntryModel getShareObject].tempPrivateKey = tempPrivateString;
    
//    }
}

+ (EntryModel *) getPrivatekeyAndPublickey
{
    EntryModel *model = nil;
    NSString *modelJson = [KeyCUtil getKeyValueWithKey:libkey];
    if ([[NSString getNotNullValue:modelJson] isEmptyString]) {
        
        unsigned char signpk[32];
        unsigned char signsk[64];

        unsigned char pk[32];
        unsigned char sk[32];
       // 生成签名公私钥对
        crypto_sign_keypair(signpk,signsk);
        // 签名公私钥对转换成解密公私钥对
        int signResult = crypto_sign_ed25519_pk_to_curve25519(pk,signpk);
        signResult = crypto_sign_ed25519_sk_to_curve25519(sk,signsk);
        
        // 将签名公私钥对转成nsstring 并以空格隔开
         NSData *signpkdata = [NSData dataWithBytesNoCopy:signpk length:32 freeWhenDone:NO];
         NSString *signPublicString = [signpkdata base64EncodedString];
        
        NSData *signskdata = [NSData dataWithBytesNoCopy:signsk length:64 freeWhenDone:NO];
        NSString *signPrivateString = [signskdata base64EncodedString];
        
        // 将解密公私钥对转成nsstring 并以空格隔开
        NSData *pkdata = [NSData dataWithBytesNoCopy:pk length:32 freeWhenDone:NO];
        NSString *enPublicString = [pkdata base64EncodedString];
        NSData *skdata = [NSData dataWithBytesNoCopy:sk length:32 freeWhenDone:NO];
        NSString *enPrivateString = [skdata base64EncodedString];
        
        model = [[EntryModel alloc] init];
        model.publicKey = enPublicString;
        model.privateKey = enPrivateString;
        model.signPublicKey = signPublicString;
        model.signPrivateKey = signPrivateString;
        [KeyCUtil saveStringToKeyWithString:model.mj_JSONString key:libkey];
    } else {
        if (![[NSString getNotNullValue:[EntryModel getShareObject].publicKey] isEmptyString]) {
            model = [EntryModel getShareObject];
        } else {
            model = [EntryModel getObjectWithKeyValues:[modelJson mj_keyValues]];
        }
        
    }
    
    // 生成临时公私钥对
    unsigned char temppk[32];
    unsigned char tempsk[32];
    crypto_box_keypair(temppk, tempsk);
    
    
    NSData *temppkdata = [NSData dataWithBytesNoCopy:temppk length:32 freeWhenDone:NO];
    NSData *tempskdata = [NSData dataWithBytesNoCopy:tempsk length:32 freeWhenDone:NO];

    // 将临时公私钥对转成nsstring 并以空格隔开
    NSString *tempPublicString = [temppkdata base64EncodedString];
    NSString *tempPrivateString = [tempskdata base64EncodedString];

    model.tempPublicKey = tempPublicString;
    model.tempPrivateKey = tempPrivateString;
    [EntryModel getShareObject].publicKey = model.publicKey;
    [EntryModel getShareObject].privateKey = model.privateKey;
    [EntryModel getShareObject].signPublicKey = model.signPublicKey;
    [EntryModel getShareObject].signPrivateKey = model.signPrivateKey;
    [EntryModel getShareObject].tempPublicKey = tempPublicString;
    [EntryModel getShareObject].tempPrivateKey = tempPrivateString;
    
    return model;
}

// char[] 转nsstring 32
+ (NSMutableString *) charsToString:(unsigned char[]) chars length:(int) length
{
    NSLog(@"chars = %s",chars);
    NSMutableString *hexString = [[NSMutableString alloc] init];
    for (int i=0; i<length; i++)
    {
        if (i == length-1) {
            [hexString appendFormat:@"%x", chars[i]];
        } else {
            [hexString appendFormat:@"%x", chars[i]];
        }
        
    }
    NSLog(@"hexString = %@",hexString);
    return hexString;
}
// 生成对称密钥
+ (NSString *) getSymmetryWithPrivate:(NSString *) privateKey publicKey:(NSString *) publicKey
{
    if ([[NSString getNotNullValue:privateKey] isEmptyString] || [[NSString getNotNullValue:publicKey] isEmptyString]) {
        return @"";
    }
    unsigned char gk[32];
 
    NSData *skData = [privateKey base64DecodedData];
    const unsigned char *sk = [skData bytes];
    NSData *pkData = [publicKey base64DecodedData];
    const unsigned char *pk = [pkData bytes];
    // 生成对称密钥
    int result = crypto_box_beforenm(gk,pk,sk);
    if (result >= 0) {
         NSData *gkData = [NSData dataWithBytesNoCopy:gk length:32 freeWhenDone:NO];
        return [gkData base64EncodedString];
    }
    return @"";
}
// 加密文件
+ (NSData *) encryMsgPairWithSymmetry:(NSString *) symmetryKey enFileData:(NSData *) fileData
{
    if ([[NSString getNotNullValue:symmetryKey] isEmptyString]) {
        return nil;
    }
    
    // 得到对称密钥
    NSData *gkData = [symmetryKey base64DecodedData];
    const unsigned char *gk = [gkData bytes];
    
    NSData *nonceData = [FILE_NONCE base64DecodedData];
    const uint8_t *nonceKey = [nonceData bytes];
    
    //将加密消息 base58转码
    char *css = [fileData bytes];
    int lenght = fileData.length;
    char enstr[lenght+crypto_box_BOXZEROBYTES];
    const int encrypted_length = encrypt_data_symmetric(gk,nonceKey, css,lenght, enstr);
    if (encrypted_length) {
        // NSLog(@"---%s",enstr);
        NSLog(@"------加密成功");
        NSData *enstrData = [NSData dataWithBytesNoCopy:enstr length:lenght+crypto_box_BOXZEROBYTES freeWhenDone:NO];
        return enstrData;
    }
    
    return nil;
}



// 解密文件
+ (NSData *) decryMsgPairWithSymmetry:(NSString *) symmetryKey enFileData:(NSData *) fileData
{
    if ([[NSString getNotNullValue:symmetryKey] isEmptyString] ) {
        return nil;
    }
    
    // 得到对称密钥
    NSData *gkData = [symmetryKey base64DecodedData];
    const unsigned char *gk = [gkData bytes];
    
    NSData *nonceData = [FILE_NONCE base64DecodedData];
    const uint8_t *nonceKey = [nonceData bytes];
    
    const char *msgKey = [fileData bytes];
    int length = fileData.length;
    char destr[length+crypto_box_ZEROBYTES];
    const int decrypted_length = decrypt_data_symmetric(gk,nonceKey, msgKey,length, destr);
    if (decrypted_length >= 0) {
    
        // NSLog(@"---%@---解密成功",destrsss);
        NSLog(@"------解密成功");
        return nil;
    }
    return nil;
}





//  加密消息
+ (NSString *) encryMsgPairWithSymmetry:(NSString *) symmetryKey enMsg:(NSString *) enMsg nonce:(NSString *) nonce
{
    if ([[NSString getNotNullValue:symmetryKey] isEmptyString] || [[NSString getNotNullValue:enMsg] isEmptyString] || [[NSString getNotNullValue:nonce] isEmptyString]) {
        return @"";
    }
    
    // 得到对称密钥
    NSData *gkData = [symmetryKey base64DecodedData];
    const unsigned char *gk = [gkData bytes];
    
    NSData *nonceData = [nonce base64DecodedData];
    const uint8_t *nonceKey = [nonceData bytes];
    
    //将加密消息 base58转码
    NSData *msgtData =[enMsg dataUsingEncoding:NSUTF8StringEncoding];
    char *msgKey = [msgtData bytes];
    
    //enMsg = [enMsg base64EncodedString];
    //char css[enMsg.length+1];
    //memcpy(css, [enMsg cStringUsingEncoding:NSASCIIStringEncoding],[enMsg length]+1);
   // char enstr[sizeof(css)+crypto_box_BOXZEROBYTES];
//    char enstr[sizeof(css)+crypto_box_BOXZEROBYTES];
//    const int encrypted_length = encrypt_data_symmetric(gk,nonceKey, css,sizeof(css), enstr);
    int length = msgtData.length;
    char enstr[length+crypto_box_MACBYTES];
    const int encrypted_length = encrypt_data_symmetric(gk,nonceKey,msgKey,length, enstr);
    if (encrypted_length) {
       // NSLog(@"---%s",enstr);
        NSLog(@"------加密成功");
         NSData *enstrData = [NSData dataWithBytesNoCopy:enstr length:length+crypto_box_MACBYTES freeWhenDone:NO];
        return [enstrData base64EncodedString];
    }
    
    return @"";
}

//  解密消息
+ (NSString *) decryMsgPairWithSymmetry:(NSString *) symmetryKey enMsg:(NSString *) deMsg nonce:(NSString *) nonce
{
    if ([[NSString getNotNullValue:symmetryKey] isEmptyString] || [[NSString getNotNullValue:deMsg] isEmptyString] || [[NSString getNotNullValue:nonce] isEmptyString]) {
        return @"";
    }
    
    // 得到对称密钥
    NSData *gkData = [symmetryKey base64DecodedData];
    const unsigned char *gk = [gkData bytes];
    
    NSData *nonceData = [nonce base64DecodedData];
    const uint8_t *nonceKey = [nonceData bytes];
    
    NSData  *msgData = [deMsg base64DecodedData];
    const char *msgKey = [msgData bytes];
    int length = msgData.length;
    //char destr[length+crypto_box_ZEROBYTES];
    char destr[length-crypto_box_MACBYTES];
    
    const int decrypted_length = decrypt_data_symmetric(gk,nonceKey, msgKey,length, destr);
    if (decrypted_length >= 0) {
        //NSString *destrsss = [NSString stringWithCString:destr encoding:NSUTF8StringEncoding];
      //  destrsss = [destrsss base64DecodedString];
       // NSLog(@"---%@---解密成功",destrsss);
        NSData *data = [NSData dataWithBytes:destr length:length-crypto_box_MACBYTES];
        NSString* destrsss = [[NSString alloc] initWithData:data  encoding:NSUTF8StringEncoding];
        NSLog(@"------解密成功");
        return destrsss;
    }
    return @"";
}


// 签名私钥签名临时公钥
+ (NSString *) getOwenrSignPrivateKeySignOwenrTempPublickKey
{
    NSData *tempPKData = [[EntryModel getShareObject].tempPublicKey base64DecodedData];
        const unsigned char *tempPK = [tempPKData bytes];
    NSData *singSKData = [[EntryModel getShareObject].signPrivateKey base64DecodedData];
    const unsigned char *singSK = [singSKData bytes];
        
    unsigned char sm[96];
    unsigned long long smlen_p;
    int resut = crypto_sign(sm,&smlen_p,tempPK,tempPKData.length,singSK);
    if (resut >= 0 ) {
        NSData *enstrData = [NSData dataWithBytesNoCopy:sm length:96 freeWhenDone:NO];
        NSString *signStr = [enstrData base64EncodedString];
        return signStr;
    } else {
        return @"";
    }
}

+ (NSString *) getOwenrSignTemp:(NSString *) temptime
{
    NSData *temptimeData = [temptime dataUsingEncoding:NSUTF8StringEncoding];
    const unsigned char *tempTime = [temptimeData bytes];
    
    NSData *singSKData = [[EntryModel getShareObject].signPrivateKey base64DecodedData];
    const unsigned char *singSK = [singSKData bytes];
    
    unsigned char sm[temptimeData.length+64];
    unsigned long long smlen_p;
    int resut = crypto_sign(sm,&smlen_p,tempTime,temptimeData.length,singSK);
    if (resut >= 0 ) {
        NSData *enstrData = [NSData dataWithBytesNoCopy:sm length:temptimeData.length+64 freeWhenDone:NO];
        NSString *signStr = [enstrData base64EncodedString];
        return signStr;
    } else {
        return @"";
    }
}

+ (BOOL)verifySign:(NSString *)sign withSignPublickey:(NSString *) signPublickey timestamp:(NSString *)timestamp {
    //NSLog(@"msgstr = %@",sign);
        
    NSData *msgData = [sign base64DecodedData];
    const unsigned char *msgKey = [msgData bytes];
    
    NSData *signPKData = [signPublickey base64DecodedData];
    const unsigned char *signPK = [signPKData bytes];
    
    unsigned char m[msgData.length];
    unsigned long long mlen_p;
    int result = crypto_sign_open(m,&mlen_p,msgKey,msgData.length,signPK);
    if (result >= 0) {
        return YES;
    }
    return NO;
}

// 签名验证
+ (NSString *) verifySignWithSignPublickey:(NSString *) signPublickey verifyMsg:(NSString *) verifyMsg
{
    
    //NSLog(@"msgstr = %@",verifyMsg);
    
    NSData *msgData = [verifyMsg base64DecodedData];
    const unsigned char *msgKey = [msgData bytes];
    
    NSData *signPKData = [signPublickey base64DecodedData];
    const unsigned char *signPK = [signPKData bytes];
    
    unsigned char m[32];
    unsigned long long mlen_p;
   int result = crypto_sign_open(m,&mlen_p,msgKey,msgData.length,signPK);
    if (result >= 0) {
        NSData *enstrData = [NSData dataWithBytesNoCopy:m length:32 freeWhenDone:NO];
        NSString *singPublic = [enstrData base64EncodedString];
        return singPublic;
    }
    return @"";
}
// 公钥加密对称密钥 -非对称加密方式
+ (NSString *) asymmetricEncryptionWithSymmetry:(NSString *) symmetryKey enPK:(NSString *) enpk
{
    NSData *gkData = [symmetryKey base64DecodedData];
    const unsigned char *gk = [gkData bytes];
    
    NSData *pkData = [enpk base64DecodedData];
    const unsigned char *pk = [pkData bytes];

     unsigned char m[32+48];
     int result = crypto_box_seal(m,gk,gkData.length,pk);
    if (result >=0) {
        NSData *enstrData = [NSData dataWithBytesNoCopy:m length:80 freeWhenDone:NO];
        return [enstrData base64EncodedString];
    }
    return @"";
}
// 私钥解密对称密钥 -非对称解密
+ (NSString *) asymmetricDecryptionWithSymmetry:(NSString *) symmetryKey
{
    NSData *skData = [[EntryModel getShareObject].privateKey base64DecodedData];
    const unsigned char *sk = [skData bytes];
    
    NSData *gkData = [symmetryKey base64DecodedData];
    const unsigned char *gk = [gkData bytes];
    
    NSData *pkData = [[EntryModel getShareObject].publicKey base64DecodedData];
    const unsigned char *pk = [pkData bytes];
   unsigned char m[32];
   int result = crypto_box_seal_open(m,gk,gkData.length,pk,sk);
    if (result >=0) {
        NSData *enstrData = [NSData dataWithBytesNoCopy:m length:32 freeWhenDone:NO];
        return [enstrData base64EncodedString];
    }
    return @"";
}
// 签名公钥转加密公钥
+ (NSString *) getFriendEnPublickkeyWithFriendSignPublicKey:(NSString *) friendSignPublicKey
{
    NSData *signpkData = [friendSignPublicKey base64DecodedData];
    const unsigned char *signpk = [signpkData bytes];
    
    unsigned char pk[32];
    int signResult = crypto_sign_ed25519_pk_to_curve25519(pk,signpk);
    if (signResult >= 0) {
        NSData *enstrData = [NSData dataWithBytesNoCopy:pk length:sizeof(pk) freeWhenDone:NO];
        return [enstrData base64EncodedString];
    }
    return @"";
}
// 得到生成对称密钥nonce
+ (NSString *) getGenterSysmetryNonce
{
    uint8_t nonceKey[CRYPTO_NONCE_SIZE];
    random_nonce(nonceKey);
    NSData *enstrData = [NSData dataWithBytesNoCopy:nonceKey length:sizeof(nonceKey) freeWhenDone:NO];
    return [enstrData base64EncodedString];
}



/*
 + (EntryModel *) getPrivatekeyAndPublickey
 {
 
 EntryModel *model = nil;
 NSString *modelJson = [KeyCUtil getKeyValueWithKey:libkey];
 if (![[NSString getNotNullValue:modelJson] isEmptyString]) {
 
 unsigned char signpk[32];
 unsigned char signsk[64];
 
 unsigned char pk[32];
 unsigned char sk[32];
 // 生成签名公私钥对
 crypto_sign_keypair(signpk,signsk);
 
 // 签名公私钥对转换成解密公私钥对
 int signResult = crypto_sign_ed25519_pk_to_curve25519(pk,signpk);
 signResult = crypto_sign_ed25519_sk_to_curve25519(sk,signsk);
 
 // 将签名公私钥对转成nsstring 并以空格隔开
 NSString *signPublicString = [LibsodiumUtil charsToString:signpk length:32];
 NSString *signPrivateString = [LibsodiumUtil charsToString:signsk length:64];
 // 将解密公私钥对转成nsstring 并以空格隔开
 NSString *enPublicString = [LibsodiumUtil charsToString:pk length:32];
 NSString *enPrivateString = [LibsodiumUtil charsToString:sk length:32];
 
 model = [[EntryModel alloc] init];
 model.publicKey = enPublicString;
 model.privateKey = enPrivateString;
 model.signPublicKey = signPublicString;
 model.signPrivateKey = signPrivateString;
 
 [KeyCUtil saveStringToKeyWithString:model.mj_JSONString key:libkey];
 } else {
 if (![[NSString getNotNullValue:[EntryModel getShareObject].publicKey] isEmptyString]) {
 model = [EntryModel getShareObject];
 } else {
 model = [EntryModel getObjectWithKeyValues:[modelJson mj_keyValues]];
 }
 
 }
 
 // 生成临时公私钥对
 unsigned char temppk[32];
 unsigned char tempsk[32];
 crypto_box_keypair(temppk, tempsk);
 
 
 NSData *pdata = [NSData dataWithBytesNoCopy:temppk length:32 freeWhenDone:NO];
 NSData *sdata = [NSData dataWithBytesNoCopy:tempsk length:32 freeWhenDone:NO];
 
 // NSString *base64 = [sdata base64EncodedString];
 
 char *sspk = [pdata bytes];
 char *sssk = [sdata bytes];
 
 uint8_t nonceKey[CRYPTO_NONCE_SIZE];
 random_nonce(nonceKey);
 
 NSData *nonce = [NSData dataWithBytesNoCopy:nonceKey length:24 freeWhenDone:NO];
     char *nocesss = [nonce bytes];
 
 char gk[32];
 int result = crypto_box_beforenm(gk,sspk,sssk);
     
     NSData *gksdata = [NSData dataWithBytesNoCopy:nonceKey length:32 freeWhenDone:NO];
     char *gksss = [gksdata bytes];
     
 
 NSString *enMsg = [Base58Util Base58EncodeWithCodeName:@"12345好有"];
 char css[enMsg.length*2];
 memcpy(css, [enMsg cStringUsingEncoding:NSASCIIStringEncoding], 2*[enMsg length]);
 char enstr[sizeof(css)+crypto_box_BOXZEROBYTES];
 const int encrypted_length = encrypt_data_symmetric(gksss,nocesss, css,sizeof(css), enstr);
 if (encrypted_length) {
 NSLog(@"---%s",enstr);
 }
   
 NSData *msgdata = [NSData dataWithBytesNoCopy:enstr length:enMsg.length*2+crypto_box_BOXZEROBYTES freeWhenDone:NO];
      int datalen  = msgdata.length;
   char *msgkey =  [msgdata bytes];

 char destr[msgdata.length+crypto_box_ZEROBYTES];
 const int decrypted_length = decrypt_data_symmetric(gksss,nocesss, msgkey,datalen, destr);
 if (decrypted_length >= 0) {
 NSString *destrsss = [NSString stringWithCString:destr encoding:NSUTF8StringEncoding];
 destrsss = [Base58Util Base58DecodeWithCodeName:destrsss];
 NSLog(@"---%@---解密成功",destrsss);
 
 }
 
 // 将临时公私钥对转成nsstring 并以空格隔开
 NSString *tempPublicString = [LibsodiumUtil charsToString:temppk length:32];
 NSString *tempPrivateString = [LibsodiumUtil charsToString:tempsk length:32];
 
 
 
 model.tempPublicKey = tempPublicString;
 model.tempPrivateKey = tempPrivateString;
 [EntryModel getShareObject].publicKey = model.publicKey;
 [EntryModel getShareObject].privateKey = model.privateKey;
 [EntryModel getShareObject].signPublicKey = model.signPublicKey;
 [EntryModel getShareObject].signPrivateKey = model.signPrivateKey;
 [EntryModel getShareObject].tempPublicKey = tempPublicString;
 [EntryModel getShareObject].tempPrivateKey = tempPrivateString;
 
 return model;
 }
 
 // char[] 转nsstring 32
 + (NSMutableString *) charsToString:(unsigned char[]) chars length:(int) length
 {
 NSLog(@"chars = %s",chars);
 NSMutableString *hexString = [[NSMutableString alloc] init];
 for (int i=0; i<length; i++)
 {
 if (i == length-1) {
 [hexString appendFormat:@"%x", chars[i]];
 } else {
 [hexString appendFormat:@"%x", chars[i]];
 }
 
 }
 NSLog(@"hexString = %@",hexString);
 return hexString;
 }
 // 生成对称密钥
 + (NSString *) getSymmetryWithPrivate:(NSString *) privateKey publicKey:(NSString *) publicKey
 {
 if ([[NSString getNotNullValue:privateKey] isEmptyString] || [[NSString getNotNullValue:publicKey] isEmptyString]) {
 return @"";
 }
 unsigned char gk[32];
 unsigned char pk[32];
 unsigned char sk[32];
 
 
 NSArray *publicArr = [publicKey componentsSeparatedByString:@" "];
 for (int i = 0; i < publicArr.count ; ++i) {
 const char *s = [publicArr[i] UTF8String];
 char ch = strtol(s, NULL, 16);
 pk[i] = ch;
 }
 
 NSArray *privateArr = [privateKey componentsSeparatedByString:@" "];
 for (int i = 0; i < privateArr.count ; ++i) {
 const char *s = [privateArr[i] UTF8String];
 char ch = strtol(s, NULL, 16);
 sk[i] = ch;
 }
 // 生成对称密钥
 int result = crypto_box_beforenm(gk,pk,sk);
 if (result >= 0) {
 return [LibsodiumUtil charsToString:gk length:32];
 }
 return @"";
 }
 
 //  加密消息
 + (NSString *) encryMsgPairWithSymmetry:(NSString *) symmetryKey enMsg:(NSString *) enMsg nonce:(NSString *) nonce
 {
 if ([[NSString getNotNullValue:symmetryKey] isEmptyString] || [[NSString getNotNullValue:enMsg] isEmptyString] || [[NSString getNotNullValue:nonce] isEmptyString]) {
 return @"";
 }
 
 unsigned char gk[32];
 // 得到对称密钥
 NSArray *publicArr = [symmetryKey componentsSeparatedByString:@" "];
 for (int i = 0; i < publicArr.count ; ++i) {
 const char *s = [publicArr[i] UTF8String];
 char ch = strtol(s, NULL, 16);
 gk[i] = ch;
 }
 
 uint8_t nonceKey[CRYPTO_NONCE_SIZE];
 NSArray *nonceArr = [nonce componentsSeparatedByString:@" "];
 for (int i = 0; i < nonceArr.count ; ++i) {
 const char *s = [nonceArr[i] UTF8String];
 char ch = strtol(s, NULL, 16);
 nonceKey[i] = ch;
 }
 
 //将加密消息 base58转码
 enMsg = [Base58Util Base58EncodeWithCodeName:enMsg];
 char css[enMsg.length*2];
 memcpy(css, [enMsg cStringUsingEncoding:NSASCIIStringEncoding], 2*[enMsg length]);
 char enstr[sizeof(css)+crypto_box_BOXZEROBYTES];
 const int encrypted_length = encrypt_data_symmetric(gk,nonceKey, css,sizeof(css), enstr);
 if (encrypted_length) {
 NSLog(@"---%s",enstr);
 return [LibsodiumUtil charsToString:enstr length:sizeof(enstr)];
 }
 
 return @"";
 }
 
 //  解密消息
 + (NSString *) decryMsgPairWithSymmetry:(NSString *) symmetryKey enMsg:(NSString *) deMsg nonce:(NSString *) nonce
 {
 if ([[NSString getNotNullValue:symmetryKey] isEmptyString] || [[NSString getNotNullValue:deMsg] isEmptyString] || [[NSString getNotNullValue:nonce] isEmptyString]) {
 return @"";
 }
 
 unsigned char gk[32];
 // 得到对称密钥
 NSArray *publicArr = [symmetryKey componentsSeparatedByString:@" "];
 for (int i = 0; i < publicArr.count ; ++i) {
 const char *s = [publicArr[i] UTF8String];
 char ch = strtol(s, NULL, 16);
 gk[i] = ch;
 }
 uint8_t nonceKey[CRYPTO_NONCE_SIZE];
 NSArray *nonceArr = [nonce componentsSeparatedByString:@" "];
 for (int i = 0; i < nonceArr.count ; ++i) {
 const char *s = [nonceArr[i] UTF8String];
 char ch = strtol(s, NULL, 16);
 nonceKey[i] = ch;
 }
 
 // 加密字符串转成 char[]
 NSArray *msgArr = [deMsg componentsSeparatedByString:@" "];
 unsigned char enstrmsgkey[msgArr.count];
 for (int i = 0; i < msgArr.count ; ++i) {
 const char *s = [msgArr[i] UTF8String];
 char ch = strtol(s, NULL, 16);
 enstrmsgkey[i] = ch;
 }
 
 unsigned char parkey2[32];
 char destr[sizeof(enstrmsgkey)+crypto_box_ZEROBYTES];
 const int decrypted_length = decrypt_data_symmetric(gk,nonceKey, enstrmsgkey,sizeof(enstrmsgkey), destr);
 if (decrypted_length >= 0) {
 NSString *destrsss = [NSString stringWithCString:destr encoding:NSUTF8StringEncoding];
 destrsss = [Base58Util Base58DecodeWithCodeName:destrsss];
 NSLog(@"---%@---解密成功",destrsss);
 return destrsss;
 }
 return @"";
 }
 
 
 // 签名私钥签名临时公钥
 + (NSString *) getOwenrSignPrivateKeySignOwenrTempPublickKey
 {
 
 NSArray *temppkArr = [[EntryModel getShareObject].tempPublicKey componentsSeparatedByString:@" "];
 unsigned char tempPK[32];
 for (int i = 0; i < temppkArr.count ; ++i) {
 const char *s = [temppkArr[i] UTF8String];
 char ch = strtol(s, NULL, 16);
 tempPK[i] = ch;
 }
 
 NSArray *signPrivateArr = [[EntryModel getShareObject].signPrivateKey componentsSeparatedByString:@" "];
 unsigned char singSK[64];
 for (int i = 0; i < signPrivateArr.count ; ++i) {
 const char *s = [signPrivateArr[i] UTF8String];
 char ch = strtol(s, NULL, 16);
 singSK[i] = ch;
 }
 
 unsigned char sm[96];
 unsigned long long smlen_p;
 int resut = crypto_sign(sm,&smlen_p,tempPK,sizeof(tempPK),singSK);
 if (resut >= 0 ) {
 NSString *signStr = [LibsodiumUtil charsToString:sm length:96];
 return signStr;
 } else {
 return @"";
 }
 }
 // 签名验证
 + (BOOL) verifySignWithSignPublickey:(NSString *) signPublickey tempPublic:(NSString *) tempPublicKey verifyMsg:(NSString *) verifyMsg
 {
 
 NSLog(@"msgstr = %@",verifyMsg);
 NSArray *msgArr = [verifyMsg componentsSeparatedByString:@" "];
 unsigned char msgKey[96];
 for (int i = 0; i < msgArr.count ; ++i) {
 const char *s = [msgArr[i] UTF8String];
 char ch = strtol(s, NULL, 16);
 msgKey[i] = ch;
 }
 
 
 NSArray *signPKArr = [signPublickey componentsSeparatedByString:@" "];
 unsigned char signPK[32];
 for (int i = 0; i < signPKArr.count ; ++i) {
 const char *s = [signPKArr[i] UTF8String];
 char ch = strtol(s, NULL, 16);
 signPK[i] = ch;
 }
 
 unsigned char m[32];
 unsigned long long mlen_p;
 int result = crypto_sign_open(m,&mlen_p,msgKey,sizeof(msgKey),signPK);
 if (result >= 0) {
 NSString *singPublic = [LibsodiumUtil charsToString:m length:sizeof(m)];
 NSLog(@"pk = %@,singPublic = %@",tempPublicKey,singPublic);
 return YES;
 }
 return NO;
 }
 // 公钥加密对称密钥 -非对称加密方式
 + (NSString *) asymmetricEncryptionWithSymmetry:(NSString *) symmetryKey
 
 {
 unsigned char gk[32];
 NSArray *symmetryKeyArr = [symmetryKey componentsSeparatedByString:@" "];
 for (int i = 0; i < symmetryKeyArr.count ; ++i) {
 const char *s = [symmetryKeyArr[i] UTF8String];
 char ch = strtol(s, NULL, 16);
 gk[i] = ch;
 }
 unsigned char pk[32];
 NSArray *publicArr = [[EntryModel getShareObject].publicKey componentsSeparatedByString:@" "];
 for (int i = 0; i < publicArr.count ; ++i) {
 const char *s = [publicArr[i] UTF8String];
 char ch = strtol(s, NULL, 16);
 pk[i] = ch;
 }
 
 unsigned char m[32+48];
 int result = crypto_box_seal(m,gk,sizeof(gk),pk);
 if (result >=0) {
 return [LibsodiumUtil charsToString:m length:80];
 }
 return @"";
 }
 // 私钥解密对称密钥 -非对称解密
 + (NSString *) asymmetricDecryptionWithSymmetry:(NSString *) symmetryKey
 {
 unsigned char sk[32];
 NSArray *privateArr = [[EntryModel getShareObject].privateKey componentsSeparatedByString:@" "];
 for (int i = 0; i < privateArr.count ; ++i) {
 const char *s = [privateArr[i] UTF8String];
 char ch = strtol(s, NULL, 16);
 sk[i] = ch;
 }
 unsigned char m[32];
 
 unsigned char gk[80];
 NSArray *symmetryKeyArr = [symmetryKey componentsSeparatedByString:@" "];
 for (int i = 0; i < symmetryKeyArr.count ; ++i) {
 const char *s = [symmetryKeyArr[i] UTF8String];
 char ch = strtol(s, NULL, 16);
 gk[i] = ch;
 }
 
 unsigned char pk[32];
 NSArray *publicArr = [[EntryModel getShareObject].publicKey componentsSeparatedByString:@" "];
 for (int i = 0; i < publicArr.count ; ++i) {
 const char *s = [publicArr[i] UTF8String];
 char ch = strtol(s, NULL, 16);
 pk[i] = ch;
 }
 
 int result = crypto_box_seal_open(m,gk,sizeof(gk),pk,sk);
 if (result >=0) {
 return [LibsodiumUtil charsToString:m length:32];
 }
 return @"";
 }
 // 签名公钥转加密公钥
 + (NSString *) getFriendEnPublickkeyWithFriendSignPublicKey:(NSString *) friendSignPublicKey
 {
 unsigned char signpk[32];
 NSArray *publicArr = [friendSignPublicKey componentsSeparatedByString:@" "];
 for (int i = 0; i < publicArr.count ; ++i) {
 const char *s = [publicArr[i] UTF8String];
 char ch = strtol(s, NULL, 16);
 signpk[i] = ch;
 }
 unsigned char pk[32];
 int signResult = crypto_sign_ed25519_pk_to_curve25519(pk,signpk);
 if (signResult >= 0) {
 return [LibsodiumUtil charsToString:pk length:32];
 }
 return @"";
 }
 // 得到生成对称密钥nonce
 + (NSString *) getGenterSysmetryNonce
 {
 uint8_t nonceKey[CRYPTO_NONCE_SIZE];
 random_nonce(nonceKey);
 return [LibsodiumUtil charsToString:nonceKey length:24];
 }
*/
@end
