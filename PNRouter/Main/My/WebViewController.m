//
//  WebViewController.m
//  Qlink
//
//  Created by 旷自辉 on 2018/5/30.
//  Copyright © 2018年 pan. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

#define HELP_URL @"https://myconfidant.io/support"
#define SHARE_FRIEND_URL @"https://myconfidant.io"

@interface WebViewController ()<WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet WKWebView *myWebView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
//设置加载进度条
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@end

@implementation WebViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_myWebView removeObserver:self
                    forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
}

- (IBAction)clickBack:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _myWebView.navigationDelegate = self;
    NSString *urlString = HELP_URL;
     _lblTitle.text = @"Help Center";
    if (_fromType == WebFromTypeShareFriend) {
        urlString = SHARE_FRIEND_URL;
        _lblTitle.text = @"Share with Friends";
    }
    
    urlString = @"https://accounts.google.com/o/oauth2/auth?client_id=873428561545-aui4v5nvn6b1dtodnthmmg5q1ci0vski.apps.googleusercontent.com&redirect_uri=urn%3Aietf%3Awg%3Aoauth%3A2.0%3Aoob&response_type=code&scope=https%3A%2F%2Fmail.google.com%2F%20https%3A%2F%2Fwww.googleapis.com%2Fauth%2Fuserinfo.email";
    
    [_progressView setTrackTintColor:[UIColor colorWithRed:240.0/255
                                                     green:240.0/255
                                                      blue:240.0/255
                                                     alpha:1.0]];
    _progressView.progressTintColor = [UIColor greenColor];
    // 添加进度观察者
    [_myWebView addObserver:self
                 forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
                    options:0
                    context:nil];
    //在web页面直接添加观察者
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(windowDidBecomeHidden:) name:UIWindowDidBecomeHiddenNotification object:nil];

    [_myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
 
    
}

#pragma mark --当调用系统白播放视频时，系统默认会隐藏掉状态栏，通过此方法当视频退出后显示大状态栏
-(void)windowDidBecomeHidden:(NSNotification *)noti{
    
    UIWindow * win = (UIWindow *)noti.object;
    
    if(win){
        UIViewController *rootVC = win.rootViewController;
        NSArray<__kindof UIViewController *> *vcs = rootVC.childViewControllers;
        if([vcs.firstObject isKindOfClass:NSClassFromString(@"AVPlayerViewController")]){
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        }
    }
}

#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    //开始加载的时候，让进度条显示
    self.progressView.hidden = NO;
}
// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
    
}
// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
  
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    // NSStringLocalizable(@"request_error")
    [AppD.window showHint:error.domain];
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    [AppD.window showHint:@"Load failed"];
}
// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
}
//kvo 监听进度
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]
        && object == _myWebView) {
        [self.progressView setAlpha:1.0f];
        BOOL animated = _myWebView.estimatedProgress > self.progressView.progress;
        [self.progressView setProgress:_myWebView.estimatedProgress
                              animated:animated];
        
        if (_myWebView.estimatedProgress >= 1.0f) {
            [UIView animateWithDuration:0.3f
                                  delay:0.3f
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [self.progressView setAlpha:0.0f];
                             }
                             completion:^(BOOL finished) {
                                 [self.progressView setProgress:0.0f animated:NO];
                             }];
        }
    }else{
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
