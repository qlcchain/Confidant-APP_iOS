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

#define NTOHL(x)    (x) = ntohl((__uint32_t)x) //转换成本地字节流
#define NTOHS(x)    (x) = ntohs((__uint16_t)x) //转换成本地字节流
#define NTOHLL(x)   (x) = ntohll((__uint64_t)x) //转换成本地字节流
#define HTONL(x)    (x) = htonl((__uint32_t)x) //转换成网络字节流
#define HTONS(x)    (x) = htons((__uint16_t)x) //转换成网络字节流
#define HTONLL(x)   (x) = htonll((__uint64_t)x) //转换网络字节流


static CGFloat request_time = 8.0f;
static NSString *Action_SendFile = @"SendFile";
static NSString *Action_SendFileEnd = @"SendFileEnd";
static int sendFileSizeMax = 1024*100;

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
    char content[1024*100];
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
}
@property (nonatomic ,strong) SocketFileUtil *fileUtil;
@property (nonatomic ,strong) NSData *fileData;
@property (nonatomic ,strong) NSString *fileTextConnent;
@property (nonatomic ,strong) NSString *toid;
@property (nonatomic ,strong) NSString *fileid;
@property (nonatomic ,strong) NSString *fileMessageId;
@property (nonatomic ,strong) NSString *messageid;
@property (nonatomic ,strong) NSMutableDictionary *statusDic;
@property (nonatomic ,assign) uint32_t fileType;
//@property (nonatomic ,assign) uint32_t currentSegSize; // 当前片段大小
//@property (nonatomic ,assign) uint32_t currentSegSeq; // 当前片段序号
//@property (nonatomic ,assign) uint32_t currentFileOffset; // 当前偏移量

@end

@implementation SocketDataUtil

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
                [[NSNotificationCenter defaultCenter] postNotificationName:FILE_SEND_NOTI object:text];
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
    if (resultFile.code == 0) {
        [self sendFileWithTag:2];
    } else {
       [self sendFileWithTag:1];
    }
}
#pragma mark -如果超过10秒没收到确认消息，则文件传输失败，需要重新发起发送文件流程
- (void) checkFileIsComplete {
    if (!_isComplete) {
        if ([_fileUtil isConnected]) { // 网络正常重发
            //[_fileUtil sendWithText:self.fileTextConnent];
        } else {
            // 发送失败通知
            _isComplete = YES;
             [_fileUtil disconnect];
            [[NSNotificationCenter defaultCenter] postNotificationName:FILE_SEND_NOTI object:nil];
        }
    }
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

- (void) sendFileId:(NSString *) toid fileName:(NSString *) fileName fileData:(NSData *) imgData fileid:(int)fileid fileType:(uint32_t) fileType messageid:(NSString *)messageid srcKey:(NSString *) srcKey dstKey:(NSString *) dstKey
{
    
//    char crcbytes[] = {
//        0x1a, 0x2b, 0x3c, 0x4d, 0x5e, 0x6f, 0x7f, 0x8f
//    };
//    NSData *myData1 = [NSData dataWithBytes:crcbytes length:sizeof(crcbytes)];
//    uint16_t crc161 = [myData1 hexadecimalUint16];
//    HTONS(crc161);
    
//    sendFile.action = 1;
//    sendFile.segsize = 1024;
//    sendFile.segseq = 1;
//    sendFile.offset = 0;
//    sendFile.fileid = 1234;
//    sendFile.crc = 0;
//    sendFile.segmore = 0;
//    sendFile.cotinue = 0;
//
//
//
//    memcpy(sendFile.filename, [@"img1" cStringUsingEncoding:NSASCIIStringEncoding],[@"img1" length]);
//    memcpy(sendFile.fromid, [@"12345" cStringUsingEncoding:NSASCIIStringEncoding],[@"12345" length]);
//    memcpy(sendFile.toid, [@"12345" cStringUsingEncoding:NSASCIIStringEncoding],[@"12345" length]);
//
//    NSData *myData = [NSData dataWithBytes:&sendFile length:sizeof(sendFile)];
//    NSLog(@"%@",myData);
    
    // filename 做url编码
    //stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet
  
    
    fileName = [Base58Util Base58EncodeWithCodeName:fileName];
    self.messageid = messageid;
    self.fileType = fileType;
    self.fileData = imgData;
    self.toid = toid;
    self.fileid = [NSString stringWithFormat:@"%d",fileid];
    currentSegseq = 1;
    //int millSecond = [[NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])] intValue];
    uint32_t action = fileType;
    uint32_t segseq = 1;
    uint32_t offset = 0;
    uint32_t millFileid = fileid;
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
    
    sendFile.magic = magic;
    sendFile.action = action;
    sendFile.segsize = sendFileSize;
    sendFile.segseq = segseq;
    sendFile.offset = offset;
    sendFile.fileid = millFileid;
    sendFile.crc = crc;
    sendFile.segmore = segMoreBlg;
    sendFile.cotinue = 0;
    
    memcpy(sendFile.toid, [toid cStringUsingEncoding:NSASCIIStringEncoding],[toid length]);
    memcpy(sendFile.srcKey, [srcKey cStringUsingEncoding:NSASCIIStringEncoding],[srcKey length]);
    memcpy(sendFile.dstKey, [dstKey cStringUsingEncoding:NSASCIIStringEncoding],[dstKey length]);
    
    printf("srckey = %s , dskey = %s",sendFile.srcKey,sendFile.dstKey);

      memcpy(sendFile.filename, [fileName cStringUsingEncoding:NSASCIIStringEncoding],[fileName length]);
    // NSUTF8StringEncoding  NSASCIIStringEncoding
    memcpy(sendFile.fromid,[[UserModel getUserModel].userId cStringUsingEncoding:NSASCIIStringEncoding],[[UserModel getUserModel].userId length]);
    
    NSData *sendData = nil;
    if (segMoreBlg == 1) {
        sendData = [self.fileData subdataWithRange:NSMakeRange(offset, sendFileSizeMax)];
    } else {
        sendData = [self.fileData subdataWithRange:NSMakeRange(offset, self.fileData.length-offset)];
    }
    memcpy(sendFile.content,[sendData bytes],[sendData length]);
    // 结构体转data
    NSData *myData = [NSData dataWithBytes:&sendFile length:sizeof(sendFile)];
    uint16_t crc16 = [myData hexadecimalUint16];
    HTONS(crc16);
    sendFile.crc = crc16;
    // data转结构体
   // [myData getBytes:&newJoin length:sizeof(newJoin)];
    
    NSLog(@"%s,%s",sendFile.filename,sendFile.toid);
    
    myData = [NSData dataWithBytes:&sendFile length:sizeof(sendFile)];
    
    @weakify_self
    [_fileUtil setOnConnect:^{
        NSLog(@"%@--%@",[weakSelf.fileUtil class],weakSelf.fileUtil.socket);
        [weakSelf sendFileData:myData];
    }];
    
    [_fileUtil setOnDisconnect:^(NSError * error, NSString * url) {
        if (weakSelf.isComplete) {
            [[SocketManageUtil getShareObject] clearDisConnectSocket];
        } else {
             [[NSNotificationCenter defaultCenter] postNotificationName:FILE_SEND_NOTI object:@[@(2),weakSelf.fileid,weakSelf.toid,@(weakSelf.fileType),weakSelf.messageid?:@""]];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:FILE_SEND_NOTI object:@[@(2),self.fileid,self.toid,@(self.fileType),self.messageid?:@""]];
            return;
        }
        NSData *myData = [NSData dataWithBytes:&sendFile length:sizeof(sendFile)];
        [self sendFileData:myData];
    } else {
        if (sendFile.segmore == 0) { //文件发送完成
            [_fileUtil disconnect];
            [[NSNotificationCenter defaultCenter] postNotificationName:FILE_SEND_NOTI object:@[@(0),self.fileid,self.toid,@(self.fileType),self.messageid?:@"",self.fileMessageId]];
            return;
        }
        if (![_fileUtil isConnected]) { // socket断开连接
            [_fileUtil disconnect];
            [[NSNotificationCenter defaultCenter] postNotificationName:FILE_SEND_NOTI object:@[@(2),self.fileid,self.toid,@(self.fileType),self.messageid?:@""]];
            return;
        }
        
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
        
        memcpy(sendFile.content,[sendData bytes],[sendData length]);
        
        
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
        uint16_t crc16 = [myData hexadecimalUint16];
        HTONS(crc16);
        sendFile.crc = crc16;
        
        myData = [NSData dataWithBytes:&sendFile length:sizeof(sendFile)];
        [self sendFileData:myData];
        
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
    if ([self.statusDic[[NSString stringWithFormat:@"%u",currentSegseq]] isEqualToString:@"0"]) {
        [self sendFileWithTag:1];
    }
}
@end
