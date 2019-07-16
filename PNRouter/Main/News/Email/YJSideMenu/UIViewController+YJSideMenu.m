//
//  UIViewController+YJSideMenu.m
//  TTTT
//
//  Created by 刘亚军 on 2019/3/19.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import "UIViewController+YJSideMenu.h"
#import "YJSideMenu.h"

@implementation UIViewController (YJSideMenu)
- (YJSideMenu *)sideMenuViewController{
    UIViewController *iter = self.parentViewController;
    while (iter) {
        if ([iter isKindOfClass:[YJSideMenu class]]) {
            return (YJSideMenu *)iter;
        } else if (iter.parentViewController && iter.parentViewController != iter) {
            iter = iter.parentViewController;
        } else {
            iter = nil;
        }
    }
    return nil;
}

- (void)yj_presentLeftMenuViewController:(id)sender{
    [self.sideMenuViewController presentLeftMenuViewController];
}
- (void) hideSideMenu
{
    [self.sideMenuViewController hideMenuViewController];
}

- (void)clickFloderHideMenuViewController:(FloderModel *) floderModel;
{
    [self.sideMenuViewController clickFloderHideMenuViewController:floderModel];
}
@end
