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
#import "PNEmailOptionEnumView.h"
#import "PNEmailPreViewController.h"
#import "EmailAttchModel.h"
//#import <WebKit/WebKit.h>
#import "EmailOptionUtil.h"
#import "PNEmailMoveViewController.h"
#import "PNEmailSendViewController.h"
#import "NSString+HexStr.h"

@interface PNEmailDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>//WKNavigationDelegate
{
    CGFloat webViewHeight;
    BOOL isLoadingFinished;
}
@property (nonatomic ,assign) BOOL isMove;
@property (nonatomic ,assign) BOOL isHidden;
@property (weak, nonatomic) IBOutlet UILabel *lblFloderName;
@property (weak, nonatomic) IBOutlet UIButton *nodeBtn;
@property (weak, nonatomic) IBOutlet UITableView *mainTabV;
@property (nonatomic, strong) NSMutableArray *userArray;
//@property (nonatomic ,strong) WKWebView *myWebView;

@property (nonatomic ,strong) UIWebView *myWebView;

@property (nonatomic ,strong) EmailListInfo *emailInfo;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (nonatomic ,strong) UIScrollView *wbScrollView;

@property (nonatomic, strong) PNEmailOptionEnumView *enumView;

@property (weak, nonatomic) IBOutlet UIButton *forwardBtn;
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;

@end

@implementation PNEmailDetailViewController
// 初始化方法
- (id)initWithEmailListModer:(EmailListInfo *)listInfo
{
    if (self = [super init]) {
        self.emailInfo = listInfo;
/*
        static NSString * mainJavascript = @"\
        var imageElements = function() {\
            var imageNodes = document.getElementsByTagName('img');\
            return [].slice.call(imageNodes);\
        };\
        \
        var findCIDImageURL = function() {\
            var images = imageElements();\
            \
            var imgLinks = [];\
            for (var i = 0; i < images.length; i++) {\
                var url = images[i].getAttribute('src');\
                if (url.indexOf('cid:') == 0 || url.indexOf('x-mailcore-image:') == 0)\
                    imgLinks.push(url);\
            }\
            return JSON.stringify(imgLinks);\
        };\
        \
        var replaceImageSrc = function(info) {\
            var images = imageElements();\
            \
            for (var i = 0; i < images.length; i++) {\
                var url = images[i].getAttribute('src');\
                if (url.indexOf(info.URLKey) == 0) {\
                    images[i].setAttribute('src', info.LocalPathKey);\
                    break;\
                }\
            }\
        };\
        ";
        
        self.htmlContent = [NSMutableString string];
        [self.htmlContent appendFormat:@"<html><head><script>%@</script></head>"
         @"<body>%@</body><iframe src='x-mailcore-msgviewloaded:' style='width: 0px; height: 0px; border: none;'>"
         @"</iframe></html>", mainJavascript, self.emailInfo.htmlContent];
 
        self.emailInfo.htmlContent = @"<span style=\"color:#000000; font-size:16px;\">在线等方面取得进展</span><span style=\"color:#000000; font-size:16px;\">……</span><span style=\"color:#000000; font-size:16px;\">一个人</span><span style=\"color:#000000; font-size:16px;\">uuu </span><span style=\"color:#000000; font-size:16px;\">哈哈哈哈哈</span><i><span style=\"color:#000000; font-size:16px;\">永恒不变那你就</span></i><i><span style=\"color:#ffd200; font-size:18px;\">已接近你你你</span></i><span style=\"color:#000000; font-size:16px;\"><br/><br/><br/>-------------</span><span style=\"color:#000000; font-size:16px;\">原始邮件</span><span style=\"color:#000000; font-size:16px;\">-------------<br/><br/></span><span style=\"color:#000000; font-size:16px;\"><br/><br/>-------------</span><span style=\"color:#000000; font-size:16px;\">原始邮件</span><span style=\"color:#000000; font-size:16px;\">-------------<br/><br/><br/>• </span><span style=\"color:#000000; font-size:16px;\">一额一ｕ</span><span style=\"color:#000000; font-size:16px;\">ui</span><span style=\"color:#000000; font-size:16px;\">好多好多好电影</span><span style=\"color:#0caeff; font-size:16px;\">还喜欢喜欢喜欢喜欢的</span><br/><span style=\"color:#000000; font-size:16px;\">发自我的</span><span style=\"color:#000000; font-size:16px;\">iPhone<br/><br/></span>";
 */
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

- (IBAction)clickForwardAction:(id)sender {
    
}
- (IBAction)clickReplyAction:(id)sender {
    
    PNEmailSendViewController *vc = [[PNEmailSendViewController alloc] initWithEmailListInfo:self.emailInfo sendType:ReplyEmail];
    [self presentModalVC:vc animated:YES];
    // 回复
    // 构建邮件体的发送内容
    /*
    MCOMessageBuilder *messageBuilder = [[MCOMessageBuilder alloc] init];
    messageBuilder.header.from = [MCOAddress addressWithDisplayName:@"张三" mailbox:@"111111@qq.com"];   // 发送人
    messageBuilder.header.to = @[[MCOAddress addressWithMailbox:@"222222@qq.com"]];       // 收件人（多人）
    messageBuilder.header.cc = @[[MCOAddress addressWithMailbox:@"@333333qq.com"]];      // 抄送（多人）
    messageBuilder.header.bcc = @[[MCOAddress addressWithMailbox:@"444444@qq.com"]];    // 密送（多人）
    messageBuilder.header.subject = @"测试邮件";    // 邮件标题
    messageBuilder.textBody = @"hello world";           // 邮件正文
    
    
    // 如果邮件是回复或者转发，原邮件中往往有附件以及正文中有其他图片资源，
    // 如果有需要你可将原文原封不动的也带过去，这里发送的正文就可以如下配置
     
    NSString * bodyHtml = @"<p>我是原邮件正文</p>";
    NSString *body = @"我是邮件回复的内容";
    NSMutableString*fullBodyHtml = [NSMutableString stringWithFormat:@"%@<br/>-------------原始邮件-------------<br/>%@",[body stringByReplacingOccurrencesOfString:@"\n"withString:@"<br/>"],bodyHtml];
    [messageBuilder setHTMLBody:fullBodyHtml];
    
    // 添加正文里的附加资源
    NSArray *inattachments = msgPaser.htmlInlineAttachments;
    for (MCOAttachment*attachmentininattachments) {
        [messageBuilder addRelatedAttachment:attachment];    //添加html正文里的附加资源（图片）
    }
    
    // 添加邮件附件
    for (MCOAttachment*attachmentinattachments) {
        [builder addAttachment:attachment];    //添加附件
    }
    */
}
- (IBAction)clickBackBtn:(id)sender {
    if (_isMove) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EMIAL_FLAGS_CHANGE_NOTI object:@(2)];
    }
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)ClickRightBtn:(UIButton *)sender {
    if (sender.tag == 30) {
        if (!self.enumView) {
            self.enumView = [PNEmailOptionEnumView loadPNEmailOptionEnumView];
            @weakify_self
            [self.enumView setEmumBlock:^(NSInteger row) {
                if (row == 0) { //设为未读
                    [weakSelf.view showHudInView:weakSelf.view hint:@""];
                    [EmailOptionUtil setEmailReaded:NO uid:weakSelf.emailInfo.uid folderPath:weakSelf.emailInfo.floderPath complete:^(BOOL success) {
                        [weakSelf.view hideHud];
                        if (!success) {
                            [weakSelf.view showFaieldHudInView:weakSelf.view hint:@"Failure."];
                        } else {
                            [weakSelf.view showSuccessHudInView:weakSelf.view hint:@"Success."];
                            weakSelf.emailInfo.Read -=1;
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:EMIAL_FLAGS_CHANGE_NOTI object:@(0)];
                        }
                    }];
                } else if (row == 1) { // 设为star
                    [weakSelf.view showHudInView:weakSelf.view hint:@""];
                    
                    BOOL isStar = [EmailOptionUtil checkEmailStar:weakSelf.emailInfo.Read];
                    
                    [EmailOptionUtil setEmailStaredUid:weakSelf.emailInfo.uid folderPath:weakSelf.emailInfo.floderPath isAdd:isStar? NO:YES  complete:^(BOOL success) {
                        [weakSelf.view hideHud];
                        if (!success) {
                            [weakSelf.view showFaieldHudInView:weakSelf.view hint:@"Failure."];
                        } else {
                            weakSelf.emailInfo.Read = isStar?weakSelf.emailInfo.Read-4:weakSelf.emailInfo.Read+4;
                            [weakSelf.mainTabV reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                            [weakSelf.view showSuccessHudInView:weakSelf.view hint:@"Success."];
                            [[NSNotificationCenter defaultCenter] postNotificationName:EMIAL_FLAGS_CHANGE_NOTI object:@(1)];
                        }
                    }];
                } else if (row == 2) { // 保存节点
                    
                } else if (row == 3) { // 移动to
                    
                    PNEmailMoveViewController *vc = [[PNEmailMoveViewController alloc] initWithFloderPath:weakSelf.emailInfo.floderPath uid:weakSelf.emailInfo.uid];
                    [vc setMoveBlock:^{
                         [weakSelf.view showSuccessHudInView:weakSelf.view hint:@"Success."];
                        weakSelf.isMove = YES;
                    }];
                    [weakSelf presentModalVC:vc animated:YES];
                    
                } else if (row == 4) { // 删除
                    [weakSelf.view showHudInView:weakSelf.view hint:@""];
                    [EmailOptionUtil deleteEmailUid:weakSelf.emailInfo.uid folderPath:weakSelf.emailInfo.floderPath folderName:weakSelf.emailInfo.floderName complete:^(BOOL success) {
                        [weakSelf.view hideHud];
                        if (success) {
                            [[NSNotificationCenter defaultCenter] postNotificationName:EMIAL_FLAGS_CHANGE_NOTI object:@(3)];
                            [weakSelf leftNavBarItemPressedWithPop:YES];
                        } else {
                            [weakSelf.view showFaieldHudInView:weakSelf.view hint:@"Failure."];
                        }
                    }];
                }
            }];
        }
        BOOL isShowMove = NO;
        if ([self.emailInfo.floderName isEqualToString:Inbox] && !_isMove) {
            isShowMove = YES;
        }
        BOOL isStar = [EmailOptionUtil checkEmailStar:self.emailInfo.Read];
        [self.enumView showEmailOptionEnumViewWithStar:isStar? YES:NO isShowMove:isShowMove];
        
    } else if (sender.tag == 20) { // 删除邮件

        [self.view showHudInView:self.view hint:@""];
        @weakify_self
        [EmailOptionUtil deleteEmailUid:weakSelf.emailInfo.uid folderPath:weakSelf.emailInfo.floderPath folderName:weakSelf.emailInfo.floderName complete:^(BOOL success) {
            [weakSelf.view hideHud];
            if (success) {
                [[NSNotificationCenter defaultCenter] postNotificationName:EMIAL_FLAGS_CHANGE_NOTI object:@(3)];
                [weakSelf leftNavBarItemPressedWithPop:YES];
            } else {
                [weakSelf.view showFaieldHudInView:weakSelf.view hint:@"Failure."];
            }
        }];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    _forwardBtn.layer.cornerRadius = 8.0f;
    _forwardBtn.layer.masksToBounds = YES;
    
    _replyBtn.layer.cornerRadius = 8.0f;
    _replyBtn.layer.masksToBounds = YES;
    _replyBtn.layer.borderColor = MAIN_PURPLE_COLOR.CGColor;
    _replyBtn.layer.borderWidth = 1.0f;
    
    _lblFloderName.text = self.emailInfo.floderName;
    [_progressView setTrackTintColor:[UIColor colorWithRed:240.0/255
                                                     green:240.0/255
                                                      blue:240.0/255
                                                     alpha:1.0]];
    _progressView.progressTintColor = [UIColor greenColor];
    if (self.emailInfo.attachCount > 0) {
         webViewHeight = 200;
    }

    
    _isHidden = YES;
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
        if (_isHidden) {
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
        return rows*itemH+((rows-1)*4)+32+38;
    }
    return 0;
}
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            EmailTopDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:EmailTopDetailCellResue];
            if (_isHidden) {
                [cell.hiddenBtn setTitle:@"Details" forState:UIControlStateNormal];
                cell.lineView.hidden = NO;
            } else {
                cell.lineView.hidden = YES;
                [cell.hiddenBtn setTitle:@"Hide" forState:UIControlStateNormal];
            }
            [cell setEmialInfoModel:self.emailInfo];
            @weakify_self
            [cell setHiddenBlock:^{
                weakSelf.isHidden = !weakSelf.isHidden;
                [weakSelf.mainTabV reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
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
        @weakify_self
        [cell setClickAttBlock:^(NSInteger selItem) {
            EmailAttchModel *model = weakSelf.emailInfo.attchArray[selItem];
            PNEmailPreViewController *vc = [[PNEmailPreViewController alloc] initWithFileName:model.attName fileData:model.attData];
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }];
        return cell;
    }
    return nil;
}




#pragma mark ------------webview -------------------------
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
    NSLog(@"----initialScale = %f---------",initialScale);
    //将</head>替换为meta+head
    NSString *stringForReplace = [NSString stringWithFormat:@"<meta name=\"viewport\" content=\" initial-scale=%f, minimum-scale=0.1, maximum-scale=2.0, user-scalable=yes\"></head>",initialScale];
    
    NSRange range =  NSMakeRange(0, str.length);
    //替换
    [str replaceOccurrencesOfString:@"</head>" withString:stringForReplace options:NSLiteralSearch range:range];
    return str;
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"----didFailLoadWithError---------");
    [self.view showHint:@"Mail load failed"];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"----webViewDidFinishLoad---------");
    //若已经加载完成，则显示webView并return
    if(isLoadingFinished)
    {
        CGFloat newHeight =  [[webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollHeight "] floatValue];
        
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
    
    // [self.mainTabV reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    
    //加载实际要现实的html
    [self.myWebView loadHTMLString:html baseURL:nil];
    
}



-(void)dealloc{
//    [_myWebView removeObserver:self
//                    forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    _myWebView.delegate = nil;
  
}




#pragma mark - webview
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString* requestURL = request.URL.absoluteString;
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:requestURL] options:@{} completionHandler:^(BOOL success) {
            
        }];
        return NO;
    }
  
    return YES;

}


@end
