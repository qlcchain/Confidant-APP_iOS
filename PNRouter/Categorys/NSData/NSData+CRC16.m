//
//  NSData+CRC16.m
//  CRC16_iOS
//
//  Created by Echo on 16/3/21.
//  Copyright © 2016年 Liu Xuanyi. All rights reserved.
//

#import "NSData+CRC16.h"

@implementation NSData (CRC16)


- (NSData*)crc16 {
    const uint8_t *byte = (const uint8_t *)self.bytes;
    uint16_t length = (uint16_t)self.length;
    uint16_t res =  gen_crc16(byte, length);
    
    NSData *val = [NSData dataWithBytes:&res length:sizeof(res)];
    
    return val;
}

#define PLOY 0X1021

uint16_t gen_crc16(const uint8_t *data, uint16_t size) {
    uint16_t crc = 0;
    uint8_t i;
    for (; size > 0; size--) {
        crc = crc ^ (*data++ <<8);
        for (i = 0; i < 8; i++) {
            if (crc & 0X8000) {
                crc = (crc << 1) ^ PLOY;
            }else {
                crc <<= 1;
            }
        }
        crc &= 0XFFFF;
    }
    return crc;
}

- (uint16_t) hexadecimalUint16
{
    const uint8_t *byte = (const uint8_t *)self.bytes;
    uint16_t length = (uint16_t)self.length;
    uint16_t res =  gen_crc16(byte, length);
    return res;
}

- (NSString *)hexadecimalString
{
    const unsigned char *dataBuffer = (const unsigned char *)[self bytes];
    
    if (!dataBuffer)
    {
        return [NSString string];
    }
    
    NSUInteger          dataLength  = [self length];
    NSMutableString     *hexString  = [NSMutableString stringWithCapacity:(dataLength * 2)];
    
    for (int i = 0; i < dataLength; ++i)
    {
        [hexString appendFormat:@"%02x", (unsigned int)dataBuffer[i]];
    }
    
    return [NSString stringWithString:hexString];
}


@end
