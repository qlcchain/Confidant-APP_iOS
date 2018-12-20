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

+ (RSAModel *) getCurrentRASModel
{
   NSString *modeJson = [KeyCUtil getKeyValueWithKey:rsakey];
    RSAModel *rsaModel = nil;
    if (!modeJson || [modeJson isEmptyString]) {
       rsaModel = [RSAUtil genterRSAPrivateKeyAndPublicKey];
        if (rsaModel) {
             [KeyCUtil saveStringToKeyWithString:rsaModel.mj_JSONString key:rsakey];
        }
    } else {
        rsaModel = [RSAModel getObjectWithKeyValues:[modeJson mj_keyValues]];
        rsaModel.publicKey = [rsaModel.publicKey stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        //NSLog(@"%@----%@",rsaModel.publicKey,rsaModel.privateKey);
    }
    return rsaModel;
}

@end
