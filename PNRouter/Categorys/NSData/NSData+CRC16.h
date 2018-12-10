//
//  NSData+CRC16.h
//  CRC16_iOS
//
//  Created by Echo on 16/3/21.
//  Copyright © 2016年 Liu Xuanyi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (CRC16)

//Nsdata  CRC 校验 ，返回data
-(NSData*)crc16 ;

//Nsdata 转化成 hex字符串
- (NSString *)hexadecimalString;

- (uint16_t) hexadecimalUint16;

@end
