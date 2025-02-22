//
//  AFHTTPClientV2.h
//  PAFNetClient
//
//  Created by JK.PENG on 14-1-22.
//  Copyright (c) 2014年 njut. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "AFNetworking.h"
#import <AFNetworking/AFNetworking.h>
#define TimeOut_Request 60
#define TimeOut_GetRequest 8

typedef enum HttpMethod {
    HttpMethodGet      = 0,
    HttpMethodPost     = 1,
    HttpMethodDelete   = 2,
}HttpMethod;

@class AFHTTPClientV2;

typedef void (^HTTPRequestV2SuccessBlock)(NSURLSessionDataTask *dataTask, id responseObject);
typedef void (^HTTPRequestV2FailedBlock)(NSURLSessionDataTask *dataTask, NSError *error);


@interface AFHTTPClientV2 : NSObject

+ (instancetype)shareInstance;
//@property (nonatomic, strong) NSDictionary *userInfo;

+ (void)cancelAllOperations;

+ (NSURLSessionDataTask *)requestWithBaseURLStr:(NSString *)URLString
                                   params:(id)params
                               httpMethod:(HttpMethod)httpMethod
                             successBlock:(HTTPRequestV2SuccessBlock)successReqBlock
                              failedBlock:(HTTPRequestV2FailedBlock)failedReqBlock;

+ (NSURLSessionDataTask *)requestWithBaseURLStr:(NSString *)URLString
                                   params:(id)params
                               httpMethod:(HttpMethod)httpMethod
                                 userInfo:(NSDictionary*)userInfo
                             successBlock:(HTTPRequestV2SuccessBlock)successReqBlock
                              failedBlock:(HTTPRequestV2FailedBlock)failedReqBlock;

+ (NSURLSessionDataTask *)requestXMLWithBaseURLStr:(NSString *)URLString
                                      params:(id)params
                                  httpMethod:(HttpMethod)httpMethod
                                    userInfo:(NSDictionary*)userInfo
                                successBlock:(HTTPRequestV2SuccessBlock)successReqBlock
                                 failedBlock:(HTTPRequestV2FailedBlock)failedReqBlock;

+ (NSURLSessionDataTask *)requestWithBaseURLStr:(NSString *)URLString
                               parameters:(id)parameters
                constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                  success:(void (^)(NSURLSessionDataTask *dataTask, id responseObject))success
                                  failure:(void (^)(NSURLSessionDataTask *dataTask, NSError *error))failure;

+ (NSURLSessionDataTask *)requestWithBaseURLStr:(NSString *)URLString
                               parameters:(id)parameters
                                 userInfo:(NSDictionary*)userInfo
                constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                                  success:(void (^)(NSURLSessionDataTask *dataTask, id responseObject))success
                                  failure:(void (^)(NSURLSessionDataTask *dataTask, NSError *error))failure;

+ (void) downFileWithBaseURLStr:(NSString *) ULRString fileName:(NSString *) fileName friendid:(NSString *) friendid
                  progressBlock:(void(^)(CGFloat progress)) progressBlock
                        success:(void (^)(NSURLSessionDownloadTask *dataTask, NSString *filePath)) success
                        failure:(void (^)(NSURLSessionDownloadTask *dataTask, NSError *error))failure;
+ (NSURLSessionDataTask *)requestWithConfidantCSURLStr:(NSString *)URLString
               parameters:(id)parameters
                 userInfo:(NSDictionary*)userInfo
constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                  success:(void (^)(NSURLSessionDataTask *dataTask, id responseObject))success
                                               failure:(void (^)(NSURLSessionDataTask *dataTask, NSError *error))failure;

+ (NSURLSessionDownloadTask *)downFileWithBaseURLStr:(NSString *)ULRString
                      filePath:(NSString *)filePath
                 progressBlock:(void(^)(CGFloat progress)) progressBlock
                       success:(void (^)(NSURLSessionDownloadTask *dataTask, NSString *filePath)) success
                       failure:(void (^)(NSURLSessionDownloadTask *dataTask, NSError *error))failure;
+ (NSURLSessionDataTask *)requestConfidantWithBaseURLStr:(NSString *)URLString
      params:(id)params
  httpMethod:(HttpMethod)httpMethod
    userInfo:(NSDictionary*)userInfo
successBlock:(HTTPRequestV2SuccessBlock)successReqBlock
                                             failedBlock:(HTTPRequestV2FailedBlock)failedReqBlock;

@end
