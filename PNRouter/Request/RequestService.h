//
//  RequestService.h
//  Qlink
//
//  Created by Jelly Foo on 2018/3/26.
//  Copyright © 2018年 pan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPClientV2.h"


@interface RequestService : NSObject

+ (NSString *)getPrefixUrl;
+ (void)cancelAllOperations;
+ (instancetype)getInstance;
+ (NSURLSessionDataTask *)requestWithJsonUrl:(NSString *)url params:(id)params httpMethod:(HttpMethod)httpMethod successBlock:(HTTPRequestV2SuccessBlock)successReqBlock failedBlock:(HTTPRequestV2FailedBlock)failedReqBlock;

+ (NSURLSessionDataTask *)requestWithUrl:(NSString *)url params:(id)params httpMethod:(HttpMethod)httpMethod isSign:(BOOL)isSign successBlock:(HTTPRequestV2SuccessBlock)successReqBlock failedBlock:(HTTPRequestV2FailedBlock)failedReqBlock;

+ (NSURLSessionDataTask *)requestWithUrl:(NSString *)url params:(id)params httpMethod:(HttpMethod)httpMethod successBlock:(HTTPRequestV2SuccessBlock)successReqBlock failedBlock:(HTTPRequestV2FailedBlock)failedReqBlock;

+ (NSURLSessionDataTask *)postImage:(NSString *)url
                   parameters:(id)parameters
    constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))bodyBlock
                      success:(HTTPRequestV2SuccessBlock)successReqBlock
                      failure:(HTTPRequestV2FailedBlock)failedReqBlock;

+ (void) downFileWithBaseURLStr:(NSString *) url fileName:(NSString *) fileName friendid:(NSString *) friendid
                  progressBlock:(void(^)(CGFloat progress)) progressBlock
                        success:(void (^)(NSURLSessionDownloadTask *dataTask,NSString *filePath)) success
                        failure:(void (^)(NSURLSessionDownloadTask *dataTask, NSError *error))failure;

+ (NSURLSessionDownloadTask *)downFileWithBaseURLStr:(NSString *)url
                      filePath:(NSString *)filePath
                 progressBlock:(void(^)(CGFloat progress)) progressBlock
                       success:(void (^)(NSURLSessionDownloadTask *dataTask, NSString *filePath)) success
                       failure:(void (^)(NSURLSessionDownloadTask *dataTask, NSError *error))failure;
+ (NSURLSessionDataTask *)postImage7:(NSString *)url
               parameters:(id)parameters
constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))bodyBlock
                  success:(HTTPRequestV2SuccessBlock)successReqBlock
                             failure:(HTTPRequestV2FailedBlock)failedReqBlock;

@end
