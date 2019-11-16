//
//  EmailAttchView.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/29.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EmailAttchView.h"
#import "AttchCollectionCell.h"
#import "AttchImgageCell.h"
#import "EmailAttchModel.h"
#import "SystemUtil.h"
#import "HeadReusableView.h"
#import "AESCipher.h"

#import <GoogleSignIn/GoogleSignIn.h>
#import "NSString+Base64.h"
#import "GoogleServerManage.h"
#import "EmailAccountModel.h"
#import <GoogleAPIClientForREST/GTLRBase64.h>
#import "NSData+UTF8.h"

@interface EmailAttchView ()<UICollectionViewDelegate,UICollectionViewDataSource>

@end

@implementation EmailAttchView

- (NSMutableArray *)attchArray
{
    if (!_attchArray) {
        _attchArray = [NSMutableArray array];
    }
    return _attchArray;
}

- (void) setAttchs:(NSArray *) atts deKey:(nonnull NSString *)deKey
{
    self.deKey = deKey;
    if (self.attchArray.count == 0) {
        [self.attchArray addObjectsFromArray:atts];
    } else {
        [self.attchArray removeAllObjects];
        [self.attchArray addObjectsFromArray:atts];
    }
    [self.collectionV reloadData];
}
- (void)awakeFromNib
{
    
    [_collectionV registerNib:[UINib nibWithNibName:AttchCollectionCellResue bundle:nil] forCellWithReuseIdentifier:AttchCollectionCellResue];
    [_collectionV registerNib:[UINib nibWithNibName:AttchImgageCellResue bundle:nil] forCellWithReuseIdentifier:AttchImgageCellResue];
    [_collectionV registerNib:[UINib nibWithNibName:HeadReusableViewResue bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeadReusableViewResue];
    
    _collectionV.delegate = self;
    _collectionV.dataSource = self;
     [super awakeFromNib];
}

#pragma mark - UICollectionViewDelegate,UICollectionViewDataSource
/**
 分区个数
 */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
/**
 每个分区item的个数
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.attchArray.count;
}
/**
 创建cell
 */
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    EmailAttchModel*attachment = self.attchArray[indexPath.item];
    
    NSString *fileHz = [[attachment.attName componentsSeparatedByString:@"."] lastObject];
    if ([fileHz isEqualToString:@"webp"] || [fileHz isEqualToString:@"bmp"] || [fileHz isEqualToString:@"jpg"] || [fileHz isEqualToString:@"png"] || [fileHz isEqualToString:@"tif"] || [fileHz isEqualToString:@"jpeg"]) {
        
        AttchImgageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AttchImgageCellResue forIndexPath:indexPath];
        
       
        if (attachment.attSize > 0) {
            cell.lblCount.text = [SystemUtil transformedValue:attachment.attSize];
        } else {
            cell.lblCount.text = [SystemUtil transformedValue:attachment.attData.length];
        }
        
        if (attachment.attData) {
            attachment.downStatus = 2;
            [cell.loadActivity stopAnimating];
            cell.loadActivity.hidden = YES;
            if (self.deKey && self.deKey.length > 0) {
                NSData *imgData = aesDecryptData(attachment.attData, [self.deKey dataUsingEncoding:NSUTF8StringEncoding]);
                cell.headImgV.image = [UIImage imageWithData:imgData];
                
            } else {
                cell.headImgV.image = [UIImage imageWithData:attachment.attData];
            }
            
        } else {
            if (attachment.attSize > 0) {
                
                if (attachment.downStatus == 2) { // 下载完成
                    [cell.loadActivity stopAnimating];
                    cell.loadActivity.hidden = YES;
                } else if (attachment.downStatus == 1){ // 下载中
                    [cell.loadActivity startAnimating];
                    cell.loadActivity.hidden = NO;
                } else {
                    [cell.loadActivity startAnimating];
                    cell.loadActivity.hidden = NO;
                    
                    attachment.downStatus = 1;
                    
                    [self getAttDataWithAttM:attachment];
                }
            }
        }
        
        
        return cell;
    } else {
        
        AttchCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AttchCollectionCellResue forIndexPath:indexPath];
        
        if (attachment.attData) {
            attachment.downStatus = 2;
            [cell.loadActivity stopAnimating];
            cell.loadActivity.hidden = YES;
        } else {
            if (attachment.downStatus == 2) { // 下载完成
                [cell.loadActivity stopAnimating];
                cell.loadActivity.hidden = YES;
            } else if (attachment.downStatus == 1){ // 下载中
                [cell.loadActivity startAnimating];
                cell.loadActivity.hidden = NO;
            } else {
                [cell.loadActivity startAnimating];
                cell.loadActivity.hidden = NO;
                
                attachment.downStatus = 1;
                
                [self getAttDataWithAttM:attachment];
            }
        }
        
        cell.lblName.text = attachment.attName;
        NSArray *names = [attachment.attName componentsSeparatedByString:@"."];
        if (names && names.count>1) {
            NSString *typeName = [names lastObject];
            if ([typeName containsString:@"doc"]) {
                cell.headImgV.image = [UIImage imageNamed:@"doc"];
            } else if ([typeName containsString:@"txt"]) {
                cell.headImgV.image = [UIImage imageNamed:@"txt"];
            } else if ([typeName containsString:@"ppt"]) {
                cell.headImgV.image = [UIImage imageNamed:@"ppt"];
            } else if ([typeName containsString:@"pdf"]) {
                cell.headImgV.image = [UIImage imageNamed:@"pdf"];
            } else if ([typeName containsString:@"zip"] || [typeName containsString:@"rar"]) {
                cell.headImgV.image = [UIImage imageNamed:@"zip"];
            } else if ([typeName containsString:@"xls"]) {
                cell.headImgV.image = [UIImage imageNamed:@"xls"];
            } else if ([typeName containsString:@"text"]) {
                cell.headImgV.image = [UIImage imageNamed:@"text"];
            } else if ([typeName containsString:@"mp3"]) {
                cell.headImgV.image = [UIImage imageNamed:@"mp3"];
            } else {
                NSArray *mvs = @[@"AVI",@"WMV",@"RM",@"RMVB",@"MPEG1",@"MPEG2",@"MPEG4",@"MP4",@"3GP",@"ASF",@"SWF",@"VOB",@"DAT",@"MOV",@"M4V",@"FLV",@"F4V",@"MKV",@"MTS",@"TS"];
                if ([mvs containsObject:typeName]) {
                    cell.headImgV.image = [UIImage imageNamed:@"mp4"];
                } else {
                    cell.headImgV.image = [UIImage imageNamed:@"other"];
                }
            }
        } else {
            cell.headImgV.image = [UIImage imageNamed:@"other"];
        }
        
        if (attachment.attSize > 0) {
            cell.lblCount.text = [SystemUtil transformedValue:attachment.attSize];
        } else {
            cell.lblCount.text = [SystemUtil transformedValue:attachment.attData.length];
        }
        
        return cell;
    }
    
}


/**
 点击某个cell
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击了第%ld分item",(long)indexPath.item);
    EmailAttchModel*attachment = self.attchArray[indexPath.item];
    if (attachment.attData) {
        if (_clickAttBlock) {
            _clickAttBlock(indexPath.item);
        }
    } else {
        if (attachment.downStatus == 2) {
            attachment.downStatus = 1;
            [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            [self getAttDataWithAttM:attachment];
        }
    }
}
/**
 cell的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat itemW = (SCREEN_WIDTH-32-4)/2;
    CGFloat itemH = itemW*(128.0/170);
    return CGSizeMake(itemW,itemH);
}

/**
 分区内cell之间的最小行间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 4;
}
/**
 分区内cell之间的最小列间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 4;
}

/**
 创建区头视图和区尾视图
 */
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    if (kind == UICollectionElementKindSectionHeader){
        HeadReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HeadReusableViewResue forIndexPath:indexPath];
        return headerView;
    }
    return nil;
}

/**
 区头大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH-32,HeadReusableViewHeight);
}


// googleapi get 附件
- (void) getAttDataWithAttM:(EmailAttchModel *) attM
{
    
    
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    
    //获取文件路径
    NSString *tmpDirectory =NSTemporaryDirectory();
    NSString *filePath=[tmpDirectory stringByAppendingPathComponent:attM.attName];
    NSFileManager *fileManger=[NSFileManager defaultManager];
    
    if (![fileManger fileExistsAtPath:filePath]) {//不存在就去请求加载
        
        GTLRGmailQuery_UsersMessagesAttachmentsGet *list = [GTLRGmailQuery_UsersMessagesAttachmentsGet queryWithUserId:accountM.userId messageId:self.messageId identifier:attM.attId];
        @weakify_self
        [[GoogleServerManage getGoogleServerManageShare].gmailService executeQuery:list completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
            attM.downStatus = 2;
            if (!callbackError) {
                GTLRObject *gltM = object;
                NSString *dataStr = gltM.JSON[@"data"]?:@"";
                if (dataStr.length > 0) {
                    NSData *contentData = GTLRDecodeWebSafeBase64(dataStr);
                    attM.attData = contentData;
                    [weakSelf.collectionV reloadData];
                    // 保存到本地
                    [attM.attData writeToFile:filePath atomically:YES];
                }
            } else {
                [weakSelf.collectionV reloadData];
            }
        }];
        
    } else {
        attM.downStatus = 2;
        attM.attData = [NSData dataWithContentsOfFile:filePath];
       [self.collectionV reloadData];
    }

}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
