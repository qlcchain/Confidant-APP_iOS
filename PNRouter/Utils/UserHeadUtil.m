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

@implementation UserHeadUtil
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void) addNoti {
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAvatarSuccessNoti:) name:UpdateAvatar_Success_Noti object:nil];
}
+ (instancetype)getUserHeadUtilShare
{
    static UserHeadUtil *shareObject = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareObject = [[self alloc] init];
        [shareObject addNoti];
    });
    return shareObject;
}
- (void) sendUpdateAvatarWithFid:(NSString *) fid md5:(NSString *) md5 showHud:(BOOL) isShow
{
    [SendRequestUtil sendUpdateAvatarWithFid:fid Md5:md5 showHud:isShow];
}

- (void) downUserHeadWithDic:(NSDictionary *) parames
{
    if ([SystemUtil isSocketConnect]) {
        
        NSString *filePath = parames[@"FileName"];
        NSString *fileNameBase58 = filePath.lastPathComponent;
        NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58]?:@"";
        NSString *downloadFilePath = [SystemUtil getTempDownloadFilePath:fileName];
        NSString *signPublicKey = parames[@"TargetKey"];
        
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
        NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58]?:@"";
        NSString *toid = parames[@"ToId"];
        
    //    [SendRequestUtil sendToxPullFileWithFromId:[UserConfig getShareObject].userId toid:toid fileName:fileNameBase58 msgId:@"" fileOwer:YES fileFrom:@"2"];
    }
}

#pragma mark -noti
- (void) updateAvatarSuccessNoti:(NSNotification *) noti {
    NSDictionary *receiveDic = noti.object;
    NSDictionary *params = receiveDic[@"params"];
    [self downUserHeadWithDic:params];
}

@end
