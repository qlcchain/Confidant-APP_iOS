//
//  PNEmailDetailViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNEmailDetailViewController.h"
#import "EmailTopDetailCell.h"
#import "EmailUserCell.h"
#import "EmailTimeCell.h"
#import "EmailContentCell.h"
#import "EmailAttchCell.h"
#import "EmailListInfo.h"
#import "EmailUserModel.h"
#import "NSDate+Category.h"
//#import <WebKit/WebKit.h>

@interface PNEmailDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>//WKNavigationDelegate
{
    BOOL isHidden;
    CGFloat webViewHeight;
    BOOL isLoadingFinished;
}
@property (weak, nonatomic) IBOutlet UILabel *lblFloderName;
@property (weak, nonatomic) IBOutlet UIButton *nodeBtn;
@property (weak, nonatomic) IBOutlet UITableView *mainTabV;
@property (nonatomic, strong) NSMutableArray *userArray;
//@property (nonatomic ,strong) WKWebView *myWebView;

@property (nonatomic ,strong) UIWebView *myWebView;

@property (nonatomic ,strong) EmailListInfo *emailInfo;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic ,strong) UIScrollView *wbScrollView;

@end

@implementation PNEmailDetailViewController
// 初始化方法
- (id)initWithEmailListModer:(EmailListInfo *)listInfo
{
    if (self = [super init]) {
        self.emailInfo = listInfo;
    }
    return self;
}
#pragma mark ------layz------------------
- (NSMutableArray *)userArray
{
    if (!_userArray) {
        
        _userArray = [NSMutableArray array];
        // 添加发送人
        EmailUserModel *userModel = [[EmailUserModel alloc] init];
        userModel.userType = UserFrom;
        userModel.userName = self.emailInfo.fromName;
        userModel.userAddress = self.emailInfo.From;
        [_userArray addObject:userModel];
        // 添加收送人
        if (self.emailInfo.toUserArray) {
            [_userArray addObjectsFromArray:self.emailInfo.toUserArray];
        }
        // 添加抄送人
        if (self.emailInfo.ccUserArray) {
            [_userArray addObjectsFromArray:self.emailInfo.ccUserArray];
        }
        // 添加密送人
        if (self.emailInfo.bccUserArray) {
            [_userArray addObjectsFromArray:self.emailInfo.bccUserArray];
        }
    }
    return _userArray;
}


#pragma makr -----IBOUT Click ----------

- (IBAction)clickBackBtn:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)ClickRightBtn:(id)sender {
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    _lblFloderName.text = self.emailInfo.floderName;
    
    [_progressView setTrackTintColor:[UIColor colorWithRed:240.0/255
                                                     green:240.0/255
                                                      blue:240.0/255
                                                     alpha:1.0]];
    _progressView.progressTintColor = [UIColor greenColor];
    
    
    isHidden = YES;
    _mainTabV.delegate = self;
    _mainTabV.dataSource = self;
    _mainTabV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _mainTabV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_mainTabV registerNib:[UINib nibWithNibName:EmailTopDetailCellResue bundle:nil] forCellReuseIdentifier:EmailTopDetailCellResue];
    [_mainTabV registerNib:[UINib nibWithNibName:EmailUserCellResue bundle:nil] forCellReuseIdentifier:EmailUserCellResue];
    [_mainTabV registerNib:[UINib nibWithNibName:EmailTimeCellResue bundle:nil] forCellReuseIdentifier:EmailTimeCellResue];
    [_mainTabV registerNib:[UINib nibWithNibName:EmailContentCellResue bundle:nil] forCellReuseIdentifier:EmailContentCellResue];
    [_mainTabV registerNib:[UINib nibWithNibName:EmailAttchCellResue bundle:nil] forCellReuseIdentifier:EmailAttchCellResue];
  
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (isHidden) {
            return 1;
        } else {
            return self.userArray.count+2;
        }
    } else if (section == 1) {
        return 1;
    } else if (section == 2) {
        if (self.emailInfo.attachCount > 0) {
            return 1;
        }
    }
    return 0;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
           return EmailTopDetailCellDefaultHeight;
        } else if (indexPath.row <= self.userArray.count) {
            return EmailUserCellHeight;
        } else {
            return EmailTimeCellHeight;
        }
    }
    if (indexPath.section == 1) {
        return webViewHeight;
    }
    if (indexPath.section == 2) {
        CGFloat itemW = (SCREEN_WIDTH-32-4)/2;
        CGFloat itemH = itemW*(128.0/170);
        CGFloat rows = self.emailInfo.attachCount/2 + self.emailInfo.attachCount%2;
        return rows*itemH+((rows-1)*4)+32;
    }
    return 0;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            EmailTopDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailTopDetailCellResue];
            if (isHidden) {
                [cell.hiddenBtn setTitle:@"Details" forState:UIControlStateNormal];
                cell.lineView.hidden = NO;
            } else {
                cell.lineView.hidden = YES;
                [cell.hiddenBtn setTitle:@"Hide" forState:UIControlStateNormal];
            }
            [cell setEmialInfoModel:self.emailInfo];
            
            [cell setHiddenBlock:^{
                self->isHidden = !self->isHidden;
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
            }];
            return cell;
        } else if (indexPath.row <= self.userArray.count) {
             EmailUserCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailUserCellResue];
            EmailUserModel *model = [self.userArray objectAtIndex:indexPath.row-1];
            [cell setUserModel:model];
            return cell;
        } else {
            EmailTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailTimeCellResue];
            cell.lblTime.text = [self.emailInfo.revDate formattedDateYearYueRi:@"dd/MM/yyy HH:mm"];
            return cell;
        }
    } else if (indexPath.section == 1) {
        EmailContentCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailContentCellResue];
        if (!cell.webView.delegate) {
            self.myWebView = cell.webView;
            self.wbScrollView = self.myWebView.scrollView;
            self.wbScrollView.scrollEnabled = NO;
            self.myWebView.delegate = self;
            [self.myWebView sizeToFit];
            self.myWebView.scalesPageToFit = NO;
            [cell setWebViewHtmlContent:self.emailInfo.htmlContent];
            // 添加进度观察者
//            [self.myWebView addObserver:self
//                           forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
//                              options:0
//                              context:nil];
        }
        return cell;
    } else if (indexPath.section == 2) {
         EmailAttchCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailAttchCellResue];
        [cell setAttchs:self.emailInfo.attchArray];
        return cell;
    }
    return nil;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    [webView stringByEvaluatingJavaScriptFromString:@"document.body.style.zoom=1.0"];
//    webView.hidden = YES;
    
    
}

//获取宽度已经适配于webView的html。这里的原始html也可以通过js从webView里获取
- (NSString *)htmlAdjustWithPageWidth:(CGFloat )pageWidth
                                 html:(NSString *)html
                              webView:(UIWebView *)webView
{
    NSMutableString *str = [NSMutableString stringWithString:html];
    //计算要缩放的比例
    CGFloat initialScale = webView.frame.size.width/pageWidth;
    if (initialScale > 1) {
        initialScale = 1;
    }
    //将</head>替换为meta+head
    NSString *stringForReplace = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\" initial-scale=%f, minimum-scale=0.1, maximum-scale=2.0, user-scalable=yes\"></head>",initialScale];
    
    NSRange range =  NSMakeRange(0, str.length);
    //替换
    [str replaceOccurrencesOfString:@"</head>" withString:stringForReplace options:NSLiteralSearch range:range];
    return str;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
    
    
    
    //若已经加载完成，则显示webView并return
    if(isLoadingFinished)
    {
        CGFloat newHeight =  [[webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollHeight "] floatValue];
       // NSString *bodyWidth= [webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollWidth "];
       // CGFloat initialScale = webView.frame.size.width/[bodyWidth floatValue];

       // newHeight = newHeight*initialScale;
        newHeight = webView.scrollView.contentSize.height;
        NSLog(@"--%f---%f",newHeight,webView.scrollView.contentSize.height);
        
        if (self->webViewHeight != newHeight) {
            self->webViewHeight = newHeight;
            [self.mainTabV reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }
        return;
    }
    
    //js获取body宽度
    NSString *bodyWidth= [webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollWidth "];
    
    int widthOfBody = [bodyWidth intValue];
    
    //获取实际要显示的html
    NSString *html = [self htmlAdjustWithPageWidth:widthOfBody
                                              html:self.emailInfo.htmlContent
                                           webView:webView];
    self.emailInfo.htmlContent = html;
    //设置为已经加载完成
    isLoadingFinished = YES;
    //加载实际要现实的html
    [self.myWebView loadHTMLString:html baseURL:nil];
    
    
    /*
    webView.hidden = NO;
    [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.body.style.zoom=%lf",SCREEN_WIDTH/webView.scrollView.contentSize.width-0.00001]];
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.textAlign = 'center';"];
    
    CGFloat newHeight =  [[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById('content').offsetHeight;"] floatValue];
    
    NSLog(@"--%f---%f",newHeight,webView.scrollView.contentSize.height);

    if (self->webViewHeight != newHeight) {
        self->webViewHeight = newHeight;
        [self.mainTabV reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
     */
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSString* requestURL = request.URL.absoluteString;
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:requestURL] options:@{} completionHandler:^(BOOL success) {
            
        }];
        return NO;
    }
    return YES;
    
}

/*
#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if ([scrollView isEqual:self.mainTabV]) {
      
        CGFloat yOffSet = scrollView.contentOffset.y;
    
        if (yOffSet <= 0) {
            self.wbScrollView.scrollEnabled = YES;
            self.mainTabV.bounces = NO;
        }else{
            self.wbScrollView.scrollEnabled = NO;
            self.mainTabV.bounces = YES;
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
    NSLog(@"加载完成");
    //这个方法也可以计算出webView滚动视图滚动的高度
    @weakify_self
    [webView evaluateJavaScript:@"document.body.scrollWidth"completionHandler:^(id _Nullable result,NSError * _Nullable error){
        
        NSLog(@"scrollWidth高度：%.2f",[result floatValue]);
        CGFloat ratio =  CGRectGetWidth(self.myWebView.frame) /[result floatValue];
        
        [webView evaluateJavaScript:@"document.body.scrollHeight"completionHandler:^(id _Nullable result,NSError * _Nullable error){
            NSLog(@"scrollHeight高度：%.2f",[result floatValue]);
            NSLog(@"scrollHeight计算高度：%.2f",[result floatValue]*ratio);
            CGFloat newHeight = [result floatValue]*ratio;
            
            if (self->webViewHeight != newHeight) {
                self->webViewHeight = newHeight;
                [weakSelf.mainTabV reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
            }
            
            //KVO监听网页内容高度变化
            if (newHeight < CGRectGetHeight(self.view.frame)) {
                //如果webView此时还不是满屏，就需要监听webView的变化  添加监听来动态监听内容视图的滚动区域大小
                [weakSelf.wbScrollView addObserver:weakSelf forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            }
        }];
        
    }];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    // NSStringLocalizable(@"request_error")
    NSLog(@"didFailProvisionalNavigation");
}
// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    NSLog(@"didFailProvisionalNavigation");
}
// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    
}
//kvo 监听进度
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    
    if ([keyPath isEqualToString:@"contentSize"]) {
        //更具内容的高重置webView视图的高度
        NSLog(@"Height is changed! new=%@", [change valueForKey:NSKeyValueChangeNewKey]);
        NSLog(@"tianxia :%@",NSStringFromCGSize(self.myWebView.scrollView.contentSize));
        CGFloat newHeight = self.myWebView.scrollView.contentSize.height;
        
        NSLog(@"offsetHeight高度：%.2f",newHeight);
        
        if (webViewHeight != newHeight) {
            webViewHeight = newHeight;
            [self.mainTabV reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }
    } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(estimatedProgress))]
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
//        [super observeValueForKeyPath:keyPath
//                             ofObject:object
//                               change:change
//                              context:context];
    }
    
}
*/
-(void)dealloc{
//    [_myWebView removeObserver:self
//                    forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    _myWebView.delegate = nil;
  
}


@end
