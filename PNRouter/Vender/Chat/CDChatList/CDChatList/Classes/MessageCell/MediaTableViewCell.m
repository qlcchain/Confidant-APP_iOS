//
//  MediaTableViewCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/10/19.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "MediaTableViewCell.h"
#import "ChatHelpr.h"
#import "UITool.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "UIView+WebCache.h"
#import "ChatListInfo.h"
#import "SystemUtil.h"
#import "RMDownloadIndicator.h"
#import "RequestService.h"
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

@interface MediaTableViewCell()
/**
 图片_左侧
 */
@property(nonatomic, strong) UIImageView *imageContent_left;
@property(nonatomic, strong) UIButton *media_left;

/**
 图片_右侧侧
 */
@property(nonatomic, strong) UIImageView *imageContent_right;
@property(nonatomic, strong) UIButton *media_right;

@property (strong, nonatomic) RMDownloadIndicator *filedIndicator_left;

@property (strong, nonatomic) RMDownloadIndicator *filedIndicator_right;

@end;


@implementation MediaTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGes:)];
    [self addGestureRecognizer:longPressRecognizer];
    
    [self initLeftImageContent];
    [self initRightImageContent];
    
    return self;
}

#pragma -mark layz
- (RMDownloadIndicator *)filedIndicator_left
{
    if (!_filedIndicator_left) {
        _filedIndicator_left = [[RMDownloadIndicator alloc]initWithFrame:CGRectMake(0 ,0, 40, 40) type:kRMFilledIndicator];
        _filedIndicator_left.layer.borderColor = [UIColor whiteColor].CGColor;
        _filedIndicator_left.layer.borderWidth = 1.0f;
        _filedIndicator_left.layer.cornerRadius = 20;
        //_filedIndicator_left.center = self.view.center;
        [_filedIndicator_left setBackgroundColor:[UIColor clearColor]];
        [_filedIndicator_left setFillColor:[UIColor whiteColor]];
        [_filedIndicator_left setStrokeColor:[UIColor whiteColor]];
        _filedIndicator_left.radiusPercent = 0.45;
        [_filedIndicator_left loadIndicator];
    }
    return _filedIndicator_left;
}

- (RMDownloadIndicator *)filedIndicator_right
{
    if (!_filedIndicator_right) {
        _filedIndicator_right = [[RMDownloadIndicator alloc]initWithFrame:CGRectMake(0 ,0, 40, 40) type:kRMFilledIndicator];
        _filedIndicator_right.layer.borderColor = [UIColor whiteColor].CGColor;
        _filedIndicator_right.layer.borderWidth = 1.0f;
        _filedIndicator_right.layer.cornerRadius = 20;
        //_filedIndicator_left.center = self.view.center;
        [_filedIndicator_right setBackgroundColor:[UIColor clearColor]];
        [_filedIndicator_right setFillColor:[UIColor whiteColor]];
        [_filedIndicator_right setStrokeColor:[UIColor whiteColor]];
        _filedIndicator_right.radiusPercent = 0.45;
        [_filedIndicator_right loadIndicator];
    }
    return _filedIndicator_right;
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
    
    self.media_left = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.msgContent_left insertSubview:self.media_left
                           belowSubview:self.bubbleImage_left];
    [self.msgContent_left insertSubview:self.filedIndicator_left belowSubview:self.bubbleImage_left];
    
    
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
    
    self.media_right = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.msgContent_right insertSubview:self.media_right
                            belowSubview:self.bubbleImage_right];
    [self.msgContent_right insertSubview:self.filedIndicator_right
                            belowSubview:self.bubbleImage_right];
    
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
    self.media_left.frame = bubbleRec;
    self.filedIndicator_left.center = self.bubbleImage_left.center;
    self.imageContent_left.image = data.mediaImage;
    NSString *friendID = data.FromId;
    if (data.isGroup) {
        friendID = data.ToId;
    }
    NSString *filePath = [[SystemUtil getBaseFilePath:friendID] stringByAppendingPathComponent:data.fileName];

    if ([SystemUtil filePathisExist:filePath]) {
        
        [self.media_left setImage:[UIImage imageNamed:@"Video playback"] forState:UIControlStateNormal];
        if (!data.mediaImage) {
            @weakify_self
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSURL *fileURL = [NSURL fileURLWithPath:filePath];
                NSData *fileData = [NSData dataWithContentsOfURL:fileURL];
                if (fileData) {
                    UIImage *image = [SystemUtil thumbnailImageForVideo:fileURL];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            data.mediaImage = image;
                            [weakSelf.tableView updateMessage:data];
                        });
                    }
                }
            });
        }
        
        
    } else {
        [self.media_left setImage:[UIImage imageNamed:@"Video download"] forState:UIControlStateNormal];
    }
    
   
    
    
    
}


-(void)configImage_Right:(CDChatMessage)data {
    
    CGRect bubbleRec = self.bubbleImage_right.frame;
    self.imageContent_right.frame = bubbleRec;
    self.media_right.frame = bubbleRec;
    self.filedIndicator_right.center = self.bubbleImage_right.center;
    self.imageContent_right.image = data.mediaImage;
    
    NSString *filePath = [[SystemUtil getBaseFilePath:data.ToId] stringByAppendingPathComponent:data.fileName];
    if ([SystemUtil filePathisExist:filePath]) {
        [self.media_right setImage:[UIImage imageNamed:@"Video playback"] forState:UIControlStateNormal];
        if (!data.mediaImage) {
            @weakify_self
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSURL *fileURL = [NSURL fileURLWithPath:filePath];
                NSData *fileData = [NSData dataWithContentsOfURL:fileURL];
                if (fileData) {
                    UIImage *image = [SystemUtil thumbnailImageForVideo:fileURL];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            data.mediaImage = image;
                            [weakSelf.tableView updateMessage:data];
                        });
                    }
                }
            });
        }
    } else {
        [self.media_right setImage:[UIImage imageNamed:@"Video download"] forState:UIControlStateNormal];
    }
    
//    UIImage *image = nil;
//    if (fileData) {
//        image = [UIImage imageWithData:fileData];
//    }
//    if (image) {
//        self.imageContent_right.image = image;
//    } else {
//        if (data.msgState != CDMessageStateDownloading) {
//            self.imageContent_right.image = nil;
//            return;
//        }
//    }
}

-(void)tapContent:(UITapGestureRecognizer *)tap {
    //
    
    if (self.msgModal.msgState == CDMessageStateDownloading) {
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
            dataUtil.fileInfo = [NSString stringWithFormat:@"%f*%f",self.msgModal.fileWidth,self.msgModal.fileHeight];
            [dataUtil sendFileId:self.msgModal.ToId fileName:[self.msgModal.fileName base64EncodedString] fileData:fileData fileid:self.msgModal.fileID fileType:4 messageid:self.msgModal.messageId srcKey:(NSString *)srcKey dstKey:dsKey isGroup:self.msgModal.isGroup];
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
    
    
    
    NSString *friendid = self.msgModal.ToId;
    if (self.msgModal.isLeft && !self.msgModal.isGroup) {
        friendid = self.msgModal.FromId;
    }
    NSString *filePath = [[SystemUtil getBaseFilePath:friendid] stringByAppendingPathComponent:self.msgModal.fileName];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    if (fileData) {
        if (self.tableView.msgDelegate) {
            [self.tableView.msgDelegate clickFileCellWithMsgMode:self.msgModal withFilePath:filePath];
        }
    } else { // 下载视频
       
        if (self.msgModal.msgState == CDMessageStateSending) {
            return;
        }
        self.msgModal.msgState = CDMessageStateDownloading;
        [self.tableView updateMessage:self.msgModal];
        
        NSString *msgkey = self.msgModal.srckey;
        if (self.msgModal.isLeft) {
            msgkey = self.msgModal.dskey;
        }
        if ([SystemUtil isSocketConnect]) {
            @weakify_self
            [RequestService downFileWithBaseURLStr:self.msgModal.filePath friendid:friendid progressBlock:^(CGFloat progress) {
                
            } success:^(NSURLSessionDownloadTask *dataTask , NSString *filePath) {
                
                NSString *path = [[SystemUtil getBaseFilePath:friendid] stringByAppendingPathComponent:filePath];
                 if ([[MD5Util md5WithPath:path] isEqualToString:[NSString getNotNullValue:weakSelf.msgModal.fileMd5]]) {
                      NSLog(@"下载文件成功! filePath ===== %@",filePath);
                      NSData *data = [NSData dataWithContentsOfFile:path];
                     if (msgkey) {
                         NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:msgkey];
                         if (!datakey) {
                             weakSelf.msgModal.msgState = CDMessageStateDownloadFaild;
                             [SystemUtil removeDocmentFilePath:path];
                             return;
                         }
                         datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
                         if (datakey && ![datakey isEmptyString]) {
                             data = aesDecryptData(data, [datakey dataUsingEncoding:NSUTF8StringEncoding]);
                             [SystemUtil removeDocmentFilePath:path];
                             if (!data) {
                                 weakSelf.msgModal.msgState = CDMessageStateDownloadFaild;
                                 [SystemUtil removeDocmentFilePath:path];
                             } else {
                                 [data writeToFile:path atomically:YES];
                                 weakSelf.msgModal.msgState = CDMessageStateNormal;
                             }
                             
                         } else {
                             weakSelf.msgModal.msgState = CDMessageStateDownloadFaild;
                             [SystemUtil removeDocmentFilePath:path];
                         }
                         
                     } else {
                         weakSelf.msgModal.msgState = CDMessageStateDownloadFaild;
                         [SystemUtil removeDocmentFilePath:path];
                     }
                 }
               
                [weakSelf.tableView updateMessage:weakSelf.msgModal];
                
            } failure:^(NSURLSessionDownloadTask *dataTask, NSError *error) {
                weakSelf.msgModal.msgState = CDMessageStateDownloadFaild;
                [SystemUtil removeDocmentFilePath:filePath];
                [weakSelf.tableView updateMessage:weakSelf.msgModal];
#ifdef DEBUG
                NSLog(@"[CDChatList] 下载文件出现问题%@",error.localizedDescription);
#endif
            }];
        } else {
            if (self.msgModal.isGroup) {
                
                [SendRequestUtil sendToxPullFileWithFromId:self.msgModal.ToId toid:[UserConfig getShareObject].userId fileName:[Base58Util Base58EncodeWithCodeName:self.msgModal.fileName] msgId:self.msgModal.messageId fileOwer:@"5" fileFrom:@"1"];
                
            } else if (self.msgModal.isLeft) {
                [SendRequestUtil sendToxPullFileWithFromId:self.msgModal.FromId toid:self.msgModal.ToId fileName:[Base58Util Base58EncodeWithCodeName:self.msgModal.fileName] msgId:self.msgModal.messageId fileOwer:@"2" fileFrom:@"1"];
            } else {
                [SendRequestUtil sendToxPullFileWithFromId:self.msgModal.ToId toid:self.msgModal.FromId fileName:[Base58Util Base58EncodeWithCodeName:self.msgModal.fileName] msgId:self.msgModal.messageId fileOwer:@"1" fileFrom:@"1"];
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
