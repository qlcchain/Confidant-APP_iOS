//
//  SocketDataUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/29.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketDataUtil : NSObject

@property (nonatomic ,assign) BOOL isComplete;


//- (void) sendFileWithParames:(NSDictionary *) parames fileData:(NSData *) data;

+ (NSDictionary *) sendFileId:(NSString *) toid fileName:(NSString *) fileName fileData:(NSData *) imgData;

- (void) sendFileId:(NSString *) toid fileName:(NSString *) fileName fileData:(NSData *) imgData fileid:(int) fileid fileType:(uint32_t) fileType messageid:(NSString *) messageid srcKey:(NSString *) srcKey dstKey:(NSString *) dstKey;
@end
