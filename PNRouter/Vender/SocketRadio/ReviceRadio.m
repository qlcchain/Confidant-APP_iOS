//
//  ReviceRadio.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/12.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "ReviceRadio.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#import  <arpa/inet.h>
#import "AESCipher.h"
#import "RoutherConfig.h"
#import "RouterModel.h"
#import <AFNetworking/AFNetworking.h>
#import "SystemUtil.h"
#import "AFHTTPClientV2.h"

#define MCAST_PORT 18000
#define MCAST_ADDR "224.0.0.254"
#define BUFF_SIZE 256
#define MCAST_INTERVAL 1

@implementation ReviceRadio
{
    int sendCount;
}
+ (instancetype) getReviceRadio
{
    static ReviceRadio *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
    });
    return shareObject;
}

- (void) reviceRadionMessage
{
    int s;
    struct sockaddr_in sockaddr_in;
    struct sockaddr_in local_addr;
    
    int err = -1;
    
    /*建立socket*/
    s = socket(AF_INET, SOCK_DGRAM, 0);
    if (s == -1) {
        printf("建立socket失败");
        return;
    }
    //socklen_t timeout = 2;
    struct timeval timeout = {1, 0};
    setsockopt(s, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
    /*填写 sockaddr_in ser_addr 结构
     AF_INET    表示使用 IPV4
     */
    memset(&local_addr, 0, sizeof(local_addr));
    local_addr.sin_family = AF_INET;
    local_addr.sin_addr.s_addr = htonl(INADDR_ANY);
    local_addr.sin_port = htons(MCAST_PORT);
    
    /*绑定客户端*/
    err = bind(s,(struct sockaddr*)&local_addr, sizeof(local_addr)) ;
    if(err < 0)
    {
        NSLog(@"绑定客户端时失败");
        return;
    }
    
    struct ip_mreq mreq;
    mreq.imr_multiaddr.s_addr = inet_addr(MCAST_ADDR);
    mreq.imr_interface.s_addr = htonl(INADDR_ANY);
    err = setsockopt(s, IPPROTO_IP, IP_ADD_MEMBERSHIP, &mreq, sizeof(mreq));
    if (err < 0) {
        NSLog(@"setsockopt():IP_ADD_MEMBERSHIP\n");
        return;
    }
    
    int times = 0;
    int addr_len = 0;
    char buff[BUFF_SIZE];
    int n = 0;
    
    for(times = 0; times < 3; times++) {
        addr_len = sizeof(local_addr);
        memset(buff, 0, BUFF_SIZE);
        n = recvfrom(s, buff, BUFF_SIZE, 0,(struct sockaddr*)&local_addr,&addr_len);
        if (n == -1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [AppD.window hideHud];
                [[NSNotificationCenter defaultCenter] postNotificationName:GB_FINASH_NOTI object:nil];
            });
            break;
        }
        if (buff) {
            NSString *result = [[NSString alloc] initWithCString:buff encoding:NSASCIIStringEncoding];
            if (result && ![result isEmptyString]) {
                result = aesDecryptString(result,ROUTER_IP_KEY);
            }
            NSArray *resultArr = [result componentsSeparatedByString:@";"];
            if (resultArr && resultArr.count == 2) {
                
                if (![[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterToxid] isEmptyString]) {
                    
                    if ([resultArr[1] isEqualToString:[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterToxid]]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[RoutherConfig getRoutherConfig] addRoutherWithArray:resultArr];
                            [RoutherConfig getRoutherConfig].currentRouterIp = resultArr[0];
                            [RoutherConfig getRoutherConfig].currentRouterToxid = resultArr[1];
                            NSLog(@"---%@---%@",resultArr[0],resultArr[1]);
                            [AppD.window hideHud];
                            [[NSNotificationCenter defaultCenter] postNotificationName:GB_FINASH_NOTI object:nil];
                        });
                        break;
                    }
                } else {
                    BOOL isexit = [RouterModel routerIsExitsWithToxid:resultArr[1]];
                    if (isexit) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[RoutherConfig getRoutherConfig] addRoutherWithArray:resultArr];
                            [RoutherConfig getRoutherConfig].currentRouterIp = resultArr[0];
                             [RoutherConfig getRoutherConfig].currentRouterToxid = resultArr[1];
                            NSLog(@"---%@---%@",resultArr[0],resultArr[1]);
                            [AppD.window hideHud];
                            [[NSNotificationCenter defaultCenter] postNotificationName:GB_FINASH_NOTI object:nil];
                        });
                        break;
                    }
                }
                if (times == 2) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [AppD.window hideHud];
                        [[NSNotificationCenter defaultCenter] postNotificationName:GB_FINASH_NOTI object:nil];
                    });
                }
            }
        } else {
            if (times == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [AppD.window hideHud];
                    [[NSNotificationCenter defaultCenter] postNotificationName:GB_FINASH_NOTI object:nil];
                });
            }
        }
        sleep(MCAST_INTERVAL);
    }
    
    err = setsockopt(s, IPPROTO_IP, IP_DROP_MEMBERSHIP, &mreq, sizeof(mreq));
    close(s);
}

- (void) sendRadionMessageWithRouterid:(NSString *) routerid
{
   int optval = 1;//这个值一定要设置，否则可能导致sendto()失败
    sendCount++;
    if (sendCount == 4) {
        dispatch_async(dispatch_get_main_queue(), ^{
//            [AppD.window hideHud];
//            [[NSNotificationCenter defaultCenter] postNotificationName:GB_FINASH_NOTI object:nil];
            [self sendFailedNoti];
        });
        return;
    }
    int brdcFd;
    if((brdcFd = socket(PF_INET, SOCK_DGRAM, 0)) == -1){
        printf("socket fail\n");
        [self sendRadionMessageWithRouterid:routerid];
        return;
    }
    
    struct sockaddr_in localAddr;
    memset(&localAddr, 0, sizeof(struct sockaddr_in));
     localAddr.sin_family = AF_INET;
     NSString *localIP = [SystemUtil getIPAddress];
    if ([localIP isEqualToString:@"error"]) {
        close(brdcFd);
        [self sendRadionMessageWithRouterid:routerid];
    }
    char *ipAddress = [localIP UTF8String];
     localAddr.sin_addr.s_addr = inet_addr(ipAddress);
     localAddr.sin_port = htons(0);
    setsockopt(brdcFd, SOL_SOCKET,SO_REUSEADDR, &optval, sizeof(int));
    /*绑定客户端*/
    int err = bind(brdcFd,(struct sockaddr*)&localAddr, sizeof(localAddr)) ;
    if(err < 0)
    {
        NSLog(@"绑定客户端时失败");
          close(brdcFd);
        
        [self sendRadionMessageWithRouterid:routerid];
        return;
    }
    
    setsockopt(brdcFd, SOL_SOCKET, SO_BROADCAST, &optval, sizeof(int));
    
    struct sockaddr_in theirAddr;
    memset(&theirAddr, 0, sizeof(struct sockaddr_in));
    theirAddr.sin_family = AF_INET;
    theirAddr.sin_addr.s_addr = htonl(INADDR_BROADCAST); //inet_addr("255.255.255.255");
    theirAddr.sin_port = htons(MCAST_PORT);

    int sendBytes;
    char buff[BUFF_SIZE];
    NSString *sendMessage = @"";
    if (routerid.length == 17) {
       sendMessage = [@"MAC" stringByAppendingString:aesEncryptString(routerid, ROUTER_IP_KEY)];
    } else {
        sendMessage =  [@"QLC" stringByAppendingString:aesEncryptString(routerid, ROUTER_IP_KEY)];
    }
    memcpy(buff, [sendMessage cStringUsingEncoding:NSASCIIStringEncoding],[sendMessage length]);
    if((sendBytes = sendto(brdcFd, buff, strlen(buff), 0,
                           (struct sockaddr *)&theirAddr, sizeof(struct sockaddr))) == -1){
        printf("sendto fail, errno=%d\n", errno);
          close(brdcFd);
        [self sendRadionMessageWithRouterid:routerid];
        return ;
    }
    printf("msg=%s, msgLen=%d, sendBytes=%d\n", buff, strlen(buff), sendBytes);
    
    struct timeval timeout = {1, 0};
    optval = 0;
    setsockopt(brdcFd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));

    char revbuff[BUFF_SIZE];
    int addr_len = 0;
    int n = 0;
    n = recvfrom(brdcFd, revbuff, BUFF_SIZE, 0,(struct sockaddr *)&theirAddr,&addr_len);
    if (revbuff) {
        printf("revbuff=%s\n",revbuff);
        NSString *result = [[NSString alloc] initWithCString:revbuff encoding:NSASCIIStringEncoding];
        if (result && ![result isEmptyString]) {
            result = aesDecryptString(result,ROUTER_IP_KEY);
            NSArray *resultArr = [result componentsSeparatedByString:@";"];
            if (resultArr && resultArr.count == 2) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    AppD.isWifiConnect = YES;
                    [[RoutherConfig getRoutherConfig] addRoutherWithArray:resultArr];
                    [RoutherConfig getRoutherConfig].currentRouterIp = resultArr[0];
                    [RoutherConfig getRoutherConfig].currentRouterToxid = resultArr[1];
                    [RoutherConfig getRoutherConfig].currentRouterPort = @"18006";
                    NSLog(@"---%@---%@",resultArr[0],resultArr[1]);
                    [AppD.window hideHud];
                    [[NSNotificationCenter defaultCenter] postNotificationName:GB_FINASH_NOTI object:nil];
                    
                });
                
                
            } else {
                close(brdcFd);
                [self sendRadionMessageWithRouterid:routerid];
            }
        } else {
              close(brdcFd);
            [self sendRadionMessageWithRouterid:routerid];
        }
        
    } else {
        close(brdcFd);
        [self sendRadionMessageWithRouterid:routerid];
    }
    close(brdcFd);
}


-(void)startListenAndNewThreadWithRouterid:(NSString *) routerid
{
    
    AppD.isConnect = NO;
    
    if ([SystemUtil isVPNOn]) {
        [self sendFailedNoti];
        return;
    }
    
    AFNetworkReachabilityManager  *man=[AFNetworkReachabilityManager sharedManager];
    
    // AFNetworkReachabilityStatusUnknown          = -1,
    // AFNetworkReachabilityStatusNotReachable     = 0,
    // AFNetworkReachabilityStatusReachableViaWWAN = 1,
    // AFNetworkReachabilityStatusReachableViaWiFi = 2,
    
    //开始监听
    [man startMonitoring];
    @weakify_self
    [man setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
                
            case AFNetworkReachabilityStatusUnknown:
                AppD.isWifiConnect = NO;
                [weakSelf sendFailedNoti];
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                AppD.isWifiConnect = NO;
                 [weakSelf sendFailedNoti];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                AppD.isWifiConnect = NO;
                 [weakSelf sendFailedNoti];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWiFi:
                AppD.isWifiConnect = YES;
                self->sendCount = 0;
                [weakSelf sendGBWithRouterId:routerid];
                break;
                
        }
    }];
}
- (void) sendFailedNoti
{
  
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    
    if (![[NSString getNotNullValue:[RoutherConfig getRoutherConfig].currentRouterMAC] isEmptyString]) {
         [self sendGBFinsh];
    } else {
         [self sendRequestWithRid:[RoutherConfig getRoutherConfig].currentRouterToxid];
    }
}

- (void) sendGBFinsh
{
     [AppD.window hideHud];
      [[NSNotificationCenter defaultCenter] postNotificationName:GB_FINASH_NOTI object:nil];
}

- (void) sendGBWithRouterId:(NSString *) routerid
{
     [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    [[RoutherConfig getRoutherConfig].routherArray removeAllObjects];
    [NSThread detachNewThreadSelector:@selector(sendRadionMessageWithRouterid:) toTarget:self withObject:routerid];
}

- (void) sendRequestWithRid:(NSString *) rid
{
    NSLog(@"----sendRequestWithRid---pprmap---");
    NSString *url = [NSString stringWithFormat:@"https://pprouter.online:9001/v1/pprmap/Check?rid=%@",rid?:@""];
    @weakify_self
    [AFHTTPClientV2 requestWithBaseURLStr:url params:@{} httpMethod:HttpMethodGet successBlock:^(NSURLSessionDataTask *dataTask, id responseObject) {
        
        NSInteger retCode = [responseObject[@"RetCode"] integerValue];
        NSInteger connStatus = [responseObject[@"ConnStatus"] integerValue];
        if (retCode == 0 && connStatus == 1) {
            NSString *routerIp = responseObject[@"ServerHost"];
            NSString *routerPort = [NSString stringWithFormat:@"%@",responseObject[@"ServerPort"]];
            NSString *routerId = [NSString stringWithFormat:@"%@",responseObject[@"Rid"]];
            [RoutherConfig getRoutherConfig].currentRouterPort = routerPort;
            [[RoutherConfig getRoutherConfig] addRoutherWithArray:@[routerIp?:@"",routerId?:@""]];
            [RoutherConfig getRoutherConfig].currentRouterIp = routerIp;
            [RoutherConfig getRoutherConfig].currentRouterToxid = routerId;
            NSLog(@"---%@---%@",routerIp,routerId);
        }
        NSLog(@"----successBlock-----");
         [weakSelf sendGBFinsh];
    } failedBlock:^(NSURLSessionDataTask *dataTask, NSError *error) {
        [weakSelf sendGBFinsh];
         NSLog(@"-----failedBlock----");
    }];
}
@end

