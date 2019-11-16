//
//  QBaseViewController.h
//  Qlink
//
//  Created by Jelly Foo on 2018/3/21.
//  Copyright © 2018年 pan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCTManager.h"

@interface PNBaseViewController : UIViewController {
    BOOL showRightNavBarItem;
    BOOL showNavigationBar;
}
@property (strong, nonatomic) id<OCTManager> manager;
@property (nonatomic,strong) UIButton *rightNavBtn;

- (instancetype)initWithManager:(id<OCTManager>)manager;

- (id)initWithShowCustomNavigationBar:(BOOL)_showNavigationBar;
- (void)leftNavBarItemPressedWithPop:(BOOL) isPop;
- (void)rightNavBarItemPressed;
- (void)presentModalVC:(UIViewController *)VC animated:(BOOL)animated;
- (void) moveNavgationViewController:(UIViewController *) vs;
- (void)refreshContent;
// 移除上二个vs
- (void) moveNavgationBackViewController;
// 移除上一个vs
- (void) moveNavgationBackOneViewController;
// 保留第一个和最后一个
- (void) moveAllNavgationViewController;
- (void)setRootVCWithVC:(PNBaseViewController *) vc;
- (void)jumpToQR;
- (void) parsePowTempCode;
- (void)jumpToCircleQR;
- (void) scanSuccessfulWithIsMacd:(BOOL) isMac;
- (void) parsePowTempCodeBlock;
- (void) scanSuccessfulWithIsAccount:(NSArray *) values;
- (void) scanSuccessfulWithIsInvite:(NSArray *) values;

- (void)showEmptyViewToView:(UIView *)view img:(UIImage *)img title:(NSString *)title;
- (void)hideEmptyView;

- (void) toxLoginSuccessWithManager:(id<OCTManager>) manager;
- (void) loginToxWithShowHud:(BOOL) showHud;
- (void) logOutTox;
- (void)jumpToLoginDevice;
@end
