//
//  LibsodiumUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/1/15.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RSAModel;

NS_ASSUME_NONNULL_BEGIN

@interface LibsodiumUtil : NSObject
+ (NSMutableString *) charsToString:(unsigned char[32]) chars;
+ (RSAModel *) getPrivatekeyAndPublickey;
//  生成对称密钥
+ (NSMutableString *) getSymmetricKeyPair;
+ (NSString *)  encrypt_data_symmetric:(char *) msg chararr:(char[]) srckey;
@end

NS_ASSUME_NONNULL_END
