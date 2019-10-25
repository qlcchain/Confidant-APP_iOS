//
//  OtherFileOpenViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/4/9.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "OtherFileOpenViewController.h"
#import "SystemUtil.h"
#import "UserConfig.h"
#import "NSString+File.h"
#import "MyConfidant-Swift.h"
#import "SocketCountUtil.h"
#import "NSDate+Category.h"
#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "AESCipher.h"
#import "SocketDataUtil.h"
#import "SocketManageUtil.h"
#import "MD5Util.h"
#import "TaskListViewController.h"
#import "ChooseContactViewController.h"
#import "FriendModel.h"
#import "ChatListDataUtil.h"
#import "UserModel.h"
#import "ChatModel.h"

@interface OtherFileOpenViewController ()
{
    NSInteger fileID;
    int fileType;
}
@property (weak, nonatomic) IBOutlet UIImageView *fileTypeImgVIew;
@property (weak, nonatomic) IBOutlet UILabel *lblFileName;
@property (weak, nonatomic) IBOutlet UILabel *lblFileSize;
@property (nonatomic ,strong) NSString *fileName;
@property (nonatomic ,strong) NSData *fileData;
@property (nonatomic ,copy) NSURL *url;
@end

@implementation OtherFileOpenViewController

- (void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [super viewWillAppear:animated];
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}
- (IBAction)sendContactAction:(id)sender {
    ChooseContactViewController *vc = [[ChooseContactViewController alloc] init];
    vc.docOPenTag = 1;
    [self presentModalVC:vc animated:YES];
}
- (IBAction)uploadFileAction:(id)sender {
    
    self.fileName = [NSString getUploadFileNameOfCorrectLength:self.fileName];
    NSString *uploadName = [Base58Util Base58EncodeWithCodeName:self.fileName];

    [SendRequestUtil sendUploadFileReqWithUserId:[UserConfig getShareObject].userId FileName:uploadName FileSize:@(self.fileData.length) FileType:@(fileType) showHud:YES fetchParam:^(NSDictionary * _Nonnull dic) {
    }];
    
}
- (id) initWithFileUrl:(NSURL *) fileUrl
{
    if (self = [super init]) {
        self.url = fileUrl;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *fileURL = self.url.absoluteString;
    NSArray *array = [fileURL componentsSeparatedByString:@"."];
    //NSString *fileSuffix = [array lastObject];
    
    array = [fileURL componentsSeparatedByString:@"/"];
    NSString *otherFileName = [[array lastObject] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    self.fileName = otherFileName;
    
    [self.view showHudInView:self.view hint:@""];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:self.url];
        if (data) {
            self.fileData = data;
            dispatch_async(dispatch_get_main_queue(), ^{
                self->fileType = [self sd_contentTypeForImageData:data];
                [self.view hideHud];
                self->_lblFileSize.text = [SystemUtil transformedZSValue:data.length];
            });
        }
    });
    
    _lblFileName.text = otherFileName;
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFileReqSuccessNoti:) name:UploadFileReq_Success_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didToxUploadFile:) name:DID_UPLOAD_FILE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileForwardNoti:) name:DOC_OPEN_CHOOSE_FRIEND_NOTI object:nil];
}

- (int)sd_contentTypeForImageData:(NSData *)data {
    
    if ([SystemUtil thumbnailImageForVideo:self.url]) {
        return 4;
    }
    
    uint8_t c;
    [data getBytes:&c length:1];
    switch (c) {
        case 0xFF:
            return 1;
        case 0x89:
            return 1;
        case 0x47:
            return 1;
        case 0x49:
        case 0x4D:
            return 1;
        case 0x52:
            // R as RIFF for WEBP
            if ([data length] < 12) {
                return 5;
            }
            NSString *testString = [[NSString alloc] initWithData:[data subdataWithRange:NSMakeRange(0, 12)] encoding:NSASCIIStringEncoding];
            if ([testString hasPrefix:@"RIFF"] && [testString hasSuffix:@"WEBP"]) {
                return 1;
            }
    }
    return 5;
}

#pragma mark ---noti
#pragma mark - Noti
- (void)uploadFileReqSuccessNoti:(NSNotification *)noti {
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSString *fileName = self.fileName;
        long tempMsgid = [SocketCountUtil getShareObject].fileIDCount++;
        tempMsgid = [NSDate getTimestampFromDate:[NSDate date]]+tempMsgid;
        self->fileID = tempMsgid;
        
        NSString *msgKey = [SystemUtil getDoc32AESKey];
        
        NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
        NSString *symmetKey = [symmetData base64EncodedString];
        // 自己公钥加密对称密钥
        NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
        
        NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
        
        NSData *fileData = aesEncryptData(self.fileData,msgKeyData);
        
        if ([SystemUtil isSocketConnect]) { // socket
            SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
            dataUtil.srcKey = srcKey;
            dataUtil.fileid = [NSString stringWithFormat:@"%ld",(long)self->fileID];
            
            [dataUtil sendFileId:@"" fileName:fileName fileData:fileData fileid:self->fileID fileType:self->fileType messageid:@"" srcKey:srcKey dstKey:@"" isGroup:NO];
            [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
        } else { // tox
            NSString *path = [[SystemUtil getTempUploadPhotoBaseFilePath] stringByAppendingPathComponent:fileName];
            BOOL isSuccess = [fileData writeToFile:path atomically:YES];
            if (isSuccess) {
                
                NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":[UserConfig getShareObject].userId,@"ToId":@"",@"FileName":[Base58Util Base58EncodeWithCodeName:fileName],@"FileMD5":[MD5Util md5WithPath:path],@"FileSize":@(fileData.length),@"FileType":@(self->fileType),@"SrcKey":srcKey,@"DstKey":@"",@"FileId":@(self->fileID)};
                [SendToxRequestUtil uploadFileWithFilePath:path parames:parames fileData:fileData];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([SystemUtil isSocketConnect]) { // socket
                [self performSelector:@selector(jumpTaskListVC) withObject:self afterDelay:1.5];
            }
        });
    });
}

- (void) jumpTaskListVC
{
    [AppD.window hideHud];
    TaskListViewController *vc = [[TaskListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

// tox文件正在上传
- (void) didToxUploadFile:(NSNotification *) noti
{
    NSString *fileid = noti.object;
    if ([fileid integerValue] == fileID) {
        [self jumpTaskListVC];
    }
}


#pragma mark - Noti
- (void)fileForwardNoti:(NSNotification *)noti {
    
    
    [self.view showHudInView:self.view hint:@"Send..."];
    
    NSArray *modeArray = (NSArray *)noti.object;
    @weakify_self
    [modeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            FriendModel *model = obj;
            long tempMsgid = (long)[ChatListDataUtil getShareObject].tempMsgId++;
            tempMsgid = [NSDate getTimestampFromDate:[NSDate date]]+tempMsgid;
            if (model.isGroup) { // 转发到群聊
                // 自己私钥解密
                NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:model.publicKey];
                // 截取前16位
                if (!datakey || datakey.length == 0) {
                    return;
                }
                
                NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
                NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
                int msgid = [mill intValue];
                
                NSString *filePath = [[SystemUtil getBaseFilePath:model.userId] stringByAppendingPathComponent:weakSelf.fileName];
                [weakSelf.fileData writeToFile:filePath atomically:YES];
                
                NSString *symmetKey = [[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding];
                NSData *msgKeyData =[[symmetKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
                NSData *endData = aesEncryptData(weakSelf.fileData,msgKeyData);
                
                
                [weakSelf sendGroupFileWithToid:model.userId fileName:weakSelf.fileName fileData:endData fileId:msgid fileType:self->fileType messageId:[NSString stringWithFormat:@"%d",msgid] srcKey:@"" dsKey:@"" publicKey:model.publicKey msgKey:@"" fileInfo:@""];
                
                
            } else {
                
                model.publicKey = [model.publicKey stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                
                NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
                NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
                int msgid = [mill intValue];
                
                
                NSString *filePath = [[SystemUtil getBaseFilePath:model.userId] stringByAppendingPathComponent:weakSelf.fileName];
                [weakSelf.fileData writeToFile:filePath atomically:YES];
                
                
                // 生成32位对称密钥
                NSString *msgKey =  msgKey = [SystemUtil getDoc32AESKey];
                
                NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
                NSString *symmetKey = [symmetData base64EncodedString];
                // 好友公钥加密对称密钥
                NSString *dsKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:model.publicKey];
                // 自己公钥加密对称密钥
                NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
                
                NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
                NSData *enData = aesEncryptData(weakSelf.fileData,msgKeyData);
                
                
                [weakSelf sendFileWithToid:model.userId fileName:weakSelf.fileName fileData:enData fileId:msgid fileType:self->fileType messageId:[NSString stringWithFormat:@"%d",msgid] srcKey:srcKey dsKey:dsKey publicKey:model.publicKey msgKey:msgKey fileInfo:@""];
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (idx == modeArray.count-1) {
                    [weakSelf.view hideHud];
                    [weakSelf.view showHint:@"Send success."];
                }
            });
            
        });
    }];
}


#pragma mark -发送文件
- (void) sendFileWithToid:(NSString *) toId fileName:(NSString *) fileName fileData:(NSData *) fileData fileId:(int) fileId fileType:(int) fileType messageId:(NSString *) messageId srcKey:(NSString *) srcKey dsKey:(NSString *) dsKey publicKey:(NSString *) publicKey msgKey:(NSString *) msgKey fileInfo:(NSString *) fileInfo
{
    if ([SystemUtil isSocketConnect]) {
        ChatModel *chatModel = [[ChatModel alloc] init];
        chatModel.fromId = [UserConfig getShareObject].userId;
        chatModel.toId = toId;
        chatModel.toPublicKey = publicKey;
        chatModel.msgType = fileType;
        chatModel.fileSize = fileData.length;
        chatModel.msgid = (long)[messageId integerValue];
        chatModel.bg_tableName = CHAT_CACHE_TABNAME;
        chatModel.fileName = fileName;
        //chatModel.filePath =[[SystemUtil getBaseFilePath:toId] stringByAppendingPathComponent:fileName];
        chatModel.srcKey = srcKey;
        chatModel.dsKey = dsKey;
        chatModel.msgKey = msgKey;
        chatModel.sendTime = [NSDate getTimestampFromDate:[NSDate date]];
        
        NSString *fileNameInfo = fileName;
        if (fileInfo && fileInfo.length>0) {
            fileNameInfo = [NSString stringWithFormat:@"%@,%@",fileNameInfo,fileInfo];
            chatModel.fileName = fileNameInfo;
        }
        [chatModel bg_save];
        SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
        [dataUtil sendFileId:toId fileName:fileNameInfo fileData:fileData fileid:fileId fileType:fileType messageid:messageId srcKey:srcKey dstKey:dsKey isGroup:NO];
        [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
    } else {
        NSString *filePath = [[SystemUtil getTempBaseFilePath:toId] stringByAppendingPathComponent:[Base58Util Base58EncodeWithCodeName:fileName]];
        
        if ([fileData writeToFile:filePath atomically:YES]) {
            
            if (fileInfo && fileInfo.length > 0) {
                NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":[UserConfig getShareObject].userId,@"ToId":toId,@"FileName":[Base58Util Base58EncodeWithCodeName:fileName],@"FileMD5":[MD5Util md5WithPath:filePath],@"FileSize":@(fileData.length),@"FileType":@(fileType),@"SrcKey":srcKey,@"DstKey":dsKey,@"FileId":messageId,@"FileInfo":fileInfo};
                [SendToxRequestUtil sendFileWithFilePath:filePath parames:parames];
            } else {
                NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":[UserConfig getShareObject].userId,@"ToId":toId,@"FileName":[Base58Util Base58EncodeWithCodeName:fileName],@"FileMD5":[MD5Util md5WithPath:filePath],@"FileSize":@(fileData.length),@"FileType":@(fileType),@"SrcKey":srcKey,@"DstKey":dsKey,@"FileId":messageId,@"FileInfo":fileInfo};
                [SendToxRequestUtil sendFileWithFilePath:filePath parames:parames];
            }
        }
    }
}


#pragma mark -群聊发送文件
- (void) sendGroupFileWithToid:(NSString *) toId fileName:(NSString *) fileName fileData:(NSData *) fileData fileId:(int) fileId fileType:(int) fileType messageId:(NSString *) messageId srcKey:(NSString *) srcKey dsKey:(NSString *) dsKey publicKey:(NSString *) publicKey msgKey:(NSString *) msgKey fileInfo:(NSString *) fileInfo
{
    if ([SystemUtil isSocketConnect]) {
        
        ChatModel *chatModel = [[ChatModel alloc] init];
        chatModel.fromId = [UserConfig getShareObject].userId;
        chatModel.toId = toId;
        chatModel.fileInfo = fileInfo;
        chatModel.toPublicKey = publicKey;
        chatModel.msgType = fileType;
        chatModel.fileSize = fileData.length;
        chatModel.msgid = (long)[messageId integerValue];
        chatModel.bg_tableName = CHAT_CACHE_TABNAME;
        chatModel.fileName = fileName;
        chatModel.filePath =[[SystemUtil getBaseFilePath:toId] stringByAppendingPathComponent:fileName];
        chatModel.srcKey = srcKey;
        chatModel.dsKey = dsKey;
        chatModel.msgKey = msgKey;
        chatModel.sendTime = [NSDate getTimestampFromDate:[NSDate date]];
        [chatModel bg_save];
        
        
        SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
        dataUtil.fileInfo = fileInfo;
        [dataUtil sendFileId:toId fileName:fileName fileData:fileData fileid:fileId fileType:fileType messageid:messageId srcKey:srcKey dstKey:dsKey isGroup:YES];
        [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
    } else {
        
        NSString *filePath = [[SystemUtil getTempBaseFilePath:toId] stringByAppendingPathComponent:[Base58Util Base58EncodeWithCodeName:fileName]];
        
        if ([fileData writeToFile:filePath atomically:YES]) {
            NSDictionary *parames = @{@"Action":@"GroupSendFileDone",@"UserId":[UserConfig getShareObject].userId,@"GId":toId,@"FileName":[Base58Util Base58EncodeWithCodeName:fileName],@"FileMD5":[MD5Util md5WithPath:filePath],@"FileSize":@(fileData.length),@"FileType":@(fileType),@"DstKey":dsKey,@"FileId":messageId,@"FileInfo":fileInfo};
            [SendToxRequestUtil sendFileWithFilePath:filePath parames:parames];
        }
    }
}
@end
