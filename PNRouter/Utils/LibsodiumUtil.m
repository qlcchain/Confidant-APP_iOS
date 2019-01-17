//
//  LibsodiumUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/1/15.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "LibsodiumUtil.h"
#import "RSAModel.h"
#import <libsodium/crypto_box.h>
#import "KeyCUtil.h"
//#import <toxcore/crypto_core.h>
#import "crypto_core.h"
#import <libsodium/crypto_box.h>
//#import <toxcore/ccompat.h>
#import "ccompat.h"
#define libkey @"libkey"

@implementation LibsodiumUtil
+ (RSAModel *) getPrivatekeyAndPublickey
{
    RSAModel *model = nil;
    NSString *modelJson = [KeyCUtil getKeyValueWithKey:libkey];
    if ([[NSString getNotNullValue:modelJson] isEmptyString]) {
        
        unsigned char pk[32];
        unsigned char sk[32];
        int result = crypto_box_keypair(pk, sk);
        if (result < 0) {
            crypto_box_keypair(pk, sk);
        }
        
        NSString *publicString = [LibsodiumUtil charsToString:pk];
        NSString *privateString = [LibsodiumUtil charsToString:sk];
        
        model = [[RSAModel alloc] init];
        model.publicKey = publicString;
        model.privateKey = privateString;
        
        [KeyCUtil saveStringToKeyWithString:model.mj_JSONString key:libkey];
        

    // unsigned char k[32];
    //NSData *sdata = [NSData dataWithBytesNoCopy:pk length:32 freeWhenDone:NO];
        
    } else {
        model = [RSAModel getObjectWithKeyValues:[modelJson mj_keyValues]];
    }
    [RSAModel getShareObject].publicKey = model.publicKey;
    [RSAModel getShareObject].privateKey = model.privateKey;
    return model;
}

// char[] 转nsstring
+ (NSMutableString *) charsToString:(unsigned char[32]) chars
{
    NSLog(@"chars = %s",chars);
    NSMutableString *hexString = [NSMutableString string];
    for (int i=0; i<32; i++)
    {
        if (i == 31) {
            [hexString appendFormat:@"%x", chars[i]];
        } else {
            [hexString appendFormat:@"%x ", chars[i]];
        }
        
    }
    NSLog(@"hexString = %@",hexString);
    return hexString;
}
//  生成对称密钥
+ (NSMutableString *) getSymmetricKeyPair
{
    unsigned char gk[32];
    unsigned char pk[32];
    unsigned char sk[32];
    
    unsigned char mCode;
    NSArray *publicArr = [[RSAModel getShareObject].publicKey componentsSeparatedByString:@" "];
    for (int i = 0; i < publicArr.count ; ++i) {
        sscanf([[publicArr objectAtIndex:i] UTF8String], "%x", &mCode);
        pk[i] = mCode;
    }
    
    NSArray *privateArr = [[RSAModel getShareObject].privateKey componentsSeparatedByString:@" "];
    for (int i = 0; i < privateArr.count ; ++i) {
        sscanf([[privateArr objectAtIndex:i] UTF8String], "%x", &mCode);
        sk[i] = mCode;
    }
    
//    uint8_t nonce[CRYPTO_NONCE_SIZE];
//    random_nonce(nonce);
//    
//    const uint8_t *plains = "123abc4567";
//    char enstr[sizeof(plains) + crypto_box_MACBYTES + crypto_box_BOXZEROBYTES];
//    
//   const int decrypted_length = encrypt_data(pk,sk,nonce,plains,sizeof(plains),enstr);
//    
//    char plain[sizeof(enstr) + crypto_box_ZEROBYTES];
    
    
    int result = crypto_box_beforenm(gk,pk,sk);
    if (result >=0) {
         return [LibsodiumUtil charsToString:gk];
    }
    return @"";
}

+ (NSString *)  encrypt_data_symmetric:(char *) msg chararr:(char[32]) srckey
{
    
   size_t sit = sizeof(msg);
    VLA(uint8_t, temp_plain, sizeof(msg) + crypto_box_ZEROBYTES);
    VLA(uint8_t, temp_encrypted, sizeof(msg) + crypto_box_MACBYTES + crypto_box_BOXZEROBYTES);
    
    memset(temp_plain, 0, crypto_box_ZEROBYTES);
    memcpy(temp_plain + crypto_box_ZEROBYTES, msg,sizeof(msg)); // Pad the message with 32 0 bytes.
    
        uint8_t nonce[CRYPTO_NONCE_SIZE];
        random_nonce(nonce);
    
    if (crypto_box_afternm(temp_encrypted, temp_plain, sizeof(msg) + crypto_box_ZEROBYTES, nonce, srckey) != 0) {
        return @"";
    }
    
    /* Unpad the encrypted message. */
    VLA(uint8_t, encrypted, sizeof(msg) + crypto_box_MACBYTES);
    memcpy(encrypted, temp_encrypted + crypto_box_BOXZEROBYTES, sizeof(msg) + crypto_box_MACBYTES);
    
    
    VLA(uint8_t, temp_plain2, sizeof(encrypted) + crypto_box_ZEROBYTES);
    VLA(uint8_t, temp_encrypted2, sizeof(encrypted) + crypto_box_BOXZEROBYTES);
    
    memset(temp_encrypted2, 0, crypto_box_BOXZEROBYTES);
    memcpy(temp_encrypted2 + crypto_box_BOXZEROBYTES, encrypted, sizeof(encrypted)); // Pad the message with 16 0 bytes.
    
    if (crypto_box_open_afternm(temp_plain2, temp_encrypted2, sizeof(encrypted) + crypto_box_BOXZEROBYTES, nonce, srckey) != 0) {
        return @"";
    }
     VLA(uint8_t, plain, sizeof(encrypted) + crypto_box_MACBYTES);
    memcpy(plain, temp_plain2 + crypto_box_ZEROBYTES, sizeof(encrypted) - crypto_box_MACBYTES);
    return @"";
}
@end
