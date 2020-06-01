//
//  PNFeedbackImgAlertView.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/27.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNFeedbackImgAlertView.h"
#import "PNImgCollectionCell.h"

@interface PNFeedbackImgAlertView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic, strong) NSMutableArray *imgArray;
@end

@implementation PNFeedbackImgAlertView
- (NSMutableArray *)imgArray
{
    if (!_imgArray) {
        _imgArray = [NSMutableArray array];
    }
    return _imgArray;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(_backView.bounds)) byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(16,16)];//圆角大小
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, CGRectGetHeight(_backView.bounds));//_backView.bounds;
    maskLayer.path = maskPath.CGPath;
    _backView.layer.mask = maskLayer;
}

- (IBAction)clickCloseAction:(id)sender {
    [self hidePNFeedbackImgAlertView];
}

+ (instancetype) loadPNFeedbackImgAlertView
{
    PNFeedbackImgAlertView *view = [[[NSBundle mainBundle] loadNibNamed:@"PNFeedbackImgAlertView" owner:self options:nil] lastObject];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    view.bottomV.constant = -285;
    view.imgCollectionView.delegate = view;
    view.imgCollectionView.dataSource = view;
    [view.imgCollectionView registerNib:[UINib nibWithNibName:PNImgCollectionCellResue bundle:nil] forCellWithReuseIdentifier:PNImgCollectionCellResue];
    [view layoutIfNeeded];
    return view;
}
- (void) showPNFeedbackImgAlertView
{
    [AppD.window addSubview:self];
    _bottomV.constant = 0;
       @weakify_self
       [UIView animateWithDuration:0.3 animations:^{
           [weakSelf layoutIfNeeded];
       }];
}
- (void) hidePNFeedbackImgAlertView
{
    _bottomV.constant = -285;
    @weakify_self
    [UIView animateWithDuration:0.3 animations:^{
        [weakSelf layoutIfNeeded];
    } completion:^(BOOL finished) {
        [weakSelf removeFromSuperview];
    }];
}


#pragma mark ---------colletion 代理回调
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
    return self.imgArray.count;
}
/**
 创建cell
 */
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PNImgCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PNImgCollectionCellResue forIndexPath:indexPath];
    cell.tag = indexPath.item;
    cell.closeBtn.hidden = YES;
    return cell;
}
/**
 点击某个cell
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

}
/**
 cell的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    CGFloat itemW = 130;
    CGFloat itemH = 194;
    return CGSizeMake(itemW,itemH);
}

/**
 分区内cell之间的最小行间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
/**
 分区内cell之间的最小列间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}

@end
