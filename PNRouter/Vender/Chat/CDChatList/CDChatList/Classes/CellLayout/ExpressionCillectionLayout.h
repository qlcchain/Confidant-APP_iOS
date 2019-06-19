//
//  ExpressionCillectionLayout.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/5/31.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ExpressionCillectionLayout : UICollectionViewLayout
@property (nonatomic) CGSize       itemSize;
@property (nonatomic) CGFloat      lineSpacing;
@property (nonatomic) CGFloat      itemSpacing;
@property (nonatomic) UIEdgeInsets pageContentInsets;
@end

NS_ASSUME_NONNULL_END
