//
//  ENMessageUtil.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/2/14.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "ENMessageUtil.h"

@implementation ENMessageUtil

// 53-54位  类型 00 表示加密信息  01 手动密码加解密类型 02 加密信息需要支付token再解密 其他类型等待后续扩展再定义
+ (NSString *) enMessageStr:(NSString *) messageStr enType:(NSString *) enType qlcAccount:(NSString *) qlcAccount tokenNum:(NSString *) tokenNum tokenType:(NSString *) tokenType enNonce:(NSString *) enNonce
{
    NSString *enMessage = @"UUxDSUQ=";
    enMessage = [enMessage stringByAppendingString:[EntryModel getShareObject].publicKey];
    enMessage = [enMessage stringByAppendingString:enType];
    if ([enType isEqualToString:@"02"]) {
        enMessage = [enMessage stringByAppendingString:qlcAccount];
        enMessage = [enMessage stringByAppendingString:tokenNum];
        enMessage = [enMessage stringByAppendingString:tokenType];
    } else if ([enType isEqualToString:@"00"]) {
        enMessage = [enMessage stringByAppendingString:enNonce];
    }
    enMessage = [enMessage stringByAppendingString:messageStr];
    NSLog(@"enMessage = %@",enMessage);
    return enMessage;
}

+ (NSString *) deMessageStr:(NSString *) messageStr
{
    if (!messageStr || messageStr.length == 0) {
        return @"";
    }
    NSString *deMessage = @"";
    if ([messageStr hasPrefix:@"UUxDSUQ"]) { //是加密
        // 获取对方公钥
       NSRange range = NSMakeRange(8, 44);
       NSString *dePK = [messageStr substringWithRange:range];
       NSString *deType = [messageStr substringWithRange:NSMakeRange(52, 2)];
       if ([deType isEqualToString:@"00"]) {
            NSString *symmetryString = [LibsodiumUtil getSymmetryWithPrivate:[EntryModel getShareObject].privateKey publicKey:dePK];
           NSString *nonce = [messageStr substringWithRange:NSMakeRange(54, 32)];
           NSString *enMessage = [messageStr substringWithRange:NSMakeRange(86,messageStr.length-86)];;
           deMessage =  [LibsodiumUtil decryMsgPairWithSymmetry:symmetryString enMsg:enMessage nonce:nonce];
       }
    }
     NSLog(@"deMessage = %@",deMessage);
    return deMessage;
}
@end
