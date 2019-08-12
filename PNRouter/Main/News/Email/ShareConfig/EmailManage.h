//
//  EmailManage.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/10.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmailManage : NSObject

@property (nonatomic , strong,nullable) MCOSMTPSession *smtpSession;
@property (nonatomic , strong,nullable) MCOIMAPSession *imapSeeion;

singleton_interface(EmailManage)

@end

NS_ASSUME_NONNULL_END
