//
//  UIViewController+YJSideMenu.h
//  TTTT
//
//  Created by 刘亚军 on 2019/3/19.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class YJSideMenu;
@class FloderModel;
@interface UIViewController (YJSideMenu)
@property (strong, readonly, nonatomic) YJSideMenu *sideMenuViewController;

// IB Action Helper methods

- (IBAction)yj_presentLeftMenuViewController:(nullable id)sender;
- (void) hideSideMenu;
- (void)clickFloderHideMenuViewController:(FloderModel *) floderModel;
@end

NS_ASSUME_NONNULL_END
