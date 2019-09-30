//
//  PNEmailSendViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNEmailSendViewController.h"
#import "EmailListInfo.h"
#import "PNEmailContactViewController.h"
#import "EmailContactModel.h"
#import "EmailUserModel.h"
#import "HXAttributedString.h"

#import "AttchCollectionCell.h"
#import "AttchImgageCell.h"
#import "EmailAttchModel.h"
#import "SystemUtil.h"
#import "NSDate+Category.h"

#import "PNEmailAttchSelView.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <YBImageBrowser/YBImageBrowser.h>
#import "PNDocumentPickerViewController.h"
#import "TZImagePickerController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "NSString+Trim.h"

#import "SIXEditorView.h"
#import "SIXHTMLParser.h"
#import "EmailManage.h"
#import "EmailAccountModel.h"
#import "EmailOptionUtil.h"
#import "NSString+RegexCategory.h"
#import "UserConfig.h"
//#import <IQKeyboardManager/IQKeyboardManager.h>


#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "AESCipher.h"
#import "EmailUserKeyModel.h"
#import "MCOCIDURLProtocol.h"
#import "PNEmailPreViewController.h"

#import "EmailDataBaseUtil.h"

#import "PNEmailContactView.h"

#import <IQKeyboardManager/IQKeyboardManager.h>

@interface PNEmailSendViewController ()<UITextViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UINavigationControllerDelegate,
UIImagePickerControllerDelegate,TZImagePickerControllerDelegate,UIDocumentPickerDelegate,YBImageBrowserDelegate,UIWebViewDelegate>
{
    YBImageBrowser *browser;
}

@property (nonatomic, strong) PNEmailContactView *contactView;

@property (weak, nonatomic) IBOutlet UIButton *sendBtn;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextView *toTF;
@property (weak, nonatomic) IBOutlet UITextView *ccTF;
@property (weak, nonatomic) IBOutlet UITextView *bccTF;
@property (weak, nonatomic) IBOutlet UITextView *subTF;
@property (weak, nonatomic) IBOutlet SIXEditorView *contentTF;
@property (weak, nonatomic) IBOutlet UICollectionView *attchCollectinView;
@property (weak, nonatomic) IBOutlet UILabel *lblSend;
@property (weak, nonatomic) IBOutlet UIButton *attCountBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subContraintH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentContraintH;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *AttCollectionContraintH;
@property (nonatomic ,assign) int selContactType; // 1:收件人 2: 抄送人
@property (nonatomic, strong) EmailListInfo *emailInfo;
@property (nonatomic, strong) NSString *toAddress;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toTFH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ccTFH;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bccTFH;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bccBackH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ccBackH;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webH;
@property (weak, nonatomic) IBOutlet UIWebView *myWebView;

@property (nonatomic, strong) NSMutableArray *contactArray;
@property (nonatomic, strong) NSString *emailStrings;
@property (nonatomic, strong) NSMutableArray *toContacts;
@property (nonatomic, strong) NSMutableArray *ccContacts;
@property (nonatomic, strong) NSMutableArray *bccContacts;
    @property (weak, nonatomic) IBOutlet UIImageView *lockImgView;
@property (weak, nonatomic) IBOutlet UIScrollView *mainScrollView;

@property (nonatomic ,strong) UITextView *selTextView;

@property (nonatomic, strong) NSMutableArray *attchArray;

@property (nonatomic ,strong) PNEmailAttchSelView *selAttchView;
// 转发时是否包含附件
@property (nonatomic, assign) BOOL isShowAttchs;

@property (nonatomic, strong) NSMutableString *htmlContent;
@property (nonatomic, strong) MCOMessageParser *messageParser;
    @property (nonatomic, assign) BOOL isSend;
@end

@implementation PNEmailSendViewController
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
     _myWebView.delegate = nil;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = NO;
   // [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.view endEditing:YES];
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
    [super viewWillDisappear:animated];
    
   //[IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    
}
#pragma mark ---------IBOUT BTN CLICK
- (IBAction)clickShowUserActin:(UIButton *)sender {
    if (!sender.selected) {
        [self textDidChange:_ccTF];
        [self textDidChange:_bccTF];
    } else {
        _ccBackH.constant = 0;
        _bccBackH.constant = 0;
    }
    sender.selected = !sender.selected;
}
- (IBAction)clickSelToUserAction:(id)sender {
    self.selTextView = _toTF;
    _selContactType = 1;
    PNEmailContactViewController *vc = [[PNEmailContactViewController alloc] init];
    [self presentModalVC:vc animated:YES];
    

}
- (IBAction)clickSelCCUserAction:(id)sender {
    self.selTextView = _ccTF;
    _selContactType = 2;
    PNEmailContactViewController *vc = [[PNEmailContactViewController alloc] init];
    [self presentModalVC:vc animated:YES];
    
    
}
- (IBAction)clickSelBCCUserAction:(id)sender {
    self.selTextView = _bccTF;
    _selContactType = 3;
    PNEmailContactViewController *vc = [[PNEmailContactViewController alloc] init];
    [self presentModalVC:vc animated:YES];
    
}

- (IBAction)clickBackAction:(id)sender {
     [self.view endEditing:YES];
    if (!self.emailInfo || ![self.emailInfo.floderName isEqualToString:Drafts]) {
        if (self.toContacts.count > 0 || self.subTF.text.trim.length > 0 || self.contentTF.text.length > 0 || self.attchArray.count > 1) {
            UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            @weakify_self
            UIAlertAction *delAction = [UIAlertAction actionWithTitle:@"Delete Draft" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf deleteDraft];
            }];
            UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"Save Draft" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf saveDraft];
            }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [alertVC addAction:delAction];
            [alertVC addAction:saveAction];
            [alertVC addAction:cancelAction];
            
            [self presentViewController:alertVC animated:YES completion:nil];
            
            return;
        }
    }
    
    [self leftNavBarItemPressedWithPop:NO];
}
#pragma mark--------------保存或删除到草稿箱------------------
- (void) deleteDraft
{
    [self leftNavBarItemPressedWithPop:NO];
//    if (self.emailInfo && [self.emailInfo.floderName isEqualToString:Drafts]) {
//        [EmailOptionUtil deleteEmailUid:self.emailInfo.uid folderPath:self.emailInfo.floderPath folderName:self.emailInfo.floderName complete:^(BOOL success) {
//
//        }];
//    } else {
//        [self leftNavBarItemPressedWithPop:NO];
//    }
}
- (MCOMessageBuilder*) getSendMessageBuilder
{
    EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    // 构建邮件体的发送内容
    MCOMessageBuilder *messageBuilder = [[MCOMessageBuilder alloc] init];
    // 发送人
    messageBuilder.header.from = [MCOAddress addressWithDisplayName:[[accountM.User componentsSeparatedByString:@"@"] firstObject]  mailbox:accountM.User];
    // 收件人（多人）
    NSMutableArray *toArr = [NSMutableArray array];
    [self.toContacts enumerateObjectsUsingBlock:^(EmailContactModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MCOAddress *addresM = [MCOAddress addressWithDisplayName:obj.userName mailbox:obj.userAddress];
        [toArr addObject:addresM];
    }];
    messageBuilder.header.to = toArr;
    
    // 抄送（多人）
    NSMutableArray *ccArr = [NSMutableArray array];
    [self.ccContacts enumerateObjectsUsingBlock:^(EmailContactModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MCOAddress *addresM = [MCOAddress addressWithDisplayName:obj.userName mailbox:obj.userAddress];
        [ccArr addObject:addresM];
    }];
    messageBuilder.header.cc = ccArr;
    
    // 密送（多人）
    NSMutableArray *bccArr = [NSMutableArray array];
    [self.bccContacts enumerateObjectsUsingBlock:^(EmailContactModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MCOAddress *addresM = [MCOAddress addressWithDisplayName:obj.userName mailbox:obj.userAddress];
        [bccArr addObject:addresM];
    }];
    messageBuilder.header.bcc = bccArr;
    
    // 邮件标题
    messageBuilder.header.subject = _subTF.text;
    // 邮件正文
    messageBuilder.textBody = _contentTF.text;
    // 添加附件
    NSMutableArray *attchs = [NSMutableArray arrayWithArray:self.attchArray];
    if (attchs.count > 1) {
        [attchs removeLastObject];
        __block NSMutableArray *attachMents = [NSMutableArray arrayWithCapacity:attchs.count];
        [attchs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EmailAttchModel *attchM = obj;
            MCOAttachment *attachment = [MCOAttachment attachmentWithData:attchM.attData filename:attchM.attName];
            [attachMents addObject:attachment];
        }];
        messageBuilder.attachments = attachMents;
    }
    
    // 添加正文里的附加资源
    if (self.emailInfo && self.emailInfo.parserData) {
      MCOMessageParser *msgPaser = [MCOMessageParser messageParserWithData:self.emailInfo.parserData];
        NSArray *inattachments = msgPaser.htmlInlineAttachments;
        for (MCOAttachment*attachment in inattachments) {
            [attachment setInlineAttachment:YES];
            [attachment setAttachment:YES];
            [messageBuilder addRelatedAttachment:attachment];
            //添加html正文里的附加资源（图片）
        }
    }
    
    return messageBuilder;
}
- (void) saveDraft {
    
    MCOMessageBuilder *messageBuilder = [self getSendMessageBuilder];
    
   
   
    @weakify_self
    [SIXHTMLParser htmlStringWithAttributedText:_contentTF.attributedText
                                    orignalHtml:@""
                           andCompletionHandler:^(NSString *html) {
                               
                               if (weakSelf.emailInfo.htmlContent && weakSelf.emailInfo.htmlContent.length > 0) {
                                   html = [html stringByAppendingString:weakSelf.emailInfo.htmlContent];
                               }
                               [messageBuilder setHTMLBody:html];
                               // 发送邮件
                               NSData * rfc822Data =[messageBuilder data];
                               [EmailOptionUtil createDraft:rfc822Data complete:^(BOOL success) {
                                   
                               }];
                               [weakSelf leftNavBarItemPressedWithPop:NO];
                           }];
}
- (void) checkIsEncode
{
    NSMutableArray *emails = [NSMutableArray array];
    if (self.toContacts && self.toContacts.count > 0) {
        __block BOOL isEmail = YES;
        [self.toContacts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EmailContactModel *contactM = obj;
            contactM.userAddress = [NSString trimWhitespace:contactM.userAddress];
            if (![contactM.userAddress isEmailAddress]) {
                isEmail = NO;
                *stop = YES;
            }
            [emails addObject:[[contactM.userAddress lowercaseString] base64EncodedString]];
        }];
        if (!isEmail) {
            _lockImgView.hidden = YES;
            return;
        }
        
        
    }
    if (self.ccContacts && self.ccContacts.count > 0) {
        __block BOOL isEmail = YES;
        [self.ccContacts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EmailContactModel *contactM = obj;
            contactM.userAddress = [NSString trimWhitespace:contactM.userAddress];
            if (![contactM.userAddress isEmailAddress]) {
                isEmail = NO;
                *stop = YES;
            }
            [emails addObject:[[contactM.userAddress lowercaseString] base64EncodedString]];
        }];
        if (!isEmail) {
            _lockImgView.hidden = YES;
            return;
        }
    }
    if (self.bccContacts && self.bccContacts.count > 0) {
        __block BOOL isEmail = YES;
        [self.bccContacts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EmailContactModel *contactM = obj;
            contactM.userAddress = [NSString trimWhitespace:contactM.userAddress];
            if (![contactM.userAddress isEmailAddress]) {
                isEmail = NO;
                *stop = YES;
            }
            [emails addObject:[[contactM.userAddress lowercaseString] base64EncodedString]];
        }];
        if (!isEmail) {
            _lockImgView.hidden = YES;
            return;
        }
    }
    if (emails.count <= 30) {
        self.isSend = NO;
        NSString *emailStrings = [emails componentsJoinedByString:@","];
        [SendRequestUtil sendEmailUserkeyWithUsers:emailStrings unum:@(emails.count) ShowHud:NO];
    } else {
        _lockImgView.hidden = YES;
        return;
    }
}
- (IBAction)clickSendAction:(id)sender {
    [self.view endEditing:YES];
    EmailAccountModel *accountModel = [EmailAccountModel getConnectEmailAccount];
    NSMutableArray *emails = [NSMutableArray array];
    if (self.toContacts && self.toContacts.count > 0) {
       __block BOOL isEmail = YES;
        [self.toContacts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EmailContactModel *contactM = obj;
            contactM.userAddress = [NSString trimWhitespace:contactM.userAddress];
            if (![contactM.userAddress isEmailAddress]) {
                isEmail = NO;
                *stop = YES;
            }
            [emails addObject:[[contactM.userAddress lowercaseString] base64EncodedString]];
            [EmailDataBaseUtil insertDataWithUser:accountModel.User userName:contactM.userName userAddress:contactM.userAddress date:[NSDate date]];
        }];
        if (!isEmail) {
            [self.view showHint:@"To: Not a valid email address"];
            return;
        }
    }
    if (self.ccContacts && self.ccContacts.count > 0) {
        __block BOOL isEmail = YES;
        [self.ccContacts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EmailContactModel *contactM = obj;
            contactM.userAddress = [NSString trimWhitespace:contactM.userAddress];
            if (![contactM.userAddress isEmailAddress]) {
                isEmail = NO;
                *stop = YES;
            }
            [emails addObject:[[contactM.userAddress lowercaseString] base64EncodedString]];
            [EmailDataBaseUtil insertDataWithUser:accountModel.User userName:contactM.userName userAddress:contactM.userAddress date:[NSDate date]];
        }];
        if (!isEmail) {
            [self.view showHint:@"Cc: Not a valid email address"];
            return;
        }
    }
    if (self.bccContacts && self.bccContacts.count > 0) {
        __block BOOL isEmail = YES;
        [self.bccContacts enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            EmailContactModel *contactM = obj;
            contactM.userAddress = [NSString trimWhitespace:contactM.userAddress];
            if (![contactM.userAddress isEmailAddress]) {
                isEmail = NO;
                *stop = YES;
            }
            [emails addObject:[[contactM.userAddress lowercaseString] base64EncodedString]];
            [EmailDataBaseUtil insertDataWithUser:accountModel.User userName:contactM.userName userAddress:contactM.userAddress date:[NSDate date]];
        }];
        if (!isEmail) {
            [self.view showHint:@"Bcc: Not a valid email address"];
            return;
        }
    }
    if (emails.count <= 30) {
        self.isSend = YES;
        [self.view showHudInView:self.view hint:@"Sending…" userInteractionEnabled:NO hideTime:REQEUST_TIME_60];
        self.emailStrings = [emails componentsJoinedByString:@","];
        [SendRequestUtil sendEmailUserkeyWithUsers:self.emailStrings unum:@(emails.count) ShowHud:NO];
    } else {
        _lockImgView.hidden = YES;
        [self sendEmailWithShowLoading:YES keys:nil];
    }
}

- (void) sendEmailWithShowLoading:(BOOL) isLoading keys:(NSArray *) userKeys
{
    MCOMessageBuilder *messageBuilder = [self getSendMessageBuilder];
    NSString *symmetKey = @"";
    NSString *msgKey = @"";
    if (userKeys && userKeys.count > 0) {
        // 生成32位对称密钥
        msgKey = [SystemUtil get32AESKey];
        NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
        symmetKey = [symmetData base64EncodedString];
        // 好友公钥加密对称密钥
      //  NSString *dsKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:model.publicKey];
        // 自己公钥加密对称密钥
       // NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
        
        NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
        if (messageBuilder.textBody && messageBuilder.textBody.length > 0) {
            messageBuilder.textBody = aesEncryptString(messageBuilder.textBody, [msgKey substringToIndex:16]);
        }
        // 资源文件加密
        if (messageBuilder.relatedAttachments && messageBuilder.relatedAttachments.count > 0) {
            [messageBuilder.relatedAttachments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MCOAttachment *attachment = obj;
                attachment.data = aesEncryptData(attachment.data,msgKeyData);
                NSLog(@"---length = %ld",attachment.data.length);
            }];
        }
        // 附件文件加密
        if (messageBuilder.attachments && messageBuilder.attachments.count > 0) {
            [messageBuilder.attachments enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                MCOAttachment *attachment = obj;
                attachment.data = aesEncryptData(attachment.data,msgKeyData);
                NSLog(@"---length = %ld",attachment.data.length);
            }];
        }
 
    }
    @weakify_self
    if (isLoading) {
         [self.view showHudInView:self.view hint:@"Sending…" userInteractionEnabled:NO hideTime:REQEUST_TIME_60];
    }
    [SIXHTMLParser htmlStringWithAttributedText:_contentTF.attributedText
                                    orignalHtml:@""
                           andCompletionHandler:^(NSString *html) {
                               NSString *writeHtml = html?:@"";
                               __block NSString *keys = @"";
                               if (userKeys && userKeys.count>0) {
                                   [userKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                                       EmailUserKeyModel *userKeyM = obj;
                                       keys = [keys stringByAppendingString:userKeyM.User];
                                       keys = [keys stringByAppendingString:@"&&"];
                                       // 签名转加密
                                       NSString *pubKey = [LibsodiumUtil getFriendEnPublickkeyWithFriendSignPublicKey:userKeyM.PubKey];
                                       NSString *dsKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:pubKey];
                                       keys = [keys stringByAppendingString:dsKey];
                                       keys = [keys stringByAppendingString:@"##"];
                                   }];
                                   
                                   EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
                                   // 加上自己加密key ，方便已发送解密
                                   keys = [keys stringByAppendingString:[accountM.User base64EncodedString]];
                                   keys = [keys stringByAppendingString:@"&&"];
                                   NSString *dsKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
                                   keys = [keys stringByAppendingString:dsKey];
                               }
                               if (weakSelf.sendType == ReplyEmail) {
                                   writeHtml =[writeHtml stringByAppendingString:@"<br/><br/><br/><div>----------------- Original -----------------</div>"];
                               } else if (weakSelf.sendType == ForwardEmail) {
                                   writeHtml =[writeHtml stringByAppendingString:@"<br/><br/><br/><div>----------------- Fwd -----------------</div>"];
                               }
                               
                               writeHtml = [writeHtml stringByAppendingString:weakSelf.emailInfo.htmlContent?:@""];
                               
                               if (keys.length > 0) {
                                   if ([writeHtml containsString:confidantEmialText]) {
                                       writeHtml = [writeHtml stringByReplacingOccurrencesOfString:confidantHtmlStr withString:@""];
                                   }
                                   writeHtml = aesEncryptString(writeHtml, [msgKey substringToIndex:16]);
                                   NSString *userKeyStr = [NSString stringWithFormat:@"<span style=\'display:none\' confidantkey=\'%@\'></span>",keys];
                                   
                                   NSString *friendID = [NSString stringWithFormat:@"<span style=\'display:none\' confidantuserid=\'%@\'></span>",[UserConfig getShareObject].userId];
                                   
                                   writeHtml = [writeHtml stringByAppendingString:userKeyStr];
                                   writeHtml = [writeHtml stringByAppendingString:friendID];
                                   writeHtml = [writeHtml stringByAppendingString:confidantHtmlStr];
                               } else {
                                   
                                   NSString *friendID = [NSString stringWithFormat:@"<span style=\'display:none\' confidantuserid=\'%@\'></span>",[UserConfig getShareObject].userId];
                                   writeHtml = [writeHtml stringByAppendingString:friendID];
                                   
                                   if (![writeHtml containsString:@"Sent from MyConfidant"]) {
                                       writeHtml = [writeHtml stringByAppendingString:confidantHtmlStr];
                                   }
                               }
                               
                               [messageBuilder setHTMLBody:writeHtml];
                               // 发送邮件
                               NSData * rfc822Data =[messageBuilder data];
                               MCOSMTPSendOperation *sendOperation = [EmailManage.sharedEmailManage.smtpSession sendOperationWithData:rfc822Data];
                               /*
                               [sendOperation setProgress:^(unsigned int current, unsigned int maximum) {
                                   NSLog(@"----%d--------%d",current,maximum);
                               }];*/
                               
                               [sendOperation start:^(NSError *error) {
                                   [weakSelf.view hideHud];
                                   if (error == nil) {
                                       // 保存到已发送
                                       [EmailOptionUtil copySent:rfc822Data complete:^(BOOL success) {
                                       }];
                                       // 发送推送请求
                                       [SendRequestUtil sendEmailSendNotiWithEmails:weakSelf.emailStrings showHud:NO];
                                       // 添加对方为好友
                                       if (weakSelf.emailInfo.friendId && weakSelf.emailInfo.friendId.length > 0) {

                                           // 发送好友请求
                                           if (![weakSelf.emailInfo.friendId isEqualToString:[UserConfig getShareObject].userId]) {

                                              NSString *msg = [NSString stringWithFormat:@"I'm %@",[UserConfig getShareObject].userName];
                                               msg = [msg base64EncodedString];

                                               [SendRequestUtil sendAddFriendWithFriendId:weakSelf.emailInfo.friendId msg:msg showHud:NO];
                                           }
                                       }
                                       [weakSelf leftNavBarItemPressedWithPop:NO];
                                       [AppD.window showSuccessHudInView:AppD.window hint:@"Successed"];
                                   } else {
                                       [weakSelf.view showFaieldHudInView:weakSelf.view hint:@"send failure"];
                                   }
                               }];
                           }];
}

- (instancetype) initWithEmailListInfo:(EmailListInfo *) info sendType:(EmailSendType)type isShowAttch:(BOOL)isShowAttch
{
    if (self = [super init]) {
        self.emailInfo = info;
        self.sendType = type;
        self.isShowAttchs = isShowAttch;

    }
    return self;
}
- (instancetype) initWithEmailListInfo:(EmailListInfo *) info sendType:(EmailSendType)type
{
    if (self = [super init]) {
        self.emailInfo = info;
        self.sendType = type;
    }
    return self;
}
- (instancetype) initWithEmailToAddress:(NSString *) toAddress sendType:(EmailSendType) type
{
    if (self = [super init]) {
        self.toAddress = toAddress;;
        self.sendType = type;
    }
    return self;
}
- (void) addNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectContactNoti:) name:EMIAL_CONTACT_SEL_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getEmailUserKeyNoti:) name:EMAIL_GETKEY_NOTI object:nil];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    _bccBackH.constant = 0;
    _ccBackH.constant = 0;
     _sendBtn.enabled = NO;
    
    [self addNoti];
    
    _toTF.delegate = self;
    _ccTF.delegate = self;
    _bccTF.delegate = self;
    _subTF.delegate = self;
    _contentTF.delegate = self;
    
    _toTF.scrollEnabled = NO;
    _ccTF.scrollEnabled = NO;
    _bccTF.scrollEnabled = NO;
    _subTF.scrollEnabled = NO;
    _contentTF.scrollEnabled = NO;
    
    _toTF.layoutManager.allowsNonContiguousLayout = NO;
    _ccTF.layoutManager.allowsNonContiguousLayout = NO;
    _bccTF.layoutManager.allowsNonContiguousLayout = NO;
    _subTF.layoutManager.allowsNonContiguousLayout = NO;
    _contentTF.layoutManager.allowsNonContiguousLayout = NO;

     EmailAccountModel *accountM = [EmailAccountModel getConnectEmailAccount];
    
    _contentTF.editable = YES;
    if (@available(iOS 11.0, *)) {
        self.contentTF.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [_attchCollectinView registerNib:[UINib nibWithNibName:AttchCollectionCellResue bundle:nil] forCellWithReuseIdentifier:AttchCollectionCellResue];
    [_attchCollectinView registerNib:[UINib nibWithNibName:AttchImgageCellResue bundle:nil] forCellWithReuseIdentifier:AttchImgageCellResue];
    
    [self updateCollectionHeight];
    _attchCollectinView.delegate = self;
    _attchCollectinView.dataSource = self;
    
    if (self.emailInfo && self.emailInfo.htmlContent) {
        
        _webH.constant = 50;
        
        NSMutableString * html = [NSMutableString string];
        NSString *originStr = @"<div>----------------- Original -----------------</div>";
        if (self.sendType == DraftEmail) {
            originStr = @"";
        } else if (self.sendType == ForwardEmail) {
            originStr = @"<div>----------------- Fwd -----------------</div>";
        }
        [html appendFormat:@"<html><head><script>%@</script><style>%@</style></head>"
         @"<body>%@%@</body><iframe src='x-mailcore-msgviewloaded:' style='width: 0px; height: 0px; border: none;'>"
         @"</iframe></html>", mainJavascript, mainStyle,originStr,self.emailInfo.htmlContent];
        self.htmlContent = html;
        
        self.messageParser = [MCOMessageParser messageParserWithData:self.emailInfo.parserData];
        self.myWebView.scrollView.bounces = NO;
        //           self.wbScrollView.scrollEnabled = NO;
        //            self.myWebView.delegate = self;
        //           self.myWebView.scalesPageToFit = YES;
        [self.myWebView setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        [self.myWebView setDelegate:self];
        
        [self.myWebView loadHTMLString:self.htmlContent baseURL:nil];
    }
    
    if (_sendType == ReplyEmail) {
        
        _lblTitle.text = [NSString stringWithFormat:@"Re: %@",self.emailInfo.fromName];
        
        // 更新 to 联系人
        EmailContactModel *contactM = [[EmailContactModel alloc] init];
        contactM.userName = self.emailInfo.fromName;
        contactM.userAddress = self.emailInfo.From;
        [self.toContacts addObject:contactM];
        
       __block NSString *toNames = [NSString stringWithFormat:kContactFormat,contactM.userName];
        
        if (self.emailInfo.toUserArray) {
            @weakify_self
            [self.emailInfo.toUserArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                EmailUserModel *userM = obj;
                NSComparisonResult resultCompare = [userM.userAddress caseInsensitiveCompare:accountM.User];
                if (resultCompare != NSOrderedSame) {
                    EmailContactModel *cotactM = [[EmailContactModel alloc] init];
                    cotactM.userName = userM.userName;
                    cotactM.userAddress = userM.userAddress;
                    [weakSelf.toContacts addObject:cotactM];
                    
                    toNames = [toNames stringByAppendingString:[NSString stringWithFormat:kContactFormat,userM.userName]];
                }
            }];
        }
        _toTF.text = toNames;
        // 更新高度
        [self textDidChange:_toTF];
        
        // cc
        if (self.emailInfo.ccUserArray && self.emailInfo.ccUserArray.count > 0) {
            __block NSString *ccNames = @"";
            @weakify_self
            [self.emailInfo.ccUserArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                EmailUserModel *userM = obj;
                NSComparisonResult resultCompare = [userM.userAddress caseInsensitiveCompare:accountM.User];
                if (resultCompare != NSOrderedSame) {
                    EmailContactModel *cotactM = [[EmailContactModel alloc] init];
                    cotactM.userName = userM.userName;
                    cotactM.userAddress = userM.userAddress;
                    [weakSelf.ccContacts addObject:cotactM];
                    
                    ccNames = [ccNames stringByAppendingString:[NSString stringWithFormat:kContactFormat,userM.userName]];
                }
            }];
            _ccTF.text = ccNames;
            // 更新高度
            [self textDidChange:_ccTF];
        }
        
        // bcc
        if (self.emailInfo.bccUserArray && self.emailInfo.bccUserArray.count > 0) {
            __block NSString *bccNames = @"";
            @weakify_self
            [self.emailInfo.bccUserArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                
                EmailUserModel *userM = obj;
                NSComparisonResult resultCompare = [userM.userAddress caseInsensitiveCompare:accountM.User];
                if (resultCompare != NSOrderedSame) {
                    EmailContactModel *cotactM = [[EmailContactModel alloc] init];
                    cotactM.userName = userM.userName;
                    cotactM.userAddress = userM.userAddress;
                    [weakSelf.bccContacts addObject:cotactM];
                    
                    bccNames = [bccNames stringByAppendingString:[NSString stringWithFormat:kContactFormat,userM.userName]];
                }
            }];
            _bccTF.text = bccNames;
            // 更新高度
            [self textDidChange:_bccTF];
        }
       
        
        // 更新标题
        if (self.emailInfo.Subject && [self.emailInfo.Subject containsString:@"Re:"]) {
            _subTF.text = self.emailInfo.Subject;
        } else {
            _subTF.text = [NSString stringWithFormat:@"Re: %@",self.emailInfo.Subject?:@""];
        }
        
        [self textDidChange:_subTF];
        
        [self performSelector:@selector(textViewBecomeFirstResponder:) withObject:self.contentTF afterDelay:0.5];
        
    } else if (_sendType == NewEmail) { // 新邮件
        _lblTitle.text = @"Compose";
        if (_toAddress && _toAddress.length > 0) {
            // 更新 to 联系人
            EmailContactModel *contactM = [[EmailContactModel alloc] init];
            contactM.userName = [_toAddress componentsSeparatedByString:@"@"][0];
            contactM.userAddress = _toAddress;
            [self.toContacts addObject:contactM];
            
            NSString *toNames = [NSString stringWithFormat:kContactFormat,contactM.userName];
            _toTF.text = toNames;
            // 更新高度
            [self textDidChange:_toTF];
        }
        [self performSelector:@selector(textViewBecomeFirstResponder:) withObject:_toTF afterDelay:0.5];
    } else if (_sendType == ForwardEmail) { // 转发
        
        // 更新标题
        if (self.emailInfo.Subject && [self.emailInfo.Subject containsString:@"Fwd:"]) {
            _subTF.text = self.emailInfo.Subject;
            _lblTitle.text = self.emailInfo.Subject;
        } else {
            _subTF.text = [NSString stringWithFormat:@"Fwd: %@",self.emailInfo.Subject?:@""];
            _lblTitle.text = [NSString stringWithFormat:@"Fwd: %@",self.emailInfo.Subject?:@""];
        }
        
        
        [self textDidChange:_subTF];
        
        // 附件
        if (self.emailInfo.attchArray && self.emailInfo.attchArray.count > 0 && _isShowAttchs) {
            @weakify_self
            [self.emailInfo.attchArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                EmailAttchModel *attchM = obj;
                EmailAttchModel *attchNew = [[EmailAttchModel alloc] init];
                attchNew.attName = attchM.attName;
                if (weakSelf.emailInfo.deKey && weakSelf.emailInfo.deKey.length > 0) {
                    attchNew.attData = aesDecryptData(attchM.attData, [weakSelf.emailInfo.deKey dataUsingEncoding:NSUTF8StringEncoding]);
                } else {
                    attchNew.attData = attchM.attData;
                }
                [weakSelf addAttchReloadCollectionWithAttch:attchNew];
            }];
        }
        
        // 更新正文
//        NSMutableString*fullBodyHtml = [NSMutableString stringWithFormat:@"<br/><br/><br/>Here are the forwarded emails<br/>%@",self.emailInfo.htmlContent];
//        [self contentTFLoadData:fullBodyHtml];
        
         [self performSelector:@selector(textViewBecomeFirstResponder:) withObject:_toTF afterDelay:0.5];
        
    } else if (_sendType == DraftEmail) { // 草稿箱
        if (self.emailInfo.Subject && self.emailInfo.Subject.length > 0) {
             _lblTitle.text = self.emailInfo.Subject;
        } else {
            _lblTitle.text = @"Drafts";
        }
        _subTF.text = self.emailInfo.Subject?:@"";
        if (self.emailInfo.htmlContent) {
            [self contentTFLoadData:self.emailInfo.htmlContent];
        } else {
            if (self.emailInfo.content) {
                _contentTF.text = self.emailInfo.content;
            }
        }
        // 收件人
        if (self.emailInfo.toUserArray && self.emailInfo.toUserArray.count > 0) {
            @weakify_self
            __block NSString *toNames = @"";
            [self.emailInfo.toUserArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                EmailUserModel *userM = obj;
                EmailContactModel *cotactM = [[EmailContactModel alloc] init];
                cotactM.userName = userM.userName;
                cotactM.userAddress = userM.userAddress;
                [weakSelf.toContacts addObject:cotactM];
                
                toNames = [toNames stringByAppendingString:[NSString stringWithFormat:kContactFormat,userM.userName]];
            }];
            _toTF.text = toNames;
            // 更新高度
            [self textDidChange:_toTF];
        }
        
        // 抄送人
        if (self.emailInfo.ccUserArray && self.emailInfo.ccUserArray.count > 0) {
            @weakify_self
            __block NSString *ccNames = @"";
            [self.emailInfo.ccUserArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                EmailUserModel *userM = obj;
                EmailContactModel *cotactM = [[EmailContactModel alloc] init];
                cotactM.userName = userM.userName;
                cotactM.userAddress = userM.userAddress;
                [weakSelf.ccContacts addObject:cotactM];
                
                ccNames = [ccNames stringByAppendingString:[NSString stringWithFormat:kContactFormat,userM.userName]];
            }];
            _ccTF.text = ccNames;
            // 更新高度
            [self textDidChange:_ccTF];
        }
        
        // 密送人
        if (self.emailInfo.bccUserArray && self.emailInfo.bccUserArray.count > 0) {
            @weakify_self
            __block NSString *bccNames = @"";
            [self.emailInfo.bccUserArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                EmailUserModel *userM = obj;
                EmailContactModel *cotactM = [[EmailContactModel alloc] init];
                cotactM.userName = userM.userName;
                cotactM.userAddress = userM.userAddress;
                [weakSelf.ccContacts addObject:cotactM];
                
                bccNames = [bccNames stringByAppendingString:[NSString stringWithFormat:kContactFormat,userM.userName]];
            }];
            _bccTF.text = bccNames;
            // 更新高度
            [self textDidChange:_bccTF];
        }
        
        // 附件
        if (self.emailInfo.attchArray && self.emailInfo.attchArray.count > 0) {
            @weakify_self
            [self.emailInfo.attchArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                EmailAttchModel *attchM = obj;
                [weakSelf addAttchReloadCollectionWithAttch:attchM];
            }];
        }
       
    }
    
    _lockImgView.hidden = YES;
    
    if (_subTF.text.trim.length > 0 && _toTF.text.trim.length > 0) {
        if (!_sendBtn.selected) {
            _sendBtn.selected = YES;
            _sendBtn.enabled = YES;
            [self checkIsEncode];
        }
    } else {
        _sendBtn.selected = NO;
        _sendBtn.enabled = NO;
    }
    
    @weakify_self
    [EmailContactModel bg_findAsync:EMAIL_CONTACT_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"user"),bg_sqlValue(accountM.User)] complete:^(NSArray * _Nullable array) {
        [weakSelf.contactArray addObjectsFromArray:array];
    }];
    
}

- (void) contentTFLoadData:(NSString *) htmlString
{
    if (htmlString.length == 0) return;
    @weakify_self
    [SIXHTMLParser attributedTextWithHtmlString:htmlString
                                     imageWidth:self.contentTF.frame.size.width-self.contentTF.textContainer.lineFragmentPadding*2
                           andCompletionHandler:^(NSAttributedString *attributedText) {
                               weakSelf.contentTF.attributedText = attributedText;
                               weakSelf.contentTF.font = [UIFont systemFontOfSize:16];
                               [weakSelf textDidChange:weakSelf.contentTF];
//                               if (weakSelf.toTF.text.length > 0) {
//                                   [weakSelf performSelector:@selector(textViewBecomeFirstResponder:) withObject:weakSelf.contentTF afterDelay:0.5];
//                               }
                           }];
    
    
    
    
}
- (void) textViewBecomeFirstResponder:(UITextView *) txtView
{
   [txtView becomeFirstResponder];
    if (txtView == _contentTF) {
        txtView.selectedRange = NSMakeRange(0, 0);
    }
}

#pragma mark -----------layz----------------
- (PNEmailContactView *)contactView
{
    if (!_contactView) {
        _contactView = [PNEmailContactView loadPNEmailContactView];
        _contactView.hidden = YES;
        [self.view addSubview:_contactView];
        
        @weakify_self
        [_contactView setContactBlock:^(EmailContactModel * _Nonnull contactModel) {
            
           weakSelf.contactView.hidden = YES;
           
            NSMutableArray *tempArray = nil;
            if (weakSelf.selContactType == 1) {
                tempArray = weakSelf.toContacts;
                
            } else if (weakSelf.selContactType == 2) {
                tempArray = weakSelf.ccContacts;
                
            } else {
                tempArray = weakSelf.bccContacts;
            }
            
            // 删除原有内容
           NSArray *kcfArray = [weakSelf.selTextView.text componentsSeparatedByString:kCFormat];
            NSMutableArray *kcfMutArray = [NSMutableArray arrayWithArray:kcfArray];
            [kcfMutArray removeLastObject];
            
            NSString *textString = @"";
            if (kcfMutArray.count > 0) {
                textString = [kcfMutArray componentsJoinedByString:kCFormat];
                textString = [textString stringByAppendingString:kCFormat];
            }
            weakSelf.selTextView.text = textString;
            
            __block BOOL isExit = NO;
            [tempArray enumerateObjectsUsingBlock:^(EmailContactModel *obj1, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([contactModel.userAddress isEqualToString:obj1.userAddress]) {
                    isExit = YES;
                    *stop = YES;
                }
            }];
            if (!isExit) {
                NSInteger insertIndex = weakSelf.selTextView.text.length;
                NSString *insertString = [NSString stringWithFormat:kContactFormat,contactModel.userName];
                NSMutableString *string = [NSMutableString stringWithString:weakSelf.selTextView.text];
                [string insertString:insertString atIndex:insertIndex];
                weakSelf.selTextView.text = string;
                // 更新高度
                [weakSelf textDidChange:weakSelf.selTextView];
                [tempArray addObject:contactModel];
            }
        }];
    }
    return _contactView;
}
- (NSMutableArray *)toContacts
{
    if (!_toContacts) {
        _toContacts = [NSMutableArray array];
    }
    return _toContacts;
}
- (NSMutableArray *)contactArray
{
    if (!_contactArray) {
        _contactArray = [NSMutableArray array];
    }
    return _contactArray;
}
- (NSMutableArray *)ccContacts
{
    if (!_ccContacts) {
        _ccContacts = [NSMutableArray array];
    }
    return _ccContacts;
}
- (NSMutableArray *)bccContacts
{
    if (!_bccContacts) {
        _bccContacts = [NSMutableArray array];
    }
    return _bccContacts;
}
- (NSMutableArray *)attchArray
{
    if (!_attchArray) {
        _attchArray = [NSMutableArray array];
        EmailAttchModel *model =[[EmailAttchModel alloc] init];
        [_attchArray addObject:model];
    }
    return _attchArray;
}
- (PNEmailAttchSelView *)selAttchView
{
    if (!_selAttchView) {
        _selAttchView = [PNEmailAttchSelView loadPNEmailAttchSelView];
        @weakify_self
        [_selAttchView setEmumBlock:^(NSInteger row) {
            if (row == 10) { // 图片
                [weakSelf selectImage];
            } else if (row == 20) { // 拍摄
                [weakSelf selectCamera:YES];
            } else if (row == 30) { // 视频
                [weakSelf selectVedio];
            } else { // 文件
                [weakSelf selectFile];
            }
        }];
    }
    return _selAttchView;
}
#pragma mark ----------------noti--------------
- (void) selectContactNoti:(NSNotification *) noti
{
    NSArray *contacts = noti.object;
    @weakify_self
    [contacts enumerateObjectsUsingBlock:^(EmailContactModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __block BOOL isExit = NO;
        NSMutableArray *tempArray = nil;
        if (weakSelf.selContactType == 1) {
            tempArray = self.toContacts;
        } else if (weakSelf.selContactType == 2) {
            tempArray = self.ccContacts;
        } else {
            tempArray = self.bccContacts;
        }
        [tempArray enumerateObjectsUsingBlock:^(EmailContactModel *obj1, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.userAddress isEqualToString:obj1.userAddress]) {
                isExit = YES;
                *stop = YES;
            }
        }];
        if (!isExit) {
            
            NSInteger insertIndex = weakSelf.selTextView.text.length;
            NSString *insertString = [NSString stringWithFormat:kContactFormat,obj.userName];
            NSMutableString *string = [NSMutableString stringWithString:weakSelf.selTextView.text];
            [string insertString:insertString atIndex:insertIndex];
           
            
            weakSelf.selTextView.text = string;
          
            
            // 更新高度
            [self textDidChange:self.selTextView];
            
            [tempArray addObject:obj];
            
        }
    }];
    
    
    if (_subTF.text.trim.length > 0 && _toTF.text.trim.length > 0) {
        if (!_sendBtn.selected) {
            _sendBtn.selected = YES;
            _sendBtn.enabled = YES;
        }
    } else {
        _sendBtn.selected = NO;
        _sendBtn.enabled = NO;
    }
    
    if (contacts && contacts.count>0) {
        [self checkIsEncode];
    }
}
- (void) getEmailUserKeyNoti:(NSNotification *) noti
{
    NSDictionary *dic = noti.object;
    NSInteger retCode = [dic[@"RetCode"] integerValue];
    NSString *Payload = dic[@"Payload"];
    if (retCode == 0 && Payload) { // 需要加密
        NSArray *payloadArr = [EmailUserKeyModel mj_objectArrayWithKeyValuesArray:Payload.mj_JSONObject];
        
        if (payloadArr && payloadArr.count > 0) {
            _lockImgView.hidden = NO;
        } else {
            _lockImgView.hidden = YES;
        }
        
        if (_isSend) {
            _isSend = NO;
            [self sendEmailWithShowLoading:NO keys:payloadArr];
        }
        
    } else {
        _lockImgView.hidden = YES;
        if (_isSend) {
            _isSend = NO;
            [self sendEmailWithShowLoading:NO keys:nil];
        }
    }
}







#pragma mark -----------------textview--------------------
- (void) textFormatWithTextView:(UITextView *) textView
{
    if (textView.text.length>0) {
        NSArray *array = [textView.text componentsSeparatedByString:kCFormat];
        NSString *toAddress = [array lastObject];
        if ([toAddress isEmptyString]) {
            [textView resignFirstResponder];
            return;
        }
        
        NSMutableArray *tempArray = nil;
        if (textView == _toTF) {
            tempArray = self.toContacts;
        } else if (textView == _ccTF) {
            tempArray = self.ccContacts;
        } else {
            tempArray = self.bccContacts;
        }
        
        __block BOOL isExit = NO;
        [tempArray enumerateObjectsUsingBlock:^(EmailContactModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([toAddress isEqualToString:obj.userAddress]) {
                isExit = YES;
                *stop = YES;
            }
        }];
        if (!isExit) {
            if (![toAddress containsString:kCFormat]) {
                EmailContactModel *contactModel = [[EmailContactModel alloc] init];
                contactModel.userName = toAddress;
                contactModel.userAddress = toAddress;
                toAddress = [NSString stringWithFormat:kContactFormat,toAddress];
                [tempArray addObject:contactModel];
            }
            NSMutableArray *mutArr = [NSMutableArray arrayWithArray:array];
            [mutArr removeLastObject];
            NSString *textString = @"";
            if (mutArr.count > 0) {
                textString = [mutArr componentsJoinedByString:kCFormat];
                textString = [textString stringByAppendingString:kCFormat];
            } 
           
            textView.text = [textString stringByAppendingString:toAddress];
            [self textDidChange:textView];
        }
    }
}

#pragma mark ------------textveiw delegate -------------
#pragma mark 文本 UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView == _ccTF) {
        if (_bccBackH.constant == 0) {
            _bccBackH.constant = 55;
        }
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
     if (textView == _toTF || textView == _ccTF || textView == _bccTF) {
         
         self.contactView.hidden = YES;
         _mainScrollView.scrollEnabled = YES;
         
         [self textFormatWithTextView:textView];
         [self checkIsEncode];
     }
}
- (void)textViewDidChange:(UITextView *)textView
{
    if (_subTF.text.trim.length > 0 && _toTF.text.trim.length > 0) {
        if (!_sendBtn.selected) {
            _sendBtn.selected = YES;
            _sendBtn.enabled = YES;
        }
    } else {
        _sendBtn.selected = NO;
        _sendBtn.enabled = NO;
    }
    [self textDidChange:textView];
    
    
    if (textView == _ccTF || textView == _toTF || textView == _bccTF) {
        NSString *textStr = textView.text.trim;
        if (textStr && textStr.length > 0) {
            if (self.contactArray.count > 0) {
                textStr = [[textStr componentsSeparatedByString:kCFormat] lastObject];
                __block NSMutableArray *tempArr = [NSMutableArray array];
                [self.contactArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    EmailContactModel *model = obj;
                    NSString *userName = [model.userName lowercaseString];
                    NSString *userAddress = [model.userAddress lowercaseString];
                    
                    if ([userName containsString:[textStr lowercaseString]] || [userAddress containsString:[textStr lowercaseString]]) {
                        [tempArr addObject:model];
                    }
                }];
                
                if (tempArr.count > 0) {
                    
                    CGFloat contentY = 0;
                    CGFloat currentTFH = 0;
                    
                    if (textView == _ccTF) {
                        self.selContactType = 2;
                        self.selTextView = _ccTF;
                        currentTFH = _ccTFH.constant+22;
                        contentY = _toTFH.constant+22;
                        [_mainScrollView setContentOffset:CGPointMake(0,contentY) animated:NO];
                    } else if (textView == _bccTF) {
                        self.selContactType = 3;
                        self.selTextView = _bccTF;
                        currentTFH = _bccTFH.constant+22;
                        contentY = _ccTFH.constant+22+_toTFH.constant+22;
                        [_mainScrollView setContentOffset:CGPointMake(0,contentY ) animated:NO];
                    } else {
                        self.selContactType = 1;
                        self.selTextView = _toTF;
                        currentTFH = _toTFH.constant+22;
                        [_mainScrollView setContentOffset:CGPointMake(0, contentY) animated:NO];
                    }
                    self.contactView.hidden = NO;
                    self.contactView.frame = CGRectMake(0, NAVIGATION_BAR_HEIGHT+currentTFH, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-currentTFH);
                    _mainScrollView.scrollEnabled = NO;
                    [self.contactView setLoadDataArray:tempArr];
                    
                } else {
                    self.contactView.hidden = YES;
                    _mainScrollView.scrollEnabled = YES;
                }
            }
            
        } else {
            self.contactView.hidden = YES;
            _mainScrollView.scrollEnabled = YES;
        }
    }
    
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if (textView == _toTF || textView == _ccTF || textView == _bccTF) {
        if ([text isEqualToString:@"\n"]) { // 点击return时
            
            self.contactView.hidden = YES;
            _mainScrollView.scrollEnabled = YES;
            
            [self textFormatWithTextView:textView];
            [self checkIsEncode];
            return NO;
        }

        if ([text isEqualToString:@""]) {
            NSRange selectRange = textView.selectedRange;
            if (selectRange.length > 0)
            {
                //用户长按选择文本时不处理
                return YES;
            }
            NSMutableArray *tempArray = nil;
            if (textView == _toTF) {
                if (self.toContacts.count == 0) {
                    return YES;
                }
                tempArray = self.toContacts;
            } else if (textView == _ccTF) {
                if (self.ccContacts.count == 0) {
                    return YES;
                }
                tempArray = self.ccContacts;
            } else {
                if (self.bccContacts.count == 0) {
                    return YES;
                }
                tempArray = self.bccContacts;
            }
            
            // 判断删除的是一个@中间的字符就整体删除
            NSMutableString *string = [NSMutableString stringWithString:textView.text];
            BOOL inAt = NO;
            NSInteger index = range.location;
            
            for (EmailContactModel *atModel in tempArray) {
                // 找到所有@位置
                NSArray *atValues = [self rangeOfSubString:atModel.userName inString:string];
                
                for (NSValue *valueRange in atValues) {
                    NSRange matchMange = [valueRange rangeValue];
                    NSRange newRange = NSMakeRange(matchMange.location, matchMange.length+1);
                    
                    if (NSLocationInRange(range.location, newRange) && newRange.length+newRange.location <= string.length)
                    {
                        inAt = YES;
                        index = matchMange.location;
                        
                        [string replaceCharactersInRange:newRange withString:@""];
                        [tempArray removeObject:atModel];
                        break;
                    }
                }
                
                if (inAt) {
                    break;
                }
            }
            if (inAt)
            {
                textView.text = string;
                [self textDidChange:textView];
                textView.selectedRange = NSMakeRange(index, 0);
                return NO;
            }
        }
        return YES;
    }
    return YES;
}
- (NSArray*) rangeOfSubString:(NSString*)subStr inString:(NSString*)string {
    
    NSMutableArray *rangeArray = [NSMutableArray array];
    NSString*string1 = [string stringByAppendingString:subStr];
    NSString *temp;
    for(int i =0; i < string.length; i++) {
        temp = [string1 substringWithRange:NSMakeRange(i, subStr.length)];
        if ([temp isEqualToString:subStr]) {
            NSRange range = {i,subStr.length};
            [rangeArray addObject: [NSValue valueWithRange:range]];
        }
    }
    return rangeArray;
}

- (void)textViewDidChangeSelection:(UITextView *)textView
{
    
    // 光标不能点落在@词中间
    NSRange range = textView.selectedRange;
    if (range.length > 0)
    {
        // 选择文本时可以
        return;
    }
    
    NSMutableArray *tempArray = nil;
    if (textView == _toTF) {
       
        tempArray = self.toContacts;
    } else if (textView == _ccTF) {
        
        tempArray = self.ccContacts;
    } else if (textView == _bccTF){
        
        tempArray = self.bccContacts;
    }
    if (!tempArray) {
        return;
    }
    NSMutableString *string = [NSMutableString stringWithString:textView.text];
    for (EmailContactModel *atModel in tempArray) {
        NSRange matchMange = [string rangeOfString:atModel.userName];
        NSRange newRange = NSMakeRange(matchMange.location , matchMange.length + 1);
        
        if (NSLocationInRange(range.location, newRange))
        {
           // textView.selectedRange = NSMakeRange(matchMange.location + matchMange.length, 0);
             textView.selectedRange = NSMakeRange(textView.text.length, 0);
            break;
        }
    }
    
    
}

- (void)textDidChange:(UITextView *) textView
{
    // 根据文字内容决定placeholderView是否隐藏
    //    self.placeholderView.hidden = self.text.length > 0;
    
    NSInteger height = ceilf([textView sizeThatFits:CGSizeMake(textView.bounds.size.width, MAXFLOAT)].height);
    
   // if (_textH != height) { // 高度不一样，就改变了高度
        
    [textView.superview layoutIfNeeded];
    
    if (textView == _toTF) {
        if (height <= 33) {
            _toTFH.constant = 33;
        } else if (height > 33) {
            _toTFH.constant = height;
        }
    } else if (textView == _ccTF) {
        if (height <= 33) {
            _ccTFH.constant = 33;
        } else if (height > 33) {
            _ccTFH.constant = height;
        }
         _ccBackH.constant = _ccTFH.constant+22;
    } else if (textView == _bccTF) {
        if (height <= 33) {
            _bccTFH.constant = 33;
        } else if (height > 33) {
            _bccTFH.constant = height;
        }
        _bccBackH.constant = _bccTFH.constant+22;
    } else if (textView == _subTF) {
        if (height <= 33) {
            _subContraintH.constant = 33;
        } else if (height > 33) {
            _subContraintH.constant = height;
        }
    } else if (textView == _contentTF) {
        if (height < 80) {
            _contentContraintH.constant = 80;
        } else if (height > 80) {
            _contentContraintH.constant = height;
        }
    }
}



// 更新collection高度  附件数量
- (void) updateCollectionHeight
{
    CGFloat itemW = (SCREEN_WIDTH-32-4)/2;
    CGFloat itemH = itemW*(128.0/170);
    CGFloat rows = self.attchArray.count/2 + self.attchArray.count%2;
    CGFloat collectionH = rows*itemH+((rows-1)*4);
    if (self.attchArray.count-1 == 0) {
        _attCountBtn.hidden = YES;
    } else {
        _attCountBtn.hidden = NO;
        [_attCountBtn setTitle:[NSString stringWithFormat:@" %lu",self.attchArray.count-1] forState:UIControlStateNormal];
    }
    _AttCollectionContraintH.constant = collectionH;
}

#pragma mark ------------collectiondelegate-------------------
/**
 分区个数
 */
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
/**
 每个分区item的个数
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.attchArray.count;
}
/**
 创建cell
 */
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    
    EmailAttchModel*attachment = self.attchArray[indexPath.item];
    NSString *fileHz = @"";
    if (attachment.attName && attachment.attName.length > 0) {
        fileHz = [[attachment.attName componentsSeparatedByString:@"."] lastObject];
    }
    
    if ([fileHz isEqualToString:@"webp"] || [fileHz isEqualToString:@"bmp"] || [fileHz isEqualToString:@"jpg"] || [fileHz isEqualToString:@"png"] || [fileHz isEqualToString:@"tif"] || [fileHz isEqualToString:@"jpeg"] || !attachment.attData) {
        
        AttchImgageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AttchImgageCellResue forIndexPath:indexPath];
        cell.tag = indexPath.item;
        cell.closeBtn.hidden = NO;
        
        @weakify_self
        [cell setCloseBlock:^(NSInteger tag) {
            [collectionView performBatchUpdates:^{
                [weakSelf.attchArray removeObjectAtIndex:tag];
                [collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:tag inSection:0]]];
            }completion:^(BOOL finished){
                [collectionView reloadData];
                [weakSelf updateCollectionHeight];
            }];
            
        }];
        
        if (!attachment.attData) {
            cell.closeBtn.hidden = YES;
            cell.lblCount.text = @"";
            cell.backImgView.hidden = YES;
            cell.headImgV.image = [UIImage imageNamed:@"add_pictures"];
            cell.backV.backgroundColor = RGB(230, 230, 230);
            cell.headImgV.contentMode = UIViewContentModeCenter;
        } else {
            cell.lblCount.text = [SystemUtil transformedValue:attachment.attData.length];
            cell.backImgView.hidden = NO;
            cell.headImgV.image = [UIImage imageWithData:attachment.attData];
            
            cell.backV.backgroundColor = MAIN_WHITE_COLOR;
            cell.headImgV.contentMode = UIViewContentModeScaleAspectFill;
        }
        return cell;
    } else {
        AttchCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AttchCollectionCellResue forIndexPath:indexPath];
        
        @weakify_self
        [cell setCloseBlock:^(NSInteger tag) {
            [collectionView performBatchUpdates:^{
                [weakSelf.attchArray removeObjectAtIndex:tag];
                [collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:tag inSection:0]]];
            }completion:^(BOOL finished){
                [collectionView reloadData];
                [weakSelf updateCollectionHeight];
                
            }];
        }];
        
        cell.tag = indexPath.item;
        cell.closeBtn.hidden = NO;
        cell.lblName.text = attachment.attName;
        NSArray *names = [attachment.attName componentsSeparatedByString:@"."];
        if (names && names.count>1) {
            NSString *typeName = [names lastObject];
            if ([typeName containsString:@"doc"]) {
                cell.headImgV.image = [UIImage imageNamed:@"doc"];
            } else if ([typeName containsString:@"txt"]) {
                cell.headImgV.image = [UIImage imageNamed:@"txt"];
            } else if ([typeName containsString:@"ppt"]) {
                cell.headImgV.image = [UIImage imageNamed:@"ppt"];
            } else if ([typeName containsString:@"pdf"]) {
                cell.headImgV.image = [UIImage imageNamed:@"pdf"];
            } else if ([typeName containsString:@"zip"] || [typeName containsString:@"rar"]) {
                cell.headImgV.image = [UIImage imageNamed:@"zip"];
            } else if ([typeName containsString:@"xls"]) {
                cell.headImgV.image = [UIImage imageNamed:@"xls"];
            } else if ([typeName containsString:@"text"]) {
                cell.headImgV.image = [UIImage imageNamed:@"text"];
            } else if ([typeName containsString:@"mp3"]) {
                cell.headImgV.image = [UIImage imageNamed:@"mp3"];
            } else {
                NSArray *mvs = @[@"AVI",@"WMV",@"RM",@"RMVB",@"MPEG1",@"MPEG2",@"MPEG4",@"MP4",@"3GP",@"ASF",@"SWF",@"VOB",@"DAT",@"MOV",@"M4V",@"FLV",@"F4V",@"MKV",@"MTS",@"TS"];
                if ([mvs containsObject:typeName]) {
                    cell.headImgV.image = [UIImage imageNamed:@"mp4"];
                } else {
                    cell.headImgV.image = [UIImage imageNamed:@"other"];
                }
            }
        } else {
            cell.headImgV.image = [UIImage imageNamed:@"other"];
        }
        cell.lblCount.text = [SystemUtil transformedValue:attachment.attData.length];
        return cell;
    }
    
}

/**
 点击某个cell
 */
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.view endEditing:YES];
    if (indexPath.row == self.attchArray.count-1) { // 最后一个为添加附件
        [self.selAttchView showEmailAttchSelView];
    } else {
        EmailAttchModel*attachment = self.attchArray[indexPath.item];
        PNEmailPreViewController *vc = [[PNEmailPreViewController alloc] initWithFileName:attachment.attName fileData:attachment.attData];
        [self.navigationController pushViewController:vc animated:YES];
    }
}
/**
 cell的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat itemW = (SCREEN_WIDTH-32-4)/2;
    CGFloat itemH = itemW*(128.0/170);
    return CGSizeMake(itemW,itemH);
}

/**
 分区内cell之间的最小行间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 4;
}
/**
 分区内cell之间的最小列间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 4;
}

/**
 创建区头视图和区尾视图
 */
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    return nil;
}


#pragma mark------------添加附件更新collectionview -----------
- (void) addAttchReloadCollectionWithAttch:(EmailAttchModel *) attchM
{
    EmailAttchModel *selAttchM = [self.attchArray lastObject];
    [self.attchArray removeLastObject];
    [self.attchArray addObject:attchM];
    [self.attchArray addObject:selAttchM];
    [_attchCollectinView reloadData];
    [self updateCollectionHeight];
}


#pragma mark -----------选择附件------------------------
/**
 调用系统相机
 
 @param isCamera 是否是调用相机
 */
- (void)selectCamera:(BOOL)isCamera {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
             [AppD.window showHint:@"Please allow access to album in \"Settings - privacy - album\" of iPhone"];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            //调用系统相册的类
            UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
            //    更改titieview的字体颜色
            NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
            attrs[NSForegroundColorAttributeName] = MAIN_PURPLE_COLOR;
            [pickerController.navigationBar setTitleTextAttributes:attrs];
            pickerController.navigationBar.translucent = NO;
            pickerController.navigationBar.barTintColor = MAIN_WHITE_COLOR;
            pickerController.navigationBar.tintColor = [UIColor whiteColor];
            //设置选取的照片是否可编辑
            pickerController.allowsEditing = NO;
            //设置相册呈现的样式
            if (isCamera) {
                pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
                NSString *requiredMediaType = ( NSString *)kUTTypeImage;
                NSString *requiredMediaType1 = ( NSString *)kUTTypeMovie;
                NSArray *arrMediaTypes=[NSArray arrayWithObjects:requiredMediaType, requiredMediaType1,nil];
                [pickerController setMediaTypes:arrMediaTypes];
                pickerController.videoMaximumDuration = 10;//最长拍摄时间
                pickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;//拍摄质量
                
            } else {
                pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            //选择完成图片或者点击取消按钮都是通过代理来操作我们所需要的逻辑过程
            pickerController.delegate = self;
            //使用模态呈现相册
            //[self showDetailViewController:pickerController sender:nil];
            [self.navigationController presentViewController:pickerController animated:YES completion:nil];
        });
    }
}

#pragma mark ------ UIImagePickerController delegate---------
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker  dismissViewControllerAnimated:YES completion:nil];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    // 判断获取类型：图片
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        
        UIImage *img = info[UIImagePickerControllerOriginalImage];
        NSData *imgData = UIImageJPEGRepresentation(img,1.0);
        [self sendImgageWithImage:img imgData:imgData];
        
    }else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]){
        // 判断获取类型：视频
        //获取视频文件的url
        NSURL* mediaURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSNumber *size;
        [mediaURL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
        CGFloat sizeMB = [size floatValue]/(1024.0*1024.0);
        if (sizeMB <= 100) {
            AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:mediaURL options:nil];
            UIImage *coverImage = [SystemUtil thumbnailImageForVideo:mediaURL];
            [self extractedVideWithAsset:asset evImage:coverImage];
            
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [AppD.window showHint:@"Video cannot be larger than 100MB"];
            });
        }
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


/**
 调用相册
 */
- (void)selectImage{
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    @weakify_self
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
                // 无相机权限 做一个友好的提示
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view endEditing:YES];
                    [AppD.window showHint:@"Please allow access to the album in \"Settings - privacy - album\" on the iPhone"];
                });
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf pushTZImagePickerControllerWithIsSelectImgage:YES];
                });
                
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view endEditing:YES];
                [AppD.window showHint:@"Denied or Restricted"];
            });
            
        }
    }];
}
/**
 选择视频
 */
- (void) selectVedio
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    @weakify_self
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view endEditing:YES];
                    [AppD.window showHint:@"Please allow access to album in \"Settings - privacy - album\" of iPhone"];
                });
                // 无相机权限 做一个友好的提示
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf pushTZImagePickerControllerWithIsSelectImgage:NO];
                });
                
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.view endEditing:YES];
                [AppD.window showHint:@"Denied or Restricted"];
            });
            
        }
    }];
}
/**
 选择文件
 */
- (void) selectFile
{
    NSArray *documentTypes = @[@"public.item"];
    PNDocumentPickerViewController *vc = [[PNDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeImport];
    vc.delegate = self;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    if (@available(iOS 11.0, *)) {
        vc.allowsMultipleSelection = NO;
    } else {
        // Fallback on earlier versions
    }
    [self presentViewController:vc animated:YES completion:nil];
}

/**
 跳转到选择图片vc
 
 @param isImage 是
 */
- (void)pushTZImagePickerControllerWithIsSelectImgage:(BOOL) isImage {
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:3 delegate:self pushPhotoPickerVc:YES];
    // imagePickerVc.navigationBar.translucent = NO;
    
#pragma mark - 五类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = NO;
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    imagePickerVc.allowTakeVideo = NO;   // 在内部显示拍视频按
    imagePickerVc.videoMaximumDuration = 15; // 视频最大拍摄时间
    [imagePickerVc setUiImagePickerControllerSettingBlock:^(UIImagePickerController *imagePickerController) {
        imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    }];
    
   
    imagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    imagePickerVc.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [imagePickerVc setPhotoPickerPageUIConfigBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
        [doneButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }];
   
    // 3. 设置是否可以选择视频/图片/原图
    imagePickerVc.allowPickingVideo = !isImage;
    imagePickerVc.allowPickingImage = isImage;
    imagePickerVc.allowPickingOriginalPhoto = isImage;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingMultipleVideo = YES; // 是否可以多选视频
    
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    
    imagePickerVc.maxImagesCount = 9;
    imagePickerVc.alwaysEnableDoneBtn = YES;
    
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = NO;
    imagePickerVc.needCircleCrop = NO;
    
    imagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    // 设置是否显示图片序号
    imagePickerVc.showSelectedIndex = NO;
    
#pragma mark - 到这里为止
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    @weakify_self
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (photos.count > 0 && assets.count>0) {
            PHAsset *asset = assets[0];
            if (asset.mediaType == 1) { // 图片
                [photos enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    UIImage *img = obj;
                    NSData *imgData = UIImageJPEGRepresentation(img,1.0);
                    if (imgData.length/(1024*1024) > 100) {
                        [AppD.window showHint:@"Image cannot be larger than 100MB"];
                        *stop = YES;
                    }
                    [weakSelf sendImgageWithImage:img imgData:imgData];
                }];
            } else {
                [photos enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    UIImage *img = obj;
                    [weakSelf getPHAssetVedioWithOverImg:img phAsset:assets[idx]];
                }];
            }
        }
    }];
    // 你可以通过block或者代理，来得到用户选择的视频.
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *phAsset) {
        [weakSelf getPHAssetVedioWithOverImg:coverImage phAsset:phAsset];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

/**
 得到选中的图片并发送
 
 @param img 图片
 @param imgData 图片data
 */
- (void) sendImgageWithImage:(UIImage *) img imgData:(NSData *) imgData
{
    EmailAttchModel *attchM = [[EmailAttchModel alloc] init];
    attchM.attData = imgData;
    NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    attchM.attName = [mills stringByAppendingString:@".jpg"];
    
    [self addAttchReloadCollectionWithAttch:attchM];
    
   
    
    /*
    // 生成32位对称密钥
    NSString *msgKey = [SystemUtil get32AESKey];
    NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
    NSString *symmetKey = [symmetData base64EncodedString];
    // 好友公钥加密对称密钥
    NSString *dsKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:model.publicKey];
    // 自己公钥加密对称密钥
    NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
    
    NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
    imgData = aesEncryptData(imgData,msgKeyData);
    
    [self sendFileWithToid:self.friendModel.userId fileName:uploadFileName fileData:imgData fileId:msgid fileType:1 messageId:model.messageId srcKey:srcKey dsKey:dsKey publicKey:self.friendModel.publicKey msgKey:msgKey fileInfo:[NSString stringWithFormat:@"%f*%f",model.fileWidth,model.fileHeight]];
     */
}

/**
 得到选择的视频
 
 @param coverImage 视频封面图
 @param phAsset phasset
 */
- (void) getPHAssetVedioWithOverImg:(UIImage *) coverImage phAsset:(PHAsset *)phAsset
{
    PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    @weakify_self
    [[PHImageManager defaultManager] requestAVAssetForVideo:phAsset options:options resultHandler:^(AVAsset *avAsset, AVAudioMix *audioMix, NSDictionary *info) {
        if ([avAsset isKindOfClass:[AVURLAsset class]]) {
            AVURLAsset* urlAsset = (AVURLAsset*)avAsset;
            NSNumber *size;
            [urlAsset.URL getResourceValue:&size forKey:NSURLFileSizeKey error:nil];
            CGFloat sizeMB = [size floatValue]/(1024.0*1024.0);
            if (sizeMB <= 100) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf extractedVideWithAsset:urlAsset evImage:coverImage];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [AppD.window showHint:@"Video cannot be larger than 100MB"];
                });
            }
        }}];
}

/**
 导出视频并发送
 @param asset asset
 @param evImage 封面图
 */
- (void)extractedVideWithAsset:(AVURLAsset *)asset evImage:(UIImage *) evImage
{
    EmailAttchModel *attchM = [[EmailAttchModel alloc] init];
    attchM.attData = [NSData dataWithContentsOfURL:asset.URL];
    attchM.attName = [asset.URL lastPathComponent];
    [self addAttchReloadCollectionWithAttch:attchM];
    
    /*
    NSString *outputPath = [NSString stringWithFormat:@"%@.mp4",mills];
    outputPath =  [[SystemUtil getBaseFilePath:self.friendModel.userId] stringByAppendingPathComponent:outputPath];
    NSURL *url = [NSURL fileURLWithPath:outputPath];
    
    BOOL result = [[NSFileManager defaultManager] copyItemAtURL:asset.URL toURL:url error:nil];
    
    if (result) {
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        //UIImage *img = [SystemUtil thumbnailImageForVideo:url];
        __block NSData *mediaData = [NSData dataWithContentsOfFile:outputPath];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
     
            // 生成32位对称密钥
            NSString *msgKey = [SystemUtil get32AESKey];
            NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
            NSString *symmetKey = [symmetData base64EncodedString];
            // 好友公钥加密对称密钥
            NSString *dsKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:model.publicKey];
            // 自己公钥加密对称密钥
            NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
            
            NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
            mediaData = aesEncryptData(mediaData,msgKeyData);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self sendFileWithToid:self.friendModel.userId fileName:model.fileName fileData:mediaData fileId:msgid fileType:4 messageId:model.messageId srcKey:srcKey dsKey:dsKey publicKey:self.friendModel.publicKey msgKey:msgKey fileInfo:[NSString stringWithFormat:@"%f*%f",model.fileWidth,model.fileHeight]];
            });
        });
    } else {
        //  [AppD.window hideHud];
        [self.view showHint:@"The current video format is not supported"];
    }
     */
    
}

#pragma mark ------ UIDocumentPickerDelegate-------
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls NS_AVAILABLE_IOS(11_0) {
    NSLog(@"didPickDocumentsAtURLs:%@",urls);
    
    //    NSURL *first = urls.firstObject;
   
    [self sendDocFileWithFileUrls:urls];
}

// called if the user dismisses the document picker without selecting a document (using the Cancel button)
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    NSLog(@"documentPickerWasCancelled");
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url NS_DEPRECATED_IOS(8_0, 11_0, "Implement documentPicker:didPickDocumentsAtURLs: instead") {
    NSLog(@"didPickDocumentAtURL:%@",url);
    [self sendDocFileWithFileUrls:@[url]];
}

/**
 发送文档文件
 
 @param urls 文件url
 */
- (void) sendDocFileWithFileUrls:(NSArray *) urls
{
    if (urls && urls.count > 0) {
        NSURL *fileUrl = urls[0];
        NSData *txtData = [NSData dataWithContentsOfURL:fileUrl];
        if (txtData.length/(1024*1024) > 100) {
            [AppD.window showHint:@"File cannot be larger than 100MB"];
            return;
        }
        
        EmailAttchModel *attchM = [[EmailAttchModel alloc] init];
        attchM.attData = txtData;
        attchM.attName = [fileUrl lastPathComponent];
        [self addAttchReloadCollectionWithAttch:attchM];
        
        
    }
}




- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"----didFailLoadWithError---------");
    //  [self.view showHint:@"Mail load failed"];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"----webViewDidFinishLoad---------");
    //若已经加载完成，则显示webView并return
        CGFloat newHeight =  [[webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollHeight "] floatValue];
        newHeight = webView.scrollView.contentSize.height;
        NSLog(@"--%f---%f",newHeight,webView.scrollView.contentSize.height);
        if (newHeight > _webH.constant) {
            _webH.constant = newHeight;
        }
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


@end
