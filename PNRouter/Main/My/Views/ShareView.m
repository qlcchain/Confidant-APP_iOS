//
//  ShareView.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ShareView.h"
#import "ShareCollectionCell.h"

@interface ShareView ()
@property (nonatomic ,copy ) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *shareContraintBotton;
@end

@implementation ShareView
- (IBAction)backAction:(id)sender {
    [self hidden];
}
- (IBAction)cancelAction:(id)sender {
    [self hidden];
}

+ (instancetype) loadShareView
{
    ShareView *view = [[[NSBundle mainBundle] loadNibNamed:@"ShareView" owner:self options:nil] lastObject];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    return view;
}

#pragma mark - layz
- (NSArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = @[@[@"Copy Link",@"icon_copylink"],@[@"Google",@"icon_google"],@[@"Twitter",@"icon_twitter"],@[@"Facebook",@"icon_facebook"],@[@"Linked",@"icon_linked"]];
    }
    return _dataArray;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    _collectionV.dataSource = self;
    _collectionV.delegate = self;
    [_collectionV registerNib:[UINib nibWithNibName:ShareCollectionCellReuse bundle:nil] forCellWithReuseIdentifier:ShareCollectionCellReuse];
    
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    ShareCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ShareCollectionCellReuse forIndexPath:indexPath];
    NSArray *sourceArr = [self.dataArray objectAtIndex:indexPath.item];
    cell.lblContent.text = sourceArr[0];
    cell.imgView.image = [UIImage imageNamed:sourceArr[1]];
    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}
#pragma mark ---- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (CGSize){77,72};
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

// 选中某item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.clickItemBlock) {
        self.clickItemBlock(indexPath.item);
    }
   
}


- (void) show
{
    [AppD.window addSubview:self];
    _shareContraintBotton.constant = -180;
    [self layoutIfNeeded];
    
    
    [UIView animateWithDuration:0.3 animations:^{
        self->_shareContraintBotton.constant = 0;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
    
}
- (void) hidden
{
    [UIView animateWithDuration:0.3 animations:^{
        self->_shareContraintBotton.constant = -180;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
