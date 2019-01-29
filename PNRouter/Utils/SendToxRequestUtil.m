//
//  SendToxRequestUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/11/29.
//  Copyright © 2018 旷自辉. All rights reserved.
//

#import "SendToxRequestUtil.h"
#import "OCTSubmanagerChats.h"
#import "SocketMessageUtil.h"
#import "OCTSubmanagerFiles.h"
#import "FileData.h"
#import "UserConfig.h"
#import "PNRouter-Swift.h"

@implementation SendToxRequestUtil
+ (void) sendTextMessageWithText:(NSString *) message manager:(id<OCTManager>) manage
{
    if (AppD.currentRouterNumber < 0) {
        [AppD.window hideHud];
        [AppD.window showHint:@"Failed to send message"];
        return;
    }
    DDLogDebug(@"send text: %@",message);
    [manage.chats sendTextMessageWithfriendNumber:AppD.currentRouterNumber text:message messageType:OCTToxMessageTypeNormal successBlock:^(OCTToxMessageId megid) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}

+ (void) sendFileWithFilePath:(NSString *) filePath parames:(NSDictionary *) parames
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [AppD.manager.files sendFileAtPath:filePath moveToUploads:NO parames:parames  toFriendId:AppD.currentRouterNumber failureBlock:^(NSError * _Nonnull error) {
            
            NSLog(@"文件发送失败 = %@",error.description);
            
           [[NSNotificationCenter defaultCenter] postNotificationName:REVER_FILE_SEND_FAIELD_NOTI object:parames];
        }];
    });
}

+ (void) uploadFileWithFilePath:(NSString *) filePath parames:(NSDictionary *) parames fileData:(NSData *) fileData
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//
//
//    });
    
    NSString *srcKey = parames[@"SrcKey"];
    int fileid = [parames[@"FileId"] intValue];
    int fileType = [parames[@"FileType"] intValue];
    NSString *fileName = parames[@"FileName"];
    [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(srcKey)] complete:^(NSArray * _Nullable array) {
        if (array && array.count > 0) {
            FileData *fileModel = array[0];
            fileModel.status = 2;
            fileModel.filePath = filePath;
            [fileModel bg_saveOrUpdateAsync:nil];
        } else {
            FileData *fileModel = [[FileData alloc] init];
            fileModel.bg_tableName = FILE_STATUS_TABNAME;
            fileModel.fileId = fileid;
            fileModel.fileSize = fileData.length;
            fileModel.fileData = fileData;
            fileModel.fileType = fileType;
            fileModel.filePath = filePath;
            fileModel.progess = 0.0f;
            fileModel.fileName = [Base58Util Base58DecodeWithCodeName:fileName];
            fileModel.fileOptionType = 1;
            fileModel.status = 2;
            fileModel.userId = [UserConfig getShareObject].userId;
            fileModel.srcKey = srcKey;
            [fileModel bg_saveAsync:nil];
        }
    }];
    
    [AppD.manager.files sendFileAtPath:filePath moveToUploads:NO parames:parames  toFriendId:AppD.currentRouterNumber failureBlock:^(NSError * _Nonnull error) {
        
        NSLog(@"文件发送失败 = %@",error.description);
        NSString *toid = parames[@"ToId"];
        if ([toid isEmptyString]) { // 上传文件
            
            NSString *srcKey = parames[@"SrcKey"];
            int fileType = [parames[@"FileType"] intValue];
            NSString *fileName = parames[@"FileName"];
            [[NSNotificationCenter defaultCenter] postNotificationName:FILE_UPLOAD_NOTI object:@[@(1),fileName,@"",@(fileType),srcKey]];
        }
        
    }];
}

@end
