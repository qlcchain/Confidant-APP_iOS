//
//  OperationRecordModel.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/26.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OperationRecordModel : BBaseModel

@property (nonatomic, strong) NSNumber *fileType;
@property (nonatomic, strong) NSNumber *operationType; // 0:上传  1:下载  2:删除
@property (nonatomic, strong) NSString *operationTime;
@property (nonatomic, strong) NSString *operationFrom;
@property (nonatomic, strong) NSString *operationTo;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *routerPath;
@property (nonatomic, strong) NSString *localPath;
@property (nonatomic, strong) NSString *userId;

+ (NSArray *)getAllOperationRecord;
+ (void)saveOrUpdateWithFileType:(NSNumber *)fileType operationType:(NSNumber *)operationType operationTime:(NSString *)operationTime operationFrom:(NSString *)operationFrom operationTo:(NSString *)operationTo fileName:(NSString *)fileName routerPath:(NSString *)routerPath localPath:(NSString *)localPath userId:(NSString *)userId;
//+ (void)saveOrUpdate:(OperationRecordModel *)model;

@end

NS_ASSUME_NONNULL_END
