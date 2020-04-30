//
//  UITableView+WFEmpty.h
//  MyConfidant
//
//  Created by 旷自辉 on 2020/4/24.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITableView (WFEmpty)

@property (nonatomic, strong, readonly) UIView *emptyView;
-(void)addEmptyViewWithImageName:(NSString*)imageName title:(NSString*)title;

@end

NS_ASSUME_NONNULL_END
