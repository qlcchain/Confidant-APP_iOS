//
//  ShareView.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/10.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClickCollectinItem)(NSInteger item);

@interface ShareView : UIView<UICollectionViewDelegate,UICollectionViewDataSource>
@property (nonatomic ,copy) ClickCollectinItem clickItemBlock;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionV;
+ (instancetype) loadShareView;
- (void) show;
@end
