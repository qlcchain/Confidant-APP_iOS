//
//  YJSideMenu.h
//  TTTT
//
//  Created by 刘亚军 on 2019/3/19.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YJSideMenuDelegate;
@class FloderModel;
@interface YJSideMenu : UIViewController<UIGestureRecognizerDelegate>

@property (weak, readwrite, nonatomic) id<YJSideMenuDelegate> delegate;

@property (assign, readwrite, nonatomic) BOOL panGestureEnabled;
@property (assign, readwrite, nonatomic) BOOL panFromEdge;

@property (assign, readwrite, nonatomic) NSUInteger panMinimumOpenThreshold;
@property (assign, readwrite, nonatomic) NSTimeInterval animationDuration;
@property (assign, readwrite, nonatomic) CGFloat contentViewInLandscapeOffsetWidth;
@property (assign, readwrite, nonatomic) CGFloat contentViewInPortraitOffsetWidth;
@property (assign, readwrite, nonatomic) CGFloat contentMaskViewAlphaRate;

@property (strong, readwrite, nonatomic) UIViewController *contentViewController;
@property (strong, readwrite, nonatomic) UIViewController *leftMenuViewController;

- (instancetype)initWithContentViewController:(UIViewController *)contentViewController leftMenuViewController:(UIViewController *)leftMenuViewController;

- (void)presentLeftMenuViewController;
- (void)hideMenuViewController;
- (void)clickFloderHideMenuViewController:(FloderModel *) floderModel;
@end


@protocol YJSideMenuDelegate <NSObject>

@optional
- (void)sideMenu:(YJSideMenu *)sideMenu didRecognizePanGesture:(UIPanGestureRecognizer *)recognizer;
- (void)sideMenu:(YJSideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(YJSideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(YJSideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(YJSideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController;
- (void)sideMenu:(YJSideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController selectFloderPath:(FloderModel *) floderModel;
@end


NS_ASSUME_NONNULL_END
