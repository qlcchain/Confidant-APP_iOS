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
#import "EmailAttchView.h"
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
#import <Masonry/Masonry.h>
#import "MCOCIDURLProtocol.h"

#import "SocketDataUtil.h"
#import "SocketManageUtil.h"
#import "SystemUtil.h"
#import "NSData+Base64.h"
#import "LibsodiumUtil.h"
#import "EntryModel.h"
#import "AESCipher.h"
#import "EmailDataBaseUtil.h"
#import "EmailAccountModel.h"
#import "NSString+Base64.h"



@interface PNEmailDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>//WKNavigationDelegate
{
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

@property (nonatomic, strong) NSMutableString *htmlContent;
@property (nonatomic, strong) MCOMessageParser *messageParser;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webH;
@property (weak, nonatomic) IBOutlet UIWebView *webV;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tabH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *attchH;

@property (weak, nonatomic) IBOutlet UIView *attBackView;
@property (nonatomic, strong) EmailAttchView *attchView;

@end

@implementation PNEmailDetailViewController
// 初始化方法
- (id)initWithEmailListModer:(EmailListInfo *)listInfo
{
    if (self = [super init]) {
        self.emailInfo = listInfo;
//        __block NSString *dsKey = @"";
//        if (listInfo.htmlContent && listInfo.htmlContent.length > 0 && (!self.emailInfo.clearEnHtmlContent || self.emailInfo.clearEnHtmlContent.length == 0)) {
//           NSArray *arrs = [self.emailInfo.htmlContent componentsSeparatedByString:@"confidantkey=\n'"];
//            if (arrs && arrs.count == 2) {
//                self.emailInfo.clearEnHtmlContent = [self.emailInfo.htmlContent stringByReplacingOccurrencesOfString:@"confidantkey=" withString:@"key"];
//                 EmailAccountModel *accountM =[EmailAccountModel getConnectEmailAccount];
//
//                NSString *enStr = [[arrs lastObject] componentsSeparatedByString:@"'></span>"][0];
//               NSArray *emailUserkeys = [enStr componentsSeparatedByString:@"##"];
//                if (emailUserkeys && emailUserkeys.count > 0) {
//                    [emailUserkeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                        NSString *uks = obj;
//                        NSArray *userkeys = [uks componentsSeparatedByString:@"&amp;&amp;"];
//                        if ([accountM.User isEqualToString:[userkeys[0] base64DecodedString]]) {
//                            dsKey = userkeys[1];
//                        }
//                    }];
//                }
//            }
//        }
//        if (!self.emailInfo.clearEnHtmlContent || self.emailInfo.clearEnHtmlContent.length == 0) {
//            self.emailInfo.clearEnHtmlContent = self.emailInfo.htmlContent;
//        }
//
//        if (dsKey.length > 0) {
//            NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:dsKey];
//            datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
//            NSString *bodyStr = [self.emailInfo.clearEnHtmlContent componentsSeparatedByString:@"</body>"][0];
//            NSString *enStr = [[bodyStr componentsSeparatedByString:@"<body>"] lastObject];
//            NSString *spanStr = [enStr componentsSeparatedByString:@"<span style='display:none'"][0];
//            NSString *deStr = aesDecryptString(spanStr, datakey)?:@"";
//            self.emailInfo.clearEnHtmlContent = [self.emailInfo.clearEnHtmlContent stringByReplacingOccurrencesOfString:enStr withString:deStr];
//            self.emailInfo.deKey = datakey;
//            //fileData = aesDecryptData(fileData, [datakey dataUsingEncoding:NSUTF8StringEncoding]);
//        }
        
        
        NSMutableString * html = [NSMutableString string];
        [html appendFormat:@"<html><head><script>%@</script><style>%@</style></head>"
         @"<body>%@</body><iframe src='x-mailcore-msgviewloaded:' style='width: 0px; height: 0px; border: none;'>"
         @"</iframe></html>", mainJavascript, mainStyle, self.emailInfo.htmlContent];
        self.htmlContent = html;
        
        self.messageParser = [MCOMessageParser messageParserWithData:self.emailInfo.parserData];
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
    
    if (self.emailInfo.attachCount > 0) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"Does it include the attachment in the original email?" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        @weakify_self
        UIAlertAction *delAction = [UIAlertAction actionWithTitle:@"Including" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf forwardJumpSendVCWithAttch:YES];
        }];
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Not Include" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf forwardJumpSendVCWithAttch:NO];
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVC addAction:delAction];
        [alertVC addAction:saveAction];
        [alertVC addAction:cancelAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    } else {
        [self forwardJumpSendVCWithAttch:NO];
    }
}
- (void) forwardJumpSendVCWithAttch:(BOOL) isAttch
{
    PNEmailSendViewController *vc = [[PNEmailSendViewController alloc] initWithEmailListInfo:self.emailInfo sendType:ForwardEmail isShowAttch:isAttch];
    [self presentModalVC:vc animated:YES];
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
    if ([self.emailInfo.floderName isEqualToString:Starred]) {
         BOOL isStar = [EmailOptionUtil checkEmailStar:self.emailInfo.Read];
        if (!isStar) { // 星标文件夹取消星标
            [[NSNotificationCenter defaultCenter] postNotificationName:EMIAL_FLAGS_CHANGE_NOTI object:@(4)];
        }
        
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
                            if (![weakSelf.emailInfo.floderName isEqualToString:Starred]) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:EMIAL_FLAGS_CHANGE_NOTI object:@(1)];
                            }
                            
                            if (isStar) { // 取消star
                                
                                [EmailDataBaseUtil delEmialStarWithEmialInfo:weakSelf.emailInfo];
                            } else { // star
                                // 保存数据
                                if (weakSelf.emailInfo.toUserArray && weakSelf.emailInfo.toUserArray.count > 0) {
                                    weakSelf.emailInfo.ToJson = [[EmailUserModel mj_keyValuesArrayWithObjectArray:weakSelf.emailInfo.toUserArray] mj_JSONString];
                                }
                                if (weakSelf.emailInfo.ccUserArray && weakSelf.emailInfo.ccUserArray.count > 0) {
                                    weakSelf.emailInfo.ccJsons = [[EmailUserModel mj_keyValuesArrayWithObjectArray:weakSelf.emailInfo.ccUserArray] mj_JSONString];
                                }
                                if (weakSelf.emailInfo.bccUserArray && weakSelf.emailInfo.bccUserArray.count > 0) {
                                    weakSelf.emailInfo.bccJsons = [[EmailUserModel mj_keyValuesArrayWithObjectArray:weakSelf.emailInfo.bccUserArray] mj_JSONString];
                                }
                                [EmailDataBaseUtil addEmialStarWithEmialInfo:weakSelf.emailInfo];
                            }
                            
                           
                        }
                    }];
                } else if (row == 2) { // 保存节点
                    [weakSelf saveEmailToNode];
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
    
    _isHidden = YES;
    _mainTabV.delegate = self;
    _mainTabV.dataSource = self;
    _mainTabV.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _mainTabV.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_mainTabV registerNib:[UINib nibWithNibName:EmailTopDetailCellResue bundle:nil] forCellReuseIdentifier:EmailTopDetailCellResue];
    [_mainTabV registerNib:[UINib nibWithNibName:EmailUserCellResue bundle:nil] forCellReuseIdentifier:EmailUserCellResue];
    [_mainTabV registerNib:[UINib nibWithNibName:EmailTimeCellResue bundle:nil] forCellReuseIdentifier:EmailTimeCellResue];
    
    
//    [_progressView setTrackTintColor:[UIColor colorWithRed:240.0/255
//                                                     green:240.0/255
//                                                      blue:240.0/255
//                                                     alpha:1.0]];
//    _progressView.progressTintColor = [UIColor greenColor];
//    // 添加进度观察者
//    [_myWebView addObserver:self
//                 forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
//                    options:0
//                    context:nil];
    
    self.myWebView = self.webV;
    self.wbScrollView = self.myWebView.scrollView;
    self.wbScrollView.bounces = NO;
    //           self.wbScrollView.scrollEnabled = NO;
    //            self.myWebView.delegate = self;
    //           self.myWebView.scalesPageToFit = YES;
    [self.myWebView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
    self.myWebView.opaque = NO; //去掉底部黑色
    [self.myWebView setDelegate:self];
    
    
    if (self.emailInfo.attachCount > 0) {
        CGFloat itemW = (SCREEN_WIDTH-32-4)/2;
        CGFloat itemH = itemW*(128.0/170);
        CGFloat rows = self.emailInfo.attachCount/2 + self.emailInfo.attachCount%2;
        _attchH.constant = rows*itemH+((rows-1)*4)+32+35;
        
        _attchView = [[[NSBundle mainBundle] loadNibNamed:@"EmailAttchView" owner:self options:nil] lastObject];
        _attchView.frame = CGRectZero;
        [_attBackView addSubview:_attchView];
        @weakify_self
        [_attchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.mas_equalTo(weakSelf.attBackView).offset(0);
        }];
        [_attchView setAttchs:self.emailInfo.attchArray deKey:self.emailInfo.deKey];
      
        [_attchView setClickAttBlock:^(NSInteger selItem) {
            EmailAttchModel *model = weakSelf.emailInfo.attchArray[selItem];
            if (weakSelf.emailInfo.deKey && weakSelf.emailInfo.deKey.length > 0) {
                PNEmailPreViewController *vc = [[PNEmailPreViewController alloc] initWithFileName:model.attName fileData:aesDecryptData(model.attData, [weakSelf.emailInfo.deKey dataUsingEncoding:NSUTF8StringEncoding])];
                 [weakSelf.navigationController pushViewController:vc animated:YES];
            } else {
                PNEmailPreViewController *vc = [[PNEmailPreViewController alloc] initWithFileName:model.attName fileData:model.attData];
                 [weakSelf.navigationController pushViewController:vc animated:YES];
            }
            
           
        }];
        
    } else {
        _attchH.constant = 0;
    }
    
    _webH.constant = SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - 128 - 82 - HOME_INDICATOR_HEIGHT - _attchH.constant;
    
    [self.myWebView loadHTMLString:self.htmlContent baseURL:nil];
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
                _tabH.constant = 128;
            } else {
                cell.lineView.hidden = YES;
                [cell.hiddenBtn setTitle:@"Hide" forState:UIControlStateNormal];
                _tabH.constant = 128+(_userArray.count*37)+33;
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
 //           self.wbScrollView.scrollEnabled = NO;
//            self.myWebView.delegate = self;
 //           self.myWebView.scalesPageToFit = YES;
            [self.myWebView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
            [self.myWebView setDelegate:self];
            [cell setWebViewHtmlContent:self.htmlContent];
            // 添加进度观察者
//            [self.myWebView addObserver:self
//                           forKeyPath:NSStringFromSelector(@selector(estimatedProgress))
//                              options:0
//                              context:nil];
        }
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
  //  [self.view showHint:@"Mail load failed"];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"----webViewDidFinishLoad---------");
    //若已经加载完成，则显示webView并return
    if(!isLoadingFinished)
    {
        CGFloat newHeight =  [[webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollHeight "] floatValue];
        
        newHeight = webView.scrollView.contentSize.height;
        NSLog(@"--%f---%f",newHeight,webView.scrollView.contentSize.height);
        if (newHeight > _webH.constant) {
            _webH.constant = newHeight;
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
  //  [_myWebView removeObserver:self
                    //forKeyPath:NSStringFromSelector(@selector(estimatedProgress))];
    _myWebView.delegate = nil;
}




#pragma mark - webview

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString* requestURL = request.URL.absoluteString;

    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:requestURL] options:@{} completionHandler:^(BOOL success) {

        }];
        return NO;
    } else {
        NSURLRequest*responseRequest = [self webView:webView resource:nil willSendRequest:request redirectResponse:nil fromDataSource:nil];
        if(responseRequest== request) {
            return YES;
        } else {
            [webView loadRequest:responseRequest];
            return NO;
        }
    }
//    NSURLRequest*responseRequest = [self webView:webView resource:nil willSendRequest:request redirectResponse:nil fromDataSource:nil];
//    if(responseRequest== request) {
//        return YES;
//    } else {
//        [webView loadRequest:responseRequest];
//        return NO;
//    }
}

- (NSURLRequest *)webView:(UIWebView *)sender resource:(id)identifier willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse fromDataSource:(id)dataSource

{
   if ([[[request URL] scheme] isEqualToString:@"x-mailcore-msgviewloaded"]) {
        [self _loadImages];
   }
    return request;
}

//加载网页中的图片

- (void) _loadImages

{
    
    NSString * result = [self.myWebView stringByEvaluatingJavaScriptFromString:@"findCIDImageURL()"];
    
    NSLog(@"-----加载网页中的图片-----");
    
    NSLog(@"%@", result);
    
    if (result==nil || [result isEqualToString:@""]) {
        return;
    }
    
    NSData * data = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSArray * imagesURLStrings = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    for(NSString * urlString in imagesURLStrings) {
        MCOAbstractPart * part =nil;
        NSURL * url;
        url = [NSURL URLWithString:urlString];
        if ([MCOCIDURLProtocol isCID:url]) {
            part = [self _partForCIDURL:url];
        } else if ([MCOCIDURLProtocol isXMailcoreImage:url]) {
            NSString * specifier = [url resourceSpecifier];
            NSString * partUniqueID = specifier;
            part = [self _partForUniqueID:partUniqueID];
        }
        if (part == nil)
            continue;
            NSString * partUniqueID = [part uniqueID];
            MCOAttachment * attachment = (MCOAttachment *) [_messageParser partForUniqueID:partUniqueID];
            NSData * data =[attachment data];
            if (data!=nil) {
                //获取文件路径
                NSString *tmpDirectory =NSTemporaryDirectory();
                NSString *filePath=[tmpDirectory stringByAppendingPathComponent : attachment.filename ];
                NSFileManager *fileManger=[NSFileManager defaultManager];
                if (![fileManger fileExistsAtPath:filePath]) {//不存在就去请求加载
                    NSData *attachmentData=[attachment data];
                    [attachmentData writeToFile:filePath atomically:YES];
                    NSLog(@"资源：%@已经下载至%@", attachment.filename,filePath);
                }
                NSURL * cacheURL = [NSURL fileURLWithPath:filePath];
            
                NSDictionary * args =@{@"URLKey": urlString,@"LocalPathKey": cacheURL.absoluteString};
                NSString * jsonString = [self _jsonEscapedStringFromDictionary:args];
                NSString * replaceScript = [NSString stringWithFormat:@"replaceImageSrc(%@)", jsonString];
                [self.myWebView stringByEvaluatingJavaScriptFromString:replaceScript];
            }
    }
}

- (NSString *)_jsonEscapedStringFromDictionary:(NSDictionary *)dictionary

{
    NSData * json = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:nil];
    NSString * jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    return jsonString;
    
}

- (NSURL *) _cacheJPEGImageData:(NSData *)imageData withFilename:(NSString *)filename

{
    NSString * path = [[NSTemporaryDirectory()stringByAppendingPathComponent:filename]stringByAppendingPathExtension:@"jpg"];
    [imageData writeToFile:path atomically:YES];
    return [NSURL fileURLWithPath:path];
    
}

- (MCOAbstractPart *) _partForCIDURL:(NSURL *)url

{
    return [_messageParser partForContentID:[url resourceSpecifier]];
}

- (MCOAbstractPart *) _partForUniqueID:(NSString *)partUniqueID

{
    return [_messageParser partForUniqueID:partUniqueID];
    
}

#pragma mark ---------------保存到节点-------------
- (void) saveEmailToNode
{
    [AppD.window showHudInView:AppD.window hint:Uploading_Str];
    
    NSString *fileid = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    
    // 生成32位对称密钥
    NSString *msgKey = [SystemUtil get32AESKey];
   
    NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
    NSString *symmetKey = [symmetData base64EncodedString];
   
    // 自己公钥加密对称密钥
    NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
    
    NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
    NSData *enData = aesEncryptData(self.emailInfo.parserData,msgKeyData);
    
    SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
    [dataUtil sendEmailToId:@"" fileName:fileid fileData:enData fileid:fileid fileType:7 srcKey:srcKey];
    [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
}

@end
