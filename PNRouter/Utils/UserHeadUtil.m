//
//  UserHeadUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/8.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "UserHeadUtil.h"
#import "RequestService.h"
#import "PNRouter-Swift.h"
#import "SystemUtil.h"
#import "SendRequestUtil.h"
#import "UserConfig.h"
#import "UserHeaderModel.h"
#import "NSData+Base64.h"
#import "ChatListDataUtil.h"
#import "UserModel.h"
#import "EntryModel.h"
#import "SocketDataUtil.h"
#import "SocketCountUtil.h"
#import "SocketManageUtil.h"
#import "NSDate+Category.h"
#import "MD5Util.h"

@interface UserHeadUtil ()

@property (nonatomic, strong) NSData *uploadImgData;
@property (nonatomic, strong) NSString *uploadFileName;
@property (nonatomic) BOOL showUpload;

@end

@implementation UserHeadUtil

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) addNoti {
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAvatarSuccessNoti:) name:UpdateAvatar_Success_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileNotExistNoti:) name:UpdateAvatar_FileNotExist_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFileFinshNoti:) name:UPLOAD_HEAD_DATA_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadAvatarSuccessNoti:) name:UploadAvatar_Success_Noti object:nil];
}

+ (instancetype)getUserHeadUtilShare {
    static UserHeadUtil *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
        [shareObject addNoti];
    });
    return shareObject;
}

#pragma mark - 更新头像
- (void) sendUpdateAvatarWithFid:(NSString *) fid md5:(NSString *) md5 showHud:(BOOL) isShow
{
    [SendRequestUtil sendUpdateAvatarWithFid:fid Md5:md5 showHud:isShow];
}

#pragma mark - 下载头像
- (void) downUserHeadWithDic:(NSDictionary *) parames {
    if (parames) {
        NSString *filePath = parames[@"FileName"];
        NSString *fileNameBase58 = filePath.lastPathComponent;
        NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58]?:@"";
        NSString *downloadFilePath = [SystemUtil getTempDownloadFilePath:fileName];
        if ([SystemUtil filePathisExist:downloadFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:downloadFilePath error:nil];
        }
        NSString *signPublicKey = parames[@"TargetKey"];
        NSString *toid = parames[@"TargetId"];
        
        if ([SystemUtil isSocketConnect]) {
            
            [RequestService downFileWithBaseURLStr:filePath filePath:downloadFilePath progressBlock:^(CGFloat progress) {
                
            } success:^(NSURLSessionDownloadTask *dataTask, NSString *filePath) {
                
                NSLog(@"success");
                NSData *fileData = [NSData dataWithContentsOfFile:filePath];
                UserHeaderModel *model = [UserHeaderModel new];
                //             NSString *signPublickey = [[ChatListDataUtil getShareObject] getFriendSignPublickeyWithFriendid:userId];
                model.UserKey = signPublicKey;
                model.UserHeaderImg64Str = [fileData base64EncodedString];
                if (model.UserKey && model.UserKey.length > 0) {
                    [UserHeaderModel saveOrUpdate:model];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:USER_HEAD_DOWN_SUCCESS_NOTI object:model];
                
            } failure:^(NSURLSessionDownloadTask *dataTask, NSError *error) {
                NSLog(@"failure");
            }];
            
        } else {
            
            NSString *filePath = parames[@"FileName"];
            NSString *fileNameBase58 = filePath.lastPathComponent;
            // NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58]?:@"";
            
            [SendRequestUtil sendToxPullFileWithFromId:toid?:@"" toid:[UserConfig getShareObject].userId fileName:fileNameBase58 msgId:@"00" fileOwer:@"4" fileFrom:@"3"];
        }
    }
    
}

#pragma mark - 上传用户头像
- (void)uploadHeader:(NSData *)imgData showToast:(BOOL)showToast {
    _showUpload = showToast;
    // 上传文件
    NSData *signPublicKeyDecodeData = [NSData dataWithBase64EncodedString:[EntryModel getShareObject].signPublicKey];
    _uploadFileName = [NSString stringWithFormat:@"%@__Avatar.jpg",[Base58Util Base58EncodeDataToStrWithData:signPublicKeyDecodeData]];
    NSString *outputPath = [[SystemUtil getTempUploadPhotoBaseFilePath] stringByAppendingPathComponent:_uploadFileName];
    _uploadImgData = imgData;
    int fileType = 6;
    
    long tempMsgid = [SocketCountUtil getShareObject].fileIDCount++;
    tempMsgid = [NSDate getTimestampFromDate:[NSDate date]]+tempMsgid;
    NSInteger fileId = tempMsgid;
    
    NSString *srcKey = @"";
    NSString *ToId = @"";
    
    if (_showUpload) {
        [AppD.window showHudInView:AppD.window hint:@"Uploading..." userInteractionEnabled:NO hideTime:REQEUST_TIME];
    }
    if ([SystemUtil isSocketConnect]) { // socket
        SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
        dataUtil.srcKey = srcKey;
        dataUtil.fileid = [NSString stringWithFormat:@"%ld",(long)fileId];
        [dataUtil sendFileId:ToId fileName:_uploadFileName fileData:_uploadImgData fileid:fileId fileType:fileType messageid:@"" srcKey:srcKey dstKey:@"" isGroup:NO];
        [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
    } else { // tox
        
        BOOL isSuccess = [_uploadImgData writeToFile:outputPath atomically:YES];
        if (isSuccess) {
            NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":[UserConfig getShareObject].userId,@"ToId":ToId,@"FileName":[Base58Util Base58EncodeWithCodeName:_uploadFileName],@"FileMD5":[MD5Util md5WithPath:outputPath],@"FileSize":@(_uploadImgData.length),@"FileType":@(fileType),@"SrcKey":srcKey,@"DstKey":@"",@"FileId":@(fileId)};
            [SendToxRequestUtil sendFileWithFilePath:outputPath parames:parames];
        }
    }
}

#pragma mark - Noti
#pragma mark - 上传用户头像完成
- (void)uploadFileFinshNoti:(NSNotification *) noti {
    if (_showUpload) {
        [AppD.window hideHud];
    }
    
    NSArray *resultArr = noti.object;
    if (resultArr && resultArr.count>0 && [resultArr[0] integerValue] == 0) { // 成功
        
        NSString *FileMd5 = [MD5Util md5WithData:_uploadImgData];
        [SendRequestUtil sendUploadAvatarWithFileName:_uploadFileName FileMd5:FileMd5 showHud:YES];
        
    } else { // 上传失败
        [AppD.window showHint:@"Failed to upload avatar."];
    }
}

#pragma mark - 上传用户头像成功
- (void)uploadAvatarSuccessNoti:(NSNotification *)noti {
    NSDictionary *receiveDic = noti.object;
    NSDictionary *params = receiveDic[@"params"];
    
    UserHeaderModel *model = [UserHeaderModel new];
    model.UserKey = [EntryModel getShareObject].signPublicKey;
    model.UserHeaderImg64Str = [_uploadImgData base64EncodedString];
    [UserHeaderModel saveOrUpdate:model];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:USER_HEAD_CHANGE_NOTI object:nil];
}

#pragma mark - 更新头像成功
- (void) updateAvatarSuccessNoti:(NSNotification *) noti {
    NSDictionary *receiveDic = noti.object;
    NSDictionary *params = receiveDic[@"params"];
    
    NSString *toid = params[@"TargetId"];
    NSString *md5 = params[@"FileMD5"];
    NSString *userId = [UserModel getUserModel].userId;
    NSString *userKey = [EntryModel getShareObject].signPublicKey;
    if ([userId isEqualToString:toid]) { // 自己头像
        NSString *userHeaderImg64Str = [UserHeaderModel getUserHeaderImg64StrWithKey:userKey];
        if (userHeaderImg64Str) { // 本地有头像
            NSString *localMd5 = [MD5Util md5WithData:[NSData dataWithBase64EncodedString:userHeaderImg64Str]];
            if (![md5 isEqualToString:localMd5]) { // 路由器和本地头像md5不一样
                // 上传
                NSData *imgData = [NSData dataWithBase64EncodedString:userHeaderImg64Str];
                [[UserHeadUtil getUserHeadUtilShare] uploadHeader:imgData showToast:NO];
            }
        } else { // 本地没有头像
            [self downUserHeadWithDic:params];
        }
    } else { // 好友头像
        [self downUserHeadWithDic:params];
    }
}

#pragma mark - 更新头像--文件不存在
- (void)fileNotExistNoti:(NSNotification *)noti {
    // 路由器上面没有头像
    NSDictionary *receiveDic = noti.object;
    NSDictionary *params = receiveDic[@"params"];
    
//    NSString *filePath = params[@"FileName"];
//    NSString *md5 = params[@"FileMD5"];
//    NSString *signPublicKey = params[@"TargetKey"];
    NSString *toid = params[@"TargetId"];
    NSString *userId = [UserModel getUserModel].userId;
    NSString *userKey = [EntryModel getShareObject].signPublicKey;
    if ([userId isEqualToString:toid]) { // 自己头像
        NSString *userHeaderImg64Str = [UserHeaderModel getUserHeaderImg64StrWithKey:userKey];
        if (userHeaderImg64Str) { // 本地有头像
            // 上传
            NSData *imgData = [NSData dataWithBase64EncodedString:userHeaderImg64Str];
            [[UserHeadUtil getUserHeadUtilShare] uploadHeader:imgData showToast:NO];
        } else { // 本地没有头像
        }
    } else { // 好友头像
    }
}

@end
