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
#import "HMScanner.h"
#import "NSString+RegexCategory.h"
#import "UserModel.h"
#import "FriendRequestViewController.h"
#import "CodeMsgViewController.h"

@interface MsgPicViewController ()<UIScrollViewDelegate>
{
    UIScrollView *scrol;
    UIImage *currentImg;
    CGRect currentRect;
    CGRect originRect;
    UIView *menuView;
}
@property (nonatomic , strong) NSString *codeVaule;
@end

@implementation MsgPicViewController

- (void)viewWillAppear:(BOOL)animated
{
    self.view.hidden = NO;
    [super viewWillAppear:animated];
}

- (void) addScrollerView
{
    scrol = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    scrol.delegate = self;
    scrol.contentSize = _img.size;
    //设置最大伸缩比例
    scrol.maximumZoomScale = 2.0f;
    //设置最小伸缩比例
    scrol.minimumZoomScale = 1.0;
    [self.view addSubview:scrol];
    [scrol addSubview:_imgView];
    
    menuView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    menuView.backgroundColor = [UIColor clearColor];
    [scrol addSubview:menuView];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = menuView.bounds;
    backBtn.backgroundColor = [UIColor clearColor];
    [backBtn addTarget:self action:@selector(cancelMenuAction:) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:backBtn];
    
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, IS_iPhoneX?95+20.5:95)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.tag = 10;
    [menuView addSubview:contentView];
    
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn2.frame = CGRectMake(0,0, SCREEN_WIDTH, 45);
    btn2.backgroundColor = [UIColor whiteColor];
    btn2.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn2 setTitleColor:MAIN_PURPLE_COLOR forState:UIControlStateNormal];
    [btn2 setTitle:@"Save Photo" forState:UIControlStateNormal];
    btn2.tag = 1;
    [btn2 addTarget:self action:@selector(clickMenumTag:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:btn2];
    
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(btn2.frame), SCREEN_WIDTH, 5)];
    lineView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [contentView addSubview:lineView];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, CGRectGetMaxY(lineView.frame), SCREEN_WIDTH, 45);
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:MAIN_PURPLE_COLOR forState:UIControlStateNormal];
    cancelBtn.tag = 0;
    [cancelBtn addTarget:self action:@selector(cancelMenuAction:) forControlEvents:UIControlEventTouchUpInside];
    [contentView addSubview:cancelBtn];
    
    menuView.hidden = YES;
    
    
    __block CGFloat downHeight = IS_iPhoneX?95+20:95;
    @weakify_self
    [HMScanner scaneImage:_img completion:^(NSArray *values) {
        downHeight = IS_iPhoneX?95+20+45.5:95+45.5;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (values && values.count > 0) {
                weakSelf.codeVaule = values.firstObject;
               CGRect rect = contentView.frame;
                rect.size.height += 45.5;
                
                UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 45, SCREEN_WIDTH,0.5)];
                lineView1.backgroundColor = [UIColor groupTableViewBackgroundColor];
                [contentView addSubview:lineView1];
                
                UIButton *codeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                codeBtn.frame = CGRectMake(0,CGRectGetMaxY(lineView1.frame), SCREEN_WIDTH, 45);
                codeBtn.backgroundColor = [UIColor whiteColor];
                codeBtn.titleLabel.font = [UIFont systemFontOfSize:16];
                [codeBtn setTitleColor:MAIN_PURPLE_COLOR forState:UIControlStateNormal];
                [codeBtn setTitle:@"Scan QR Code in image" forState:UIControlStateNormal];
                codeBtn.tag = 2;
                [codeBtn addTarget:self action:@selector(clickMenumTag:) forControlEvents:UIControlEventTouchUpInside];
                [contentView addSubview:codeBtn];
                
                rect = lineView.frame;
                rect.origin.y = CGRectGetMaxY(codeBtn.frame);
                lineView.frame = rect;
                
                rect = cancelBtn.frame;
                rect.origin.y = CGRectGetMaxY(lineView.frame);
                cancelBtn.frame = rect;
                
            }
            
        });
    }];
}
- (void) cancelMenuAction:(UIButton *) btn
{
    UIView *contentView = [menuView viewWithTag:10];
    CGRect contectRect = contentView.frame;
    contectRect.origin.y = SCREEN_HEIGHT;
    [UIView animateWithDuration:0.3 animations:^{
        contentView.frame = contectRect;
    }completion:^(BOOL finished) {
        self->menuView.hidden = YES;
    }];
}
- (void) showSaveSheet
{
    menuView.hidden = NO;
    UIView *contentView = [menuView viewWithTag:10];
    CGRect contectRect = contentView.frame;
     CGFloat downHeight = IS_iPhoneX?95+20:95;
    if (_codeVaule && _codeVaule.length>0) {
         downHeight = IS_iPhoneX?95+20+45.5:95+45.5;
    }
    
    contectRect.origin.y = SCREEN_HEIGHT - downHeight;
    [UIView animateWithDuration:0.3 animations:^{
        contentView.frame = contectRect;
    }];
}
- (void) clickMenumTag:(UIButton *) btn
{
    [self cancelMenuAction:nil];
    if (btn.tag == 1) {
         [self loadImageFinished:_img];
    } else if (btn.tag == 2) { // 识别码
        NSLog(@"codevalue = %@",_codeVaule);
        if ([_codeVaule isUrlAddress]) { // 是网址
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_codeVaule] options:@{} completionHandler:nil];
        } else {
           
            NSArray *codeValues = [_codeVaule componentsSeparatedByString:@","];
            NSString *codeType = codeValues[0];
            if ([codeType isEqualToString:@"type_0"]) {
                NSString *userID = codeValues[1];
                if (userID.length == 76) {
                    if ([userID isEqualToString:[UserModel getUserModel].userId]) {
                         [self jumpCodeValueVC];
                    } else {
                        NSString *nickName = @"";
                        if (codeValues.count>2) {
                            nickName = codeValues[2];
                        }
                        [self addFriendRequest:userID nickName:nickName signpk:codeValues[3]];
                    }
                } else {
                    [self jumpCodeValueVC];
                }
                
            }
        }
    }
   
}

#pragma mark - Transition
- (void)addFriendRequest:(NSString *)friendId nickName:(NSString *) nickName signpk:(NSString *) signpk
{
   
    if (_chatVC) {

        self.view.hidden = YES;
        [self removeFromParentViewController];
    
         FriendRequestViewController *vc = [[FriendRequestViewController alloc] initWithNickname:nickName userId:friendId signpk:signpk];
        [_chatVC.navigationController pushViewController:vc animated:YES];
    }
}

- (void) jumpCodeValueVC
{
    self.view.hidden = YES;
    [self removeFromParentViewController];
    
    CodeMsgViewController *vc = [[CodeMsgViewController alloc] initWithCodeValue:_codeVaule];
    [_chatVC.navigationController pushViewController:vc animated:YES];
}

#pragma mark -系统分享
- (void) shareAction
{
    NSArray *images = @[_img];
    UIActivityViewController *activityController=[[UIActivityViewController alloc]initWithActivityItems:images applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

- (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [AppD.window showHint:@"Save Success"];
    } else {
        [AppD.window showHint:@"Save Failed"];
    }
}

//告诉scrollview要缩放的是哪个子控件
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
         return _imgView;
}

+(void)addToRootViewController:(UIImage *)img
                       ofMsgId:(NSString *)msgId
                            in:(CGRect)imgRectIntTableView
                          from: (CDChatMessageArray) msgs vc:(PNBaseViewController *)vc{
    
    MsgPicViewController *msgVc = [[MsgPicViewController alloc] init];
    msgVc.img = img;
    msgVc.imgRectIntTableView = imgRectIntTableView;
    msgVc.msgs = msgs;
    msgVc.msgId = msgId;
    msgVc.chatVC = vc;
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
   // [msgVc.view addSubview:currentImg];
    msgVc.imgView = currentImg;
    
    [msgVc addScrollerView];
    
    UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:msgVc action:@selector(panAction:)];
    [currentImg addGestureRecognizer:panGes];
    
    UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:msgVc action:@selector(longAction:)];
    [currentImg addGestureRecognizer:longGes];
    
    
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:msgVc action:@selector(tapAction:)];
    [currentImg addGestureRecognizer:tapGes];
    
    UITapGestureRecognizer *tapGes2 = [[UITapGestureRecognizer alloc] initWithTarget:msgVc action:@selector(tapAction:)];
    tapGes2.numberOfTapsRequired = 2;
    [currentImg addGestureRecognizer:tapGes2];
    
    // 关键在这一行，双击手势确定监测失败才会触发单击手势的相应操作
    [tapGes requireGestureRecognizerToFail:tapGes2];
    
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
        
        if (ges.numberOfTapsRequired == 2) {
            if (scrol.zoomScale == 1.0f) {
                [scrol setZoomScale:2.0f animated:YES];
            } else {
                [scrol setZoomScale:1.0f animated:YES];
            }
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                self.imgView.transform = CGAffineTransformIdentity;
                self.view.alpha = 0;
                self.imgView.frame = self->originRect;
                
            } completion:^(BOOL finished) {
                [self removeFromParentViewController];
            }];
        }
        
        
    }
}

- (void) longAction:(UILongPressGestureRecognizer *) ges
{
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self showSaveSheet];
        }
            break;
        default:
        {
            
        }
            break;
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
