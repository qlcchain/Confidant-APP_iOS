//
//  EmailOptionUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/19.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface EmailOptionUtil : NSObject
+ (void) setEmailReaded:(BOOL)readed uid:(NSInteger)uid messageId:(NSString *) messageId folderPath:(NSString *)folderPath complete:(void (^)(BOOL success)) complete;
+ (void)deleteEmailUid:(NSInteger)uid messageId:(NSString *) messageId folderPath:(NSString *)folderPath folderName:(NSString *) folderName complete:(void (^)(BOOL success)) complete;
+ (void)createDraft:(NSData *)data complete:(void (^)(BOOL success)) complete;
+ (void) setEmailStaredUid:(NSInteger)uid messageId:(NSString *) messageId folderPath:(NSString *)folderPath isAdd:(BOOL) isAdd complete:(void (^)(BOOL success)) complete;
+ (void) unturnedDelete:(NSInteger) uid floderPath:(NSString *) floderPath complete:(void (^)(BOOL success)) complete;

// 复制邮件到 -指定文件夹 是否删除原邮件
+ (void) copyEmailToFloderWithFloderPath:(NSString *) floderPath toFloderName:(NSString *) toFloderName uid:(NSInteger) uid isDel:(BOOL) isDel complete:(void (^)(BOOL success)) complete;
// 判断是否为加星
+ (BOOL) checkEmailStar:(int) flags;
+ (void)copySent:(NSData *)data complete:(void (^)(BOOL success)) complete;
// google 移动邮件到已删除
+ (void) googleMoveMailToTrashWithMessageid:(NSString *) messageid complete:(void (^)(BOOL success)) complete;
@end

NS_ASSUME_NONNULL_END
