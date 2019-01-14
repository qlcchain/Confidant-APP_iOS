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
@property (nonatomic) NSInteger MsgType;
@property (nonatomic) NSInteger TimeStatmp;
@property (nonatomic, copy) NSString *From;
@property (nonatomic, copy) NSString *To;
@property (nonatomic, copy) NSString *Msg;
@property (nonatomic, copy) NSString *FileName;
@property (nonatomic, copy) NSString *FilePath;
@property (nonatomic, copy) NSString *UserKey;
@property (nonatomic, assign) CGFloat FileSize;
@property (nonatomic, assign) NSInteger Sender;
@property (nonatomic, assign) NSInteger Status;
@property (nonatomic, assign) NSInteger DbId;
@end
