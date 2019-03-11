//
//  SocketDataUtil.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/29.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "SocketDataUtil.h"
#import "PNRouter-Swift.h"
#import "SocketMessageUtil.h"
#import "SystemUtil.h"
#import "MD5Util.h"
#import "UserModel.h"
#import "NSDate+Category.h"
#import "SocketManageUtil.h"
#import "NSData+CRC16.h"
#import "PNRouter-Swift.h"
#import "UserConfig.h"
#import "FileData.h"
#import "NSDateFormatter+Category.h"
#import "ChatListModel.h"
#import "RouterModel.h"
#import "ChatListDataUtil.h"
#import "ChatModel.h"

#define NTOHL(x)    (x) = ntohl((__uint32_t)x) //转换成本地字节流
#define NTOHS(x)    (x) = ntohs((__uint16_t)x) //转换成本地字节流
#define NTOHLL(x)   (x) = ntohll((__uint64_t)x) //转换成本地字节流
#define HTONL(x)    (x) = htonl((__uint32_t)x) //转换成网络字节流
#define HTONS(x)    (x) = htons((__uint16_t)x) //转换成网络字节流
#define HTONLL(x)   (x) = htonll((__uint64_t)x) //转换网络字节流


static CGFloat request_time = 50.0f;
//static NSString *Action_SendFile = @"SendFile";
static NSString *Action_SendFileEnd = @"SendFileEnd";
static int sendFileSizeMax = 1024*1024*2;

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
/*#pragma mark -发送文件校验
- (void) sendFileWithParames:(NSDictionary *) parames fileData:(NSData *)data
{
    NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:[SocketMessageUtil getBaseParams]];
    [muDic setObject:parames forKey:@"params"];
    NSString *text = muDic.mj_JSONString;
    self.fileTextConnent = text;
    self.fileData = data;
    @weakify_self
    [_fileUtil setOnConnect:^{
        NSLog(@"%@--%@",[weakSelf.fileUtil class],weakSelf.fileUtil.socket);
        [weakSelf.fileUtil sendWithText:text];
    }];
    
    [_fileUtil setOnDisconnect:^(NSError * error, NSString * url) {
        if (weakSelf.isComplete) {
            [[SocketManageUtil getShareObject] clearDisConnectSocket];
        } else {
            if (![url isEqualToString:SOCKET_FILEURL_DEFAULT]) {
                [weakSelf.fileUtil connectWithUrl:SOCKET_FILEURL_DEFAULT];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:FILE_SEND_NOTI object:@[@(0),weakSelf.fileid?:@"",weakSelf.toid?:@"",@(weakSelf.fileType),weakSelf.messageid?:@""]];
            }
        }
    }];
    [_fileUtil setReceiveFileText:^(NSString * fileMsg) {
        [weakSelf receiveFileText:fileMsg];
    }];
    [_fileUtil setReceiveFileData:^(NSData * fileData) {
        [weakSelf receiveFileData:fileData];
    }];
     //如果超过10秒没收到确认消息，则文件传输失败，需要重新发起发送文件流程
    [_fileUtil setSendFileComplete:^{
        [weakSelf performSelector:@selector(checkFileIsComplete) withObject:weakSelf afterDelay:request_time];
    }];
   
}*/
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

- (void) sendFileId:(NSString *) toid fileName:(NSString *) fileName fileData:(NSData *) imgData fileid:(NSInteger)fileid fileType:(uint32_t) fileType messageid:(NSString *)messageid srcKey:(NSString *) srcKey dstKey:(NSString *) dstKey
{
    
    fileName = [Base58Util Base58EncodeWithCodeName:fileName];
    self.srcKey = srcKey;
    self.fileName = fileName;
    self.messageid = messageid;
    self.fileType = fileType;
    self.fileData = imgData;
    self.toid = toid;
    self.fileid = [NSString stringWithFormat:@"%ld",(long)fileid];
    currentSegseq = 1;
    //int millSecond = [[NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])] intValue];
    uint32_t action = fileType;
    uint32_t segseq = 1;
    uint32_t offset = 0;
    uint32_t millFileid = (int)fileid;
    uint16_t crc = 0;
    uint32_t magic = 0x0dadc0de;
    
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
    
//    struct SendFile *fileStruct =(struct SendFile *) malloc(sizeof(sendFile)+sendData.length);
//    memcpy(fileStruct->content,[sendData bytes],[sendData length]);
//
//    for (int i = 0; i<sendData.length; i++) {
//        NSLog(@"---%d",fileStruct->content[i]);
//    }
    

//    fileStruct->magic = magic;
//    fileStruct->action = action;
//    fileStruct->segsize = sendFileSize;
//    fileStruct->segseq = segseq;
//    fileStruct->offset = offset;
//    fileStruct->fileid = millFileid;
//    fileStruct->crc = crc;
//    fileStruct->segmore = segMoreBlg;
//    fileStruct->cotinue = 0;
    
    sendFile.magic = magic;
    sendFile.action = action;
    sendFile.segsize = sendFileSize;
    sendFile.segseq = segseq;
    sendFile.offset = offset;
    sendFile.fileid = millFileid;
    sendFile.crc = crc;
    sendFile.segmore = segMoreBlg;
    sendFile.cotinue = 0;
    
    if ([toid isEmptyString] && fileType !=6) // 上传文件
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
                fileModel.fileName = [Base58Util Base58DecodeWithCodeName:fileName];
                fileModel.fileOptionType = 1;
                fileModel.status = 2;
                fileModel.userId = [UserConfig getShareObject].userId;
                fileModel.srcKey = srcKey;
                [fileModel bg_saveAsync:nil];
            }
        }];
    }
    
    if (![toid isEmptyString]) {
        memcpy(sendFile.toid, [toid cStringUsingEncoding:NSASCIIStringEncoding],[toid length]);
    }
    memcpy(sendFile.srcKey, [srcKey cStringUsingEncoding:NSASCIIStringEncoding],[srcKey length]);
    if (![dstKey isEmptyString]) {
        memcpy(sendFile.dstKey, [dstKey cStringUsingEncoding:NSASCIIStringEncoding],[dstKey length]);
    }
    
    printf("srckey = %s , dskey = %s",sendFile.srcKey,sendFile.dstKey);

    memcpy(sendFile.filename, [fileName cStringUsingEncoding:NSASCIIStringEncoding],[fileName length]);
    memcpy(sendFile.fromid,[[UserConfig getShareObject].userId cStringUsingEncoding:NSASCIIStringEncoding],[[UserConfig getShareObject].userId length]);
    
    
//    if (![toid isEmptyString]) {
//        memcpy(fileStruct->toid, [toid cStringUsingEncoding:NSASCIIStringEncoding],[toid length]);
//    }
//    memcpy(fileStruct->srcKey, [srcKey cStringUsingEncoding:NSASCIIStringEncoding],[srcKey length]);
//    if (![dstKey isEmptyString]) {
//        memcpy(fileStruct->dstKey, [dstKey cStringUsingEncoding:NSASCIIStringEncoding],[dstKey length]);
//    }
//
//    printf("srckey = %s , dskey = %s",fileStruct->srcKey,fileStruct->dstKey);
//
//    memcpy(fileStruct->filename, [fileName cStringUsingEncoding:NSASCIIStringEncoding],[fileName length]);
//    memcpy(fileStruct->fromid,[[UserConfig getShareObject].userId cStringUsingEncoding:NSASCIIStringEncoding],[[UserConfig getShareObject].userId length]);
    
    // 结构体转data
    NSData *myData = [NSData dataWithBytes:&sendFile length:sizeof(sendFile)];
    NSMutableData *mutData = [NSMutableData dataWithData:myData];
    [mutData appendData:sendData];
    uint16_t crc16 = [mutData hexadecimalUint16];
    HTONS(crc16);
    sendFile.crc = crc16;
   // fileStruct->crc = crc16;
    // data转结构体
   // [myData getBytes:&newJoin length:sizeof(newJoin)];
    
    
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
                    if (weakSelf.fileType == 6) {
                        
                         [[NSNotificationCenter defaultCenter] postNotificationName:UPLOAD_HEAD_DATA_NOTI object:@[@(weakSelf.retCode),weakSelf.fileName,@"",@(weakSelf.fileType),weakSelf.srcKey,weakSelf.fileid]];
                    } else {
                        [[NSNotificationCenter defaultCenter] postNotificationName:FILE_UPLOAD_NOTI object:@[@(weakSelf.retCode),weakSelf.fileName,@"",@(weakSelf.fileType),weakSelf.srcKey,weakSelf.fileid]];
                    }
                    
                } else {
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:FILE_SEND_NOTI object:@[@(weakSelf.retCode),weakSelf.fileid,weakSelf.toid,@(weakSelf.fileType),weakSelf.messageid?:@""]];
                    if (weakSelf.retCode == 5) { //对方不是好友了,删除未读消息
                         [ChatModel bg_delete:CHAT_CACHE_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"fromId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"msgid"),bg_sqlValue(weakSelf.messageid)]];
                    } else {
                        // 文件发送失败，更改发送状态
                        [ChatModel bg_update:CHAT_CACHE_TABNAME where:[NSString stringWithFormat:@"set %@=%@ where %@=%@ and %@=%@",bg_sqlKey(@"isSendFailed"),bg_sqlValue(@(1)),bg_sqlKey(@"fromId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"msgid"),bg_sqlValue(weakSelf.messageid)]];
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
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:FILE_UPLOAD_NOTI object:@[@(0),self.fileName,@"",@(self.fileType),self.srcKey,self.fileid]];
                }
                
            } else {
                
                // 添加到chatlist
                ChatListModel *chatModel = [[ChatListModel alloc] init];
                chatModel.myID = [UserConfig getShareObject].userId;
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
                
                 [[NSNotificationCenter defaultCenter] postNotificationName:FILE_SEND_NOTI object:@[@(0),self.fileid,self.toid,@(self.fileType),self.messageid?:@"",self.fileMessageId]];
                
                 // 文件发送成功，删除记录
                 [ChatModel bg_delete:CHAT_CACHE_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"fromId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"msgid"),bg_sqlValue(self.messageid)]];
            }
            return;
        }
        if (![_fileUtil isConnected]) { // socket断开连接
            [_fileUtil disconnect];
            return;
        }
        
        if ([self.toid isEmptyString]) {
            CGFloat progess = (sendFileSizeMax*resultFile.segseq*1.0)/self.fileData.length;
          
            FileData *fileDataModel = [[FileData alloc] init];
            fileDataModel.progess = progess;
            fileDataModel.srcKey = self.srcKey;
            fileDataModel.status = 2;
            fileDataModel.fileId = [self.fileid integerValue];
            [[NSNotificationCenter defaultCenter] postNotificationName:File_Progess_Noti object:fileDataModel];
            
//            [FileData bg_findAsync:FILE_STATUS_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"userId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"srcKey"),bg_sqlValue(self.srcKey)] complete:^(NSArray * _Nullable array) {
//                if (array && array.count > 0) {
//                    FileData *fileModel = array[0];
//                    fileModel.progess = progess;
//                    [fileModel bg_saveOrUpdateAsync:nil];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:File_Progess_Noti object:fileModel];
//                }
//            }];
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
