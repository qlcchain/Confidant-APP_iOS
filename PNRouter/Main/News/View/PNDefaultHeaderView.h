//
//  PNDefaultHeaderView.h
//  PNRouter
//
//  Created by Jelly Foo on 2019/3/7.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PNDefaultHeaderView : UIView

+ (UIImage *)getImageWithUserkey:(NSString *)userKey Name:(NSString *)name backFrame:(CGRect)backFrame;
+ (UIImage *)getImageWithUserkey:(NSString *)userKey Name:(NSString *)name;
+ (UIImage *)getImageWithUserkey:(NSString *)userKey Name:(NSString *)name fontSize:(NSInteger)fontSize;

@end

NS_ASSUME_NONNULL_END
