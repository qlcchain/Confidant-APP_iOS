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
@property (nonatomic ,assign) BOOL isCancel;
@property (nonatomic ,strong) NSString *fileInfo;
@property (nonatomic ,strong) NSString *fileid;
@property (nonatomic ,strong) NSString *srcKey;
@property (nonatomic ,assign) BOOL isGroup;

- (void) disSocketConnect;



//- (void) sendFileWithParames:(NSDictionary *) parames fileData:(NSData *) data;

+ (NSDictionary *) sendFileId:(NSString *) toid fileName:(NSString *) fileName fileData:(NSData *) imgData;

- (void) sendFileId:(NSString *) toid fileName:(NSString *) fileName fileData:(NSData *) imgData fileid:(NSInteger) fileid fileType:(uint32_t) fileType messageid:(NSString *) messageid srcKey:(NSString *) srcKey dstKey:(NSString *) dstKey isGroup:(BOOL) isGroup;
@end
