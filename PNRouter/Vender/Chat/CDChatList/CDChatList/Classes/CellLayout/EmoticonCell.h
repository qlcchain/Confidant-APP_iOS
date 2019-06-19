//
//  EmoticonCell.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/5/30.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmojBtn : UIButton

@end

NS_ASSUME_NONNULL_BEGIN

typedef void(^ClickCollectionCellB)(NSInteger row);

@interface EmoticonCell : UICollectionViewCell
@property (nonatomic ,copy) ClickCollectionCellB clickCellB;
@property (nonatomic ,strong) EmojBtn *emoticonButton;
@end

NS_ASSUME_NONNULL_END
