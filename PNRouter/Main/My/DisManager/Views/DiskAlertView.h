//
//  MnemonicTipView.h
//  Qlink
//
//  Created by Jelly Foo on 2018/10/23.
//  Copyright © 2018 pan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^DiskClickBlock)(void);

@interface DiskAlertView : UIView

@property (nonatomic, copy) DiskClickBlock okBlock;

+ (instancetype)getInstance;
- (void)showWithTitle:(NSString *)title tip:(NSString *)tip click:(NSString *)click;

@end

NS_ASSUME_NONNULL_END
