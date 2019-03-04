//
//  PNBackgroundView.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/4.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNBackgroundView : UIView

@property (nonatomic) BOOL isShow;

+ (instancetype)getInstance;
- (void)show;
- (void)hide;

@end

NS_ASSUME_NONNULL_END
