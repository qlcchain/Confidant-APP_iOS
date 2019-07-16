//
//  YJSideMenu.m
//  TTTT
//
//  Created by 刘亚军 on 2019/3/19.
//  Copyright © 2019 刘亚军. All rights reserved.
//

#import "YJSideMenu.h"
#import "UIViewController+YJSideMenu.h"

@interface YJSideMenu ()
@property (strong, readwrite, nonatomic) UIView *menuViewContainer;
@property (strong, readwrite, nonatomic) UIView *contentViewContainer;

@property (strong, readwrite, nonatomic) UIButton *contentMaskView;

@property (assign, readwrite, nonatomic) CGPoint originalPoint;

@property (assign, readwrite, nonatomic) CGFloat contentViewInLandscapeOffsetCenterX;
@property (assign, readwrite, nonatomic) CGFloat contentViewInPortraitOffsetCenterX;

@property (assign, readwrite, nonatomic) BOOL visible;
@property (assign, readwrite, nonatomic) BOOL leftMenuVisible;
@property (assign, readwrite, nonatomic) BOOL didNotifyDelegate;
@end

@implementation YJSideMenu
#pragma mark - View life cycle
- (instancetype)init{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}
- (void)commonInit{
    _menuViewContainer = [[UIView alloc] init];
    _contentViewContainer = [[UIView alloc] init];
    _panMinimumOpenThreshold = 60.0;
     _animationDuration = 0.35f;
    _panGestureEnabled = YES;
    _panFromEdge = YES;
    _contentMaskViewAlphaRate = 0.3;
    _contentViewInLandscapeOffsetWidth = 80.f;
    _contentViewInPortraitOffsetWidth = 80.f;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.menuViewContainer];
    [self.view addSubview:self.contentViewContainer];
    
    self.menuViewContainer.frame = self.view.bounds;
    self.menuViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self addChildViewController:self.leftMenuViewController];
    self.leftMenuViewController.view.frame = self.view.bounds;
    self.leftMenuViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.menuViewContainer addSubview:self.leftMenuViewController.view];
    [self.leftMenuViewController didMoveToParentViewController:self];
    
    self.contentViewContainer.frame = self.view.bounds;
    self.contentViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = self.view.bounds;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    [self.contentViewController didMoveToParentViewController:self];
    
    
    
    
    if (self.panGestureEnabled) {
        self.view.multipleTouchEnabled = NO;
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        panGestureRecognizer.delegate = self;
        [self.view addGestureRecognizer:panGestureRecognizer];
    }
    
    _contentViewInLandscapeOffsetCenterX = CGRectGetWidth(self.view.frame)/2 - _contentViewInLandscapeOffsetWidth;
    _contentViewInPortraitOffsetCenterX  = CGRectGetWidth(self.view.frame)/2 - _contentViewInPortraitOffsetWidth;
}
#pragma mark - Public
- (instancetype)initWithContentViewController:(UIViewController *)contentViewController leftMenuViewController:(UIViewController *)leftMenuViewController{
    self = [self init];
    if (self) {
        _contentViewController = contentViewController;
        _leftMenuViewController = leftMenuViewController;
    }
    return self;
}
- (void)presentLeftMenuViewController{
    [self presentMenuViewContainerWithMenuViewController:self.leftMenuViewController];
    [self showLeftMenuViewController];
}
- (void)hideMenuViewController{
    [self hideMenuViewControllerAnimated:YES];
}
- (void)clickFloderHideMenuViewController:(FloderModel *) floderModel
{
    if ([self.delegate respondsToSelector:@selector(sideMenu:didHideMenuViewController:selectFloderPath:)]) {
        [self.delegate sideMenu:self didHideMenuViewController:self.leftMenuViewController selectFloderPath:floderModel];
    }
     [self hideMenuViewControllerAnimated:YES];
}
#pragma mark - Private
- (void)presentMenuViewContainerWithMenuViewController:(UIViewController *)menuViewController{
    self.menuViewContainer.transform = CGAffineTransformIdentity;
    self.menuViewContainer.frame = self.view.bounds;

    if ([self.delegate conformsToProtocol:@protocol(YJSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
        [self.delegate sideMenu:self willShowMenuViewController:menuViewController];
    }
}
- (void)addContentMaskView{
    if (self.contentMaskView.superview)
        return;
    self.contentMaskView.autoresizingMask = UIViewAutoresizingNone;
    self.contentMaskView.frame = self.contentViewContainer.bounds;
    self.contentMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentViewContainer addSubview:self.contentMaskView];
}
- (void)statusBarNeedsAppearanceUpdate{
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        [UIView animateWithDuration:0.3f animations:^{
            [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
        }];
    }
}
- (void)hideMenuViewControllerAnimated:(BOOL)animated{
    if ([self.delegate conformsToProtocol:@protocol(YJSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willHideMenuViewController:)]) {
        [self.delegate sideMenu:self willHideMenuViewController:self.leftMenuViewController];
    }
    [self.leftMenuViewController beginAppearanceTransition:NO animated:animated];
    self.contentMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    [self.contentMaskView removeFromSuperview];
    self.visible = NO;
    self.leftMenuVisible = NO;
    __typeof (self) __weak weakSelf = self;
    void (^animationBlock)(void) = ^{
        __typeof (weakSelf) __strong strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        strongSelf.contentViewContainer.transform = CGAffineTransformIdentity;
        strongSelf.contentViewContainer.frame = strongSelf.view.bounds;
    };
    void (^completionBlock)(void) = ^{
        __typeof (weakSelf) __strong strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        [self.leftMenuViewController endAppearanceTransition];
        if (!strongSelf.visible && [strongSelf.delegate conformsToProtocol:@protocol(YJSideMenuDelegate)] && [strongSelf.delegate respondsToSelector:@selector(sideMenu:didHideMenuViewController:)]) {
            [strongSelf.delegate sideMenu:strongSelf didHideMenuViewController:strongSelf.leftMenuViewController];
        }
    };
    
    if (animated) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIView animateWithDuration:self.animationDuration animations:^{
            animationBlock();
        } completion:^(BOOL finished) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            completionBlock();
        }];
    } else {
        animationBlock();
        completionBlock();
    }
    [self statusBarNeedsAppearanceUpdate];
}
- (void)showLeftMenuViewController{
    if (!self.leftMenuViewController) {
        return;
    }
    [self.leftMenuViewController beginAppearanceTransition:YES animated:YES];
    self.leftMenuViewController.view.hidden = NO;
    [self.view.window endEditing:YES];
    [self addContentMaskView];
    
    [UIView animateWithDuration:self.animationDuration animations:^{
       
        self.contentViewContainer.transform = CGAffineTransformIdentity;
        
        self.contentViewContainer.center = CGPointMake((UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation]) ? self.contentViewInLandscapeOffsetCenterX + CGRectGetWidth(self.view.frame) : self.contentViewInPortraitOffsetCenterX + CGRectGetWidth(self.view.frame)), self.contentViewContainer.center.y);

        self.contentMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:self.contentMaskViewAlphaRate];
        
        self.menuViewContainer.transform = CGAffineTransformIdentity;
        
    } completion:^(BOOL finished) {

        [self.leftMenuViewController endAppearanceTransition];
        if (!self.visible && [self.delegate conformsToProtocol:@protocol(YJSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didShowMenuViewController:)]) {
            [self.delegate sideMenu:self didShowMenuViewController:self.leftMenuViewController];
        }
        self.visible = YES;
        self.leftMenuVisible = YES;
    }];
    
    [self statusBarNeedsAppearanceUpdate];
}


#pragma mark - UIGestureRecognizer Delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{

    if (self.panFromEdge && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && !self.visible) {
        CGPoint point = [touch locationInView:gestureRecognizer.view];
        if (point.x < 20.0 || point.x > self.view.frame.size.width - 20.0) {

            return YES;
        } else {
            return NO;
        }
    }

    return NO;
}
- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer{
    
    if ([self.delegate conformsToProtocol:@protocol(YJSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:didRecognizePanGesture:)])
        [self.delegate sideMenu:self didRecognizePanGesture:recognizer];
    
    if (!self.panGestureEnabled) {
        return;
    }
    CGPoint point = [recognizer translationInView:self.view];
    
    CGFloat offsetX;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        offsetX =  self.contentViewInLandscapeOffsetCenterX + CGRectGetWidth(self.view.frame)/2;
    }else{
        offsetX =  self.contentViewInPortraitOffsetCenterX + CGRectGetWidth(self.view.frame)/2;
    }
    
   
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        self.originalPoint = CGPointMake(self.contentViewContainer.center.x - CGRectGetWidth(self.contentViewContainer.bounds) / 2.0,
                                         self.contentViewContainer.center.y - CGRectGetHeight(self.contentViewContainer.bounds) / 2.0);
        self.menuViewContainer.transform = CGAffineTransformIdentity;
        self.menuViewContainer.frame = self.view.bounds;
        [self addContentMaskView];
        [self.view.window endEditing:YES];
        self.didNotifyDelegate = NO;
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
       
        if (point.x < 0) {
            point.x = MAX(point.x, -[UIScreen mainScreen].bounds.size.height);
        } else {
            point.x = MIN(point.x, [UIScreen mainScreen].bounds.size.height);
        }
        [recognizer setTranslation:point inView:self.view];
        
        if (!self.didNotifyDelegate) {
            if (point.x > 0) {
                if (!self.visible && [self.delegate conformsToProtocol:@protocol(YJSideMenuDelegate)] && [self.delegate respondsToSelector:@selector(sideMenu:willShowMenuViewController:)]) {
                    [self.delegate sideMenu:self willShowMenuViewController:self.leftMenuViewController];
                }
            }
            self.didNotifyDelegate = YES;
        }
        
        if (point.x > offsetX) {
            point.x = offsetX;
        }
        
        self.contentViewContainer.transform = CGAffineTransformMakeScale(1, 1);
        
        self.contentViewContainer.transform = CGAffineTransformTranslate(self.contentViewContainer.transform, point.x, 0);
        
        self.leftMenuViewController.view.hidden = self.contentViewContainer.frame.origin.x < 0;
        
        if (self.contentViewContainer.frame.origin.x < 0) {
            self.contentViewContainer.transform = CGAffineTransformIdentity;
            self.contentViewContainer.frame = self.view.bounds;
            self.visible = NO;
        }
        
        [self statusBarNeedsAppearanceUpdate];
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        self.didNotifyDelegate = NO;
        if (self.panMinimumOpenThreshold > 0 &&
            ((self.contentViewContainer.frame.origin.x < 0 && self.contentViewContainer.frame.origin.x > -((NSInteger)self.panMinimumOpenThreshold)) ||(self.contentViewContainer.frame.origin.x > 0 && self.contentViewContainer.frame.origin.x < self.panMinimumOpenThreshold))) {
            [self hideMenuViewController];
        }else if (self.contentViewContainer.frame.origin.x == 0) {
            [self hideMenuViewControllerAnimated:NO];
        }else {
            if ([recognizer velocityInView:self.view].x > 0) {
                if (self.contentViewContainer.frame.origin.x < 0) {
                    [self hideMenuViewController];
                } else {
                    if (self.leftMenuViewController) {
                        [self showLeftMenuViewController];
                    }
                }
            } else {
                [self hideMenuViewController];
            }
        }
    }
}
#pragma mark - View Controller Rotation handler

- (BOOL)shouldAutorotate{
    return self.contentViewController.shouldAutorotate;
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    if (self.visible) {
        self.menuViewContainer.bounds = self.view.bounds;
        self.contentViewContainer.transform = CGAffineTransformIdentity;
        self.contentViewContainer.frame = self.view.bounds;
        
        self.contentViewContainer.transform = CGAffineTransformIdentity;
        
        CGPoint center;
        if (self.leftMenuVisible) {
            center = CGPointMake((UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? self.contentViewInLandscapeOffsetCenterX + CGRectGetHeight(self.view.frame) : self.contentViewInPortraitOffsetCenterX + CGRectGetWidth(self.view.frame)), self.contentViewContainer.center.y);
        } else {
            center = CGPointMake((UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation) ? -self.contentViewInLandscapeOffsetCenterX : -self.contentViewInPortraitOffsetCenterX), self.contentViewContainer.center.y);
        }
        
        self.contentViewContainer.center = center;
    }
}
#pragma mark - Status Bar Appearance Management

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden{
    return NO;
}
- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation{
    return UIStatusBarAnimationNone;
}
#pragma mark - Getter
- (UIButton *)contentMaskView{
    if (!_contentMaskView) {
        _contentMaskView = [[UIButton alloc] initWithFrame:CGRectNull];
        _contentMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
       [_contentMaskView addTarget:self action:@selector(hideMenuViewController) forControlEvents:UIControlEventTouchUpInside];
    }
    return _contentMaskView;
}
@end
