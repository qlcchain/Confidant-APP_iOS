//
//  ChooseCollectionCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/25.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *ChooseCollectionCellReuse = @"ChooseCollectionCell";

@interface ChooseCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *headerImgV;

@end
