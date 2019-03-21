//
//  CDFileTableViewCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/10/17.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "CDFileTableViewCell.h"
#import "SystemUtil.h"
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

@interface CDFileTableViewCell()
@property (nonatomic ,strong) UIImageView *file_leftImgView;
@property (nonatomic ,strong) UILabel *file_leftName;
@property (nonatomic ,strong) UILabel *file_leftSize;

@property (nonatomic ,strong) UIImageView *file_rightImgView;
@property (nonatomic ,strong) UILabel *file_rightName;
@property (nonatomic ,strong) UILabel *file_rightSize;

@property(nonatomic, strong) UIGestureRecognizer *longPressRecognizer;

@end

@implementation CDFileTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.bubbleImage_left addGestureRecognizer:tap];
    [self.bubbleImage_right addGestureRecognizer:tap2];
    self.bubbleImage_right.userInteractionEnabled = YES;
    self.bubbleImage_left.userInteractionEnabled = YES;
    
    _longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGes:)];
    [self addGestureRecognizer:_longPressRecognizer];
    return self;
}
#pragma mark -layz
- (UIImageView *)file_leftImgView
{
    if (!_file_leftImgView) {
        _file_leftImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    }
    return _file_leftImgView;
}

- (UILabel *) file_leftName
{
    if (!_file_leftName) {
        _file_leftName = [[UILabel alloc] init];
        _file_leftName.textColor = MAIN_PURPLE_COLOR;
        _file_leftName.font = [UIFont systemFontOfSize:15];
        _file_leftName.textAlignment = NSTextAlignmentLeft;
        _file_leftName.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _file_leftName;
}

- (UILabel *) file_leftSize
{
    if (!_file_leftSize) {
        _file_leftSize = [[UILabel alloc] init];
        _file_leftSize.textColor = [UIColor lightGrayColor];
        _file_leftSize.font = [UIFont systemFontOfSize:12];
        _file_leftSize.textAlignment = NSTextAlignmentLeft;
    }
    return _file_leftSize;
}

- (UIImageView *)file_rightImgView
{
    if (!_file_rightImgView) {
        
        _file_rightImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0,35, 35)];
    }
    return _file_rightImgView;
}

- (UILabel *) file_rightName
{
    if (!_file_rightName) {
        _file_rightName = [[UILabel alloc] init];
        _file_rightName.textColor = [UIColor whiteColor];
        _file_rightName.font = [UIFont systemFontOfSize:15];
        _file_rightName.textAlignment = NSTextAlignmentLeft;
        _file_rightName.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    return _file_rightName;
}

- (UILabel *) file_rightSize
{
    if (!_file_rightSize) {
        _file_rightSize = [[UILabel alloc] init];
        _file_rightSize.textColor = [UIColor lightGrayColor];
        _file_rightSize.font = [UIFont systemFontOfSize:12];
        _file_rightSize.textAlignment = NSTextAlignmentLeft;
    }
    return _file_rightSize;
}

- (void)configCellByData:(CDChatMessage)data table:(CDChatListView *)table
{
    [super configCellByData:data table:table];
    if (data.isLeft) {
        // 左侧
        //     设置消息内容, 并调整UI
        [self configFile_Left:data];
    } else {
        // 右侧
        //     设置消息内容, 并调整UI
        [self configFile_Right:data];
    }
}

- (void) configFile_Left:(CDChatMessage) data
{
    NSString *fileType = [[data.fileName componentsSeparatedByString:@"."] lastObject];
    UIImage *img = [UIImage imageNamed:[fileType stringByAppendingString:@""]];
    if (!img) {
        img = [UIImage imageNamed:@"Other"];
    }
    self.file_leftImgView.image = img;
    CGRect fileRect = self.file_leftImgView.frame;
    
    if (!self.file_leftImgView.superview) {
        [self.bubbleImage_left addSubview:self.file_leftImgView];
    }
    NSLog(@"bubbleImage_right_frame = %@",NSStringFromCGRect(self.bubbleImage_left.frame));
    fileRect.origin = CGPointMake(data.chatConfig.bubbleRoundAnglehorizInset, data.chatConfig.bubbleRoundAnglehorizInset);
    
    NSLog(@"fileRect_frame = %@",NSStringFromCGRect(fileRect));
    self.file_leftImgView.frame = fileRect;
    
    if (!self.file_leftName.superview) {
        [self.bubbleImage_left addSubview:self.file_leftName];
    }
    self.file_leftName.text = data.fileName;
    self.file_leftName.frame = CGRectMake(CGRectGetMaxX(self.file_leftImgView.frame)+10, CGRectGetMinY(self.file_leftImgView.frame), self.bubbleImage_left.frame.size.width-80, 20);
    
    if (!self.file_leftSize.superview) {
        [self.bubbleImage_left addSubview:self.file_leftSize];
    }
    self.file_leftSize.text = [SystemUtil transformedValue:data.fileSize];
    self.file_leftSize.frame = CGRectMake(CGRectGetMinX(self.file_leftName.frame), CGRectGetMaxY(self.file_leftName.frame), CGRectGetWidth(self.file_leftName.frame), 15);

}
- (void) configFile_Right:(CDChatMessage) data
{
    NSString *fileType = [[data.fileName componentsSeparatedByString:@"."] lastObject];
    UIImage *img = [UIImage imageNamed:[fileType stringByAppendingString:@""]];
    if (!img) {
        img = [UIImage imageNamed:@"Other"];
    }
    self.file_rightImgView.image = img;
    CGRect fileRect = self.file_rightImgView.frame;

    if (!self.file_rightImgView.superview) {
        [self.bubbleImage_right addSubview:self.file_rightImgView];
    }
    NSLog(@"bubbleImage_right_frame = %@",NSStringFromCGRect(self.bubbleImage_right.frame));
    fileRect.origin = CGPointMake(data.chatConfig.bubbleRoundAnglehorizInset, data.chatConfig.bubbleRoundAnglehorizInset);

    NSLog(@"fileRect_frame = %@",NSStringFromCGRect(fileRect));
    self.file_rightImgView.frame = fileRect;
    
    if (!self.file_rightName.superview) {
        [self.bubbleImage_right addSubview:self.file_rightName];
    }
    self.file_rightName.text = data.fileName;
    self.file_rightName.frame = CGRectMake(CGRectGetMaxX(self.file_rightImgView.frame)+10, CGRectGetMinY(self.file_rightImgView.frame), self.bubbleImage_right.frame.size.width-80, 20);
    
    if (!self.file_rightSize.superview) {
        [self.bubbleImage_right addSubview:self.file_rightSize];
    }
    self.file_rightSize.text = [SystemUtil transformedValue:data.fileSize];
    self.file_rightSize.frame = CGRectMake(CGRectGetMinX(self.file_rightName.frame), CGRectGetMaxY(self.file_rightName.frame), CGRectGetWidth(self.file_rightName.frame), 15);
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
                    [self showMenuWithItemX:_file_leftImgView.frame.size.width/2];
                } else {
                    [self showMenuWithItemX:_file_rightImgView.frame.size.width/2];
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
    
    // 正在下载不能点击
    if (self.msgModal.msgState == CDMessageStateDownloading) {
        return;
    }
    if (self.msgModal.msgState == CDMessageStateSendFaild) {
        // 重新发送
        self.msgModal.msgState = CDMessageStateSending;
        [self.tableView updateMessage:self.msgModal];
        NSString *filePath = [[SystemUtil getBaseFilePath:self.msgModal.ToId] stringByAppendingPathComponent:self.msgModal.fileName];
        NSData *fileData = [NSData dataWithContentsOfFile:filePath];
        
        // 生成32位对称密钥
        NSString *msgKey = [SystemUtil getDoc32AESKey];
        NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
        NSString *symmetKey = [symmetData base64EncodedString];
        // 好友公钥加密对称密钥
        NSString *dsKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:self.msgModal.publicKey];
        // 自己公钥加密对称密钥
        NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
        
        NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
        fileData = aesEncryptData(fileData,msgKeyData);
        
        if ([SystemUtil isSocketConnect]) {
            
            SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
            [dataUtil sendFileId:self.msgModal.ToId fileName:[self.msgModal.fileName base64EncodedString] fileData:fileData fileid:self.msgModal.fileID fileType:5 messageid:self.msgModal.messageId srcKey:srcKey dstKey:dsKey isGroup:NO];
            [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
            
        } else {
            
            NSString *dataPath = [[SystemUtil getTempBaseFilePath:self.msgModal.ToId] stringByAppendingPathComponent:[Base58Util Base58EncodeWithCodeName:self.msgModal.fileName]];
            
            if ([fileData writeToFile:dataPath atomically:YES]) {
                
                NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":self.msgModal.FromId,@"ToId":self.msgModal.ToId,@"FileName":[Base58Util Base58EncodeWithCodeName:self.msgModal.fileName],@"FileMD5":[MD5Util md5WithPath:dataPath],@"FileSize":@(fileData.length),@"FileType":@(self.msgModal.msgType),@"SrcKey":srcKey,@"DstKey":dsKey,@"FileId":self.msgModal.messageId};
                [SendToxRequestUtil sendFileWithFilePath:dataPath parames:parames];
            }
        }
        
        return;
    }
    
   
    
    NSString *friendid = self.msgModal.ToId;
    NSString *msgkey = self.msgModal.srckey;
    if (self.msgModal.isLeft && !self.msgModal.isGroup) {
        friendid = self.msgModal.FromId;
        msgkey = self.msgModal.dskey;
    }
    NSString *filePath = [[SystemUtil getBaseFilePath:friendid] stringByAppendingPathComponent:self.msgModal.fileName];
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    if (fileData) {
        if (self.tableView.msgDelegate) {
            [self.tableView.msgDelegate clickFileCellWithMsgMode:self.msgModal withFilePath:filePath];
        }
    } else {
        if (self.msgModal.msgState == CDMessageStateSending) {
            return;
        }
        self.msgModal.msgState = CDMessageStateDownloading;
        [self.tableView updateMessage:self.msgModal];
        
        @weakify_self
        if ([SystemUtil isSocketConnect]) {
            [RequestService downFileWithBaseURLStr:self.msgModal.filePath friendid:friendid progressBlock:^(CGFloat progress) {
                
            } success:^(NSURLSessionDownloadTask *dataTask , NSString *filePath) {
                
                NSString *path = [[SystemUtil getBaseFilePath:friendid] stringByAppendingPathComponent:filePath];
                
                if ([[MD5Util md5WithPath:path] isEqualToString:[NSString getNotNullValue:weakSelf.msgModal.fileMd5]]) {
                    
                    NSData *data = [NSData dataWithContentsOfFile:path];
                    if (msgkey) {
                        NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:msgkey];
                        datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
                        if (datakey && ![datakey isEmptyString]) {
                            data = aesDecryptData(data, [datakey dataUsingEncoding:NSUTF8StringEncoding]);
                            [SystemUtil removeDocmentFilePath:path];
                            [data writeToFile:path atomically:YES];
                            weakSelf.msgModal.msgState = CDMessageStateNormal;
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
            if (self.msgModal.isLeft) {
                [SendRequestUtil sendToxPullFileWithFromId:self.msgModal.FromId toid:self.msgModal.ToId fileName:[Base58Util Base58EncodeWithCodeName:self.msgModal.fileName] msgId:self.msgModal.messageId fileOwer:@"2" fileFrom:@"1"];
            } else {
                [SendRequestUtil sendToxPullFileWithFromId:self.msgModal.ToId toid:self.msgModal.FromId fileName:[Base58Util Base58EncodeWithCodeName:self.msgModal.fileName] msgId:self.msgModal.messageId fileOwer:@"1" fileFrom:@"1"];
            }
            
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
