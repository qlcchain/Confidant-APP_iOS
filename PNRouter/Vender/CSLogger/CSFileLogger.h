//
//  CSFileLogger.h
//  CSLog
//
//  Created by ChaoSo on 2018/6/4.
//  Copyright © 2018年 ChaoSo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#define CSLogger_Name @"cslogger"

@interface CSFileManagerDefault : DDLogFileManagerDefault

- (instancetype)initWithLogsDirectory:(NSString *)logsDirectory
                             fileName:(NSString *)name;

@end

@interface CSFileLogger : DDFileLogger

@property (nonatomic, assign) NSUInteger flag;

- (instancetype)initWithFlag:(NSUInteger)flag;
+ (NSString *)getLogsDir:(NSUInteger)flag;
+ (CSFileManagerDefault *)getFileManager:(NSString *)logsDir;

@end


