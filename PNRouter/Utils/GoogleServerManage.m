//
//  GoogleServerManage.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/10/16.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "GoogleServerManage.h"
#import <GoogleSignIn/GoogleSignIn.h>

@implementation GoogleServerManage
+ (instancetype) getGoogleServerManageShare
{
    static GoogleServerManage *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
        GTLRGmailService *service = [[GTLRGmailService alloc] init];
       // service.shouldFetchNextPages = YES;
        // Have the service object set tickets to retry temporary error conditions
        // automatically.
        service.retryEnabled = YES;
        service.APIKey = CLIENT_SECRET;
        [service setAuthorizer:[GIDSignIn sharedInstance].currentUser.authentication.fetcherAuthorizer];
        shareObject.gmailService = service;
    });
    return shareObject;
}

@end
