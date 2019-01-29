//
//  OperationRecordModel.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/26.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "OperationRecordModel.h"
#import <BGFMDB/BGFMDB.h>
#import "UserModel.h"

@implementation OperationRecordModel

/**
 自定义“联合主键” ,这里指定 name和age 为“联合主键”.
 */
+(NSArray *)bg_unionPrimaryKeys{
    return @[];
}

/**
 如果需要指定“唯一约束”字段, 在模型.m文件中实现该函数,这里指定 name和age 为“唯一约束”.
 */
+(NSArray *)bg_uniqueKeys{
    return @[];
}

/**
 设置不需要存储的属性, 在模型.m文件中实现该函数.
 */
+(NSArray *)bg_ignoreKeys{
    return @[];
}

+ (NSArray *)getAllOperationRecord {
//    NSArray* finfAlls = [OperationRecordModel bg_findAll:OperationRecord_Table];
    NSArray *finfAlls = [OperationRecordModel bg_find:OperationRecord_Table where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserModel getUserModel].userId)]];
    return finfAlls?:@[];
}

+ (NSArray *)getAllOperationRecordOrderByDesc {
    //    NSArray* finfAlls = [OperationRecordModel bg_findAll:OperationRecord_Table];
    NSArray *finfAlls = [OperationRecordModel bg_find:OperationRecord_Table where:[NSString stringWithFormat:@"where %@=%@ order by %@ desc",bg_sqlKey(@"userId"),bg_sqlValue([UserModel getUserModel].userId), bg_sqlValue(@"operationTime")]];
    return finfAlls?:@[];
}

+ (void)saveOrUpdate:(OperationRecordModel *)model {
    if (model.bg_tableName == nil) {
        model.bg_tableName = OperationRecord_Table;
    }
    [model bg_saveOrUpdateAsync:^(BOOL isSuccess) {
        NSLog(@"------------OperationRecordModel bg_saveOrUpdateAsync %@",@(isSuccess));
    }];
}

+ (void)saveOrUpdateWithFileType:(NSNumber *)fileType operationType:(NSNumber *)operationType operationTime:(NSString *)operationTime operationFrom:(NSString *)operationFrom operationTo:(NSString *)operationTo fileName:(NSString *)fileName routerPath:(NSString *)routerPath localPath:(NSString *)localPath userId:(NSString *)userId {
    OperationRecordModel *model = [OperationRecordModel new];
    model.fileType = fileType;
    model.operationType = operationType;
    model.operationTime = operationTime;
    model.operationFrom = operationFrom;
    model.operationTo = operationTo;
    model.fileName = fileName;
    model.routerPath = routerPath;
    model.localPath = localPath;
    model.userId = userId;
    [OperationRecordModel saveOrUpdate:model];
}

@end
