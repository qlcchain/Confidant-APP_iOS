//
//  FilePreviewViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/23.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "FilePreviewViewController.h"
#import <QuickLook/QuickLook.h>
#import "FileMoreAlertView.h"
#import "FileListModel.h"
#import "DetailInformationViewController.h"
#import "NSString+Base64.h"
#import "AESCipher.h"
#import "SystemUtil.h"
#import "MyConfidant-Swift.h"
#import "FileDownUtil.h"
#import "RequestService.h"
#import "ChooseContactViewController.h"
#import "FriendModel.h"
#import "ChatListDataUtil.h"
#import "NSDate+Category.h"
#import "NSData+Base64.h"
#import "ChatModel.h"
#import "UserConfig.h"
#import "SocketDataUtil.h"
#import "SocketManageUtil.h"
#import "MD5Util.h"


@interface FilePreviewViewController () <QLPreviewControllerDataSource, QLPreviewControllerDelegate>
{
    BOOL isChooseFriend;
}
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, strong) QLPreviewController *previewController;
@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (nonatomic, strong) UIDocumentInteractionController *documentIntertactionController;
@end

@implementation FilePreviewViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (_fileType == NodePhotoFile || _fileType == LocalPhotoFile) {
        NSString *deName = [Base58Util Base58DecodeWithCodeName:self.fileName];
         _lblTitle.text = deName.length >0 ?deName:self.fileName;
    } else {
         _lblTitle.text = self.fileName;
    }
    
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    // Do any additional setup after loading the view from its nib.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseContactNoti:) name:EMAIL_CHOOSE_FRIEND_SEND_NOTI object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isChooseFriend) {
        isChooseFriend = NO;
        return;
    }
    if (self.fileType == ChatFile) {
        [self previewFilePath:self.filePath];
    } else if (self.fileType == EmailFile) {
        if (!self.localFileData || self.localFileData.length == 0) {
            [self.view showHint:Decrypt_Failed];
            return;
        }
        [self.view showHudInView:self.view hint:@""];
        @weakify_self
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            weakSelf.filePath = [SystemUtil getTempDeFilePath:weakSelf.fileName];
            BOOL isWriteFinsh = [weakSelf.localFileData writeToFile:weakSelf.filePath atomically:YES];
            if (isWriteFinsh) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view hideHud];
                    [weakSelf previewFilePath:weakSelf.filePath];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view hideHud];
                    [weakSelf.view showHint:@"Failed to open"];
                });
            }
        });
       
    } else {
        
        [self.view showHudInView:self.view hint:@""];
        @weakify_self
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            if (weakSelf.fileType == DefaultFile) {
                
                NSData *fileData = [NSData dataWithContentsOfFile:weakSelf.filePath];
                if (!fileData || fileData.length == 0 ) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.view hideHud];
                        [weakSelf.view showHint:Decrypt_Failed];
                    });
                } else {
                    [weakSelf deFileWithFileData:fileData];
                }
                
            } else if (weakSelf.fileType == LocalPhotoFile) {
                [weakSelf deFileWithFileData:weakSelf.localFileData];
            } else if (weakSelf.fileType == NodePhotoFile) {
                [weakSelf downFileData];
            }
            
        });
        
    }
}
#pragma mark ----下载节点文件
- (void) downFileData
{
    self.fileName = [Base58Util Base58DecodeWithCodeName:self.fileName]?:@"";
    NSString *downloadFilePath = [SystemUtil getTempDeFilePath:self.fileName];
    if (self.floderId && self.floderId.length > 0) {
       NSString *lastTypeStr = [[self.fileName componentsSeparatedByString:@"."] lastObject];
        downloadFilePath = [SystemUtil getPhotoTempDeFloderId:self.floderId fid:[NSString stringWithFormat:@"%@.%@",self.fileId,lastTypeStr]];
    }
   
    //[SystemUtil removeDocmentFilePath:downloadFilePath];
    if ([SystemUtil filePathisExist:downloadFilePath]) {
        @weakify_self
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view hideHud];
            [weakSelf previewFilePath:downloadFilePath];
        });
    } else {
        
        if ([SystemUtil isSocketConnect]) {
            
            @weakify_self
            [RequestService downFileWithBaseURLStr:self.filePath filePath:downloadFilePath progressBlock:^(CGFloat progress) {
                
            } success:^(NSURLSessionDownloadTask *dataTask, NSString *filePath) {
            
                NSData *fileData = [NSData dataWithContentsOfFile:filePath];
                [SystemUtil removeDocmentFilePath:filePath];
                [weakSelf deFileWithFileData:fileData];
                
            } failure:^(NSURLSessionDownloadTask *dataTask, NSError *error) {
                [SystemUtil removeDocmentFilePath:downloadFilePath];
                [weakSelf.view hideHud];
                [weakSelf.view showHint:Failed];
            }];
        }
    }
    
}

- (void) deFileWithFileData:(NSData *) fileData
{
    
    NSString *deFilePath = [SystemUtil getTempDeFilePath:self.fileName];
    if (self.floderId && self.floderId.length > 0) {
       NSString *lastTypeStr = [[self.fileName componentsSeparatedByString:@"."] lastObject];
        deFilePath = [SystemUtil getPhotoTempDeFloderId:self.floderId fid:[NSString stringWithFormat:@"%@.%@",self.fileId,lastTypeStr]];
    }
    if ([SystemUtil filePathisExist:deFilePath]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view hideHud];
            [self previewFilePath:deFilePath];
        });
        return;
    }
    NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:self.userKey];
    @weakify_self
    if (datakey && datakey.length>0) {
        datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
        if (datakey && ![datakey isEmptyString]) {
            
           NSData *deFileData = aesDecryptData(fileData, [datakey dataUsingEncoding:NSUTF8StringEncoding]);
            if (deFileData) {
                BOOL isWriteFinsh = [deFileData writeToFile:deFilePath atomically:YES];
                if (isWriteFinsh) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.view hideHud];
                        [weakSelf previewFilePath:deFilePath];
                    });
                }
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view hideHud];
                    [weakSelf.view showHint:Decrypt_Failed];
                });
            }
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view hideHud];
            [weakSelf.view showHint:Decrypt_Failed];
        });
    }
}

#pragma mark - Operation
- (void)previewFilePath:(NSString *) filePath {
    
    self.filePath = filePath;
    _sourceArr = [NSMutableArray array];
    [_sourceArr addObject:filePath];
    
    _previewController = [[QLPreviewController alloc] init];
    _previewController.dataSource = self;
    _previewController.delegate = self;
    [_contentView addSubview:_previewController.view];
    
    @weakify_self
    [_previewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(weakSelf.contentView).offset(0);
    }];
    
//    if (fileType == 4) {
//        previewView.backView.backgroundColor = [UIColor blackColor];
//    }
}
#pragma mark--------------发送文件给好友
- (void) sendFileToFriend
{
    [self jumpChooseContactVC];
}
#pragma mark--------------跳转
- (void) jumpChooseContactVC
{
    isChooseFriend = YES;
    ChooseContactViewController *vc = [[ChooseContactViewController alloc] init];
    vc.docOPenTag = 6;
    [self presentModalVC:vc animated:YES];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)moreAction:(id)sender {
    
    if (_fileType == EmailFile && _localFileData) {
        @weakify_self
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
         UIAlertAction *alert = [UIAlertAction actionWithTitle:@"Send" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
             [weakSelf sendFileToFriend];
        }];
        [alertC addAction:alert];
        
        UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"Open in other apps" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf presentOptionsMenu];
        }];
        [alertC addAction:alert1];
        
        UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        [alertC addAction:alertCancel];
        [self presentViewController:alertC animated:YES completion:nil];
    } else {
        [self presentOptionsMenu];
    }
    
}

- (void)presentOptionsMenu{
    NSURL *pathUrl = [NSURL fileURLWithPath:self.filePath];
    _documentIntertactionController = [UIDocumentInteractionController interactionControllerWithURL:pathUrl];
    // _documentIntertactionController.delegate = self;
    [_documentIntertactionController presentOptionsMenuFromRect:self.view.bounds inView:self.view animated:YES];
}

#pragma mark - request methods

#pragma mark - QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return _sourceArr.count;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    NSURL *url = [NSURL fileURLWithPath:_sourceArr[index]];
    return  url;
}

- (CGRect)previewController:(QLPreviewController *)controller frameForPreviewItem:(id<QLPreviewItem>)item inSourceView:(UIView *__autoreleasing  _Nullable *)view{
    return _contentView.bounds;
}


#pragma mark------------通知回调
- (void) chooseContactNoti:(NSNotification *) noti
{
    NSArray *modeArray = (NSArray *)noti.object;
    NSInteger fileT = [SystemUtil getAttNameType:_fileName];
    @weakify_self
    [modeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        long tempMsgid = (long)[ChatListDataUtil getShareObject].tempMsgId++;
        tempMsgid = [NSDate getTimestampFromDate:[NSDate date]]+tempMsgid;
                
        if (fileT == 1) {
            [SystemUtil saveImageForTtimeWithToid:model.userId fileName:weakSelf.fileName fileTime:[NSDate getTimestampFromDate:[NSDate date]]];
        }
                
                if (model.isGroup) { // 转发到群聊
                    // 自己私钥解密
                    NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:model.publicKey];
                    // 截取前16位
                    if (!datakey || datakey.length == 0) {
                        return;
                    }
                    datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
                    
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            
                            NSString *mills = [NSString stringWithFormat:@"%llu",[NSDate getMillisecondTimestampFromDate:[NSDate date]]];
                            NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
                            int msgid = [mill intValue];
                            
                            // 自己私钥解密
                            NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:model.publicKey];
                            NSString *symmetKey = [[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding];
                            NSData *msgKeyData =[[symmetKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
                            NSData *fileDatas = aesEncryptData(weakSelf.localFileData,msgKeyData);
                            
                            NSString *fileInfo = @"";
                            if (fileT == 1) {
                                UIImage *img = [UIImage imageWithData:weakSelf.localFileData];
                                if (img) {
                                    fileInfo = [NSString stringWithFormat:@"%f*%f",img.size.width,img.size.height];
                                }
                                
                            } else if (fileT == 5) {
                                UIImage *img = [SystemUtil thumbnailImageForVideo:[NSURL fileURLWithPath:weakSelf.filePath]];
                                if (img) {
                                    fileInfo = [NSString stringWithFormat:@"%f*%f",img.size.width,img.size.height];
                                }
                            }
                            
                            [weakSelf sendGroupFileWithToid:model.userId fileName:weakSelf.fileName fileData:fileDatas fileId:msgid fileType:(int)fileT messageId:[NSString stringWithFormat:@"%d",msgid] srcKey:@"" dsKey:@"" publicKey:model.publicKey msgKey:@"" fileInfo:fileInfo];
                            
                        });
                    
                    
                } else {
                    model.publicKey = [model.publicKey stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            
                           
                            NSString *mills = [NSString stringWithFormat:@"%llu",[NSDate getMillisecondTimestampFromDate:[NSDate date]]];
                            NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
                            int msgid = [mill intValue];
                            
                            // 生成32位对称密钥
                            NSString *msgKey = [SystemUtil get32AESKey];
                           
                            NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
                            NSString *symmetKey = [symmetData base64EncodedString];
                            // 好友公钥加密对称密钥
                            NSString *dsKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:model.publicKey];
                            // 自己公钥加密对称密钥
                            NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
                            
                            NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
                            NSData *enData = aesEncryptData(weakSelf.localFileData,msgKeyData);
                            
                            NSString *fileInfo = @"";
                            if (fileT == 1) {
                                UIImage *img = [UIImage imageWithData:weakSelf.localFileData];
                                if (img) {
                                    fileInfo = [NSString stringWithFormat:@"%f*%f",img.size.width,img.size.height];
                                }
                                
                            } else if (fileT == 5) {
                                UIImage *img = [SystemUtil thumbnailImageForVideo:[NSURL fileURLWithPath:weakSelf.filePath]];
                                if (img) {
                                    fileInfo = [NSString stringWithFormat:@"%f*%f",img.size.width,img.size.height];
                                }
                            }
                            
                            [weakSelf sendFileWithToid:model.userId fileName:weakSelf.fileName fileData:enData fileId:msgid fileType:(int)fileT messageId:[NSString stringWithFormat:@"%d",msgid] srcKey:srcKey dsKey:dsKey publicKey:model.publicKey msgKey:msgKey fileInfo:fileInfo];
                            
                        });
                }
        
        if (idx == modeArray.count-1) {
            [AppD.window showHint:@"Has been sent"];
        }
    }];
}


#pragma mark --------群聊发送文件---------
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

/**
 发送文件

 @param toId toid
 @param fileName fileName
 @param fileData fileData
 @param fileId fileId
 @param fileType fileType
 @param messageId messageId
 @param srcKey srcKey
 @param dsKey dsKey
 @param publicKey publicKey
 @param msgKey msgKey
 @param fileInfo fileInfo
 */
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
    
    [FIRAnalytics logEventWithName:kFIREventSelectContent
    parameters:@{
                 kFIRParameterItemID:FIR_CHAT_SEND_FILE,
                 kFIRParameterItemName:FIR_CHAT_SEND_FILE,
                 kFIRParameterContentType:FIR_CHAT_SEND_FILE
                 }];
}
@end
