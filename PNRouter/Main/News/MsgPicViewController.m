//
//  MsgPicViewController.m
//  CDChatList_Example
//
//  Created by chdo on 2018/4/29.
//  Copyright © 2018年 chdo002. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MsgPicViewController.h"
#import <SDWebImage/SDImageCache.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface MsgPicViewController ()
{
    UIScrollView *scrol;
    UIImage *currentImg;
    CGRect currentRect;
    CGRect originRect;
}
@end

@implementation MsgPicViewController

+(void)addToRootViewController:(UIImage *)img
                       ofMsgId:(NSString *)msgId
                            in:(CGRect)imgRectIntTableView
                          from: (CDChatMessageArray) msgs{
    
    MsgPicViewController *msgVc = [[MsgPicViewController alloc] init];
    msgVc.img = img;
    msgVc.imgRectIntTableView = imgRectIntTableView;
    msgVc.msgs = msgs;
    msgVc.msgId = msgId;
    msgVc.view.backgroundColor = [UIColor clearColor];
    msgVc.view.frame = [UIScreen mainScreen].bounds;
    
    [msgVc willMoveToParentViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    [[UIApplication sharedApplication].keyWindow.rootViewController addChildViewController:msgVc];
    [[UIApplication sharedApplication].keyWindow addSubview:msgVc.view];
    
    
    UIImageView *currentImg = [[UIImageView alloc] initWithImage:img];
    
    CGRect newe =  [msgVc.view convertRect:imgRectIntTableView toView:msgVc.view];
    currentImg.frame = newe;
    msgVc->originRect = newe;
    currentImg.contentMode = UIViewContentModeScaleAspectFit;
    [msgVc.view addSubview:currentImg];
    msgVc.imgView = currentImg;
    
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:msgVc action:@selector(panAction:)];
    [currentImg addGestureRecognizer:panGes];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:msgVc action:@selector(tapAction:)];
    [currentImg addGestureRecognizer:tapGes];
    
    currentImg.userInteractionEnabled = YES;
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        currentImg.frame = msgVc.view.bounds;
        msgVc.view.backgroundColor = [UIColor blackColor];
    } completion:^(BOOL finished) {
        //        [currentImg removeFromSuperview];
        //        [msgVc didMoveToParentViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
    }];
}
-(void)tapAction:(UITapGestureRecognizer *)ges{
    if (ges.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.3 animations:^{
            self.imgView.transform = CGAffineTransformIdentity;
            self.view.alpha = 0;
            self.imgView.frame = self->originRect;
            
        } completion:^(BOOL finished) {
            [self removeFromParentViewController];
        }];
    }
}

-(void)panAction:(UIPanGestureRecognizer *)ges{
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint trans = [ges translationInView:self.view];
            CGFloat per = trans.y / cd_ScreenH() / 0.6;

            if (per > 0) {

                CGFloat scal = 1 - per;
                self.imgView.transform = CGAffineTransformMake(sqrtf(scal), 0, 0, sqrtf(scal), trans.x, trans.y);
                self.view.alpha = sqrtf(1 - per);
            } else {
                self.imgView.transform = CGAffineTransformMake(1, 0, 0, 1, trans.x, trans.y);
            }
        }
            break;
        default:
        {
            if (self.imgView.transform.ty > 40) {
                [UIView animateWithDuration:0.3 animations:^{
                    self.imgView.transform = CGAffineTransformIdentity;
                    self.view.alpha = 0;
                    self.imgView.frame = self->originRect;
                    
                } completion:^(BOOL finished) {
                    [self removeFromParentViewController];
                }];
            } else {
                [UIView animateWithDuration:0.3 animations:^{
                    self.imgView.transform = CGAffineTransformIdentity;
                    self.view.alpha = 1;
                } completion:^(BOOL finished) {
                    
                }];
            }
        }
            break;
    }
//    [ges setTranslation:CGPointZero inView:self.view];
}
@end
