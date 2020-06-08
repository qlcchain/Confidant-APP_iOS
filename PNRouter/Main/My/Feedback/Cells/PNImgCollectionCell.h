//
//  PNImgCollectionCell.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/26.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
static NSString *PNImgCollectionCellResue = @"PNImgCollectionCell";
typedef void(^ClickDelBlock)(NSInteger item);

@interface PNImgCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgV;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (nonatomic, copy) ClickDelBlock clickDelBlock;

@end

NS_ASSUME_NONNULL_END
