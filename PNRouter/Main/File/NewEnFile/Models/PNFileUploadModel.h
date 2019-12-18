//
//  PNFileUploadModel.h
//  MyConfidant
//
//  Created by 旷自辉 on 2019/12/16.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <LibsodiumSDK/LibsodiumSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNFileUploadModel : BBaseModel
@property (nonatomic, assign) NSInteger retCode;
@property (nonatomic, assign) NSInteger fileType;
@property (nonatomic, assign) NSInteger fileSize;
@property (nonatomic, assign) NSInteger fileId;
@property (strong, nonatomic) NSString *fileMd5; // 文件md5
@property (strong, nonatomic) NSString *fileName; // 文件保存路径
@property (strong, nonatomic) NSString *Finfo; // 文件附属信息
@property (strong, nonatomic) NSString *FKey; // 文件密钥
@property (assign, nonatomic) NSInteger floderId; // 文件夹id
@property (nonatomic, strong) NSString *floderName; // 文件data
@end

NS_ASSUME_NONNULL_END
