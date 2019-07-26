//
//  EmailAttchCell.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/15.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "EmailAttchCell.h"
#import "AttchCollectionCell.h"
#import "AttchImgageCell.h"
#import "EmailAttchModel.h"
#import "SystemUtil.h"
#import "HeadReusableView.h"


@interface EmailAttchCell ()<UICollectionViewDelegate,UICollectionViewDataSource>

@end

@implementation EmailAttchCell

- (NSMutableArray *)attchArray
{
    if (!_attchArray) {
        _attchArray = [NSMutableArray array];
    }
    return _attchArray;
}

- (void) setAttchs:(NSArray *) atts
{
    [self.attchArray removeAllObjects];
    [self.attchArray addObjectsFromArray:atts];
    [_collectionV reloadData];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    [_collectionV registerNib:[UINib nibWithNibName:AttchCollectionCellResue bundle:nil] forCellWithReuseIdentifier:AttchCollectionCellResue];
     [_collectionV registerNib:[UINib nibWithNibName:AttchImgageCellResue bundle:nil] forCellWithReuseIdentifier:AttchImgageCellResue];
    [_collectionV registerNib:[UINib nibWithNibName:HeadReusableViewResue bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeadReusableViewResue];
    
    _collectionV.delegate = self;
    _collectionV.dataSource = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
        cell.lblCount.text = [SystemUtil transformedValue:attachment.attData.length];
        cell.headImgV.image = [UIImage imageWithData:attachment.attData];
        return cell;
    } else {
        AttchCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AttchCollectionCellResue forIndexPath:indexPath];
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
        cell.lblCount.text = [SystemUtil transformedValue:attachment.attData.length];
        return cell;
    }
    
}


/**
 点击某个cell
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击了第%ld分item",(long)indexPath.item);
    if (_clickAttBlock) {
        _clickAttBlock(indexPath.item);
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
@end
