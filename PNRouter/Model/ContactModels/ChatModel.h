//
//  ChatModel.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/2/27.
//  Copyright © 2019 旷自辉. All rights reserved.
//


#import <BGFMDB/BGFMDB.h>
NS_ASSUME_NONNULL_BEGIN

@interface ChatModel : BBaseModel

@property (nonatomic, strong) NSString *fromId;
@property (nonatomic, strong) NSString *toId;
@property (nonatomic, strong) NSString *atIds;
@property (nonatomic, strong) NSString *messageMsg;
@property (nonatomic, assign) long msgid;
@property (nonatomic, strong) NSString *toPublicKey;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) NSString *fileInfo;
@property (nonatomic, assign) int msgType;
@property (nonatomic, strong) NSString *dsKey;
@property (nonatomic, strong) NSString *srcKey;
@property (nonatomic, strong) NSString *msgKey;
@property (nonatomic, assign) long sendTime;
@property (nonatomic, assign) float fileSize;
@property (nonatomic, assign) BOOL isSendFailed;

@end

NS_ASSUME_NONNULL_END
