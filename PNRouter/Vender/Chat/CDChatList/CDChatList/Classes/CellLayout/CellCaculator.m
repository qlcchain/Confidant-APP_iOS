//
//  CellCaculator.m
//  CDChatList
//
//  Created by chdo on 2017/10/26.
//

#import "CellCaculator.h"
#import "ChatMacros.h"
#import "CDBaseMsgCell.h"
#import "CTData.h"
#import "ChatHelpr.h"
#import "UITool.h"
#import <AVFoundation/AVFoundation.h>
#import "SDImageCache+ChatCaculator.h"
#import "SystemUtil.h"
#import "RequestService.h"
#import "NSData+Base64.h"
#import "AESCipher.h"
#import "RSAUtil.h"

@interface CellCaculator()

@end

@implementation CellCaculator

-(instancetype)init{
    self = [super init];
    self.calcuGroup = dispatch_group_create();
    self.serialQueue = dispatch_queue_create("cdchatlist_serialQueue_CellCaculator",DISPATCH_QUEUE_SERIAL);
    return self;
}

-(void)caculatorAllCellHeight: (CDChatMessageArray)msgArr
         callBackOnMainThread: (void(^)(CGFloat))completeBlock{
    
    for (int i = 0; i < msgArr.count; i++) {
        dispatch_async(self.serialQueue, ^{
            [self fetchCellHeight:i of:msgArr];
        });
    }
    
    dispatch_async(self.serialQueue, ^{
        // 总共高度
        CGFloat totalHeight = 0.0f;
        for (CDChatMessage msg in msgArr) {
            totalHeight = totalHeight + msg.cellHeight;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
           completeBlock(totalHeight);
        });
    });
}

//TODO: 获取cell的高度方式
-(CGFloat)fetchCellHeight:(NSUInteger)index of:(CDChatMessageArray)msgArr{
    
    CDChatMessage data = msgArr[index];
    // 返回缓存中的高度
    // cell的高度会被保存，textlayout 目前还没有保存方案，
    if (data.cellHeight && data.textlayout) {
        return data.cellHeight;
    }
    
    // 检查消息data中是否含有气泡配置
    data.chatConfig = data.chatConfig ?: [[ChatConfiguration alloc] init];
    data.ctDataconfig = data.ctDataconfig.textSize == 0 ? [CTData defaultConfig] : data.ctDataconfig;
    
    
    //     计算高度
    // 和上一条信息对比判断cell上是否显示时间label
    if (index > 0) {
        CDChatMessage previousData = msgArr[index - 1];
        NSInteger lastTime = previousData.TimeStatmp;
        NSInteger currentTime = data.TimeStatmp;
        data.willDisplayTime = (labs(currentTime - lastTime) > 180); // 3分钟
    } else {
        data.willDisplayTime = YES;
    }
    data.chatConfig.messageMarginBottomOfTime = data.willDisplayTime?chatMessageMarginBottomOfTime:0;
    CGSize res = [self caculateCellHeightAndBubleWidth:data];
    
    // 记录 缓存
    data.bubbleWidth = res.width;
    
    // 加上可能显示的时间视图高度
    CGFloat height = res.height;
    
    data.cellHeight = height + (data.willDisplayTime ? (data.msgType != CDMessageTypeSystemInfo ? data.chatConfig.msgTimeH : 0) : 0);
    
    // 加上可能显示的昵称高度
    if (data.userName.length > 0) {
        data.cellHeight = data.cellHeight + data.chatConfig.nickNameHeight;
    }
    
    return data.cellHeight;
//    CGFloat nameHeight = data.userName.length == 0?0:data.chatConfig.nickNameHeight;
//    CGFloat extra = data.willDisplayTime?0:data.chatConfig.messageMarginBottomOfTime;
//    data.cellHeight = data.cellHeight - extra;
//    return data.cellHeight;
}

#pragma mark 针对不同的cell，计算cell高度及气泡宽度

/**
 针对不同的cell，计算cell高度及气泡宽度
 
 @param data 消息模型
 @return cell高度
 */
-(CGSize)caculateCellHeightAndBubleWidth:(CDChatMessage)data{
    switch (data.msgType) {
        case CDMessageTypeText:
            return [self sizeForTextMessage:data];
        case CDMessageTypeImage:
            return [self sizeForImageMessage:data];
        case CDMessageTypeSystemInfo:
            return [self sizeForSysInfoMessage:data];
        case CDMessageTypeAudio:
            return [self sizeForAudioMessage:data];
        case CDMessageTypeMedia:
            return [self sizeForMediaMessage:data];
        case CDMessageTypeFile:
            return CGSizeMake(200,75+data.chatConfig.messageMarginBottomOfTime);
        case CDMessageTypeCustome:
            if ([self.list.msgDelegate respondsToSelector:@selector(chatlistSizeForMsg:ofList:)]) {
                return [self.list.msgDelegate chatlistSizeForMsg:data ofList:self.list];
            } else {
                return CGSizeMake(150, 170);
            }
        default:
            return CGSizeMake(150, 170);
    }
}


#pragma mark ---计算文字消息尺寸方法
-(CGSize) sizeForTextMessage:(CDChatMessage)msgData{
    
    NSMutableAttributedString *msg_attributeText;
    
    if (msgData.msg) {
        msg_attributeText = [[NSMutableAttributedString alloc] initWithString: msgData.msg];
    }else{
        msg_attributeText = [[NSMutableAttributedString alloc] initWithString: @" "];
    }
    
    // 文字的限制区域，红色部分
    CGSize maxTextSize = CGSizeMake(msgData.chatConfig.bubbleMaxWidth - msgData.chatConfig.bubbleSharpAnglehorizInset - msgData.chatConfig.bubbleRoundAnglehorizInset,
                                    CGFLOAT_MAX);
    
    CTData *data = [CTData dataWithStr:msgData.msg
                     containerWithSize:maxTextSize
                         configuration:msgData.ctDataconfig];
    
    msgData.textlayout = data;
    
    // 计算气泡宽度
    CGFloat bubbleWidth = ceilf(data.width) + msgData.chatConfig.bubbleSharpAnglehorizInset + msgData.chatConfig.bubbleRoundAnglehorizInset;
    // 计算整个cell高度
    CGFloat cellheight = ceilf(data.height) + msgData.chatConfig.bubbleRoundAnglehorizInset * 2 + msgData.chatConfig.messageMarginBottomOfTime + msgData.chatConfig.messageMarginBottom;
    
    // 如果 cellheight小于最小cell高度
    if (cellheight < msgData.chatConfig.messageContentH) {
        cellheight = msgData.chatConfig.messageContentH;
    }
    if (msgData.msgType == CDMessageTypeText && msgData.isLeft == NO) {
        cellheight += 10;
    }
    return CGSizeMake(bubbleWidth, cellheight);
}

#pragma mark ---计算图片消息尺寸方法

/**
 根据图片大小计算气泡宽度和cell高度
 */
CGSize caculateImageSize140By140(UIImage *image, CDChatMessage msgData) {
    
    // 图片将被限制在140*140的区域内，按比例显示
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    
    CGFloat maxSide = MAX(width, height);
    CGFloat miniSide = MIN(width, height);
    
    // 按比例缩小后的小边边长
    CGFloat actuallMiniSide = 140 * miniSide / maxSide;
    
    // 防止长图，宽图，限制最小边 下限
    if (actuallMiniSide < 80) {
        actuallMiniSide = 80;
    }
    
    // 返回的高度是图片高度，需加上消息内边距变成消息体高度
    if (maxSide == width) {
        return CGSizeMake(140, actuallMiniSide + msgData.chatConfig.messageMarginBottom + msgData.chatConfig.messageMarginBottomOfTime);
    } else {
        return CGSizeMake(actuallMiniSide, 140 + msgData.chatConfig.messageMarginBottom + msgData.chatConfig.messageMarginBottomOfTime);
    }
}

CGSize caculateFileSize140By140(CGSize size, CDChatMessage msgData) {
    
    // 图片将被限制在140*140的区域内，按比例显示
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    CGFloat maxSide = MAX(width, height);
    CGFloat miniSide = MIN(width, height);
    
    // 按比例缩小后的小边边长
    CGFloat actuallMiniSide = 140 * miniSide / maxSide;
    
    // 防止长图，宽图，限制最小边 下限
    if (actuallMiniSide < 80) {
        actuallMiniSide = 80;
    }
    
    // 返回的高度是图片高度，需加上消息内边距变成消息体高度
    if (maxSide == width) {
        return CGSizeMake(140, actuallMiniSide + msgData.chatConfig.messageMarginBottom +msgData.chatConfig.messageMarginBottomOfTime);
    } else {
        return CGSizeMake(actuallMiniSide, 140 + msgData.chatConfig.messageMarginBottom + msgData.chatConfig.messageMarginBottomOfTime);
    }
}


-(CGSize) sizeForImageMessage: (CDChatMessage)msgData {
    
    // 获得本地缓存的图片
//    NSString *friendid = msgData.ToId;
//    if (msgData.isLeft) {
//        friendid = msgData.FromId;
//    }
//    NSString *filePath = [[SystemUtil getBaseFilePath:friendid] stringByAppendingPathComponent:msgData.fileName];
//    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
//    UIImage *image = nil;
//    if (fileData) {
//        image = [UIImage imageWithData:fileData];
//    }
    // 如果本地存在图片，则通过图片计算
//    if (image) {
//        return caculateImageSize140By140(image,msgData);
//    } else {
//
//        CGSize defaulutSize = CGSizeMake(140, 140);
//        return defaulutSize;
//    }
    
    if (msgData.fileWidth > 0 && msgData.fileHeight > 0) {
        return caculateFileSize140By140(CGSizeMake(msgData.fileWidth, msgData.fileHeight),msgData);
    } else {
        CGSize defaulutSize = CGSizeMake(140, 140);
        return defaulutSize;
    }
    
}
#pragma mark -视频size
- (CGSize) sizeForMediaMessage: (CDChatMessage)msgData {
    
    CGSize defaulutSize = CGSizeMake(140, 140);
    if (msgData.mediaImage) {
        return caculateImageSize140By140(msgData.mediaImage,msgData);
    }
    return defaulutSize;
    
//    NSString *filePath = [[SystemUtil getBaseFilePath:friendid] stringByAppendingPathComponent:msgData.fileName];
//    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
//    NSData *fileData = [NSData dataWithContentsOfURL:fileURL];
//    
//    if (fileData) {
//         UIImage *image = [SystemUtil thumbnailImageForVideo:fileURL];
//        if (image) {
//             msgData.mediaImage = image;
//            return caculateImageSize140By140(image,msgData);
//        } else {
//            return  defaulutSize;
//        }
//    } else {
//        if (msgData.mediaImage) {
//            return caculateImageSize140By140(msgData.mediaImage,msgData);
//        }
//        NSString *requestUrl = [NSString stringWithFormat:@"%@%@",RequestService.getPrefixUrl,msgData.filePath];
//        NSURL *url = [NSURL URLWithString:requestUrl];
//        @weakify_self
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//           UIImage *imgage = [SystemUtil thumbnailImageForVideo:url];
//            if (imgage) {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    msgData.mediaImage = imgage;
//                    [weakSelf.list updateMessage:msgData];
//                });
//            }
//        });
//        return defaulutSize;
//    }
}

#pragma mark ---计算系统消息消息尺寸方法
-(CGSize)sizeForSysInfoMessage:(CDChatMessage)msgData{
    NSDictionary *attri = @{NSFontAttributeName: msgData.chatConfig.sysInfoMessageFont};
    CGSize maxTextSize = CGSizeMake(msgData.chatConfig.sysInfoMessageMaxWidth, CGFLOAT_MAX);
    CGSize caculateTextSize = [msgData.msg boundingRectWithSize: maxTextSize
                                                        options: NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                                     attributes:attri context:nil].size;
    CGFloat height = caculateTextSize.height + msgData.chatConfig.sysInfoPadding * 2;
    return CGSizeMake(caculateTextSize.width + msgData.chatConfig.sysInfoPadding * 2 + 10, height);
}
#pragma mark ---计算音频消息消息尺寸方法

CGSize caculateAudioCellSize(CDChatMessage msg, NSString *path) {
    
    // 以后这里需要从内存中获取data， 需要改
    AVURLAsset *audioAsset=[AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    CMTime durationTime = audioAsset.duration;
    float reultTime = [[NSString stringWithFormat:@"%.2f",CMTimeGetSeconds(durationTime)] floatValue];
    float audioTimeinSecs = ceilf(reultTime);
    // res: 0.5...1 ,  从0.5 趋近于 1, 在audioTimeinSecs = 14秒左右res到达1 调整2.71828可控制速度
    float res = (1 / (0.14 + (pow(1.71828, -audioTimeinSecs))));
    msg.audioTime = audioTimeinSecs;
    
    msg.audioTime = msg.audioTime > 0 ? msg.audioTime : 1;
    return CGSizeMake(cd_ScreenW() * 0.015 + res * 22, msg.chatConfig.messageContentH);
}

#pragma mark ---计算音频消息消息尺寸方法
-(CGSize)sizeForAudioMessage:(CDChatMessage)msgData{
    
    //     从内存取消息音频  因为AVURLAsset无法从data初始化，先不读取内存
    //    NSData *data = (NSData *)[[AATImageCache sharedImageCache] imageFromMemoryCacheForKey:msgData.messageId];
    
    //  从本地取消息音频,如果是自己发的会通过messageId缓存
    // 获得本地缓存的图片
    if (msgData.fileHeight > 0 && msgData.fileWidth > 0) {
     // CGFloat height =  msgData.fileHeight + (msgData.willDisplayTime ? msgData.chatConfig.msgTimeH : 0);
        return CGSizeMake(msgData.fileWidth, msgData.fileHeight);
    }
    NSString *friendid = msgData.ToId;
    NSString *msgkey = msgData.srckey;
    if (msgData.isLeft && !msgData.isGroup) {
        friendid = msgData.FromId;
        msgkey = msgData.dskey;
    }
    NSString *filePath = [[SystemUtil getBaseFilePath:friendid] stringByAppendingPathComponent:msgData.fileName];
    
    if ([SystemUtil filePathisExist:filePath]) {
        
        CGSize size = caculateAudioCellSize(msgData,filePath);
        if (msgData.audioTime == 1) {
            CGSize defaulutSize = CGSizeMake(50, msgData.chatConfig.messageContentH);
            return defaulutSize;
        }
        msgData.bubbleWidth = size.width;
        // 加上可能显示的时间视图高度
        CGFloat height = size.height;
        msgData.fileHeight = height;
        msgData.fileWidth = size.width;
        msgData.cellHeight = height + (msgData.willDisplayTime ? msgData.chatConfig.msgTimeH : 0);
        return size;
    } else {
        CGSize defaulutSize = CGSizeMake(50, msgData.chatConfig.messageContentH);
        return defaulutSize;
        
    }
    
    /*
    NSString *key = [NSString stringWithFormat:@"%@.%@",msgData.messageId, msgData.audioSufix];
    NSString *path = [[SDImageCache sharedImageCache] defaultCachePathForKey:key];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wundeclared-selector"
    NSData *data = [[SDImageCache sharedImageCache] performSelector:@selector(diskImageDataBySearchingAllPathsForKey:) withObject:key];
    // 通过msg取缓存
    if (!data) {
        path = [[SDImageCache sharedImageCache] defaultCachePathForKey:msgData.msg];
        
        data = [[SDImageCache sharedImageCache] performSelector:@selector(diskImageDataBySearchingAllPathsForKey:) withObject:msgData.msg];
    }
#pragma clang diagnostic pop
    
    if (data) {
        return caculateAudioCellSize(msgData,path);
    } else {
        
        CGSize defaulutSize = CGSizeMake(cd_ScreenW() * 0.4, msgData.chatConfig.messageContentH);
        if (msgData.msgState == CDMessageStateDownloading) {
            return defaulutSize;
        }
        // 若不存在，则返回占位图大小，并下载
        if (msgData.msgState != CDMessageStateSendFaild) {
            msgData.msgState = CDMessageStateDownloading;
        }
        __weak typeof(self) ws = self;
        [[[NSURLSession sharedSession] downloadTaskWithURL:[NSURL URLWithString:msgData.msg] completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            if(error){
                msgData.msgState = CDMessageStateDownloadFaild;
                [ws.list updateMessage:msgData];
#ifdef DEBUG
                NSLog(@"[CDChatList] 下载音频出现问题%@",error.localizedDescription);
#endif
            } else {
                
                NSData *data = [NSData dataWithContentsOfURL:location];
                CGSize size = caculateAudioCellSize(msgData,location.absoluteString);
                
                [[SDImageCache sharedImageCache] cd_storeImageData:data forKey:msgData.msg toDisk:YES completion:^{
                    
                }];
                msgData.bubbleWidth = size.width;
                // 加上可能显示的时间视图高度
                CGFloat height = size.height;
                msgData.cellHeight = height + (msgData.willDisplayTime ? msgData.chatConfig.msgTimeH : 0);
                msgData.msgState = CDMessageStateNormal;
                [ws.list updateMessage:msgData];
            }
        }] resume];
        
        return CGSizeMake(cd_ScreenW() * 0.4, msgData.chatConfig.messageContentH);
    }*/
    
    return CGSizeMake(cd_ScreenW() * 0.3, msgData.chatConfig.messageContentH);
}

@end


