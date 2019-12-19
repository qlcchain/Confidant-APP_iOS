//
//  PNFileModel.h
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/28.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <LibsodiumSDK/LibsodiumSDK.h>
#import <BGFMDB/BGFMDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNFileModel : BBaseModel

@property (assign, nonatomic) NSInteger fId; // 文件id
@property (assign, nonatomic) NSInteger Depens; // 相册id
@property (assign, nonatomic) NSInteger Type; // 文件类型
@property (strong, nonatomic) NSString *Fname; // 文件名称
@property (assign, nonatomic) NSInteger Size; // 文件大小
@property (assign, nonatomic) NSInteger LastModify; // 文件最后修改讨时间戳
@property (strong, nonatomic) NSString *Md5; // 文件md5
@property (strong, nonatomic) NSString *Paths; // 文件保存路径
@property (strong, nonatomic) NSString *Finfo; // 文件附属信息
@property (strong, nonatomic) NSString *FKey; // 文件密钥
@property (assign, nonatomic) NSInteger PathId; // 文件夹id
@property (nonatomic, strong) NSData *fileData; // 文件data

@property (nonatomic, assign) CGFloat progressV; // 进度
@property (nonatomic, assign) NSInteger uploadStatus; // 0:正常 1:上传中 2:上传完成 -1:上传失败

@end

NS_ASSUME_NONNULL_END
