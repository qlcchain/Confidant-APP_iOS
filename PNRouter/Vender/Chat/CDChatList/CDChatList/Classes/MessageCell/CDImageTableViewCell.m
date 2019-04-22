//
//  CDImageTableViewCell.m
//  CDChatList
//
//  Created by chdo on 2017/11/6.
//

#import "CDImageTableViewCell.h"
#import "ChatHelpr.h"
#import "UITool.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIView+WebCache.h"
#import "ChatListInfo.h"
#import "RequestService.h"
#import "SystemUtil.h"
#import "SocketDataUtil.h"
#import "SocketManageUtil.h"
#import "NSString+Base64.h"
#import "AESCipher.h"
#import "RSAUtil.h"
#import "NSData+Base64.h"
#import "PNRouter-Swift.h"
#import "MD5Util.h"
#import "LibsodiumUtil.h"
#import "EntryModel.h"
#import "UserConfig.h"
#import "ChatImgCacheUtil.h"

@interface CDImageTableViewCell()

/**
 图片_左侧
 */
@property(nonatomic, strong) UIImageView *imageContent_left;

/**
 图片_右侧侧
 */
@property(nonatomic, strong) UIImageView *imageContent_right;


@end;

@implementation CDImageTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGes:)];
    [self addGestureRecognizer:longPressRecognizer];
    
    [self initLeftImageContent];
    [self initRightImageContent];
    
    return self;
}

-(void)initLeftImageContent{
    // 将气泡图换位透明图
    UIImage *left_box = ChatHelpr.share.imageDic[@"bg_mask_left"];
    self.bubbleImage_left.image = left_box;
    
    // 在气泡图下面添加信息图片
    self.imageContent_left = [[UIImageView alloc] initWithFrame:self.bubbleImage_left.frame];
    self.imageContent_left.contentMode = UIViewContentModeScaleAspectFill;
    self.imageContent_left.clipsToBounds = YES;
    self.imageContent_left.backgroundColor = [UIColor lightGrayColor];
    [self.msgContent_left insertSubview:self.imageContent_left
                           belowSubview:self.bubbleImage_left];
    [self.msgContent_left sd_setShowActivityIndicatorView:YES];
    [self.msgContent_left sd_setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    // 点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContent:)];
    [self.bubbleImage_left addGestureRecognizer:tap];
}

-(void)initRightImageContent{
    // 将气泡图换位透明图
    UIImage *right_box = ChatHelpr.share.imageDic[@"bg_mask_right"];
    self.bubbleImage_right.image = right_box;
    
    // 在气泡图下面添加信息图片
    self.imageContent_right = [[UIImageView alloc] initWithFrame:self.bubbleImage_right.frame];
    self.imageContent_right.contentMode = UIViewContentModeScaleAspectFill;
    self.imageContent_right.clipsToBounds = YES;
    self.imageContent_right.backgroundColor = CDHexColor(0x808080);
    [self.msgContent_right insertSubview:self.imageContent_right
                            belowSubview:self.bubbleImage_right];
    [self.msgContent_right sd_setShowActivityIndicatorView:YES];
    [self.msgContent_right sd_setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    // 点击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContent:)];
    [self.bubbleImage_right addGestureRecognizer:tap];
}

-(void)configCellByData:(CDChatMessage)data table:(CDChatListView *)table{
    [super configCellByData:data table:table];
    
    if (data.isLeft) {
        // 左侧
        // 设置消息内容的总高度
        [self configImage_Left:data];
    } else {
        // 右侧
        // 设置消息内容的总高度
        [self configImage_Right:data];
    }

}

-(void)configImage_Left:(CDChatMessage)data {
    
    CGRect bubbleRec = self.bubbleImage_left.frame;
    self.imageContent_left.frame = bubbleRec;
    NSString *friendID = data.FromId;
    if (data.isGroup) {
        friendID = data.ToId;
    }
    UIImage *img = [[ChatImgCacheUtil getChatImgCacheUtilShare].imgCacheDic objectForKey:[NSString stringWithFormat:@"%@_%@",friendID,data.fileName]];
    if (img) {
        self.imageContent_left.image = img;
        data.mediaImage = img;
        if ( data.msgState != CDMessageStateNormal) {
            data.fileWidth = img.size.width;
            data.fileHeight = img.size.height;
            data.msgState = CDMessageStateNormal;
            [ self.indicator_left stopAnimating];
            [ self.indicator_left setHidden: YES];
            [self.tableView updateMessage:data];
        }
        return;
    }
    NSString *filePath = [[SystemUtil getBaseFilePath:friendID] stringByAppendingPathComponent:data.fileName];
    @weakify_self
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
         UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
         // 当图片正在下载时不能删子除路径
        if (!image && !data.isDown) {
            [SystemUtil removeDocmentFilePath:filePath];
        }
        if (image)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imageContent_left.image = image;
                data.fileWidth = image.size.width;
                data.fileHeight = image.size.height;
                if ( data.msgState != CDMessageStateNormal) {
                    [[ChatImgCacheUtil getChatImgCacheUtilShare].imgCacheDic setObject:image forKey:[NSString stringWithFormat:@"%@_%@",friendID,data.fileName?:@""]];
                    data.msgState = CDMessageStateNormal;
                    [ self.indicator_left stopAnimating];
                    [ self.indicator_left setHidden: YES];
                    [weakSelf.tableView updateMessage:data];
                }
            });
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.imageContent_left.image = nil;
            });
            if (data.msgState == CDMessageStateDownloadFaild || data.msgState == CDMessageStateNormal) {
                return;
            }
            if (data.isDown) {
                return;
            }
            data.isDown = YES;
            if ([SystemUtil isSocketConnect]) {
                @weakify_self
                [RequestService downFileWithBaseURLStr:data.filePath friendid:friendID progressBlock:^(CGFloat progress) {
                    
                } success:^(NSURLSessionDownloadTask *dataTask , NSString *filePath) {
                    data.isDown = NO;
                    if (data.dskey) {
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            NSString *friendID = data.FromId;
                            if (data.isGroup) {
                                friendID = data.ToId;
                            }
                            NSString *imgPath = [[SystemUtil getBaseFilePath:friendID] stringByAppendingPathComponent:filePath];
                    
                            
                            if ([[MD5Util md5WithPath:imgPath] isEqualToString:data.fileMd5]) {
                                
                                NSData *fileData = [NSData dataWithContentsOfFile:imgPath];
                                NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:data.dskey];
                                if (!datakey) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        data.msgState = CDMessageStateDownloadFaild;
                                        [SystemUtil removeDocmentFileName:data.fileName friendid:data.ToId];
                                        [weakSelf.tableView updateMessage:data];
                                        return ;
                                    });
                                }
                                datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
                                
                                if (data.fileKey && data.fileKey.length > 0) {
                                    datakey = aesDecryptString(data.fileKey, datakey);
                                }
                                
                                if (datakey && ![datakey isEmptyString] && fileData && fileData.length>0 && datakey.length == 16) {
                                    fileData = aesDecryptData(fileData, [datakey dataUsingEncoding:NSUTF8StringEncoding]);
                                    [SystemUtil removeDocmentFilePath:imgPath];
                                    if (!fileData || fileData.length == 0) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            data.msgState = CDMessageStateDownloadFaild;
                                            [SystemUtil removeDocmentFileName:data.fileName friendid:data.ToId];
                                            [weakSelf.tableView updateMessage:data];
                                        });
                                    } else {
                                        if ( [fileData writeToFile:imgPath atomically:YES])
                                        {
                                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                                UIImage *image = [[UIImage alloc] initWithData:fileData];
                                                if (image) {
                                                    [[ChatImgCacheUtil getChatImgCacheUtilShare].imgCacheDic setObject:image forKey:[NSString stringWithFormat:@"%@_%@",friendID,data.fileName?:@""]];
                                                    
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        data.msgState = CDMessageStateNormal;
                                                        [weakSelf.tableView updateMessage:data];
                                                        NSLog(@"下载成功! filePath = %@",filePath);
                                                    });
                                                    
                                                }  else {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        data.msgState = CDMessageStateDownloadFaild;
                                                        [SystemUtil removeDocmentFilePath:imgPath];
                                                        [weakSelf.tableView updateMessage:data];
                                                    });
                                                }
                                            });
                                        }
                                    }
                                    
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [SystemUtil removeDocmentFilePath:imgPath];
                                        data.msgState = CDMessageStateDownloadFaild;
                                        [weakSelf.tableView updateMessage:data];
                                    });
                                }
                            } else {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [SystemUtil removeDocmentFilePath:imgPath];
                                    data.msgState = CDMessageStateDownloadFaild;
                                    [weakSelf.tableView updateMessage:data];
                                });
                            }
                        });
                    }
                    
                } failure:^(NSURLSessionDownloadTask *dataTask, NSError *error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        data.isDown = NO;
                        [SystemUtil removeDocmentFileName:data.fileName friendid:data.FromId];
                        data.msgState = CDMessageStateDownloadFaild;
                        [weakSelf.tableView updateMessage:data];
                        NSLog(@"下载失败!");
                    });
                    
                }];
            } else {
                if (data.isGroup) {
                    [SendRequestUtil sendToxPullFileWithFromId:data.ToId toid:[UserConfig getShareObject].userId fileName:[Base58Util Base58EncodeWithCodeName:data.fileName] msgId:data.messageId fileOwer:@"5" fileFrom:@"1"];
                } else {
                     [SendRequestUtil sendToxPullFileWithFromId:data.FromId toid:data.ToId fileName:[Base58Util Base58EncodeWithCodeName:data.fileName] msgId:data.messageId fileOwer:@"2" fileFrom:@"1"];
                }
               
            }
            
            
        }
    });
}

-(void)configImage_Right:(CDChatMessage)data {
    
    CGRect bubbleRec = self.bubbleImage_right.frame;
    
    self.imageContent_right.frame = bubbleRec;
    
    
    UIImage *img = [[ChatImgCacheUtil getChatImgCacheUtilShare].imgCacheDic objectForKey:[NSString stringWithFormat:@"%@_%@",data.ToId,data.fileName]];
    if (img) {
         self.imageContent_right.image = img;
         data.mediaImage = img;
        if ( data.msgState != CDMessageStateNormal) {
            data.fileWidth = img.size.width;
            data.fileHeight = img.size.height;
            data.msgState = CDMessageStateNormal;
            [ self.indicator_right stopAnimating];
            [ self.indicator_right setHidden: YES];
            [self.tableView updateMessage:data];
        }
        return;
    }
    
    NSString *filePath = [[SystemUtil getBaseFilePath:data.ToId] stringByAppendingPathComponent:data.fileName];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
        // 当图片正在下载时不能删子除路径
        if (!image && !data.isDown) {
             [SystemUtil removeDocmentFilePath:filePath];
        }
        if (image)
        {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageContent_right.image = image;
                    data.fileWidth = image.size.width;
                    data.fileHeight = image.size.height;
                    if ( data.msgState != CDMessageStateNormal) {
                        [[ChatImgCacheUtil getChatImgCacheUtilShare].imgCacheDic setObject:image forKey:[NSString stringWithFormat:@"%@_%@",data.ToId,data.fileName?:@""]];
                        data.msgState = CDMessageStateNormal;
                        [ self.indicator_right stopAnimating];
                        [ self.indicator_right setHidden: YES];
                        [self.tableView updateMessage:data];
                    }
                });
           
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageContent_right.image = nil;
            });
            if (data.msgState == CDMessageStateDownloadFaild || data.msgState == CDMessageStateNormal) {
                return;
            }
            if (data.isDown) {
                return;
            }
            data.isDown = YES;
            if ([SystemUtil isSocketConnect]) {
                @weakify_self
                [RequestService downFileWithBaseURLStr:data.filePath friendid:data.ToId progressBlock:^(CGFloat progress) {
                    
                } success:^(NSURLSessionDownloadTask *dataTask , NSString *filePath) {
                     data.isDown = NO;
                    if (data.srckey) {
                        dispatch_async(dispatch_get_global_queue(0, 0), ^{
                            NSString *imgPath = [[SystemUtil getBaseFilePath:data.ToId] stringByAppendingPathComponent:filePath];
                            if ([[MD5Util md5WithPath:imgPath] isEqualToString:[NSString getNotNullValue:data.fileMd5]]) {
                                NSData *fileData = [NSData dataWithContentsOfFile:imgPath];
                                NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:data.srckey];
                                if (!datakey) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        data.msgState = CDMessageStateDownloadFaild;
                                        [SystemUtil removeDocmentFileName:data.fileName friendid:data.ToId];
                                        [weakSelf.tableView updateMessage:data];
                                        return ;
                                    });
                                }
                                datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
                                
                                if (data.fileKey && data.fileKey.length > 0) {
                                    datakey = aesDecryptString(data.fileKey, datakey);
                                }
                                
                                if (datakey && ![datakey isEmptyString] && fileData && fileData.length>0 && fileData.length>0 && datakey.length == 16) {
                                    fileData = aesDecryptData(fileData, [datakey dataUsingEncoding:NSUTF8StringEncoding]);
                                    [SystemUtil removeDocmentFilePath:imgPath];
                                    if (!fileData || fileData.length == 0) {
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            data.msgState = CDMessageStateDownloadFaild;
                                            [SystemUtil removeDocmentFileName:data.fileName friendid:data.ToId];
                                            [weakSelf.tableView updateMessage:data];
                                        });
                                    } else {
                                        if ([fileData writeToFile:imgPath atomically:YES]) {
                                            
                                            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                                UIImage *image = [[UIImage alloc] initWithData:fileData];
                                                if (image) {
                                                    [[ChatImgCacheUtil getChatImgCacheUtilShare].imgCacheDic setObject:image forKey:[NSString stringWithFormat:@"%@_%@",data.ToId,data.fileName?:@""]];
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        data.msgState = CDMessageStateNormal;
                                                        [weakSelf.tableView updateMessage:data];
                                                        NSLog(@"下载成功! filePath = %@",filePath);
                                                    });
                                                } else {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        data.msgState = CDMessageStateDownloadFaild;
                                                        [SystemUtil removeDocmentFileName:data.fileName friendid:data.ToId];
                                                        [weakSelf.tableView updateMessage:data];
                                                    });
                                                }
                                                
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
                    }
                   
                    
                } failure:^(NSURLSessionDownloadTask *dataTask, NSError *error) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         data.isDown = NO;
                         [SystemUtil removeDocmentFileName:data.fileName friendid:data.ToId];
                         data.msgState = CDMessageStateDownloadFaild;
                         [weakSelf.tableView updateMessage:data];
                         NSLog(@"下载失败!");
                     });
                    
                }];
            } else {
                if (data.isGroup) {
                    [SendRequestUtil sendToxPullFileWithFromId:data.ToId toid:[UserConfig getShareObject].userId fileName:[Base58Util Base58EncodeWithCodeName:data.fileName] msgId:data.messageId fileOwer:@"5" fileFrom:@"1"];
                } else {
                     [SendRequestUtil sendToxPullFileWithFromId:data.ToId toid:data.FromId fileName:[Base58Util Base58EncodeWithCodeName:data.fileName] msgId:data.messageId fileOwer:@"1" fileFrom:@"1"];
                }
               
            }
        }
    });
    
   
    
    /*
     else {
     
     }
     NSData *fileData = [NSData dataWithContentsOfFile:filePath];
     UIImage *image = nil;
     if (fileData) {
     image = [UIImage imageWithData:fileData];
     }
     if (image) {
     self.imageContent_right.image = image;
     if ( data.msgState == CDMessageStateDownloading) {
     data.msgState = CDMessageStateNormal;
     [self.tableView updateMessage:data];
     }
     
     }
     */
    
}

-(void)tapContent:(UITapGestureRecognizer *)tap {
    //
    [self hidMenu];
    if (self.msgModal.msgState == CDMessageStateDownloading
        ) {
        return;
    } else if (self.msgModal.msgState == CDMessageStateDownloadFaild) {
        self.msgModal.msgState = CDMessageStateDownloading;
        [self.tableView updateMessage:self.msgModal];
        return;
    } else if (self.msgModal.msgState == CDMessageStateSendFaild) {
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
            dataUtil.fileInfo = [NSString stringWithFormat:@"%f*%f",self.msgModal.fileWidth,self.msgModal.fileHeight];
            [dataUtil sendFileId:self.msgModal.ToId fileName:[self.msgModal.fileName base64EncodedString] fileData:fileData fileid:self.msgModal.fileID fileType:1 messageid:self.msgModal.messageId srcKey:srcKey dstKey:dsKey isGroup:self.msgModal.isGroup];
            [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
        } else {
            NSString *dataPath = [[SystemUtil getTempBaseFilePath:self.msgModal.ToId] stringByAppendingPathComponent:[Base58Util Base58EncodeWithCodeName:self.msgModal.fileName]];
            
            if ([fileData writeToFile:dataPath atomically:YES]) {
                if (self.msgModal.isGroup) {
                    NSDictionary *parames = @{@"Action":@"GroupSendFileDone",@"UserId":self.msgModal.FromId,@"GId":self.msgModal.ToId,@"FileName":[Base58Util Base58EncodeWithCodeName:self.msgModal.fileName],@"FileMD5":[MD5Util md5WithPath:dataPath],@"FileSize":@(fileData.length),@"FileType":@(self.msgModal.msgType),@"DstKey":@"",@"FileId":self.msgModal.messageId,@"FileInfo":[NSString stringWithFormat:@"%f*%f",self.msgModal.fileWidth,self.msgModal.fileHeight]};
                    [SendToxRequestUtil sendFileWithFilePath:dataPath parames:parames];
                } else {
                    NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":self.msgModal.FromId,@"ToId":self.msgModal.ToId,@"FileName":[Base58Util Base58EncodeWithCodeName:self.msgModal.fileName],@"FileMD5":[MD5Util md5WithPath:dataPath],@"FileSize":@(fileData.length),@"FileType":@(self.msgModal.msgType),@"SrcKey":srcKey,@"DstKey":dsKey,@"FileId":self.msgModal.messageId,@"FileInfo":[NSString stringWithFormat:@"%f*%f",self.msgModal.fileWidth,self.msgModal.fileHeight]};
                    [SendToxRequestUtil sendFileWithFilePath:dataPath parames:parames];
                }
            }
        }
        
        return;
    }
    
    ChatListInfo *info = [ChatListInfo new];
    info.eventType = ChatClickEventTypeIMAGE;
    if (self.msgModal.isLeft) {
        info.containerView = self.bubbleImage_left;
        info.image = self.imageContent_left.image;
    } else {
        info.containerView = self.bubbleImage_right;
        info.image = self.imageContent_right.image;
    }
    
    info.msgText = self.msgModal.msg;
    info.msgModel = self.msgModal;
    if ([self.tableView.msgDelegate respondsToSelector:@selector(chatlistClickMsgEvent:imgView:)]) {
        if (self.msgModal.isLeft) {
            [self.tableView.msgDelegate chatlistClickMsgEvent:info imgView:self.imageContent_left];
        } else {
            [self.tableView.msgDelegate chatlistClickMsgEvent:info imgView:self.imageContent_right];
        }
        
    } else {
#ifdef DEBUG
      NSLog(@"[CDChatList] chatlistClickMsgEvent未实现，不能响应点击事件");
#endif
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
                    [self showMenuWithItemX:_imageContent_left.frame.size.width/2];
                } else {
                    [self showMenuWithItemX:_imageContent_right.frame.size.width/2];
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

#pragma mark 菜单相关方法
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    
    if (action == @selector(selectWithdrawItem:) || action == @selector(selectForwardItem:) || action == @selector(selectDownloadItem:)) {
        return YES;
    }
    return NO;
}
-(BOOL) canBecomeFirstResponder{
    return YES;
}
@end
