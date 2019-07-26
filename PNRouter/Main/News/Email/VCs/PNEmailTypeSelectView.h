//
//  PNEmailTypeSelectView.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/17.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ClickRowBlock)(PNBaseViewController *vc, NSArray *arr);

@interface PNEmailTypeSelectView : PNBaseViewController
@property (nonatomic, copy) ClickRowBlock clickRowBlock;
@end

NS_ASSUME_NONNULL_END
