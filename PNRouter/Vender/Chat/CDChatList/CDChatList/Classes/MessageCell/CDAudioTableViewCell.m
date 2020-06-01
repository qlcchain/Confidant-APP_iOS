//
//  CDAudioTableViewCell.m
//  AATChatList
//
//  Created by chdo on 2018/1/10.
//  Copyright © 2018年 aat. All rights reserved.
//

#import "CDAudioTableViewCell.h"
#import "ChatHelpr.h"
#import "AATAudioTool.h"
#import "SystemUtil.h"
#import "VoiceConvert.h"
#import "AESCipher.h"
#import "RSAUtil.h"
#import "NSData+Base64.h"
#import "SocketDataUtil.h"
#import "SocketManageUtil.h"
#import "NSString+Base64.h"
#import "RequestService.h"
#import "MyConfidant-Swift.h"
#import "MD5Util.h"
#import "UserConfig.h"

@interface CDAudioTableViewCell()

@property(nonatomic, strong) UIImageView *wave_left; // 声波图片
@property(nonatomic, strong) UILabel *audioTimeLabel_left; // 显示音频时间
@property(nonatomic, strong) UIImageView *wave_right; //
@property(nonatomic, strong) UILabel *audioTimeLabel_right; //

@property(nonatomic, strong) UIImage *wave_left_image; // GIF图
@property(nonatomic, strong) UIImage *wave_right_image; // GIF图
@property (nonatomic ,strong) NSString *mavPath;
@property(nonatomic, strong) UIGestureRecognizer *longPressRecognizer;
@end

@implementation CDAudioTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.bubbleImage_left addGestureRecognizer:tap];
    [self.bubbleImage_right addGestureRecognizer:tap2];
    self.bubbleImage_right.userInteractionEnabled = YES;
    self.bubbleImage_left.userInteractionEnabled = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNoti:) name:AATAudioToolDidStopPlayNoti object:nil];
    _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGes:)];
    [self addGestureRecognizer:_longPressRecognizer];
    
    
    return self;
}

-(UIImage *)wave_left_image{
    if (!_wave_left_image) {
        
        NSArray *arr =@[ChatHelpr.share.imageDic[ChatHelpr.share.config.voice_left_1],
                        ChatHelpr.share.imageDic[ChatHelpr.share.config.voice_left_2],
                        ChatHelpr.share.imageDic[ChatHelpr.share.config.voice_left_3]];
        _wave_left_image = [UIImage animatedImageWithImages:arr duration:1];
    }
    return _wave_left_image;
}

-(UIImage *)wave_right_image{
    if (!_wave_right_image) {
        NSArray *arr = @[ChatHelpr.share.imageDic[ChatHelpr.share.config.voice_right_1],
                         ChatHelpr.share.imageDic[ChatHelpr.share.config.voice_right_2],
                         ChatHelpr.share.imageDic[ChatHelpr.share.config.voice_right_3]];
        _wave_right_image = [UIImage animatedImageWithImages: arr duration: 1];
    }
    return _wave_right_image;
}

-(UILabel *)audioTimeLabel_left{
    if (!_audioTimeLabel_left) {
        _audioTimeLabel_left = [[UILabel alloc] init];
        _audioTimeLabel_left.textColor = [UIColor lightGrayColor];
        _audioTimeLabel_left.textAlignment = NSTextAlignmentCenter;
        _audioTimeLabel_left.font = [UIFont systemFontOfSize:12];
        _audioTimeLabel_left.textAlignment = NSTextAlignmentLeft;
    }
    return _audioTimeLabel_left;
}

-(UILabel *)audioTimeLabel_right{
    if (!_audioTimeLabel_right) {
        _audioTimeLabel_right = [[UILabel alloc] init];
        _audioTimeLabel_right.textColor = [UIColor lightGrayColor];
        _audioTimeLabel_right.textAlignment = NSTextAlignmentCenter;
        _audioTimeLabel_right.font = [UIFont systemFontOfSize:12];
        _audioTimeLabel_right.textAlignment = NSTextAlignmentLeft;
    }
    return _audioTimeLabel_right;
}

-(UIImageView *)wave_left{
    if (!_wave_left) {
        _wave_left = [[UIImageView alloc] initWithImage:self.wave_left_image.images.lastObject];
        _wave_left.animationImages = self.wave_left_image.images;
        _wave_left.animationDuration = 1;
        _wave_left.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _wave_left;
}

-(UIImageView *)wave_right{
    if (!_wave_right) {
        _wave_right = [[UIImageView alloc] initWithImage:self.wave_right_image.images.lastObject];
        _wave_right.animationImages = self.wave_right_image.images;
        _wave_right.animationDuration = 1;
        _wave_right.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _wave_right;
}

-(void)configCellByData:(CDChatMessage)data table:(CDChatListView *)table{
    [super configCellByData:data table:table];
    
    if (data.isLeft) {
        // 左侧
        //     设置消息内容, 并调整UI
        [self configAudio_Left:data];
    } else {
        // 右侧
        //     设置消息内容, 并调整UI
        [self configAudio_Right:data];
    }
}

-(void)configAudio_Left:(CDChatMessage)data{
    
    if (!self.wave_left.superview) {
        self.wave_left.frame = CGRectMake(data.chatConfig.bubbleRoundAnglehorizInset,
                                          data.chatConfig.bubbleRoundAnglehorizInset,
                                          data.chatConfig.headSideLength,
                                          data.chatConfig.headSideLength - 2 * data.chatConfig.bubbleRoundAnglehorizInset);
        [self.bubbleImage_left addSubview:self.wave_left];
    }
//    CGRect rect = self.indicator_left.frame;
//    if (data.showSelectMsg) {
//
//    }
    self.audioTimeLabel_left.frame = self.indicator_left.frame;
    CGRect fra = self.audioTimeLabel_left.frame;
    fra.size.width = 50;
    self.audioTimeLabel_left.frame = fra;
    if (!self.audioTimeLabel_left.superview) {
        [self.msgContent_left addSubview:self.audioTimeLabel_left];
    }
    
    if ([[AATAudioTool share].audioPath isEqualToString:self.mavPath] && [[AATAudioTool share] isPlaying]) {
        [self.wave_left startAnimating];
    } else {
        [self.wave_left stopAnimating];
    }
    
    if (data.msgState == CDMessageStateNormal) {
        self.audioTimeLabel_left.text = [NSString stringWithFormat:@"%d\"",data.audioTime];
        [self.audioTimeLabel_left setHidden: NO];
    } else if (data.msgState == CDMessageStateSending) {
        [self.audioTimeLabel_left setHidden: YES];
    } else if (data.msgState == CDMessageStateSendFaild || data.msgState == CDMessageStateDownloadFaild) {
        [self.audioTimeLabel_left setHidden: YES];
    } else if (data.msgState == CDMessageStateDownloading) {
        [self.audioTimeLabel_left setHidden: YES];
    }
    NSString *friendID = data.FromId;
    if (data.isGroup) {
        friendID = data.ToId;
    }
    NSString *fileUrl = [[SystemUtil getBaseFilePath:friendID] stringByAppendingPathComponent:data.fileName];
    
    if ([SystemUtil filePathisExist:fileUrl])
    {
        AVURLAsset *audioAsset=[AVURLAsset assetWithURL:[NSURL fileURLWithPath:fileUrl]];
        CMTime durationTime = audioAsset.duration;
        float reultTime = [[NSString stringWithFormat:@"%.2f",CMTimeGetSeconds(durationTime)] floatValue];
        float audioTimeinSecs = ceilf(reultTime);
        //data.audioTime = audioTimeinSecs;
        if (audioTimeinSecs > 0) {
            if ( data.msgState != CDMessageStateNormal) {
                data.msgState = CDMessageStateNormal;
                [self.tableView updateMessage:data];
                
                self.audioTimeLabel_left.text = [NSString stringWithFormat:@"%d\"",data.audioTime];
                [self.audioTimeLabel_left setHidden: NO];
                
                [ self.indicator_left stopAnimating];
                [ self.indicator_left setHidden: YES];
            }
            return;
        }  else {
            if (!data.isDown) {
                [SystemUtil removeDocmentFilePath:fileUrl];
            }
            
        }
    }
    
    if (data.msgState == CDMessageStateDownloadFaild || data.msgState == CDMessageStateNormal) {
        return;
    }
    if (data.isDown) {
        return;
    }
    data.isDown = YES;
    if ([SystemUtil isSocketConnect]) {
        @weakify_self
        [RequestService downFileWithBaseURLStr:data.filePath fileName:data.fileName friendid:friendID progressBlock:^(CGFloat progress) {
            
        } success:^(NSURLSessionDownloadTask *dataTask , NSString *filePath) {
            data.isDown = NO;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSString *friendID = data.FromId;
                if (data.isGroup) {
                    friendID = data.ToId;
                }
                NSString *imgPath = [[SystemUtil getBaseFilePath:friendID] stringByAppendingPathComponent:filePath];
                if ([[MD5Util md5WithPath:imgPath] isEqualToString:[NSString getNotNullValue:data.fileMd5]]) {
                    
                    NSData *fileData = [NSData dataWithContentsOfFile:imgPath];
                    NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:data.dskey];
                    if (!datakey) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            data.isDown = NO;
                            [SystemUtil removeDocmentFilePath:fileUrl];
                            data.msgState = CDMessageStateDownloadFaild;
                            [weakSelf.tableView updateMessage:data];
                        });
                        return ;
                    }
                    datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
                    if (data.fileKey && data.fileKey.length > 0) {
                        datakey = aesDecryptString(data.fileKey, datakey);
                    }
                    
                    if (datakey && ![datakey isEmptyString] && fileData && fileData.length>0) {
                        fileData = aesDecryptData(fileData, [datakey dataUsingEncoding:NSUTF8StringEncoding]);
                        [SystemUtil removeDocmentFilePath:imgPath];
                        if (!fileData || fileData.length == 0) {
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                data.isDown = NO;
                                [SystemUtil removeDocmentFilePath:fileUrl];
                                data.msgState = CDMessageStateDownloadFaild;
                                [weakSelf.tableView updateMessage:data];
                            });
                            
                        } else {
                            if ([fileData writeToFile:imgPath atomically:YES]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    data.msgState = CDMessageStateNormal;
                                    [weakSelf.tableView updateMessage:data];
                                    NSLog(@"下载语音成功! filePath = %@",filePath);
                                });
                            }
                        }
                        
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            data.isDown = NO;
                            [SystemUtil removeDocmentFilePath:fileUrl];
                            data.msgState = CDMessageStateDownloadFaild;
                            [weakSelf.tableView updateMessage:data];
                        });
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        data.isDown = NO;
                        [SystemUtil removeDocmentFilePath:fileUrl];
                        data.msgState = CDMessageStateDownloadFaild;
                        [weakSelf.tableView updateMessage:data];
                    });
                }
            });
            
            
        } failure:^(NSURLSessionDownloadTask *dataTask, NSError *error) {
            data.isDown = NO;
            [SystemUtil removeDocmentFileName:data.fileName friendid:data.FromId];
            data.msgState = CDMessageStateDownloadFaild;
            [weakSelf.tableView updateMessage:data];
#ifdef DEBUG
            NSLog(@"[CDChatList] 下载语音出现问题%@",error.localizedDescription);
#endif
        }];
    } else {
        if (data.isGroup) {
            [SendRequestUtil sendToxPullFileWithFromId:data.ToId toid:[UserConfig getShareObject].userId fileName:[Base58Util Base58EncodeWithCodeName:data.fileName] filePath:data.filePath msgId:data.messageId fileOwer:@"5" fileFrom:@"1"];
        } else {
            [SendRequestUtil sendToxPullFileWithFromId:data.FromId toid:data.ToId fileName:[Base58Util Base58EncodeWithCodeName:data.fileName] filePath:data.filePath msgId:data.messageId fileOwer:@"2" fileFrom:@"1"];
        }
       
    }
}

-(void)configAudio_Right:(CDChatMessage)data {
    
    if (!self.wave_right.superview) {
        [self.bubbleImage_right addSubview:self.wave_right];
    }
    self.wave_right.frame = CGRectMake(self.bubbleImage_right.frame.size.width - data.chatConfig.bubbleRoundAnglehorizInset - data.chatConfig.headSideLength,
                                       data.chatConfig.bubbleRoundAnglehorizInset,
                                       data.chatConfig.headSideLength,
                                       data.chatConfig.headSideLength - 2 * data.chatConfig.bubbleRoundAnglehorizInset);
    
    self.audioTimeLabel_right.frame = self.indicator_right.frame;
    CGRect fra = self.audioTimeLabel_right.frame;
    fra.size.width = 50;
    self.audioTimeLabel_right.frame = fra;
    if (!self.audioTimeLabel_right.superview) {
        [self.msgContent_right addSubview:self.audioTimeLabel_right];
    }
    
    if ([[AATAudioTool share].audioPath isEqualToString: self.msgModal.msg] && [[AATAudioTool share] isPlaying]) {
        [self.wave_right startAnimating];
    } else {
        [self.wave_right stopAnimating];
    }
    
    if (data.msgState == CDMessageStateNormal) {
        self.audioTimeLabel_right.text = [NSString stringWithFormat:@"%d\"",data.audioTime];
        [self.audioTimeLabel_right setHidden: NO];
    } else if (data.msgState == CDMessageStateSending) {
        [self.audioTimeLabel_right setHidden: YES];
    } else if (data.msgState == CDMessageStateSendFaild || data.msgState == CDMessageStateDownloadFaild) {
        [self.audioTimeLabel_right setHidden: YES];
    } else if (data.msgState == CDMessageStateDownloading) {
        [self.audioTimeLabel_right setHidden: YES];
    }
    
    NSString *filePath = [[SystemUtil getBaseFilePath:data.ToId] stringByAppendingPathComponent:data.fileName];
    
    if ( [SystemUtil filePathisExist:filePath])
    {
        AVURLAsset *audioAsset=[AVURLAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
        CMTime durationTime = audioAsset.duration;
        float reultTime = [[NSString stringWithFormat:@"%.2f",CMTimeGetSeconds(durationTime)] floatValue];
        float audioTimeinSecs = ceilf(reultTime);
        if (audioTimeinSecs > 0) {
            if ( data.msgState != CDMessageStateNormal) {
                data.msgState = CDMessageStateNormal;
                [self.tableView updateMessage:data];
                
                self.audioTimeLabel_right.text = [NSString stringWithFormat:@"%d\"",data.audioTime];
                [self.audioTimeLabel_right setHidden: NO];
                
                [ self.indicator_right stopAnimating];
                [ self.indicator_right setHidden: YES];
            }
            return;
        } else {
            if (!data.isDown) {
                [SystemUtil removeDocmentFilePath:filePath];
            }
        }
    }
    
    if (data.msgState == CDMessageStateDownloadFaild || data.msgState == CDMessageStateNormal || data.msgState == CDMessageStateSending) {
        return;
    }
    if (data.isDown) {
        return;
    }
    data.isDown = YES;
    if ([SystemUtil isSocketConnect]) {
        @weakify_self
        [RequestService downFileWithBaseURLStr:data.filePath fileName:data.fileName friendid:data.ToId progressBlock:^(CGFloat progress) {
            
        } success:^(NSURLSessionDownloadTask *dataTask , NSString *filePath) {
            
            data.isDown = NO;
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSString *imgPath = [[SystemUtil getBaseFilePath:data.ToId] stringByAppendingPathComponent:filePath];
                
                if ([[MD5Util md5WithPath:imgPath] isEqualToString:[NSString getNotNullValue:data.fileMd5]]) {
                    NSData *fileData = [NSData dataWithContentsOfFile:imgPath];
                    
                    NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:data.srckey];
                    if (!datakey) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            data.isDown = NO;
                            [SystemUtil removeDocmentFilePath:imgPath];
                            data.msgState = CDMessageStateDownloadFaild;
                            [weakSelf.tableView updateMessage:data];
                            return ;
                        });
                    }
                    datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
                    if (data.fileKey && data.fileKey.length > 0) {
                        datakey = aesDecryptString(data.fileKey, datakey);
                    }
                    
                    if (datakey && ![datakey isEmptyString] && fileData && fileData.length>0) {
                        fileData = aesDecryptData(fileData, [datakey dataUsingEncoding:NSUTF8StringEncoding]);
                        if (!fileData || fileData.length == 0) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                data.isDown = NO;
                                [SystemUtil removeDocmentFilePath:imgPath];
                                data.msgState = CDMessageStateDownloadFaild;
                                [weakSelf.tableView updateMessage:data];
                            });
                        } else {
                            if ([fileData writeToFile:imgPath atomically:YES]) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    data.msgState = CDMessageStateNormal;
                                    [weakSelf.tableView updateMessage:data];
                                    NSLog(@"下载语音成功! filePath = %@",filePath);
                                });
                            }
                        }
                        
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            data.msgState = CDMessageStateDownloadFaild;
                            [SystemUtil removeDocmentFileName:data.fileName friendid:data.ToId];
                            [weakSelf.tableView updateMessage:data];
                        });
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        data.msgState = CDMessageStateDownloadFaild;
                        [SystemUtil removeDocmentFileName:data.fileName friendid:data.ToId];
                        [weakSelf.tableView updateMessage:data];
                    });
                }
            });
            
        } failure:^(NSURLSessionDownloadTask *dataTask, NSError *error) {
            data.isDown = NO;
            [SystemUtil removeDocmentFileName:data.fileName friendid:data.ToId];
            data.msgState = CDMessageStateDownloadFaild;
            [weakSelf.tableView updateMessage:data];
#ifdef DEBUG
            NSLog(@"[CDChatList] 下载语音出现问题%@",error.localizedDescription);
#endif
        }];
    } else {
        if (data.isGroup) {
            [SendRequestUtil sendToxPullFileWithFromId:data.ToId toid:[UserConfig getShareObject].userId fileName:[Base58Util Base58EncodeWithCodeName:data.fileName] filePath:data.filePath msgId:data.messageId fileOwer:@"5" fileFrom:@"1"];
        } else {
            [SendRequestUtil sendToxPullFileWithFromId:data.ToId toid:data.FromId fileName:[Base58Util Base58EncodeWithCodeName:data.fileName] filePath:data.filePath msgId:data.messageId fileOwer:@"1" fileFrom:@"1"];
        }
       
    }
}

-(void)receiveNoti:(NSNotification *)noti{
    if (noti.name == AATAudioToolDidStopPlayNoti) {
        
        NSString *path = noti.object;
        if ([path isEqualToString:self.mavPath]) {
            if (self.msgModal.isLeft) {
                [self.wave_left stopAnimating];
            } else {
                [self.wave_right stopAnimating];
            }
        }
    }
}

-(void)longPressGes:(UILongPressGestureRecognizer *)recognizer{
    
    
    CGPoint curPoint = [recognizer locationInView:self];
    if (!CGRectContainsPoint(self.bounds, curPoint)){
        return;
    }
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            NSString *friendid = self.msgModal.ToId;
            if (self.msgModal.isLeft && !self.msgModal.isGroup) {
                friendid = self.msgModal.FromId;
            }
             NSString *filePath = [[SystemUtil getBaseFilePath:friendid] stringByAppendingPathComponent:self.msgModal.fileName];
             if ([SystemUtil filePathisExist:filePath]) {
                 if (self.msgModal.isLeft) {
                     [self showMenuWithItemX:_wave_left.frame.size.width/2];
                 } else {
                     [self showMenuWithItemX:_wave_right.frame.size.width/2];
                 }
             }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            //            self.magnifierView.touchPoint = curPoint;
        }
            break;
        default:
        {
            //            [self.magnifierView removeFromSuperview];
        }
            break;
    }
}


-(void)tapGesture:(UITapGestureRecognizer *)ges{
    
    if (self.msgModal.msgState == CDMessageStateDownloading) {
        return;
    }
    if (self.msgModal.msgState == CDMessageStateDownloadFaild) {
        self.msgModal.msgState = CDMessageStateDownloading;
        [self.tableView updateMessage:self.msgModal];
        return;
    }
    
    if (self.msgModal.msgState == CDMessageStateSendFaild) {
        // 重新发送
        self.msgModal.msgState = CDMessageStateSending;
        [self.tableView updateMessage:self.msgModal];
        
        NSString *filePath = [[SystemUtil getBaseFilePath:self.msgModal.ToId] stringByAppendingPathComponent:self.msgModal.fileName];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        NSString *dsKey = @"";
        NSString *srcKey = @"";
        if (self.msgModal.isGroup) {
            // 自己私钥解密
            NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:self.msgModal.dskey];
            NSString *symmetKey = [[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding];
            NSData *msgKeyData =[[symmetKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
            fileData = aesEncryptData(fileData,msgKeyData);
        } else {
            // 生成32位对称密钥
            NSString *msgKey = [SystemUtil get32AESKey];
            NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
            NSString *symmetKey = [symmetData base64EncodedString];
            // 好友公钥加密对称密钥
            dsKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:self.msgModal.publicKey];
            // 自己公钥加密对称密钥
            srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
            
            NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
            fileData = aesEncryptData(fileData,msgKeyData);
        }
        
        
        if ([SystemUtil isSocketConnect]) {
            SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
            dataUtil.fileInfo = @"";
            [dataUtil sendFileId:self.msgModal.ToId fileName:[self.msgModal.fileName base64EncodedString] fileData:fileData fileid:self.msgModal.fileID fileType:2 messageid:self.msgModal.messageId srcKey:srcKey dstKey:dsKey isGroup:self.msgModal.isGroup];
            [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
        } else {
            NSString *dataPath = [[SystemUtil getTempBaseFilePath:self.msgModal.ToId] stringByAppendingPathComponent:[Base58Util Base58EncodeWithCodeName:self.msgModal.fileName]];
            
            if ([fileData writeToFile:dataPath atomically:YES]) {
                if (self.msgModal.isGroup) {
                    NSDictionary *parames = @{@"Action":@"GroupSendFileDone",@"UserId":self.msgModal.FromId,@"GId":self.msgModal.ToId,@"FileName":[Base58Util Base58EncodeWithCodeName:self.msgModal.fileName],@"FileMD5":[MD5Util md5WithPath:dataPath],@"FileSize":@(fileData.length),@"FileType":@(self.msgModal.msgType),@"DstKey":@"",@"FileId":self.msgModal.messageId,@"FileInfo":@""};
                    [SendToxRequestUtil sendFileWithFilePath:dataPath parames:parames];
                } else {
                    NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":self.msgModal.FromId,@"ToId":self.msgModal.ToId,@"FileName":[Base58Util Base58EncodeWithCodeName:self.msgModal.fileName],@"FileMD5":[MD5Util md5WithPath:dataPath],@"FileSize":@(fileData.length),@"FileType":@(self.msgModal.msgType),@"SrcKey":srcKey,@"DstKey":dsKey,@"FileId":self.msgModal.messageId,@"FileInfo":@""};
                    [SendToxRequestUtil sendFileWithFilePath:dataPath parames:parames];
                }
               
            }
        }
        
       
        return;
    }
    
    NSString *friendid = self.msgModal.ToId;
    if (self.msgModal.isLeft && !self.msgModal.isGroup) {
        friendid = self.msgModal.FromId;
    }
    NSString *jFileName = [[self.msgModal.fileName?:@"" componentsSeparatedByString:@"."] firstObject]?:@"";
    
    NSString *amrPath =[[SystemUtil getBaseFilePath:friendid] stringByAppendingPathComponent:self.msgModal.fileName];
    
    NSString *mavPath =[[SystemUtil getBaseFilePath:friendid] stringByAppendingPathComponent:[jFileName stringByAppendingString:@".mav"]];
    


    if (![[NSFileManager defaultManager] fileExistsAtPath:mavPath]) {
        if (![VoiceConvert ConvertAmrToWav:amrPath wavSavePath:mavPath]) {
            [self showHint:@"Invalid format."];
            return;
        }
    }
    self.mavPath = mavPath;
    if ([[AATAudioTool share].audioPath isEqualToString:mavPath]) {
        if ([[AATAudioTool share] isPlaying]){
            [[AATAudioTool share] stopPlay];
            
            if (self.msgModal.isLeft) {
                [self.wave_left stopAnimating];
            } else {
                [self.wave_right  stopAnimating];
            }
        } else {
            [AATAudioTool share].audioPath = mavPath;
            [[AATAudioTool share] play];
            
            if (self.msgModal.isLeft) {
                [self.wave_left startAnimating];
            } else {
                [self.wave_right startAnimating];
            }
        }
    } else {
        [[AATAudioTool share] stopPlay];
        [AATAudioTool share].audioPath = mavPath;
        [[AATAudioTool share] play];
        
        
        if (self.msgModal.isLeft) {
            [self.wave_left startAnimating];
        } else {
            [self.wave_right startAnimating];
        }
    }
}

#pragma mark 菜单相关方法
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    if (action == @selector(selectWithdrawItem:) || action == @selector(selectForwardItem:)) {
        return YES;
    }
    return NO;
}
-(BOOL) canBecomeFirstResponder{
    return YES;
}

@end
