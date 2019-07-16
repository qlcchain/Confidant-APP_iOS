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
#import <MailCore/MailCore.h>
#import "SystemUtil.h"


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
   
    
    MCOAttachment *attachment = self.attchArray[indexPath.row];
    NSString *fileHz = [[attachment.filename componentsSeparatedByString:@"."] lastObject];
    if ([fileHz isEqualToString:@"webp"] || [fileHz isEqualToString:@"bmp"] || [fileHz isEqualToString:@"jpg"] || [fileHz isEqualToString:@"png"] || [fileHz isEqualToString:@"tif"]) {
        
        AttchImgageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AttchImgageCellResue forIndexPath:indexPath];
        cell.lblCount.text = [SystemUtil transformedValue:attachment.data.length];
        cell.headImgV.image = [UIImage imageWithData:attachment.data];
        
        return cell;
    } else {
        AttchCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AttchCollectionCellResue forIndexPath:indexPath];
        
        cell.lblName.text = attachment.filename;
        cell.lblCount.text = [SystemUtil transformedValue:attachment.data.length];
        return cell;
    }
    
}


/**
 点击某个cell
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"点击了第%ld分item",(long)indexPath.item);
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
@end
