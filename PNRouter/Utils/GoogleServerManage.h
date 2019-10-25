//
//  GoogleServerManage.h
//  MyConfidant
//
//  Created by 旷自辉 on 2019/10/16.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTLRGmail.h"

NS_ASSUME_NONNULL_BEGIN

@interface GoogleServerManage : NSObject
@property (nonatomic ,strong) GTLRGmailService *gmailService;
+ (instancetype) getGoogleServerManageShare;
@end

NS_ASSUME_NONNULL_END
