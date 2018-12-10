//
//  ChooseMutAlertView.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/25.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ChooseMutAlertView.h"
#import "FriendModel.h"
#import "ChooseCollectionCell.h"

@interface ChooseMutAlertView()<UICollectionViewDelegate,UICollectionViewDataSource>

@end

@implementation ChooseMutAlertView
+ (instancetype) loadChooseMutAlertView
{
    ChooseMutAlertView *sockView =[[[NSBundle mainBundle] loadNibNamed:@"ChooseMutAlertView" owner:self options:nil] lastObject];
    sockView.frame = [UIScreen mainScreen].bounds;
    return sockView;
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    _backView.layer.masksToBounds = YES;
    _backView.layer.cornerRadius = 5.0f;
    _collectV.delegate = self;
    _collectV.dataSource = self;
    [_collectV registerNib:[UINib nibWithNibName:ChooseCollectionCellReuse bundle:nil] forCellWithReuseIdentifier:ChooseCollectionCellReuse];
}
#pragma mark -cancelAction
- (IBAction)cancelAction:(id)sender {
    [self hideAlertView];
}
- (IBAction)sendAction:(id)sender {
     [self hideAlertView];
}
#pragma mark -showAlertView
- (void) showAlertView
{
    [AppD.window addSubview:self];
    self.alpha = 0.0f;
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        
    }];
}
- (void) hideAlertView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
#pragma mark - setDataArray
- (void)setDataArray:(NSArray *)dataArray
{
    if (_dataArray) {
        _dataArray = [NSMutableArray arrayWithArray:dataArray];
    } else {
        [_dataArray removeAllObjects];
        [_dataArray addObjectsFromArray:dataArray];
    }
    [_collectV reloadData];
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ChooseCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ChooseCollectionCellReuse forIndexPath:indexPath];
    FriendModel *model = self.dataArray[indexPath.item];
    cell.lblName.text = [StringUtil getUserNameFirstWithName:model.username];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}
#pragma mark ---- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (CGSize){45,45};
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
