//
//  RSAModel.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/6.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "RSAModel.h"
#import "KeyCUtil.h"
#import "RSAUtil.h"

static NSString *rsakey = @"rsakey";

@implementation RSAModel

+ (void) getRSAModel
{
    NSString *modelJson = [KeyCUtil getKeyValueWithKey:rsakey];
    if (modelJson && ![modelJson isEmptyString]) {
        RSAModel *rsaModel = [RSAModel getObjectWithKeyValues:[modelJson mj_keyValues]];
        NSString *publickey = [rsaModel.publicKey stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [RSAModel getShareObject].publicKey = publickey;
        [RSAModel getShareObject].privateKey = rsaModel.privateKey;
    }
}

+ (RSAModel *) getCurrentRASModel
{
    RSAModel *rsaModel = nil;
    if ([RSAModel getShareObject].publicKey && ![[RSAModel getShareObject].publicKey isEmptyString]) {
        rsaModel = [RSAModel getShareObject];
    } else {
        rsaModel = [RSAUtil genterRSAPrivateKeyAndPublicKey];
        if (rsaModel) {
            [RSAModel getShareObject].publicKey = rsaModel.publicKey;
            [RSAModel getShareObject].privateKey = rsaModel.privateKey;
            [KeyCUtil saveStringToKeyWithString:rsaModel.mj_JSONString key:rsakey];
        }
    }
    return rsaModel;
}
+ (instancetype) getShareObject
{
    static RSAModel *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
    });
    return shareObject;
}
@end
