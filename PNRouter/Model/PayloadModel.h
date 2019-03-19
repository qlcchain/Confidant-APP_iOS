//
//  PayloadModel.h
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/14.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "BBaseModel.h"

@interface PayloadModel : BBaseModel

@property (nonatomic, strong) NSString *MsgId;
@property (nonatomic, strong) NSString *FileInfo;
@property (nonatomic) NSInteger MsgType;
@property (nonatomic) NSInteger TimeStatmp;
@property (nonatomic, copy) NSString *Msg;
@property (nonatomic, copy) NSString *FileName;
@property (nonatomic, copy) NSString *FilePath;
@property (nonatomic, copy) NSString *Sign;
@property (nonatomic, copy) NSString *PriKey;
@property (nonatomic, copy) NSString *Nonce;
@property (nonatomic, assign) CGFloat FileSize;
@property (nonatomic, assign) NSInteger Sender;
@property (nonatomic, assign) NSInteger Status;
@property (nonatomic, assign) NSInteger DbId;
@end
