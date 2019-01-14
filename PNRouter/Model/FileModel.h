//
//  FileModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/29.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

@interface FileModel : BBaseModel
@property (nonatomic ,strong) NSString *FromId;
@property (nonatomic ,strong) NSString *ToId;
@property (nonatomic ,assign) NSInteger RetCode;
@property (nonatomic ,strong) NSString *FilePath;
@property (nonatomic ,assign) CGFloat FileSize;
@property (nonatomic ,strong) NSString *FileName;
@property (nonatomic ,strong) NSString *FileMD5;
@property (nonatomic ,strong) NSString *MsgId;
@property (nonatomic ,assign) NSInteger FileType;
@property (nonatomic ,strong) NSString *SrcKey;
@property (nonatomic ,strong) NSString *DstKey;
@property (nonatomic ,assign) NSInteger timestamp;
@end
