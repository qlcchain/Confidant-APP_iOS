//
//  SocketDataUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/29.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "SocketDataUtil.h"
#import "MyConfidant-Swift.h"
#import "SocketMessageUtil.h"
#import "SystemUtil.h"
#import "MD5Util.h"
#import "UserModel.h"
#import "NSDate+Category.h"
#import "SocketManageUtil.h"
#import "NSData+CRC16.h"
#import "MyConfidant-Swift.h"
#import "UserConfig.h"
#import "FileData.h"
#import "NSDateFormatter+Category.h"
#import "ChatListModel.h"
#import "RouterModel.h"
#import "ChatListDataUtil.h"
#import "ChatModel.h"
#import "FileConfig.h"
#import "PNFileUploadModel.h"
#import "PNFileModel.h"

#define NTOHL(x)    (x) = ntohl((__uint32_t)x) //转换成本地字节流
#define NTOHS(x)    (x) = ntohs((__uint16_t)x) //转换成本地字节流
#define NTOHLL(x)   (x) = ntohll((__uint64_t)x) //转换成本地字节流
#define HTONL(x)    (x) = htonl((__uint32_t)x) //转换成网络字节流
#define HTONS(x)    (x) = htons((__uint16_t)x) //转换成网络字节流
#define HTONLL(x)   (x) = htonll((__uint64_t)x) //转换网络字节流


static CGFloat request_time = 50.0f;
//static NSString *Action_SendFile = @"SendFile";
static NSString *Action_SendFileEnd = @"SendFileEnd";


struct SendFile {
    uint32_t magic;
    uint32_t action;
    uint32_t segsize;
    uint32_t segseq;
    uint32_t offset;
    uint32_t fileid;
    uint16_t crc;
    uint8_t  segmore;
    uint8_t cotinue;
    char filename[256];
    char fromid[77];
    char toid[77];
    char srcKey[256];
    char dstKey[256];
    char porperty[1];
    char Ver[1];
    //char content[1024*1024*2];
   // char content[0];
   // char* content;
};

struct ResultFile {
    uint32_t action;
    uint32_t fileid;
    uint32_t logid;
    uint32_t segseq;
    uint16_t crc;
    uint16_t code;
    char fromid[77];
    char toid[77];
};

@interface SocketDataUtil ()
{
    struct SendFile sendFile;
    struct ResultFile resultFile;
    uint32_t currentSegseq;
    BOOL sendFinsh;
    int sendFileSizeMax;
}

@property (nonatomic ,strong) SocketFileUtil *fileUtil;
@property (nonatomic ,strong) NSData *fileData;
@property (nonatomic ,strong) NSString *fileTextConnent;
@property (nonatomic ,strong) NSString *toid;
@property (nonatomic ,strong) NSString *fileName;
@property (nonatomic ,strong) NSString *fileMessageId;
@property (nonatomic ,strong) NSString *messageid;
@property (nonatomic ,strong) NSMutableDictionary *statusDic;
@property (nonatomic ,assign) uint32_t fileType;
@property (nonatomic ,assign) NSInteger retCode;


//@property (nonatomic ,assign) uint32_t currentSegSize; // 当前片段大小
//@property (nonatomic ,assign) uint32_t currentSegSeq; // 当前片段序号
//@property (nonatomic ,assign) uint32_t currentFileOffset; // 当前偏移量

@end

@implementation SocketDataUtil

- (void) disSocketConnect
{
    [_fileUtil disconnect];
}
- (NSMutableDictionary *)statusDic
{
    if (!_statusDic) {
        _statusDic = [[NSMutableDictionary alloc] init];
    }
    return _statusDic;
}

- (instancetype) init
{
    if (self = [super init]) {
         _fileUtil = [[SocketFileUtil alloc] init];
         [_fileUtil connectWithUrl:[self connectUrl]];
    }
    return self;
}

#pragma mark - Router 响应APP
- (void) receiveFileText:(NSString *) text
{
    NSLog(@"receiveFileText = %@",text);
    NSDictionary *receiveDic = text.mj_JSONObject;
    NSString *action = receiveDic[@"params"][@"Action"];
    NSInteger retCode = [receiveDic[@"params"][@"Retcode"] integerValue];
    if ([action isEqualToString:Action_SendFile]) {
        if (retCode == 0) {// 校验发送文件成功
            NSLog(@"time123 = %@",[NSDate date]);
            [_fileUtil sendWithData:self.fileData];
        } else { // 校验发送文件失败
            if ([_fileUtil isConnected]) { // 网络正常重发
                [_fileUtil sendWithText:self.fileTextConnent];
            } else {
                // 发送失败通知
                 _isComplete = YES;
                 [_fileUtil disconnect];
            }
        }
    } else if ([action isEqualToString:Action_SendFileEnd]) {
        _isComplete = YES;
        [_fileUtil disconnect];
        if (retCode == 0) { // 文件发送成功
            
        } else if (retCode == 1) {
            DDLogDebug(@"文件大小错误");
        } else if (retCode == 2) {
             DDLogDebug(@"文件md5错误");
        }
    }
}
- (void) receiveFileData:(NSData *) data
{
    _isComplete = YES;
    
    // data 转结构体
    [data getBytes:&resultFile length:sizeof(resultFile)];
    NTOHL(resultFile.action);
    NTOHL(resultFile.fileid);
    NTOHL(resultFile.logid);
    NTOHL(resultFile.segseq);
    NTOHS(resultFile.crc);
    NTOHS(resultFile.code);
    NSLog(@"receiveFileData: code = %d------segreq = %d",resultFile.code,resultFile.segseq);
    self.fileMessageId = [NSString stringWithFormat:@"%u",resultFile.logid];
    self.fileid = [NSString stringWithFormat:@"%u",resultFile.fileid];
    self.statusDic[[NSString stringWithFormat:@"%u",currentSegseq]] = @"1";
    _retCode = resultFile.code;
    if (self.isCancel) {
        if (sendFile.segmore == 0) { //文件发送完成 调用删除接口
            NSDictionary *params = @{@"Action":@"DelMsg",@"FriendId":self.toid?:@"",@"UserId":[UserConfig getShareObject].userId?:@"",@"MsgId":self.fileMessageId?:@""};
            [SocketMessageUtil sendVersion1WithParams:params];
        }
         [_fileUtil disconnect];
    } else {
        if (resultFile.code == 0) {
            [self sendFileWithTag:2];
        } else if (resultFile.code == 5) {
            [_fileUtil disconnect];
        } else {
            [self sendFileWithTag:1];
        }
    }
    
   /* 0：成功
    1：CRC校验错误
    2：ID错误
    3：文件打开错误
    4：文件块超长
    5：已被好友删除*/
}

#pragma mark -connectUrl
- (NSString *) connectUrl
{
    NSString *connectURL = [SystemUtil connectFileUrl];
   
    return connectURL;
}

#pragma mark -发送文件校验参数
//+ (NSDictionary *) sendFileId:(NSString *) toid fileName:(NSString *) fileName fileData:(NSData *) imgData
//{
//     NSString *timestamp = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
//    if ([fileName isEmptyString]) {
//        fileName = timestamp;
//    }
//    NSString *fileMD5 = [MD5Util md5WithData:imgData];
//    NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":[UserModel getUserModel].userId?:@"",@"ToId":toid?:@"",@"FileName":fileName?:@"",@"FileSize":[NSNumber numberWithInteger:imgData.length],@"FileMD5":fileMD5};
//    return parames;
//}

- (void) sendContactsToId:(NSString *) toid fileName:(NSString *) fileName fileInfo:(NSString *) fInfo fileData:(NSData *) imgData fileid:(NSString *) fileid fileType:(uint32_t) fileType srcKey:(NSString *)srcKey
{
   NSString *base58FileName = [Base58Util Base58EncodeWithCodeName:fileName];
    self.fileType = fileType;
    self.fileData = imgData;
    self.fileInfo = fInfo;
    self.toid = toid;
    self.fileid = fileid;
    self.srcKey = srcKey;
    self.fileName = [Base58Util Base58EncodeWithCodeName:fileName];
    currentSegseq = 1;
    uint32_t action = fileType;
    uint32_t segseq = 1;
    uint32_t offset = 0;
    uint32_t millFileid = (int)fileid;
    uint16_t crc = 0;
    uint32_t magic = 0x0dadc0de;
    
    sendFileSizeMax = [FileConfig sharedFileConfig].uploadFileMaxSize;
    uint32_t sendFileSize = imgData.length>sendFileSizeMax?sendFileSizeMax:(uint32_t)imgData.length;
    uint8_t segMoreBlg = 0;
    if (imgData.length > sendFileSizeMax) {
        segMoreBlg = 1;
    }
    
    HTONL(action);
    HTONL(magic);
    HTONL(sendFileSize);
    HTONL(segseq);
    HTONL(offset);
    HTONL(millFileid);
    HTONS(crc);
    
    NSData *sendData = nil;
    if (segMoreBlg == 1) {
        sendData = [self.fileData subdataWithRange:NSMakeRange(offset, sendFileSizeMax)];
    } else {
        sendData = [self.fileData subdataWithRange:NSMakeRange(offset, self.fileData.length-offset)];
    }
    
    sendFile.magic = magic;
    sendFile.action = action;
    sendFile.segsize = sendFileSize;
    sendFile.segseq = segseq;
    sendFile.offset = offset;
    sendFile.fileid = millFileid;
    sendFile.crc = crc;
    sendFile.segmore = segMoreBlg;
    sendFile.cotinue = 0;
    
    if (![toid isEmptyString]) {
        memcpy(sendFile.toid, [toid cStringUsingEncoding:NSASCIIStringEncoding],[toid length]);
    }
    memcpy(sendFile.srcKey, [srcKey cStringUsingEncoding:NSASCIIStringEncoding],[srcKey length]);
    
    sendFile.porperty[0] = '\6';
    sendFile.Ver[0] = '\1';
    
    memcpy(sendFile.filename, [base58FileName cStringUsingEncoding:NSASCIIStringEncoding],[base58FileName length]);
    memcpy(sendFile.fromid,[[UserConfig getShareObject].userId cStringUsingEncoding:NSASCIIStringEncoding],[[UserConfig getShareObject].userId length]);
    
    // 结构体转data
    NSData *myData = [NSData dataWithBytes:&sendFile length:sizeof(sendFile)];
    NSMutableData *mutData = [NSMutableData dataWithData:myData];
    [mutData appendData:sendData];
    uint16_t crc16 = [mutData hexadecimalUint16];
    HTONS(crc16);
    sendFile.crc = crc16;

    myData = [NSData dataWithBytes:&sendFile length:sizeof(sendFile)];
    mutData = [NSMutableData dataWithData:myData];
    [mutData appendData:sendData];
    
    @weakify_self
    [_fileUtil setOnConnect:^{
        NSLog(@"%@--%@",[weakSelf.fileUtil class],weakSelf.fileUtil.socket);
        [weakSelf sendFileData:mutData];
    }];
    
    [_fileUtil setOnDisconnect:^(NSError * error, NSString * url) {
        if (!weakSelf.isCancel) {
            if (self->sendFinsh) {
                [[SocketManageUtil getShareObject] clearDisConnectSocket];
            } else {
                if (weakSelf.retCode == 0) {
                    weakSelf.retCode = 2;
                }
                [[SocketManageUtil getShareObject] clearDisConnectSocket];
                
                if ([weakSelf.toid isEmptyString]) {
                     [AppD.window hideHud];
                    if (weakSelf.fileType == 9) {
                        PNFileUploadModel *fileM = [[PNFileUploadModel alloc] init];
                        fileM.retCode = weakSelf.retCode;
                        fileM.fileId = [weakSelf.fileid integerValue];
                        fileM.floderId = 0;
                        [[NSNotificationCenter defaultCenter] postNotificationName:Upload_Contacts_Data_Success_Noti object:fileM];
                    }
                }
            }
        }
    }];
    
    [_fileUtil setReceiveFileText:^(NSString * fileMsg) {
        [weakSelf receiveFileText:fileMsg];
    }];
    [_fileUtil setReceiveFileData:^(NSData * fileData) {
        [weakSelf receiveFileData:fileData];
    }];
}

- (void) sendEmailToId:(NSString *) toid fileName:(NSString *) fileName fileData:(NSData *) imgData fileid:(NSString *) fileid fileType:(uint32_t) fileType srcKey:(NSString *)srcKey
{
   NSString *base58FileName = [Base58Util Base58EncodeWithCodeName:fileName];
    self.fileType = fileType;
    self.fileData = imgData;
    self.toid = toid;
    self.fileid = fileid;
    currentSegseq = 1;
    uint32_t action = fileType;
    uint32_t segseq = 1;
    uint32_t offset = 0;
    uint32_t millFileid = (int)fileid;
    uint16_t crc = 0;
    uint32_t magic = 0x0dadc0de;
    
    sendFileSizeMax = [FileConfig sharedFileConfig].uploadFileMaxSize;
    uint32_t sendFileSize = imgData.length>sendFileSizeMax?sendFileSizeMax:(uint32_t)imgData.length;
    uint8_t segMoreBlg = 0;
    if (imgData.length > sendFileSizeMax) {
        segMoreBlg = 1;
    }
    
    HTONL(action);
    HTONL(magic);
    HTONL(sendFileSize);
    HTONL(segseq);
    HTONL(offset);
    HTONL(millFileid);
    HTONS(crc);
    
    NSData *sendData = nil;
    if (segMoreBlg == 1) {
        sendData = [self.fileData subdataWithRange:NSMakeRange(offset, sendFileSizeMax)];
    } else {
        sendData = [self.fileData subdataWithRange:NSMakeRange(offset, self.fileData.length-offset)];
    }
    
    sendFile.magic = magic;
    sendFile.action = action;
    sendFile.segsize = sendFileSize;
    sendFile.segseq = segseq;
    sendFile.offset = offset;
    sendFile.fileid = millFileid;
    sendFile.crc = crc;
    sendFile.segmore = segMoreBlg;
    sendFile.cotinue = 0;
    
    if (![toid isEmptyString]) {
        memcpy(sendFile.toid, [toid cStringUsingEncoding:NSASCIIStringEncoding],[toid length]);
    }
    memcpy(sendFile.srcKey, [srcKey cStringUsingEncoding:NSASCIIStringEncoding],[srcKey length]);
    
    sendFile.porperty[0] = '\0';
    sendFile.Ver[0] = '\1';
    
    memcpy(sendFile.filename, [base58FileName cStringUsingEncoding:NSASCIIStringEncoding],[base58FileName length]);
    memcpy(sendFile.fromid,[[UserConfig getShareObject].userId cStringUsingEncoding:NSASCIIStringEncoding],[[UserConfig getShareObject].userId length]);
    
    // 结构体转data
    NSData *myData = [NSData dataWithBytes:&sendFile length:sizeof(sendFile)];
    NSMutableData *mutData = [NSMutableData dataWithData:myData];
    [mutData appendData:sendData];
    uint16_t crc16 = [mutData hexadecimalUint16];
    HTONS(crc16);
    sendFile.crc = crc16;

    myData = [NSData dataWithBytes:&sendFile length:sizeof(sendFile)];
    mutData = [NSMutableData dataWithData:myData];
    [mutData appendData:sendData];
    
    @weakify_self
    [_fileUtil setOnConnect:^{
        NSLog(@"%@--%@",[weakSelf.fileUtil class],weakSelf.fileUtil.socket);
        [weakSelf sendFileData:mutData];
    }];
    
    [_fileUtil setOnDisconnect:^(NSError * error, NSString * url) {
        if (!weakSelf.isCancel) {
            if (self->sendFinsh) {
                [[SocketManageUtil getShareObject] clearDisConnectSocket];
            } else {
                if (weakSelf.retCode == 0) {
                    weakSelf.retCode = 2;
                }
                [[SocketManageUtil getShareObject] clearDisConnectSocket];
                
                if ([weakSelf.toid isEmptyString]) {
                     [AppD.window hideHud];
                    if (weakSelf.fileType == 7) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:EMIAL_UPLOAD_NODE_NOTI object:@[@(1)]];
                    }
                }
            }
        }
    }];
    
    [_fileUtil setReceiveFileText:^(NSString * fileMsg) {
        [weakSelf receiveFileText:fileMsg];
    }];
    [_fileUtil setReceiveFileData:^(NSData * fileData) {
        [weakSelf receiveFileData:fileData];
    }];
}

- (void) sendFileId:(NSString *) toid fileName:(NSString *) fileName fileData:(NSData *) imgData fileid:(NSInteger)fileid fileType:(uint32_t) fileType messageid:(NSString *)messageid srcKey:(NSString *) srcKey dstKey:(NSString *) dstKey isGroup:(BOOL)isGroup
{
    
    NSArray *fileinfos = [fileName componentsSeparatedByString:@","];
    if (fileinfos && fileinfos.count>=2) {
       NSString *info = [fileinfos lastObject];
        fileName = [fileName substringWithRange:NSMakeRange(0, fileName.length-info.length-1)];
        fileName = [Base58Util Base58EncodeWithCodeName:fileName];
        fileName = [NSString stringWithFormat:@"%@,%@",fileName,info];
        self.fileInfo = info?:@"";
    } else {
        fileName = [Base58Util Base58EncodeWithCodeName:fileName];
    }

    self.srcKey = srcKey;
    self.isGroup = isGroup;
    self.fileName = [Base58Util Base58EncodeWithCodeName:fileinfos[0]];
    self.messageid = messageid;
    self.fileType = fileType;
    self.fileData = imgData;
    self.toid = toid;
    self.fileid = [NSString stringWithFormat:@"%ld",(long)fileid];
    currentSegseq = 1;
    uint32_t action = fileType;
    uint32_t segseq = 1;
    uint32_t offset = 0;
    uint32_t millFileid = (int)fileid;
    uint16_t crc = 0;
    uint32_t magic = 0x0dadc0de;
    
    sendFileSizeMax = [FileConfig sharedFileConfig].uploadFileMaxSize;
    uint32_t sendFileSize = imgData.length>sendFileSizeMax?sendFileSizeMax:(uint32_t)imgData.length;
    uint8_t segMoreBlg = 0;
    if (imgData.length > sendFileSizeMax) {
        segMoreBlg = 1;
    }
    
    HTONL(action);
    HTONL(magic);
    HTONL(sendFileSize);
    HTONL(segseq);
    HTONL(offset);
    HTONL(millFileid);
    HTONS(crc);
    
    if ([toid isEmptyString] && fileType !=6 && !_isPhoto) // 上传文件
    {
        [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(srcKey),bg_sqlKey(@"fileId"),bg_sqlValue(@(fileid))] complete:^(NSArray * _Nullable array) {
            if (array && array.count > 0) {
                FileData *fileModel = array[0];
                fileModel.status = 2;
                NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
                fileModel.optionTime = [formatter stringFromDate:[NSDate date]];
                [fileModel bg_saveOrUpdateAsync:nil];
            } else {
                FileData *fileModel = [[FileData alloc] init];
                fileModel.bg_tableName = FILE_STATUS_TABNAME;
                fileModel.fileId = fileid;
                fileModel.fileSize = imgData.length;
                NSDateFormatter *formatter = [NSDateFormatter defaultDateFormatter];
                fileModel.optionTime = [formatter stringFromDate:[NSDate date]];
                fileModel.fileData = imgData;
                fileModel.fileType = fileType;
                fileModel.progess = 0.0f;
                fileModel.fileName = fileinfos[0];
                fileModel.fileOptionType = 1;
                fileModel.status = 2;
                fileModel.userId = [UserConfig getShareObject].userId;
                fileModel.srcKey = srcKey;
                [fileModel bg_saveAsync:nil];
            }
        }];
    } else if (_isPhoto) { // 相册图片上传 改变其状态
        
        [PNFileModel bg_update:EN_FILE_TABNAME where:[NSString stringWithFormat:@"set %@=%@,%@=%@,%@=%@,%@=%@,%@=%@ where %@=%@",bg_sqlKey(@"delHidden"),bg_sqlValue(@(0)),bg_sqlKey(@"uploadStatus"),bg_sqlValue(@(1)),bg_sqlKey(@"progressV"),bg_sqlValue(@(0)),bg_sqlKey(@"toFloderId"),bg_sqlValue(@(_floderId)),bg_sqlKey(@"LastModify"),bg_sqlValue(@([NSDate getTimestampFromDate:[NSDate date]])),bg_sqlKey(@"fId"),bg_sqlValue(@(fileid))]];
    }
    
    NSData *sendData = nil;
    if (segMoreBlg == 1) {
        sendData = [self.fileData subdataWithRange:NSMakeRange(offset, sendFileSizeMax)];
    } else {
        sendData = [self.fileData subdataWithRange:NSMakeRange(offset, self.fileData.length-offset)];
    }
    
    sendFile.magic = magic;
    sendFile.action = action;
    sendFile.segsize = sendFileSize;
    sendFile.segseq = segseq;
    sendFile.offset = offset;
    sendFile.fileid = millFileid;
    sendFile.crc = crc;
    sendFile.segmore = segMoreBlg;
    sendFile.cotinue = 0;
    
    if (![toid isEmptyString]) {
        memcpy(sendFile.toid, [toid cStringUsingEncoding:NSASCIIStringEncoding],[toid length]);
    }
    memcpy(sendFile.srcKey, [srcKey cStringUsingEncoding:NSASCIIStringEncoding],[srcKey length]);
    if (![dstKey isEmptyString]) {
        memcpy(sendFile.dstKey, [dstKey cStringUsingEncoding:NSASCIIStringEncoding],[dstKey length]);
    }
//    NSString *porpertyType = @"0";
//    if (isGroup) {
//        porpertyType = @"1";
//    }
   
    if (isGroup) {
        sendFile.porperty[0] = '\1';
    } else if (_isPhoto) {
        sendFile.porperty[0] = '\3';
    } else {
         sendFile.porperty[0] = '\0';
    }
    sendFile.Ver[0] = '\1';
    
    //memcpy(sendFile.porperty, [porpertyType cStringUsingEncoding:NSASCIIStringEncoding],[porpertyType length]);
    
    memcpy(sendFile.filename, [fileName cStringUsingEncoding:NSASCIIStringEncoding],[fileName length]);
    memcpy(sendFile.fromid,[[UserConfig getShareObject].userId cStringUsingEncoding:NSASCIIStringEncoding],[[UserConfig getShareObject].userId length]);

    // 结构体转data
    NSData *myData = [NSData dataWithBytes:&sendFile length:sizeof(sendFile)];
    NSMutableData *mutData = [NSMutableData dataWithData:myData];
    [mutData appendData:sendData];
    uint16_t crc16 = [mutData hexadecimalUint16];
    HTONS(crc16);
    sendFile.crc = crc16;
    // data转结构体
   // [myData getBytes:&newJoin length:sizeof(newJoin)];
    
    
    myData = [NSData dataWithBytes:&sendFile length:sizeof(sendFile)];
    mutData = [NSMutableData dataWithData:myData];
    [mutData appendData:sendData];
    
    NSLog(@"----%@----",[mutData subdataWithRange:NSMakeRange(mutData.length-4, 4)]);
    
    @weakify_self
    [_fileUtil setOnConnect:^{
        NSLog(@"%@--%@",[weakSelf.fileUtil class],weakSelf.fileUtil.socket);
        [weakSelf sendFileData:mutData];
    }];
    
    [_fileUtil setOnDisconnect:^(NSError * error, NSString * url) {
        if (!weakSelf.isCancel) {
            if (self->sendFinsh) {
                [[SocketManageUtil getShareObject] clearDisConnectSocket];
            } else {
                if (weakSelf.retCode == 0) {
                    weakSelf.retCode = 2;
                }
                [[SocketManageUtil getShareObject] clearDisConnectSocket];
                
                if ([weakSelf.toid isEmptyString]) {
                    if (weakSelf.fileType == 6) { // 头像
                        
                         [[NSNotificationCenter defaultCenter] postNotificationName:UPLOAD_HEAD_DATA_NOTI object:@[@(weakSelf.retCode),weakSelf.fileName,@"",@(weakSelf.fileType),weakSelf.srcKey,weakSelf.fileid]];
                    } else if (weakSelf.isPhoto) { // 加密相册
                        PNFileUploadModel *fileM = [[PNFileUploadModel alloc] init];
                        fileM.retCode = weakSelf.retCode;
                        fileM.fileId = [weakSelf.fileid integerValue];
                        fileM.floderId = weakSelf.floderId;
                        [[NSNotificationCenter defaultCenter] postNotificationName:Photo_Upload_FileData_Noti object:fileM];
                    } else { // 上传文件
                        [[NSNotificationCenter defaultCenter] postNotificationName:FILE_UPLOAD_NOTI object:@[@(weakSelf.retCode),weakSelf.fileName,@"",@(weakSelf.fileType),weakSelf.srcKey,weakSelf.fileid]];
                    }
                    
                } else {
                    if (self.isGroup) {

                        [[NSNotificationCenter defaultCenter] postNotificationName:GROUP_FILE_SEND_FAIELD_NOTI object:@[@(weakSelf.retCode),weakSelf.toid,weakSelf.messageid?:@""]];
                    } else {
                         [[NSNotificationCenter defaultCenter] postNotificationName:FILE_SEND_NOTI object:@[@(weakSelf.retCode),weakSelf.fileid,weakSelf.toid,@(weakSelf.fileType),weakSelf.messageid?:@""]];
                    }
                   
                    if (weakSelf.retCode == 5) { //对方不是好友了,删除未读消息
                         [ChatModel bg_delete:CHAT_CACHE_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"fromId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"msgid"),bg_sqlValue(weakSelf.messageid)]];
                    } else {
                        // 文件发送失败，更改发送状态
                        BOOL updateB = [ChatModel bg_update:CHAT_CACHE_TABNAME where:[NSString stringWithFormat:@"set %@=%@ where %@=%@ and %@=%@",bg_sqlKey(@"isSendFailed"),bg_sqlValue(@(1)),bg_sqlKey(@"fromId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"msgid"),bg_sqlValue(weakSelf.messageid)]];
                        NSLog(@"----文件发送失败，更改发送状态-------%@",@(updateB));
                    }
                    
                }
            }
        }
    }];
    [_fileUtil setReceiveFileText:^(NSString * fileMsg) {
        [weakSelf receiveFileText:fileMsg];
    }];
    [_fileUtil setReceiveFileData:^(NSData * fileData) {
        [weakSelf receiveFileData:fileData];
    }];
}

/**
 发送文件

 @param tag 1:重发 2:发送下一段
 */
- (void) sendFileWithTag:(NSInteger) tag {

    if (tag == 1) { //重发
        if (![_fileUtil isConnected]) { // socket断开连接
            [_fileUtil disconnect];
            return;
        }
        NSData *myData = [NSData dataWithBytes:&sendFile length:sizeof(sendFile)];
        [self sendFileData:myData];
    } else {
        if (sendFile.segmore == 0) { //文件发送完成
            sendFinsh = YES;
            [_fileUtil disconnect];
            if ([self.toid isEmptyString]) {
                if (self.fileType == 6) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:UPLOAD_HEAD_DATA_NOTI object:@[@(self.retCode),self.fileName,@"",@(self.fileType),self.srcKey,self.fileid]];
                } else if (self.fileType == 7) { // email 上传完成
                    [[NSNotificationCenter defaultCenter] postNotificationName:EMIAL_UPLOAD_NODE_NOTI object:@[@(0),self.fileid,@(self.fileData.length),[MD5Util md5WithData:self.fileData]]];
                } else if (self.fileType == 9) { // 通讯录 上传完成
                    PNFileUploadModel *fileM = [[PNFileUploadModel alloc] init];
                    fileM.retCode = 0;
                    fileM.fileId = [self.fileid integerValue];
                    fileM.fileType = self.fileType;
                    fileM.fileName = self.fileName;
                    fileM.fileSize = self.fileData.length;
                    fileM.fileMd5 = [MD5Util md5WithData:self.fileData];
                    fileM.Finfo = self.fileInfo;
                    fileM.FKey = self.srcKey;
                    fileM.floderId = 0;
                     [[NSNotificationCenter defaultCenter] postNotificationName:Upload_Contacts_Data_Success_Noti object:fileM];
                } else if (self.isPhoto) {
                    PNFileUploadModel *fileM = [[PNFileUploadModel alloc] init];
                    fileM.retCode = 0;
                    fileM.fileId = [self.fileid integerValue];
                    fileM.fileType = self.fileType;
                    fileM.fileName = self.fileName;
                    fileM.fileSize = self.fileData.length;
                    fileM.fileMd5 = [MD5Util md5WithData:self.fileData];
                    fileM.Finfo = self.fileInfo;
                    fileM.FKey = self.srcKey;
                    fileM.floderId = self.floderId;
                    [[NSNotificationCenter defaultCenter] postNotificationName:Photo_Upload_FileData_Noti object:fileM];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:FILE_UPLOAD_NOTI object:@[@(0),self.fileName,@"",@(self.fileType),self.srcKey,self.fileid]];
                }
                
            } else {
                
                if (!self.isGroup) {
                    // 添加到chatlist
                    ChatListModel *chatModel = [[ChatListModel alloc] init];
                    chatModel.myID = [UserConfig getShareObject].usersn;
                    chatModel.friendID = self.toid;
                    chatModel.chatTime = [NSDate date];
                    chatModel.isHD = NO;
                    NSInteger msgType = self.fileType;
                    
                    if (msgType == 1) {
                        chatModel.lastMessage = @"[photo]";
                    } else if (msgType == 2) {
                        chatModel.lastMessage = @"[voice]";
                    } else if (msgType == 5){
                        chatModel.lastMessage = @"[file]";
                    } else if (msgType == 4){
                        chatModel.lastMessage = @"[video]";
                    }
                    [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
                }
                
                
                if (self.isGroup) {
                   // 群组文件发送成功
                    [SendRequestUtil sendGroupFilePretreatmentWithGID:self.toid fileName:self.fileName fileSize:@(self.fileData.length) fileType:@(self.fileType) fileMD5:[MD5Util md5WithData:self.fileData] fileInfo:self.fileInfo fileId:self.messageid];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:FILE_SEND_NOTI object:@[@(0),self.fileid,self.toid,@(self.fileType),self.messageid?:@"",self.fileMessageId]];
                    // 文件发送成功，删除记录
                    [ChatModel bg_delete:CHAT_CACHE_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"fromId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"msgid"),bg_sqlValue(self.messageid)]];
                }
                
                
                
            }
            return;
        }
        if (![_fileUtil isConnected]) { // socket断开连接
            [_fileUtil disconnect];
            return;
        }
        
        if ([self.toid isEmptyString] && !_isPhoto) {
            CGFloat progess = (sendFileSizeMax*resultFile.segseq*1.0)/self.fileData.length;
          
            FileData *fileDataModel = [[FileData alloc] init];
            fileDataModel.progess = progess;
            fileDataModel.srcKey = self.srcKey;
            fileDataModel.status = 2;
            fileDataModel.fileId = [self.fileid integerValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:File_Progess_Noti object:fileDataModel];
            
        } else if (_isPhoto) {
            PNFileUploadModel *fileM = [[PNFileUploadModel alloc] init];
            fileM.fileId = [self.fileid integerValue];
            fileM.floderId = self.floderId;
            fileM.progress = (sendFileSizeMax*resultFile.segseq*1.0)/self.fileData.length;
            [[NSNotificationCenter defaultCenter] postNotificationName:Photo_FileData_Upload_Progress_Noti object:fileM];
            // 更新本地进度
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                [PNFileModel bg_update:EN_FILE_TABNAME where:[NSString stringWithFormat:@"set %@=%@ where %@=%@",bg_sqlKey(@"progressV"),bg_sqlValue(@(0)),bg_sqlKey(@"fId"),bg_sqlValue(@(fileM.fileId))]];
            });
            
        }
        
      //  dispatch_async(dispatch_get_global_queue(0, 0), ^{
            uint32_t sendFileSize = self.fileData.length>(sendFileSizeMax*(resultFile.segseq+1))?sendFileSizeMax:(uint32_t)self.fileData.length-(sendFileSizeMax*resultFile.segseq);
            uint8_t segMoreBlg = 0;
            if (self.fileData.length>(sendFileSizeMax*(resultFile.segseq+1))) {
                segMoreBlg = 1;
            }
            uint32_t offset = resultFile.segseq*sendFileSizeMax;
            uint32_t segseq = resultFile.segseq+1;
            uint16_t crc = 0;
            currentSegseq = segseq;
            
            NSData *sendData = nil;
            if (segMoreBlg == 1) {
                sendData = [self.fileData subdataWithRange:NSMakeRange(offset, sendFileSizeMax)];
            } else {
                sendData = [self.fileData subdataWithRange:NSMakeRange(offset, self.fileData.length-offset)];
            }
            
            //memcpy(sendFile.content,[sendData bytes],[sendData length]);
       // sendFile.content = [sendData bytes];
            
            HTONL(sendFileSize);
            HTONL(segseq);
            HTONL(offset);
            HTONS(crc);
            sendFile.segsize = sendFileSize;
            sendFile.segseq = segseq;
            sendFile.offset = offset;
            sendFile.crc = crc;
            sendFile.segmore = segMoreBlg;
            
            // 结构体转data
            NSData *myData = [NSData dataWithBytes:&sendFile length:sizeof(sendFile)];
            NSMutableData *mutData = [NSMutableData dataWithData:myData];
            [mutData appendData:sendData];
            uint16_t crc16 = [myData hexadecimalUint16];
            HTONS(crc16);
            sendFile.crc = crc16;
            
            myData = [NSData dataWithBytes:&sendFile length:sizeof(sendFile)];
            mutData = [NSMutableData dataWithData:myData];
            [mutData appendData:sendData];
            [self sendFileData:mutData];
    //    });
        
        
    }
}
#pragma mark -5秒没有收到回复重新发新这段文件
- (void) sendFileData:(NSData *) myData
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.statusDic setValue:@"0" forKey:[NSString stringWithFormat:@"%u",currentSegseq]];
    _isComplete = NO;
    [self.fileUtil sendWithData:myData];
    [self performSelector:@selector(resendFile) withObject:self afterDelay:request_time];
}
- (void) resendFile {
    if (self.isCancel) {
        [_fileUtil disconnect];
    } else {
        if ([self.statusDic[[NSString stringWithFormat:@"%u",currentSegseq]] isEqualToString:@"0"]) {
            [self sendFileWithTag:1];
        }
    }
}
@end
