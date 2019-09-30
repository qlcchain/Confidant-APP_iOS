//
//  PNEmailSendViewController.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

typedef enum : NSUInteger {
    ReplyEmail,
    ForwardEmail,
    NewEmail,
    DraftEmail
} EmailSendType;

@class EmailListInfo;

NS_ASSUME_NONNULL_BEGIN

@interface PNEmailSendViewController : PNBaseViewController
@property (nonatomic, assign) EmailSendType sendType;
- (instancetype) initWithEmailListInfo:(EmailListInfo *) info sendType:(EmailSendType) type;
- (instancetype) initWithEmailToAddress:(NSString *) toAddress sendType:(EmailSendType) type;
- (instancetype) initWithEmailListInfo:(EmailListInfo *) info sendType:(EmailSendType) type isShowAttch:(BOOL) isShowAttch;
@end

NS_ASSUME_NONNULL_END
