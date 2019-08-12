//
//  UITextViewWithPlaceHolder.h
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//在定义类的前面加上IB_DESIGNABLE宏，实现控件在xib或storyboard上可以实时渲染
IB_DESIGNABLE
@interface UITextViewWithPlaceHolder :UITextView
//在属性前面加上IB_DESIGNABLE宏，使该属性在xib或storyboard上可以展示
@property(nonatomic,strong) IBInspectable NSString*placeHolder;
@property(nonatomic,strong)UIFont *placeHolderFont;
@property(nonatomic,strong)UIColor *placeHolderColor;

@end


NS_ASSUME_NONNULL_END
