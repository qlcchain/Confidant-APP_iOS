//
//  SendToxRequestUtil.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/29.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "OCTManager.h"


NS_ASSUME_NONNULL_BEGIN

@interface SendToxRequestUtil : NSObject
// tox 发送文本消息
+ (void) sendTextMessageWithText:(NSString *) message manager:(id<OCTManager>) manage;
// tox 发送文件
+ (void) sendFileWithFilePath:(NSString *) filePath parames:(NSDictionary *) parames;
// tox 上传文件
+ (void) uploadFileWithFilePath:(NSString *) filePath parames:(NSDictionary *) parames fileData:(NSData *) fileData;
// 取消当前fileid文件上传
+ (void) cancelToxFileUploadWithFileid:(NSString *) fileid;
// 取消当前msgid文件上传
+ (BOOL) cancelToxFileDownWithMsgid:(NSString *) msgid;
+ (BOOL) check_can_be_canceled_downWithMsgid:(NSString *) msgid;
+ (BOOL) check_can_be_canceled_uploadWithFileid:(NSString *) fileid;
// 重新上传文件
+ (void) deUploadFileWithFilePath:(NSString *) filePath parames:(NSDictionary *) parames fileData:(NSData *) fileData;
@end

NS_ASSUME_NONNULL_END
