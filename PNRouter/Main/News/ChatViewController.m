//
//  ChatViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2018/9/5.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ChatViewController.h"
#import "FriendDetailViewController.h"
#import "BaseMsgModel.h"
#import "CDChatList.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "UserModel.h"
#import "SocketMessageUtil.h"
#import "FriendModel.h"
#import "CDMessageModel.h"
#import "NSDate+Category.h"
#import "MyConfidant-Swift.h"
//#import "MessageListUtil.h"
#import "PayloadModel.h"
#import "SystemUtil.h"
#import "SocketCountUtil.h"
#import "ChooseContactViewController.h"
#import "SocketDataUtil.h"
#import "MD5Util.h"
#import "SocketManageUtil.h"
#import "FileModel.h"
#import "RequestService.h"
#import "ChatListDataUtil.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "VoiceConvert.h"
#import "ChatListModel.h"
#import "NSString+Base64.h"
#import "NSData+Base64.h"
#import "YWFilePreviewView.h"
#import "TZImagePickerController.h"
#import "NSString+UrlEncode.h"
#import "AESCipher.h"
#import "RSAUtil.h"
#import "UserConfig.h"
#import "DebugLogViewController.h"
#import "PNDocumentPickerViewController.h"
#import "ChatModel.h"
#import "PNDefaultHeaderView.h"
#import "UserHeadUtil.h"
#import "UserHeaderModel.h"
#import "NSString+Trim.h"
#import "ChatImgCacheUtil.h"
#import "RequestService.h"
#import "NSString+File.h"
#import <YBImageBrowser/YBImageBrowser.h>
#import "HMScanner.h"
#import "FriendRequestViewController.h"
#import "CodeMsgViewController.h"
#import "NSString+RegexCategory.h"
#import "RouterConfig.h"
#import "RouterModel.h"
#import "CircleOutUtil.h"
#import "UserPrivateKeyUtil.h"
#import "NSString+RegexCategory.h"


#import "PNEmailSendViewController.h"
#import "EmailAccountModel.h"
#import "PNEmailTypeSelectView.h"
#import "PNEmailConfigViewController.h"
#import "PNEmailLoginViewController.h"


#define StatusH [[UIApplication sharedApplication] statusBarFrame].size.height
#define NaviH (44 + StatusH)
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

typedef void(^PullMoreBlock)(NSArray *arr);

@interface ChatViewController ()<ChatListProtocol,
CTInputViewProtocol,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,TZImagePickerControllerDelegate,UIDocumentPickerDelegate,YBImageBrowserDelegate>
{
    YBImageBrowser *browser;
}
@property (weak, nonatomic) IBOutlet UILabel *lblNavTitle;
@property (weak, nonatomic) IBOutlet UIView *tabBackView;
@property(nonatomic, weak)CDChatListView *listView;
@property(nonatomic, weak)CTInputView *msginputView;

@property (nonatomic ,strong) FriendModel *friendModel;
@property (nonatomic) NSInteger msgStartId;
@property (nonatomic, copy) PullMoreBlock pullMoreB;
@property (nonatomic, strong) NSString *deleteMsgId;
@property (nonatomic ,strong) CDMessageModel *selectMessageModel;
@property (nonatomic ,strong) CDMessageModel *repMessageModel;
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;

@property (nonatomic ,strong) NSMutableArray *actionArr;
@property (nonatomic, strong) UIWebView * callWebview;

@end

@implementation ChatViewController


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/**
 将左边所有消息设为已读
 */
- (void) enterFore
{
    if (self.listView.msgArr.count > 0) {
        
        NSMutableArray *msgArr = [NSMutableArray array];
        
        [self.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CDMessageModel *model = (id)obj;
            if (model.isLeft) {
                [msgArr addObject:model.messageId];
            }
        }];
        if (msgArr.count > 0) {
            NSString *allMsgid = [msgArr componentsJoinedByString:@","];
            [self sendRedMsgWithMsgId:allMsgid];
        }
    }
   
}
#pragma mark ---layz
- (NSMutableArray *)actionArr
{
    if (!_actionArr) {
        _actionArr = [NSMutableArray array];
    }
    return _actionArr;
}

- (UIImagePickerController *)imagePickerVc {
    if (_imagePickerVc == nil) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
        // set appearance / 改变相册选择页的导航栏外观
        _imagePickerVc.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerVc.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
        UIBarButtonItem *tzBarItem, *BarItem;
        if (@available(iOS 9, *)) {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[TZImagePickerController class]]];
            BarItem = [UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UIImagePickerController class]]];
        } else {
            tzBarItem = [UIBarButtonItem appearanceWhenContainedIn:[TZImagePickerController class], nil];
            BarItem = [UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil];
        }
        NSDictionary *titleTextAttributes = [tzBarItem titleTextAttributesForState:UIControlStateNormal];
        [BarItem setTitleTextAttributes:titleTextAttributes forState:UIControlStateNormal];
        
    }
    return _imagePickerVc;
}


/**
 添加通知
 */
- (void)observe {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMessage:) name:RECEIVE_MESSAGE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMessageBefore:) name:ADD_MESSAGE_BEFORE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMessageSuccess:) name:DELET_MESSAGE_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDeleteMessage:) name:RECEIVE_DELET_MESSAGE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageForward:) name:CHOOSE_FRIEND_FOWARD_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFileMessage:) name:RECEVIE_FILE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileSendSuccess:) name:FILE_SEND_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendTextMessageSuccess:) name:SEND_CHATMESSAGE_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRedMsg:) name:REVER_RED_MSG_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileSendFaield:) name:REVER_FILE_SEND_FAIELD_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filePullSuccess:) name:REVER_FILE_PULL_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileToxPullSuccess:) name:REVER_FILE_PULL_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryFriendSuccess:) name:REVER_QUERY_FRIEND_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFore) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileSendingNoti:) name:FILE_SENDING_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userHeadDownloadSuccess:) name:USER_HEAD_DOWN_SUCCESS_NOTI object:nil];
    
}


- (IBAction)rightAction:(id)sender {
//    FriendDetailViewController *vc = [[FriendDetailViewController alloc] init];
//    vc.friendModel = _friendModel;
//    [self.navigationController pushViewController:vc animated:YES];
    DebugLogViewController *vc = [[DebugLogViewController alloc] init];
    vc.inputType = DebugLogTypeSystem;
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)leftAction:(id)sender {
    NSString *textString = [self.msginputView getTextViewString];
    textString = [NSString trimWhitespaceAndNewline:textString];
    if (![[NSString getNotNullValue:textString] isEmptyString]) {
        // 添加到chatlist
        ChatListModel *chatModel = [[ChatListModel alloc] init];
        chatModel.myID = [UserModel getUserModel].userId;
        chatModel.friendID = self.friendModel.userId;
        chatModel.isHD = NO;
        // 解密消息
        chatModel.isDraft = YES;
        chatModel.draftMessage = textString;
        [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
    } else {
        NSArray *friends = [ChatListModel bg_find:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@ and %@=%@",bg_sqlKey(@"friendID"),bg_sqlValue(self.friendModel.userId),bg_sqlKey(@"myID"),bg_sqlValue([UserModel getUserModel].userId),bg_sqlKey(@"isGroup"),bg_sqlValue(@(0))]];
        if (friends && friends.count > 0) {
            ChatListModel *chatModel = friends[0];
            if (chatModel.isDraft) {
                chatModel.isDraft = NO;
                chatModel.draftMessage = @"";
            }
            CDMessageModel *messageM = (CDMessageModel *)[self.listView.msgArr lastObject];
            if (messageM.msgType == 1) {
                chatModel.lastMessage = @"[photo]";
            } else if (messageM.msgType == 2) {
                chatModel.lastMessage = @"[voice]";
            } else if (messageM.msgType == 5){
                chatModel.lastMessage = @"[file]";
            } else if (messageM.msgType == 4) {
                chatModel.lastMessage = @"[video]";
            } else {
                chatModel.lastMessage = messageM.msg;
            }
            [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
        }
    }
    [self leftNavBarItemPressedWithPop:YES];
}

- (instancetype) initWihtFriendMode:(FriendModel *) model
{
    if (self = [super init]) {
        model.publicKey = [model.publicKey stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        self.friendModel = model;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = RGB(246, 246, 246);
    if (self.friendModel.remarks && self.friendModel.remarks.length > 0) {
        _lblNavTitle.text = self.friendModel.remarks;
    } else {
        _lblNavTitle.text = self.friendModel.username;
    }
    
    [self observe];
    [self loadChatUI];
    _msgStartId = 0;
    [self.listView startRefresh];
     [SocketCountUtil getShareObject].chatToId = self.friendModel.userId;
   // [self pullMessageRequest];
    
    // 当前消息置为已读
    [[ChatListDataUtil getShareObject] cancelChatHDWithFriendid:self.friendModel.userId];
    
    NSArray *friends = [ChatListModel bg_find:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@ and %@=%@",bg_sqlKey(@"friendID"),bg_sqlValue(self.friendModel.userId),bg_sqlKey(@"myID"),bg_sqlValue([UserModel getUserModel].userId),bg_sqlKey(@"isGroup"),bg_sqlValue(@(0))]];
    if (friends && friends.count > 0) {
        ChatListModel *chatModel = friends[0];
        if (chatModel.isDraft) {
            [self.msginputView setTextViewString:chatModel.draftMessage];
        }
    }

    [self sendUpdateAvatar];
//    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"1539912662170117"ofType:@"mp4"]];
//    UIImage *img = [SystemUtil thumbnailImageForVideo:url];
//    UIImageView *imgV = [[UIImageView alloc] initWithImage:img];
//    imgV.center = CGPointMake(ScreenW/2, ScreenH/2);
//    [AppD.window addSubview:imgV];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SocketCountUtil getShareObject].chatToId = self.friendModel.userId;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SocketCountUtil getShareObject].chatToId = @"";
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    
}


/**
 更新好友头像
 */
- (void)sendUpdateAvatar {
    NSString *Fid = _friendModel.userId?:@"";
    NSString *Md5 = @"0";
    NSString *userHeaderImg64Str = [UserHeaderModel getUserHeaderImg64StrWithKey:_friendModel.signPublicKey];
    if (userHeaderImg64Str) {
        Md5 = [MD5Util md5WithData:[NSData dataWithBase64EncodedString:userHeaderImg64Str]];
    }
    [[UserHeadUtil getUserHeadUtilShare] sendUpdateAvatarWithFid:Fid md5:Md5 showHud:NO];
}

/**
 拉取消息
 */
- (void)pullMessageRequest {
    UserModel *userM = [UserModel getUserModel];
    NSString *MsgType = @"1"; // 0：所有记录  1：纯聊天消息   2：文件传输记录
    NSString *MsgStartId = [NSString stringWithFormat:@"%@",@(_msgStartId)]; // 从这个消息号往前（不包含该消息），为0表示默认从最新的消息回溯
    NSString *MsgNum = @"10"; // 期望拉取的消息条数
    NSDictionary *params = @{@"Action":Action_PullMsg,@"FriendId":_friendModel.userId?:@"",@"UserId":userM.userId?:@"",@"MsgType":MsgType,@"MsgStartId":MsgStartId,@"MsgNum":MsgNum,@"SrcMsgId":@"0"};
    [SocketMessageUtil sendVersion5WithParams:params];
}

/**
 初始化聊天框 输入框
 */
- (void) loadChatUI
{
    // 初始化聊天界面
    CDChatListView *list = [[CDChatListView alloc] initWithFrame:CGRectMake(0,
                                                                            NaviH,
                                                                            ScreenW,
                                                                            ScreenH - NaviH - CTInputViewHeight - (IS_iPhoneX ? StatusH : 0))];
    list.msgDelegate = self;
    self.listView = list;
    [self.view addSubview:list];
    
    // 初始化输入框
    CTInputView *input = [[CTInputView alloc] initWithFrame:CGRectMake(0,
                                                                       list.cd_bottom,
                                                                       ScreenW,
                                                                       CTInputViewHeight)];
    input.backgroundColor = RGB(246, 246,246);
    input.delegate = self;
    self.msginputView = input;
    [self.view addSubview:input];
    
}
#pragma mark ----------- ChatListProtocol ---------
-(void)chatlistBecomeFirstResponder{
   // [self.msginputView resignFirstResponder];
}

- (void)clickFileCellWithMsgMode:(CDChatMessage)msgModel withFilePath:(NSString *)filePath
{
    [YWFilePreviewView previewFileWithPaths:filePath fileName:msgModel.fileName fileType:msgModel.msgType];
}
- (void)clickHeadWithMessage:(CDChatMessage)clickMessage
{
    FriendDetailViewController *vc = [[FriendDetailViewController alloc] init];
    vc.friendModel = self.friendModel;
    vc.isBack = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)clickChatMenuItem:(NSString *)itemTitle withMsgMode:(CDChatMessage) msgModel
{
    self.selectMessageModel = (CDMessageModel *)msgModel;
    NSString *msgId = [NSString stringWithFormat:@"%@",self.selectMessageModel.messageId];
    NSLog(@"%@",itemTitle);
    if ([itemTitle isEqualToString:@"Forward"]){ // 转发
        ChooseContactViewController *vc = [[ChooseContactViewController alloc] init];
        vc.docOPenTag = 3;
        [self presentModalVC:vc animated:YES];
    }  else if ([itemTitle isEqualToString:@"Withdraw"]){ // 删除
        
        if ([SystemUtil isSocketConnect]) {
            // 取消文件发送，删除记录
            [ChatModel bg_delete:CHAT_CACHE_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"fromId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"msgid"),bg_sqlValue(msgId)]];
        }
        
        if (self.selectMessageModel.fileID > 0 && self.selectMessageModel.messageStatu < 0) { // 是文件
            [self deleteMsg:msgId];
            if ([SystemUtil isSocketConnect]) {
                @weakify_self
                [[SocketManageUtil getShareObject].socketArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    SocketDataUtil *dataUtil = (SocketDataUtil *)obj;
                    if ([dataUtil.fileid isEqualToString:[NSString stringWithFormat:@"%d",weakSelf.selectMessageModel.fileID]]) {
                        dataUtil.isCancel = YES;
                        *stop = YES;
                    }
                }];
                
            } else {
                [[ChatListDataUtil getShareObject].fileCancelParames setObject:@"1" forKey:msgId];
                NSLog(@"------------%@",msgId);
            }
           
        } else {
            _deleteMsgId = msgId;
            UserModel *userM = [UserModel getUserModel];
            
            NSDictionary *params = @{@"Action":@"DelMsg",@"FriendId":_friendModel.userId?:@"",@"UserId":userM.userId?:@"",@"MsgId":msgId};
            [SocketMessageUtil sendVersion1WithParams:params];
        }
        
    } else if ([itemTitle isEqualToString:@"Save"]) { // 保存到相册
        NSString *friendid = msgModel.ToId;
        if (msgModel.isLeft && !msgModel.isGroup) {
            friendid = msgModel.FromId;
        }
        NSString *filePath = [[SystemUtil getBaseFilePath:friendid] stringByAppendingPathComponent:msgModel.fileName];
        if (msgModel.msgType == CDMessageTypeImage) {
            UIImage *img = [UIImage imageWithContentsOfFile:filePath];
            [self saveImage:img];
        } else if (msgModel.msgType == CDMessageTypeMedia) {
            [self saveVideo:filePath];
        }
    }  else if ([itemTitle isEqualToString:@"React"]) { // 回复
        _msginputView.isReact = YES;
        self.repMessageModel = (CDMessageModel *)msgModel;
        [_msginputView setReactString:self.selectMessageModel.msg];
    }
}
//cell 的点击事件
- (void)chatlistClickMsgEvent:(ChatListInfo *)listInfo imgView:(UIImageView *)imgV{
    switch (listInfo.eventType) {
        case ChatClickEventTypeIMAGE:
        {
            NSMutableArray *messageArr = [NSMutableArray array];
            for (int i = 0; i<self.listView.msgArr.count; i++) {
                CDMessageModel *messageModel = (CDMessageModel*)self.listView.msgArr[i];
                if (messageModel.msgType == CDMessageTypeImage) {
                    [messageArr addObject:messageModel];
                }
            }
            // 设置数据源数组并展示
            
            browser = [YBImageBrowser new];
            browser.delegate = self;
            YBImageBrowserSheetView *sheetView = [YBImageBrowserSheetView new];
            if (self.actionArr.count == 0) {
                @weakify_self
                YBImageBrowserSheetAction *action1 = [YBImageBrowserSheetAction actionWithName:@"Save Photo" identity:@"save" action:^(id<YBImageBrowserCellDataProtocol>  _Nonnull data) {
                    YBImageBrowseCellData *data1 = (YBImageBrowseCellData *)data;
                    [weakSelf loadImageFinished:data1.image];
                    
                }];
                
                YBImageBrowserSheetAction *action2 = [YBImageBrowserSheetAction actionWithName:@"Scan QR Code in image" identity:@"Scaner" action:^(id<YBImageBrowserCellDataProtocol>  _Nonnull data) {
                    YBImageBrowseCellData *data1 = (YBImageBrowseCellData *)data;
                    [HMScanner scaneImage:data1.image completion:^(NSArray *values) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (values && values.count > 0) {
                                NSString *codeVlaue = [values firstObject];
                                if ([codeVlaue isUrlAddress]) { // 是网址
                                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:codeVlaue] options:@{} completionHandler:nil];
                                } else {
                                    NSArray *codeValues = [codeVlaue componentsSeparatedByString:@","];
                                    NSString *codeType = codeValues[0];
                                    if ([codeType isEqualToString:@"type_0"]) {
                                        NSString *userID = codeValues[1];
                                        if (userID.length == 76) {
                                            if ([userID isEqualToString:[UserModel getUserModel].userId]) {
                                                [AppD.window showHint:@"You cannot add yourself as a friend."];
                                            } else {
                                                NSString *nickName = @"";
                                                if (codeValues.count>2) {
                                                    nickName = codeValues[2];
                                                }
                                                [weakSelf addFriendRequest:userID nickName:nickName signpk:codeValues[3]];
                                            }
                                        } else {
                                            [weakSelf jumpCodeValueVCWithCodeValue:codeVlaue];
                                        }
                                    } else if (codeVlaue.length == 12) {
                                        NSString *macAdress = @"";
                                        for (int i = 0; i<12; i+=2) {
                                            NSString *macIndex = [codeVlaue substringWithRange:NSMakeRange(i, 2)];
                                            macAdress = [macAdress stringByAppendingString:macIndex];
                                            if (i < 10) {
                                                macAdress = [macAdress stringByAppendingString:@":"];
                                            }
                                        }
                                        if ([macAdress isMacAddress]) {
                                            [weakSelf showAlertVCWithValues:@[macAdress] isMac:YES];
                                        } else {
                                            [weakSelf jumpCodeValueVCWithCodeValue:codeVlaue];
                                        }
                                    } else if ([[NSString getNotNullValue:codeType] isEqualToString:@"type_1"]) {
                                        // router 码
                                        NSString *result = aesDecryptString(codeValues[1],AES_KEY);
                                        result = [result stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                                        if (result && result.length == 114) {
                                            
                                            NSString *toxid = [result substringWithRange:NSMakeRange(6, 76)];
                                            NSString *sn = [result substringWithRange:NSMakeRange(result.length-32, 32)];
                                            NSLog(@"%@---%@",[RouterConfig getRouterConfig].currentRouterSn,[RouterConfig getRouterConfig].currentRouterToxid);
                                            
                                            if ([[RouterConfig getRouterConfig].currentRouterToxid isEqualToString:toxid]) {
                                                // 是当前帐户
                                                [AppD.window showHint:@"Already in the same circle."];
                                            } else {
                                                [weakSelf showAlertVCWithValues:@[toxid,sn] isMac:NO];
                                            }
                                        }
                                    } else if ([[NSString getNotNullValue:codeType] isEqualToString:@"type_2"]) {
                                        // mac 码
                                        NSString *result = aesDecryptString(codeValues[1],AES_KEY);
                                        result = [result stringByReplacingOccurrencesOfString:@"\0" withString:@""];
                                        AppD.isScaner = YES;
                                        [weakSelf showAlertVCWithValues:@[result] isMac:YES];
                                        
                                    } else if ([[NSString getNotNullValue:codeType] isEqualToString:@"type_3"]) { //帐户码
                                        
                                        [weakSelf showAlertImportAccount:codeValues];
                                        
                                    } else {
                                        [weakSelf jumpCodeValueVCWithCodeValue:codeVlaue];
                                    }
                                }
                            } else {
                               
                            }
                        });
                    }];
                }];
                
                [self.actionArr addObject:action1];
                [self.actionArr addObject:action2];
            }
           
            sheetView.actions = [NSArray arrayWithArray:self.actionArr];
            browser.sheetView = sheetView;

            
            NSString *fileDocs = [SystemUtil getBaseFilePath:self.friendModel.userId];
            NSFileManager *fm = [NSFileManager defaultManager];
            NSDirectoryEnumerator *dirEnumerater = [fm enumeratorAtPath:fileDocs];
            NSString *filePath = nil;
           __block NSInteger cidx = 0;
           
            NSMutableArray *imgDataArr = [NSMutableArray array];
           NSMutableDictionary *timeDics = [NSMutableDictionary dictionaryWithContentsOfFile:[[SystemUtil getBaseFileTimePathWithToid:self.friendModel.userId] stringByAppendingPathComponent:@"times"]];
            //开始遍历文件
            while (nil != (filePath = [dirEnumerater nextObject])) {
                NSString *imgFilePath = [NSString stringWithFormat:@"%@/%@",fileDocs,filePath];
                NSString *fileName = [imgFilePath lastPathComponent];
                
                if ([imgFilePath.pathExtension caseInsensitiveCompare:@"jpg"] == NSOrderedSame || [imgFilePath.pathExtension caseInsensitiveCompare:@"png"] == NSOrderedSame || [imgFilePath.pathExtension caseInsensitiveCompare:@"jpeg"] == NSOrderedSame || [imgFilePath.pathExtension caseInsensitiveCompare:@"bmp"] == NSOrderedSame) {

                    YBImageBrowseCellData *data1 = [YBImageBrowseCellData new];
                    
                    NSURL *fileUrl = [NSURL fileURLWithPath:imgFilePath];
                    data1.url = fileUrl;
                    if (timeDics) {
                        data1.extraData = [timeDics objectForKey:fileName];
                    }
                    [imgDataArr addObject:data1];
                }
            }
            
            NSSortDescriptor*descriptor1=[NSSortDescriptor sortDescriptorWithKey:@"extraData"ascending:YES];
            NSArray*descriptors1 = [NSArray arrayWithObject:descriptor1];
            NSMutableArray *browserDatas = [NSMutableArray arrayWithArray:[imgDataArr sortedArrayUsingDescriptors:descriptors1]];
            
            [browserDatas enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                YBImageBrowseCellData *cellData = obj;
                if ([listInfo.msgModel.fileName isEqualToString:[cellData.url lastPathComponent]]) {
                    cidx = idx;
                    cellData.sourceObject = imgV;
                    *stop = YES;
                }
            }];
     
            browser.dataSourceArray = [NSArray arrayWithArray:browserDatas];
            browser.currentIndex = cidx;
            [browser showFromController:self];
            
//            CGRect newe =  [listInfo.containerView.superview convertRect:listInfo.containerView.frame toView:self.view];
//            [MsgPicViewController addToRootViewController:listInfo.image ofMsgId:listInfo.msgModel.messageId in:newe from:messageArr vc:self];
        }
            break;
        case ChatClickEventTypeTEXT:
           // [self.view makeToast:listInfo.clickedText duration:0.5 position:CSToastPositionCenter];
            
            if (listInfo.clickedText.length>4 && [[listInfo.clickedText substringToIndex:4] isEqualToString:@"www."]) {
                listInfo.clickedText = [NSString stringWithFormat:@"https://%@",listInfo.clickedText];
            }
            if ([listInfo.clickedText isValidUrl]) { // 是url
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:listInfo.clickedText] options:@{} completionHandler:^(BOOL success) {
                    
                }];
                
            } else if ([listInfo.clickedText isEmailAddress]) { // 是邮箱
                
                if ([EmailAccountModel getLocalAllEmailAccounts].count == 0) { // 绑定邮箱
                    
                    PNEmailTypeSelectView *vc = [[PNEmailTypeSelectView alloc] init];
                    @weakify_self
                    [vc setClickRowBlock:^(PNBaseViewController * _Nonnull vc, NSArray * _Nonnull arr) {
                        [vc dismissViewControllerAnimated:NO completion:nil];
                        if ([arr[1] intValue] == 255) {
                            PNEmailConfigViewController *vc = [[PNEmailConfigViewController alloc] initWithIsEdit:NO];
                            [weakSelf presentModalVC:vc animated:YES];
                        } else {
                            PNEmailLoginViewController *loginVC  = [[PNEmailLoginViewController alloc] initWithEmailType:[arr[1] intValue] optionType:LoginEmail];
                            [weakSelf presentModalVC:loginVC animated:YES];
                        }
                    }];
                    [self presentModalVC:vc animated:YES];
                    
                } else { // 发送邮件
                    PNEmailSendViewController *vc = [[PNEmailSendViewController alloc] initWithEmailToAddress:listInfo.clickedText sendType:NewEmail];
                    [self presentModalVC:vc animated:YES];
                }
                
                
            } else if ([listInfo.clickedText isMobileNumber]) { // 是手机号
                
                NSMutableString* str=[[NSMutableString alloc] initWithFormat:@"tel:%@",listInfo.clickedText];
                if (!self.callWebview) {
                    _callWebview = [[UIWebView alloc] init];
                }
                [_callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
                [self.view addSubview:_callWebview];
            }
            break;
    }
}


/**
 下拉加载更多

 @param topMessage topMessage
 @param finnished 完成回调
 */
- (void)chatlistLoadMoreMsg:(CDChatMessage)topMessage callback:(void (^)(CDChatMessageArray,BOOL))finnished {
    @weakify_self
    self.pullMoreB = ^(NSArray *arr) {
        [weakSelf.listView stopRefresh];
        if (arr.count > 0) {
            finnished(arr,YES);
        } else {
            finnished(nil,NO);
        }
    };
    [self pullMessageRequest];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSString *jsonPath = [[NSBundle mainBundle] pathForResource:@"messageHistory" ofType:@"json"];
//        NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
//        NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
//
//        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:5];
//        for (int i = 0; i<11; i++) {
//            BaseMsgModel *model = [[BaseMsgModel alloc] init];
//            model.msg = array[0][@"msg"];
//            model.msgType = CDMessageTypeImage;
//            model.userThumImage = [UIImage imageNamed:@"thum"];
//            [arr addObject:model];
//        }
//        finnished(arr,YES);
//    });
}

#pragma mark------------ CTInputViewProtocol--------------

- (void)inputViewPopAudioath:(NSURL *)path {
    
    // 此处会存到内存和本地， 内存地址不会加密，本地地址会加密
    NSString *mill = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    mill = [mill substringWithRange:NSMakeRange(mill.length-9, 9)];
    int msgid = [mill intValue];
    
    NSString *amrPath = [[SystemUtil getBaseFilePath:self.friendModel.userId] stringByAppendingPathComponent:[mill stringByAppendingString:@".amr"]];
   
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString *mavPath = [directory stringByAppendingPathComponent:@"audio.wav"];

    if ([VoiceConvert ConvertWavToAmr:mavPath amrSavePath:amrPath]) {
        //UI操作 播放音频
        NSLog(@"wav转amr成功");
      //  [SystemUtil removeDocmentAudio];
        NSData *data = [NSData dataWithContentsOfFile:amrPath];
        CDMessageModel *mode = [[CDMessageModel alloc] init];
        mode.msgType = CDMessageTypeAudio;
        mode.msgState = CDMessageStateSending;
        mode.messageStatu = -1;
        mode.msg = amrPath;
        mode.FromId = [UserModel getUserModel].userId;
        mode.ToId = self.friendModel.userId;
        mode.fileName = [mill stringByAppendingString:@".amr"];
        
        NSString *uploadFileName = mode.fileName;
        mode.fileID = msgid;
        mode.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
        mode.publicKey = self.friendModel.publicKey;
        mode.messageId = [NSString stringWithFormat:@"%d",msgid];;
//        mode.willDisplayTime = YES;
        NSString *userKey = [EntryModel getShareObject].signPublicKey;
        mode.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:[UserModel getUserModel].username userKey:userKey]];
        mode.isLeft = NO;
        mode.audioSufix = @"amr";
        [self.listView addMessagesToBottom:@[mode]];
        
        
        // 生成32位对称密钥
        NSString *msgKey = [SystemUtil get32AESKey];
        NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
        NSString *symmetKey = [symmetData base64EncodedString];
        // 好友公钥加密对称密钥
        NSString *dsKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:self.friendModel.publicKey];
        // 自己公钥加密对称密钥
        NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
      
        NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
        data = aesEncryptData(data,msgKeyData);
        

        [self sendFileWithToid:self.friendModel.userId fileName:uploadFileName fileData:data fileId:msgid fileType:2 messageId:mode.messageId srcKey:srcKey dsKey:dsKey publicKey:self.friendModel.publicKey msgKey:msgKey fileInfo:@""];
        
    }else{
        NSLog(@"wav转amr失败");
    }
}

/**
 调用系统相机

 @param isCamera 是否是调用相机
 */
- (void)selectCamera:(BOOL)isCamera {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view endEditing:YES];
            [AppD.window showHint:@"Please allow access to album in \"Settings - privacy - album\" of iPhone"];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view endEditing:YES];
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
    if ([mediaType isEqualToString:( NSString *)kUTTypeImage]){
        
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
                     [weakSelf.view endEditing:YES];
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
#pragma mark -------点击聊天菜单回调---------
- (void)inputViewPopCommand:(NSString *)string {
    if ([string isEqualToString:@"Album"]) {
        
        [self selectImage];
        
    } else if ([string isEqualToString:@"Camera"]) {
        [self selectCamera:YES];
        
    } else if ([string isEqualToString:@"File"]) {
        
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
        
        /*
       NSString *txtPath = [[NSBundle mainBundle] pathForResource:@"测试文件1" ofType:@"txt"];
        NSData *txtData = [NSData dataWithContentsOfFile:txtPath];
        NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
        NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
        int msgid = [mill intValue];
        CDMessageModel *model = [[CDMessageModel alloc] init];
        model.msgType = CDMessageTypeFile;
        model.FromId = [UserConfig getShareObject].userId;
        model.ToId = self.friendModel.userId;
        model.fileSize = txtData.length;
        model.msgState = CDMessageStateSending;
        model.messageId = [NSString stringWithFormat:@"%d",msgid];;
        model.fileID = msgid;
        model.messageStatu = -1;
        CTDataConfig config = [CTData defaultConfig];
        config.isOwner = YES;
        model.willDisplayTime = YES;
        model.fileName = @"测试文件1.txt";
        NSString *uploadFileName = model.fileName;
        model.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
        model.publicKey = self.friendModel.publicKey;
        model.ctDataconfig = config;
        NSString *nkName = [UserModel getUserModel].username;
        model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName]];
        NSString *filePath = [[SystemUtil getBaseFilePath:self.friendModel.userId] stringByAppendingPathComponent:model.fileName];
        [txtData writeToFile:filePath atomically:YES];
        [self.listView addMessagesToBottom:@[model]];
        
        // 生成32位对称密钥
        NSString *msgKey = [SystemUtil get32AESKey];
        NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
        NSString *symmetKey = [symmetData base64EncodedString];
        // 好友公钥加密对称密钥
        NSString *dsKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:self.friendModel.publicKey];
        // 自己公钥加密对称密钥
        NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
        
        NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
        txtData = aesEncryptData(txtData,msgKeyData);
     
        
        [self sendFileWithToid:self.friendModel.userId fileName:uploadFileName fileData:txtData fileId:msgid fileType:5 messageId:model.messageId srcKey:srcKey dsKey:dsKey publicKey:self.friendModel.publicKey];
    */
        
    } else if ([string isEqualToString:@"Short Video"]) { // 视频
        
         //[self pushTZImagePickerController];
        
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
   
}

/**
 发送文件

 @param toId toid
 @param fileName fileName
 @param fileData fileData
 @param fileId fileId
 @param fileType fileType
 @param messageId messageId
 @param srcKey srcKey
 @param dsKey dsKey
 @param publicKey publicKey
 @param msgKey msgKey
 @param fileInfo fileInfo
 */
- (void) sendFileWithToid:(NSString *) toId fileName:(NSString *) fileName fileData:(NSData *) fileData fileId:(int) fileId fileType:(int) fileType messageId:(NSString *) messageId srcKey:(NSString *) srcKey dsKey:(NSString *) dsKey publicKey:(NSString *) publicKey msgKey:(NSString *) msgKey fileInfo:(NSString *) fileInfo
{
    if ([SystemUtil isSocketConnect]) {
        ChatModel *chatModel = [[ChatModel alloc] init];
        chatModel.fromId = [UserConfig getShareObject].userId;
        chatModel.toId = toId;
        chatModel.toPublicKey = publicKey;
        chatModel.msgType = fileType;
        chatModel.fileSize = fileData.length;
        chatModel.msgid = (long)[messageId integerValue];
        chatModel.bg_tableName = CHAT_CACHE_TABNAME;
        chatModel.fileName = fileName;
        //chatModel.filePath =[[SystemUtil getBaseFilePath:toId] stringByAppendingPathComponent:fileName];
        chatModel.srcKey = srcKey;
        chatModel.dsKey = dsKey;
        chatModel.msgKey = msgKey;
        chatModel.sendTime = [NSDate getTimestampFromDate:[NSDate date]];
       
        NSString *fileNameInfo = fileName;
        if (fileInfo && fileInfo.length>0) {
            fileNameInfo = [NSString stringWithFormat:@"%@,%@",fileNameInfo,fileInfo];
            chatModel.fileName = fileNameInfo;
        }
        [chatModel bg_save];
        SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
        [dataUtil sendFileId:toId fileName:fileNameInfo fileData:fileData fileid:fileId fileType:fileType messageid:messageId srcKey:srcKey dstKey:dsKey isGroup:NO];
        [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
    } else {
        NSString *filePath = [[SystemUtil getTempBaseFilePath:toId] stringByAppendingPathComponent:[Base58Util Base58EncodeWithCodeName:fileName]];
        
        if ([fileData writeToFile:filePath atomically:YES]) {
            
            if (fileInfo && fileInfo.length > 0) {
                NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":[UserConfig getShareObject].userId,@"ToId":toId,@"FileName":[Base58Util Base58EncodeWithCodeName:fileName],@"FileMD5":[MD5Util md5WithPath:filePath],@"FileSize":@(fileData.length),@"FileType":@(fileType),@"SrcKey":srcKey,@"DstKey":dsKey,@"FileId":messageId,@"FileInfo":fileInfo};
                [SendToxRequestUtil sendFileWithFilePath:filePath parames:parames];
            } else {
                NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":[UserConfig getShareObject].userId,@"ToId":toId,@"FileName":[Base58Util Base58EncodeWithCodeName:fileName],@"FileMD5":[MD5Util md5WithPath:filePath],@"FileSize":@(fileData.length),@"FileType":@(fileType),@"SrcKey":srcKey,@"DstKey":dsKey,@"FileId":messageId,@"FileInfo":fileInfo};
                [SendToxRequestUtil sendFileWithFilePath:filePath parames:parames];
            }
           
            [SendRequestUtil sendQueryFriendWithFriendId:self.friendModel.userId];
        }
    }
}

#pragma makr ------点击发送按钮回调--------
- (void)inputViewPopSttring:(NSString *)string {
    // 去掉前后空格和换行符
    string = [NSString trimWhitespaceAndNewline:string];
    
    if (string && ![string isEmptyString]) {
        UserModel *userM = [UserModel getUserModel];
        // 生成签名
        NSString *signString = [LibsodiumUtil getOwenrSignPrivateKeySignOwenrTempPublickKey];
        // 生成nonce
        NSString *nonceString = [LibsodiumUtil getGenterSysmetryNonce];
        // 生成对称密钥
        NSString *symmetryString = [LibsodiumUtil getSymmetryWithPrivate:[EntryModel getShareObject].tempPrivateKey publicKey:self.friendModel.publicKey];
        // 加密消息
        NSString *msg = [LibsodiumUtil encryMsgPairWithSymmetry:symmetryString enMsg:string nonce:nonceString];
        // 加密对称密钥
        NSString *enSymmetString = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetryString enPK:[EntryModel getShareObject].publicKey];
        //DDLogDebug(@"临时公钥：%@   对称密钥：%@",[EntryModel getShareObject].tempPublicKey,symmetryString);

        CDMessageModel *model = [[CDMessageModel alloc] init];
        model.FromId = [UserConfig getShareObject].userId;
        model.ToId = self.friendModel.userId;
        model.publicKey = self.friendModel.publicKey;
        model.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
        long tempMsgid = (long)[ChatListDataUtil getShareObject].tempMsgId++;
        tempMsgid = [NSDate getTimestampFromDate:[NSDate date]]+tempMsgid;
        model.messageId = [NSString stringWithFormat:@"%ld",(long)tempMsgid];
        model.msg = string;
        model.msgState = CDMessageStateNormal;
        model.nonceKey = nonceString;
        model.signKey = signString;
        model.symmetKey = enSymmetString;
        model.messageStatu = -1;
        
        // 发送消息
        if (_msginputView.isReact) {
            model.repModel = [[PayloadModel alloc] init];
            model.AssocId = [self.repMessageModel.messageId integerValue];
            model.repModel.Msg = self.repMessageModel.msg;
            model.repModel.MsgType = self.repMessageModel.msgType;
            model.repModel.UserName = _lblNavTitle.text;
            model.repModel.TimeStamp = self.repMessageModel.TimeStatmp;
        }
        
        [self addMessagesToList:model];
        
        NSInteger repMsgId = 0;
        if (_msginputView.isReact) {
            repMsgId = self.repMessageModel? [self.repMessageModel.messageId integerValue]:0;
        }
        NSDictionary *params = @{@"Action":@"SendMsg",@"To":_friendModel.userId?:@"",@"From":userM.userId?:@"",@"Msg":msg?:@"",@"Sign":signString?:@"",@"Nonce":nonceString?:@"",@"PriKey":enSymmetString?:@"",@"AssocId":@(repMsgId)};
        
        if ([SystemUtil isSocketConnect]) {
            ChatModel *chatModel = [[ChatModel alloc] init];
            chatModel.fromId = model.FromId;
            chatModel.toId = model.ToId;
            chatModel.repMsgId = repMsgId;
            chatModel.toPublicKey = model.publicKey;
            chatModel.msgType = 0;
            chatModel.msgid = tempMsgid;
            chatModel.messageMsg = string;
            chatModel.sendTime = [NSDate getTimestampFromDate:[NSDate date]];
            chatModel.bg_tableName = CHAT_CACHE_TABNAME;
            [chatModel bg_save];
        }
        
        [SocketMessageUtil sendChatTextWithParams:params withSendMsgId:model.messageId];
        
        if (![SystemUtil isSocketConnect]) {
            [SendRequestUtil sendQueryFriendWithFriendId:self.friendModel.userId];
        }
        
        self.repMessageModel = nil;
    }
    
}


#pragma mark ----当输入框frame变化是，会回调此方法---------
- (void)inputViewWillUpdateFrame:(CGRect)newFrame animateDuration:(double)duration animateOption:(NSInteger)opti {
    //  当输入框因为多行文本变高时，listView需要做响应变化
    
    CGFloat inset_bot = ScreenHeight - CTInputViewHeight - newFrame.origin.y - (IS_iPhoneX ? StatusH : 0);

    UIEdgeInsets inset = UIEdgeInsetsMake(self.listView.contentInset.top,
                                          self.listView.contentInset.left,
                                          inset_bot,
                                          self.listView.contentInset.right);
    NSLog(@"inset = %@",NSStringFromUIEdgeInsets(inset));
    [self.listView setContentInset:inset];
    [self.listView relayoutTable:YES];
    
    // 异步让tableview滚到最底部
//    NSInteger cellCount = [self.listView numberOfRowsInSection:0];
//    NSInteger num = cellCount - 1 > 0 ? cellCount - 1 : NSNotFound;
//    if (num != NSNotFound) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            NSIndexPath *index = [NSIndexPath indexPathForRow:num inSection:0];
//            [self.listView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//            });
//
//    }
   
    
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

#pragma mark --文件发送中通知--------
- (void) fileSendingNoti:(NSNotification *) noti
{
    NSArray *resultArr = noti.object;
    @weakify_self
    [weakSelf.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([resultArr[0] isEqualToString:weakSelf.friendModel.userId]) {
            if ([resultArr[1] integerValue] == [obj.messageId integerValue]) {
                obj.msgState = CDMessageStateSending;
                [weakSelf.listView updateMessage:obj];
            }
        }
    }];
}
#pragma mark ---查询当前用户是不是自己好友通知-------
- (void) queryFriendSuccess:(NSNotification *) noti
{
    NSString *friendId = noti.object;
    if ([friendId isEqualToString:self.friendModel.userId]) {
        CDMessageModel *messageModel = [[CDMessageModel alloc] init];
        messageModel.msgType = 3;
        messageModel.msg = @"You are not his (her) friend, please send him (her) friend request.";
        [self.listView addMessagesToBottom:@[messageModel]];
    }
}
#pragma mark-----tox拉取文件成功通知-------
- (void) fileToxPullSuccess:(NSNotification *) noti
{
    NSArray *array = noti.object;
    if (array && array.count>0) {
      __block NSString *fileName = [Base58Util Base58DecodeWithCodeName:array[1]];
        @weakify_self
        [weakSelf.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.fileName isEqualToString:fileName]) { // 收到tox文件
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    
                    NSString *tempPath = [[SystemUtil getTempBaseFilePath:array[0]] stringByAppendingPathComponent:array[1]];
                    tempPath = [tempPath stringByAppendingString:[NSString stringWithFormat:@"%d",[array[2] intValue]]];
                    NSString *docPath = [[SystemUtil getBaseFilePath:weakSelf.friendModel.userId] stringByAppendingPathComponent:fileName];
                    if ([SystemUtil filePathisExist:docPath]) {
                        [SystemUtil removeDocmentFilePath:docPath];
                    }
                    NSData *fileData = [NSData dataWithContentsOfFile:tempPath];
                    NSString *msgkey = @"";
                    if (obj.isLeft) {
                        msgkey = obj.dskey;
                    } else {
                        msgkey = obj.srckey;
                    }
                    
                    NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:msgkey];
                    datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
                    
                    fileData = aesDecryptData(fileData, [datakey dataUsingEncoding:NSUTF8StringEncoding]);
                    [SystemUtil removeDocmentFilePath:tempPath];
                    
                    if ([fileData writeToFile:docPath atomically:YES]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (obj.msgType == 1) {
                                // 根据filename 保存 filetime
                                [SystemUtil saveImageForTtimeWithToid:weakSelf.friendModel.userId fileName:fileName fileTime:obj.TimeStatmp];
                            }
                            
                            obj.msgState = CDMessageStateNormal;
                            obj.isDown = NO;
                            [weakSelf.listView updateMessage:obj];
                            *stop = YES;
                            NSLog(@"下载文件成功! filePath = %@",docPath);
                        });
                    }
                    
//                    if (array.count > 2) {
//                        obj.msgState = CDMessageStateDownloadFaild;
//                        obj.isDown = NO;
//                        [weakSelf.listView updateMessage:obj];
//                        *stop = YES;
//                        NSLog(@"下载文件失败! ");
//                    } else {
//
//                    }
                });
            }
        }];
    }
    
}
#pragma mark----文件拉取成功通知---------
- (void) filePullSuccess:(NSNotification *) noti
{
    __block FileModel *model =(FileModel *) noti.object;
    @weakify_self
    [weakSelf.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *messageId = [NSString stringWithFormat:@"%@",obj.messageId];
        NSString *messageId2 = [NSString stringWithFormat:@"%@",model.MsgId];
        if ([messageId isEqualToString:messageId2]) { // 收到tox文件
            if (model.RetCode != 0) {
                obj.msgState = CDMessageStateDownloadFaild;
                obj.isDown = NO;
                [weakSelf.listView updateMessage:obj];
            }
            *stop = YES;
        }
    }];
}
#pragma mark ---消息已读通知----
- (void) receiveRedMsg:(NSNotification *) noti
{
    NSArray *arr = (NSArray *)noti.object;
    NSString *fromid = arr[0];
    NSString *msgIds = arr[1];
    NSArray *msgIdArr = [msgIds componentsSeparatedByString:@","];
    if ([fromid isEqualToString:self.friendModel.userId]) {
        @weakify_self
        [msgIdArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *msgId = obj;
            [weakSelf.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (!obj.isLeft) {
                    NSString *messageId = [NSString stringWithFormat:@"%@",obj.messageId];
                    if ([messageId isEqualToString:msgId]) { // 设为已读
                        obj.messageStatu = 2;
                        [weakSelf.listView updateMessage:obj];
                    }
                }
            }];
        }];
    }
}
#pragma mark --消息转发通知-----
- (void) messageForward:(NSNotification *)noti {
   __block NSData *fileDatas = nil;
    NSArray *modeArray = (NSArray *)noti.object;
    @weakify_self
    [modeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        long tempMsgid = (long)[ChatListDataUtil getShareObject].tempMsgId++;
        tempMsgid = [NSDate getTimestampFromDate:[NSDate date]]+tempMsgid;
        
        if (weakSelf.selectMessageModel.msgType == 1) {
            [SystemUtil saveImageForTtimeWithToid:model.userId fileName:weakSelf.selectMessageModel.fileName fileTime:[NSDate getTimestampFromDate:[NSDate date]]];
        }
        
        if (model.isGroup) { // 转发到群聊
            // 自己私钥解密
            NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:model.publicKey];
            // 截取前16位
            if (!datakey || datakey.length == 0) {
                return;
            }
            datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
            if (weakSelf.selectMessageModel.msgType == CDMessageTypeText) { // 转发文字
                // aes加密
                NSString *enMsg = aesEncryptString(weakSelf.selectMessageModel.msg, datakey);
                // 发送消息
                [SendRequestUtil sendGroupMessageWithGid:model.userId point:@"" msg:enMsg msgid:[NSString stringWithFormat:@"%ld",tempMsgid] repId:@(0)];
                
                if ([SystemUtil isSocketConnect]) {
                    ChatModel *chatModel = [[ChatModel alloc] init];
                    chatModel.fromId = [UserConfig getShareObject].userId;
                    chatModel.toId = model.userId;
                    chatModel.toPublicKey = model.publicKey;
                    chatModel.msgType = 0;
                    chatModel.msgid = tempMsgid;
                    chatModel.messageMsg = weakSelf.selectMessageModel.msg;
                    chatModel.bg_tableName = CHAT_CACHE_TABNAME;
                    chatModel.sendTime = [NSDate getTimestampFromDate:[NSDate date]];
                    [chatModel bg_save];
                }
                
            } else {
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    NSString *filePath = [[SystemUtil getBaseFilePath:weakSelf.friendModel.userId] stringByAppendingPathComponent:weakSelf.selectMessageModel.fileName];
                    if (!fileDatas) {
                        fileDatas = [NSData dataWithContentsOfFile:filePath];
                    }
                    NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
                    NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
                    int msgid = [mill intValue];
                    
                    filePath = [[SystemUtil getBaseFilePath:model.userId] stringByAppendingPathComponent:weakSelf.selectMessageModel.fileName];
                    [fileDatas writeToFile:filePath atomically:YES];
                    
                    // 自己私钥解密
                    NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:model.publicKey];
                    NSString *symmetKey = [[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding];
                    NSData *msgKeyData =[[symmetKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
                    fileDatas = aesEncryptData(fileDatas,msgKeyData);
                    
                    NSString *fileInfo = @"";
                    if (weakSelf.selectMessageModel.fileWidth > 0 && weakSelf.selectMessageModel.fileHeight > 0) {
                        fileInfo = [NSString stringWithFormat:@"%f*%f",weakSelf.selectMessageModel.fileWidth,weakSelf.selectMessageModel.fileHeight];
                    }
                    
                    [weakSelf sendGroupFileWithToid:model.userId fileName:weakSelf.selectMessageModel.fileName fileData:fileDatas fileId:msgid fileType:weakSelf.selectMessageModel.msgType messageId:[NSString stringWithFormat:@"%d",msgid] srcKey:@"" dsKey:@"" publicKey:model.publicKey msgKey:@"" fileInfo:[NSString stringWithFormat:@"%f*%f",weakSelf.selectMessageModel.fileWidth,weakSelf.selectMessageModel.fileHeight]];
                    
                });
            }
            
        } else {
            model.publicKey = [model.publicKey stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
            UserModel *userM = [UserModel getUserModel];
            // 生成签名
            NSString *signString = [LibsodiumUtil getOwenrSignPrivateKeySignOwenrTempPublickKey];
            // 生成nonce
            NSString *nonceString = [LibsodiumUtil getGenterSysmetryNonce];
            
            if (weakSelf.selectMessageModel.msgType == CDMessageTypeText) { // 转发文字
                // 生成对称密钥
                NSString *symmetryString = [LibsodiumUtil getSymmetryWithPrivate:[EntryModel getShareObject].tempPrivateKey publicKey:model.publicKey];
                // 加密消息
                NSString *msg = [LibsodiumUtil encryMsgPairWithSymmetry:symmetryString enMsg:weakSelf.selectMessageModel.msg nonce:nonceString];
                // 加密对称密钥
                NSString *enSymmetString = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetryString enPK:[EntryModel getShareObject].publicKey];
                
                NSDictionary *params = @{@"Action":@"SendMsg",@"To":model.userId?:@"",@"From":userM.userId?:@"",@"Msg":msg?:@"",@"Sign":signString?:@"",@"Nonce":nonceString?:@"",@"PriKey":enSymmetString?:@""};
                
                if ([model.userId isEqualToString:weakSelf.friendModel.userId]) {
                    CDMessageModel *messageModel = [[CDMessageModel alloc] init];
                    messageModel.FromId = [UserConfig getShareObject].userId;
                    messageModel.ToId = model.userId;
                    messageModel.publicKey = model.publicKey;
                    messageModel.messageId = [NSString stringWithFormat:@"%ld",(long)tempMsgid];
                    messageModel.msg = weakSelf.selectMessageModel.msg;
                    messageModel.msgState = CDMessageStateNormal;
                    messageModel.nonceKey = nonceString;
                    messageModel.signKey = signString;
                    messageModel.symmetKey = enSymmetString;
                    messageModel.messageStatu = -1;
                    [self addMessagesToList:messageModel];
                }
                [SocketMessageUtil sendChatTextWithParams:params withSendMsgId:[NSString stringWithFormat:@"%ld",(long)tempMsgid]];
                
                if ([SystemUtil isSocketConnect]) {
                    ChatModel *chatModel = [[ChatModel alloc] init];
                    chatModel.fromId = [UserConfig getShareObject].userId;
                    chatModel.toId = model.userId;
                    chatModel.toPublicKey = model.publicKey;
                    chatModel.msgType = 0;
                    chatModel.msgid = tempMsgid;
                    chatModel.messageMsg = weakSelf.selectMessageModel.msg;
                    chatModel.bg_tableName = CHAT_CACHE_TABNAME;
                    chatModel.sendTime = [NSDate getTimestampFromDate:[NSDate date]];
                    [chatModel bg_save];
                }
                
            } else { // 转发文件
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    NSString *filePath = [[SystemUtil getBaseFilePath:weakSelf.friendModel.userId] stringByAppendingPathComponent:weakSelf.selectMessageModel.fileName];
                    if (!fileDatas) {
                        fileDatas = [NSData dataWithContentsOfFile:filePath];
                    }
                    NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
                    NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
                    int msgid = [mill intValue];
                    
                    CDMessageModel *messageModel = [[CDMessageModel alloc] init];
                    
                    filePath = [[SystemUtil getBaseFilePath:model.userId] stringByAppendingPathComponent:weakSelf.selectMessageModel.fileName];
                    [fileDatas writeToFile:filePath atomically:YES];
                    
                    
                    if ([model.userId isEqualToString: weakSelf.friendModel.userId]) {
                        messageModel.msgType = weakSelf.selectMessageModel.msgType;
                        messageModel.FromId = [UserConfig getShareObject].userId;
                        messageModel.ToId = model.userId;
                        messageModel.fileSize = fileDatas.length;
                        messageModel.fileWidth = weakSelf.selectMessageModel.fileWidth;
                        messageModel.fileHeight = weakSelf.selectMessageModel.fileHeight;
                        messageModel.msgState = CDMessageStateSending;
                        messageModel.messageId = [NSString stringWithFormat:@"%d",msgid];
                        messageModel.fileID = msgid;
                        messageModel.messageStatu = -1;
                        CTDataConfig config = [CTData defaultConfig];
                        config.isOwner = YES;
//                        messageModel.willDisplayTime = YES;
                        messageModel.fileName = weakSelf.selectMessageModel.fileName;
                        messageModel.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
                        messageModel.publicKey = model.publicKey;
                        messageModel.ctDataconfig = config;
                        NSString *nkName = [UserModel getUserModel].username;
                        NSString *userKey = [EntryModel getShareObject].signPublicKey;
                        messageModel.userThumImage =  [SystemUtil genterViewToImage:[weakSelf getHeadViewWithName:nkName userKey:userKey]];
                        
                       
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [weakSelf.listView addMessagesToBottom:@[messageModel]];
                        });
                    }
                    
                    
                    // 生成32位对称密钥
                    NSString *msgKey = [SystemUtil get32AESKey];
                    if (weakSelf.selectMessageModel.msgType == 5) {
                        msgKey = [SystemUtil getDoc32AESKey];
                    }
                    NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
                    NSString *symmetKey = [symmetData base64EncodedString];
                    // 好友公钥加密对称密钥
                    NSString *dsKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:model.publicKey];
                    // 自己公钥加密对称密钥
                    NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
                    
                    NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
                    NSData *enData = aesEncryptData(fileDatas,msgKeyData);
                    
                    NSString *fileInfo = @"";
                    if (weakSelf.selectMessageModel.fileWidth > 0 && weakSelf.selectMessageModel.fileHeight > 0) {
                        fileInfo = [NSString stringWithFormat:@"%f*%f",weakSelf.selectMessageModel.fileWidth,weakSelf.selectMessageModel.fileHeight];
                    }
                    
                    [weakSelf sendFileWithToid:model.userId fileName:weakSelf.selectMessageModel.fileName fileData:enData fileId:msgid fileType:weakSelf.selectMessageModel.msgType messageId:[NSString stringWithFormat:@"%d",msgid] srcKey:srcKey dsKey:dsKey publicKey:model.publicKey msgKey:msgKey fileInfo:fileInfo];
                    
                });
            }
        }
        
    }];
}
#pragma mark --文件发送失败通知----
- (void) fileSendFaield:(NSNotification *) noti
{
    NSDictionary *resultDic = noti.object;
    NSString *messageId = resultDic[@"FileId"];
    @weakify_self
    [self.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CDMessageModel *model = (id)obj;
        if ([[NSString stringWithFormat:@"%@",model.messageId] isEqualToString:messageId]) {
            model.msgState = CDMessageStateSendFaild;
            model.messageStatu = -1;
            [weakSelf.listView updateMessage:model];
            *stop = YES;
        }
    }];
}
#pragma mark --文件发送成功通知----
- (void) fileSendSuccess:(NSNotification *) noti
{
    NSArray *arr = (NSArray *)noti.object;
    if (arr && arr.count > 0) {
        
        if (![arr[2] isEqualToString:self.friendModel.userId]) {
            return;
        }
       __block NSInteger fileIndex = -1;
        @weakify_self
        [self.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CDMessageModel *model = (id)obj;
            if ([[NSString stringWithFormat:@"%@",model.messageId] isEqualToString:arr[4]]) {
                fileIndex = idx;
                *stop = YES;
            }
        }];
        if (fileIndex < 0) {
            return;
        }
         CDMessageModel *model = (CDMessageModel *)[weakSelf.listView.msgArr objectAtIndex:fileIndex];
        if ([arr[0] integerValue] != 0) { // 文件发送失败
            NSLog(@"文件发送失败");
            model.msgState = CDMessageStateSendFaild;
            model.messageStatu = -1;
            
        } else {
            
            NSLog(@"文件发送成功");
           
            // 添加到最后一条消息
            model.msgState = CDMessageStateNormal;
            if (model.messageStatu == 1) {
                return;
            }
            model.messageStatu = 1;
            model.messageId = arr[5];
            
        }
        [weakSelf.listView updateMessage:model];
        if ([arr[0] integerValue] == 5) {
            CDMessageModel *messageModel = [[CDMessageModel alloc] init];
            messageModel.msgType = 3;
            messageModel.msg = @"You are not his (her) friend, please send him (her) friend request.";
            [weakSelf.listView addMessagesToBottom:@[messageModel]];
        }
    }
}
#pragma mark -----收到文件消息通知------
- (void) receiveFileMessage:(NSNotification *) noti
{
    FileModel *fileModel = (FileModel *)noti.object;
    NSString *userId = [UserConfig getShareObject].userId;
    if (!(([fileModel.ToId isEqualToString:userId] && [fileModel.FromId isEqualToString:self.friendModel.userId]) || ([fileModel.FromId isEqualToString:userId] && [fileModel.ToId isEqualToString:self.friendModel.userId]))) {
        return;
    }
    
    // 去重
    __block BOOL isExist = NO;
    [self.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CDMessageModel *model = (id)obj;
        if ([model.messageId integerValue] == [fileModel.MsgId integerValue]) {
            isExist = YES;
            *stop = YES;
        }
    }];
    if (isExist) {
        return;
    }
    
    // 已读
    [self sendRedMsgWithMsgId:[NSString stringWithFormat:@"%@",fileModel.MsgId]];
    
    CDMessageModel *model = [[CDMessageModel alloc] init];
    model.filePath = fileModel.FilePath;
    NSLog(@"filepath = %@",model.filePath);
    if (!(fileModel.FileType == 5 || fileModel.FileType == 4)) {
         model.msgState = CDMessageStateDownloading;
    }
    model.fileSize = fileModel.FileSize;
    if (fileModel.FileInfo && fileModel.FileInfo.length > 0) {
        NSArray *whs = [fileModel.FileInfo componentsSeparatedByString:@"*"];
        model.fileWidth = [whs[0] floatValue];
        model.fileHeight = [whs[1] floatValue];
    }
    model.fileName = [Base58Util Base58DecodeWithCodeName:fileModel.FileName];
    model.fileMd5 = fileModel.FileMD5;
    model.messageId = [NSString stringWithFormat:@"%@",fileModel.MsgId];
    model.FromId = fileModel.FromId;
    model.ToId = fileModel.ToId;
    model.msgType = fileModel.FileType;
    model.isLeft = YES;
    model.srckey = fileModel.SrcKey;
    model.dskey = fileModel.DstKey;
    CTDataConfig config = [CTData defaultConfig];
    config.isOwner = NO;
//    model.willDisplayTime = YES;
    model.TimeStatmp = fileModel.timestamp;
    model.publicKey = self.friendModel.publicKey;
    model.ctDataconfig = config;
    NSString *nkName = self.friendModel.username;
    NSString *userKey = self.friendModel.signPublicKey;
    model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName userKey:userKey]];
    [self.listView addMessagesToBottom:@[model]];
}

#pragma mark ------消息发送成功通知-------
- (void) sendTextMessageSuccess:(NSNotification *) noti
{
    NSArray *array = noti.object;
    if (array && array.count > 0) {
        
        NSString *sendMsgid = array[2];
        NSString *msgid = array[1];
        
        __block BOOL isExist = NO;
        __block NSInteger index = 0;
        @weakify_self
        [self.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CDMessageModel *model = (id)obj;
            if ([model.messageId integerValue] == [sendMsgid integerValue]) {
                isExist = YES;
                if ([array[0] integerValue] == 0) { // 发送成功
                    model.messageId = msgid;
                    model.msgState = CDMessageStateNormal;
                    model.messageStatu = 1;
                    [weakSelf.listView updateMessage:model];
                } else {
                    model.msgState = CDMessageStateSendFaild;
                    if ([array[0] integerValue] == 2) {
                        CDMessageModel *messageModel = [[CDMessageModel alloc] init];
                        messageModel.msgType = 3;
                        messageModel.msg = @"You are not his (her) friend, please send him (her) friend request.";
                        [weakSelf.listView addMessagesToBottom:@[messageModel]];
                    }
                }
                index = idx;
                *stop = YES;
            }
        }];
    }
}
#pragma mark ------收到文本消息通知--------
- (void)addMessage:(NSNotification *)noti {
    CDMessageModel *revModel = noti.object;
    if (!revModel) {
        return;
    }
    if ([revModel.FromId isEqualToString:self.friendModel.userId]) {
        // 已读
        [self sendRedMsgWithMsgId:revModel.messageId];
        
        // 去重
        __block BOOL isExist = NO;
        [self.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CDMessageModel *model = (id)obj;
            if ([model.messageId integerValue] == [revModel.messageId integerValue]) {
                isExist = YES;
                *stop = YES;
            }
        }];
        if (!isExist) {
            revModel.publicKey = self.friendModel.publicKey;
            [self addMessagesToList:revModel];
        }
    }
    
    
}

#pragma mark -----得到一条文字消息 并添加到listview------
- (void) addMessagesToList:(CDMessageModel *) model
{
    NSString *userId = [UserConfig getShareObject].userId;
    if (!(([model.ToId isEqualToString:userId] && [model.FromId isEqualToString:self.friendModel.userId]) || ([model.FromId isEqualToString:userId] && [model.ToId isEqualToString:self.friendModel.userId]))) {
        return;
    }
    if ([model.FromId isEqualToString:userId]) {
        model.isLeft = NO;
    } else {
        model.isLeft = YES;
    }
    CTDataConfig config = [CTData defaultConfig];
    if (!model.isLeft) {
       // config.textColor = MAIN_PURPLE_COLOR.CGColor;
        config.isOwner = YES;
    }
    model.publicKey = self.friendModel.publicKey;
//    model.willDisplayTime = YES;
    model.ctDataconfig = config;
    NSString *nkName = [UserModel getUserModel].username;
    NSString *userKey = [EntryModel getShareObject].signPublicKey;
    if (model.isLeft) {
        nkName = self.friendModel.username;
        userKey = self.friendModel.signPublicKey;
    }
    model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName userKey:userKey]];
    [self.listView addMessagesToBottom:@[model]];
}
#pragma mark ------拉取消息成功通知-----
- (void)addMessageBefore:(NSNotification *)noti {
    
    [self.listView stopRefresh];
    NSArray *resultArr = noti.object;
    if (!resultArr) {
        return;
    }
    NSArray *messageArr = resultArr[0];
    if (self.listView.msgArr && self.listView.msgArr.count > 0) {
        if (_msgStartId == 0) {
            return;
        }
    }
    
    if ([resultArr[1] intValue] == 1 && [resultArr[2] integerValue] > 0) { // 拉取回复消息的消息
        PayloadModel *payloadM = messageArr[0];
        @weakify_self
        [self.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CDMessageModel *messageM = (id)obj;
            if (messageM.AssocId > 0 && messageM.AssocId == [payloadM.MsgId integerValue]) { // 找到对应回复消息
                if ([messageM.messageId integerValue] == [resultArr[2] integerValue]) {
                    
                    if (payloadM.MsgType == 0) { // 文字
                        
                        if (payloadM.Sender == 0) {
                            NSString *symmetKey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:payloadM.PriKey];
                            payloadM.Msg = [LibsodiumUtil decryMsgPairWithSymmetry:symmetKey enMsg:payloadM.Msg nonce:payloadM.Nonce];
                             payloadM.UserName = [UserModel getUserModel].username;
                        } else {
                            // 解签名
                            NSString *tempPublickey = [LibsodiumUtil verifySignWithSignPublickey:self.friendModel.signPublicKey verifyMsg:payloadM.Sign];
                            if (![tempPublickey isEmptyString]) {
                                // 生成对称密钥
                                NSString *deSymmetKey = [LibsodiumUtil getSymmetryWithPrivate:[EntryModel getShareObject].privateKey publicKey:tempPublickey];
                                NSString *deMsg = [LibsodiumUtil decryMsgPairWithSymmetry:deSymmetKey enMsg:payloadM.Msg nonce:payloadM.Nonce];
                                if (![deMsg isEmptyString]) {
                                    payloadM.UserName =weakSelf.lblNavTitle.text;
                                    payloadM.Msg = deMsg;
                                }
                            }
                        }
                        
                        messageM.repModel = payloadM;
                        [weakSelf.listView updateMessage:messageM];
                        
                        if (weakSelf.listView.msgArr.count <= 10) {
                            [weakSelf.listView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.listView.msgArr.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                        }
                        
                    } else if (payloadM.MsgType == CDMessageTypeFile) {
                        
                        if (payloadM.FileName && payloadM.FileName.length>0) {
                            payloadM.FileName = [Base58Util Base58DecodeWithCodeName:payloadM.FileName];
                        }
                        if (payloadM.Sender == 0) {
                            payloadM.UserName = [UserModel getUserModel].username;
                        } else {
                            payloadM.UserName =weakSelf.lblNavTitle.text;
                        }
                        messageM.repModel = payloadM;
                        [weakSelf.listView updateMessage:messageM];
                        
                        if (weakSelf.listView.msgArr.count <= 10) {
                            [weakSelf.listView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:weakSelf.listView.msgArr.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                        }
                        
                    }
                   
                    *stop = YES;
                }
            }
        }];
        return;
    }

    NSMutableArray *msgArr = [NSMutableArray array];
    NSMutableArray *messageModelArr = [NSMutableArray array];
    [messageArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PayloadModel *payloadModel = obj;
        CDMessageModel *model = [[CDMessageModel alloc] init];
         NSString *userId = [UserConfig getShareObject].userId;
        if (payloadModel.Sender == 0) {
            model.FromId = userId?:@"";
            model.ToId = self.friendModel.userId;
        } else {
            model.ToId = userId?:@"";
            model.FromId = self.friendModel.userId;
        }
        if (payloadModel.FileInfo && payloadModel.FileInfo.length>0) {
            NSArray *whs = [payloadModel.FileInfo componentsSeparatedByString:@"*"];
            model.fileWidth = [whs[0] floatValue];
            model.fileHeight = [whs[1] floatValue];
        }
        
        model.messageStatu = payloadModel.Status;
        model.AssocId = payloadModel.AssocId;
        model.publicKey = self.friendModel.publicKey;
        model.messageId = [NSString stringWithFormat:@"%@",payloadModel.MsgId];
        model.TimeStatmp = payloadModel.TimeStamp;
        model.msgType = payloadModel.MsgType;
        if (model.msgType >=1 && model.msgType !=5 && model.msgType !=4) { // 图片
            model.msgState = CDMessageStateDownloading;
        }
        if (payloadModel.FileName) {
             model.fileName = [Base58Util Base58DecodeWithCodeName:payloadModel.FileName];
        }
        model.fileMd5 = payloadModel.FileMD5;
        model.filePath = payloadModel.FilePath;
        model.fileSize = payloadModel.FileSize;
       
        if ([model.FromId isEqualToString:userId]) {
            model.isLeft = NO;
        } else {
            model.isLeft = YES;
            [msgArr addObject:model.messageId];
        }
        model.signKey = payloadModel.Sign;
        model.nonceKey = payloadModel.Nonce;
        model.symmetKey = payloadModel.PriKey;
        if (model.msgType != CDMessageTypeText) {
            
            if (payloadModel.Sender == 0) {
                model.srckey = payloadModel.Sign;
            } else {
                model.dskey = payloadModel.PriKey;
            }
        } else {
            if (payloadModel.Sender == 0) {
                NSString *symmetKey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:payloadModel.PriKey];
                model.msg = [LibsodiumUtil decryMsgPairWithSymmetry:symmetKey enMsg:payloadModel.Msg nonce:payloadModel.Nonce];
            } else {
                // 解签名
                NSString *tempPublickey = [LibsodiumUtil verifySignWithSignPublickey:self.friendModel.signPublicKey verifyMsg:payloadModel.Sign];
                if (![tempPublickey isEmptyString]) {
                    // 生成对称密钥
                    NSString *deSymmetKey = [LibsodiumUtil getSymmetryWithPrivate:[EntryModel getShareObject].privateKey publicKey:tempPublickey];
                    NSString *deMsg = [LibsodiumUtil decryMsgPairWithSymmetry:deSymmetKey enMsg:payloadModel.Msg nonce:payloadModel.Nonce];
                    if (![deMsg isEmptyString]) {
                        model.msg = deMsg;
                    }
                }
                
            }
        }
        
        CTDataConfig config = [CTData defaultConfig];
        if (!model.isLeft) {
            //config.textColor = MAIN_PURPLE_COLOR.CGColor;
            config.isOwner = YES;
        }
        model.ctDataconfig = config;
        NSString *nkName = [UserModel getUserModel].username;
        NSString *userKey = [EntryModel getShareObject].signPublicKey;
        if (model.isLeft) {
            nkName = self.friendModel.username;
            userKey = self.friendModel.signPublicKey;
        }
        model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName userKey:userKey]];
        [messageModelArr addObject:model];
    }];
    
    if (_msgStartId == 0) { // 第一次自动加载
        
         NSArray *chats = [ChatModel bg_find:CHAT_CACHE_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"fromId"),bg_sqlValue([UserModel getUserModel].userId),bg_sqlKey(@"toId"),bg_sqlValue(self.friendModel.userId)]];
        if (chats && chats.count > 0) {
            @weakify_self
            [chats enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ChatModel *chatModel = obj;
                
                CDMessageModel *model = [[CDMessageModel alloc] init];
                model.FromId = chatModel.fromId;
                model.ToId = chatModel.toId;
                model.msgType = chatModel.msgType;
                model.publicKey = weakSelf.friendModel.publicKey;
                model.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
                model.messageId = [NSString stringWithFormat:@"%ld",(long)chatModel.msgid];
                CTDataConfig config = [CTData defaultConfig];
                config.isOwner = YES;
                model.ctDataconfig = config;
                
                NSString *nkName = [UserModel getUserModel].username;
                NSString *userKey = [EntryModel getShareObject].signPublicKey;
                model.userThumImage =  [SystemUtil genterViewToImage:[weakSelf getHeadViewWithName:nkName userKey:userKey]];
                
                if (model.msgType == 0) { // 文字
                    model.msg = chatModel.messageMsg;
                    model.msgState = CDMessageStateNormal;
                    model.messageStatu = -1;
                } else {
                    model.fileSize = chatModel.fileSize;
                    model.msgState = CDMessageStateSending;
                    model.fileID = (int)chatModel.msgid;
                    model.messageStatu = -1;
                    NSArray *nameInfos = [chatModel.fileName componentsSeparatedByString:@","];
                    if (nameInfos.count >=2) {
                        model.fileName = nameInfos[0];
                       NSArray *whs = [[nameInfos lastObject] componentsSeparatedByString:@"*"];
                        model.fileWidth = [whs[0] floatValue];
                        model.fileHeight = [whs[1] floatValue];
                    } else {
                        model.fileName = chatModel.fileName;
                    }
                }
                [messageModelArr addObject:model];
            }];
            
        }
        self.listView.msgArr = messageModelArr;
        
    } else { // 下拉刷新
        if (_pullMoreB) {
            _pullMoreB(messageModelArr);
        }
    }
    // 发送已读
    if (msgArr.count > 0) {
        NSString *allMsgid = [msgArr componentsJoinedByString:@","];
        [self sendRedMsgWithMsgId:allMsgid];
    }
   
    
    if (messageArr && messageArr.count > 0) { // 更新最开始的消息id
        _msgStartId = [((PayloadModel *)messageArr.firstObject).MsgId integerValue];
    }
    @weakify_self
    [messageArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PayloadModel *model = obj;
        // 查找回复消息内容
        if (model.AssocId > 0) {
            // 在服务器中查找回复消息
            UserModel *userM = [UserModel getUserModel];
            NSString *MsgStartId = [NSString stringWithFormat:@"%@",@(model.AssocId+1)];
            NSDictionary *params = @{@"Action":Action_PullMsg,@"FriendId":weakSelf.friendModel.userId?:@"",@"UserId":userM.userId?:@"",@"MsgType":@"1",@"MsgStartId":MsgStartId,@"MsgNum":@(1),@"SrcMsgId":model.MsgId};
            [SocketMessageUtil sendVersion5WithParams:params];
        }
    }];
}
#pragma mark ---删除消息成功通知-----
- (void)deleteMessageSuccess:(NSNotification *)noti {
    
    NSString *MsgId = [NSString stringWithFormat:@"%@",noti.object];
    [self deleteMsg:MsgId];

    if (self.selectMessageModel) {
        if (self.selectMessageModel.fileName && ![self.selectMessageModel.fileName isBlankString]) {
            // 删除本的文件
            [SystemUtil removeDocmentFileName:self.selectMessageModel.fileName friendid:self.friendModel.userId];
        }
    }
}
#pragma mark ---收到删除消息通知----
- (void)receiveDeleteMessage:(NSNotification *)noti {
    
    NSArray *resultArr = noti.object;
    if (resultArr && resultArr.count>0) {
        NSString *friendId = resultArr[1];
        if ([friendId isEqualToString:self.friendModel.userId]) {
            NSString *MsgId = [NSString stringWithFormat:@"%@",resultArr[0]];
            [self deleteMsg:MsgId];
        }
    }
}

#pragma mark -----发送已读------
- (void) sendRedMsgWithMsgId:(NSString *) msgid
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    BOOL result = (state != UIApplicationStateBackground);
    if (result) {
        [SendRequestUtil sendRedMsgWithFriendId:self.friendModel.userId msgid:msgid];
    }
    
}

/**
 删除消息

 @param MsgId msgid
 */
- (void)deleteMsg:(NSString *)MsgId {
    dispatch_async(dispatch_get_main_queue(), ^{
        __block BOOL isExist = NO;
        __block NSInteger index = 0;
        [self.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CDMessageModel *model = (id)obj;
            //        if ([model.messageId isEqualToString:MsgId]) {
            if ([model.messageId integerValue] == [MsgId integerValue]) {
                isExist = YES;
                index = idx;
                *stop = YES;
            }
        }];
        if (isExist) {
            NSMutableArray *tempArr = [NSMutableArray arrayWithArray:self.listView.msgArr];
            if (tempArr && tempArr.count > 0) {
                [tempArr removeObjectAtIndex:index];
                self.listView.isDelete = YES;
                self.listView.msgArr = tempArr;
                
                if (index != tempArr.count) {
                    return ;
                }
                ChatListModel *chatModel = [[ChatListModel alloc] init];
                chatModel.myID = [UserModel getUserModel].userId;
                chatModel.friendID = self.friendModel.userId;
                
                if (self.listView.msgArr.count > 0) {
                    CDMessageModel *messageModel = (id)[tempArr lastObject];
                    chatModel.chatTime = [NSDate date];
                    chatModel.isHD = NO;
                    if (messageModel.msgType == 1) {
                        chatModel.lastMessage = @"[photo]";
                    } else if (messageModel.msgType == 2) {
                        chatModel.lastMessage = @"[voice]";
                    } else if (messageModel.msgType == 5){
                        chatModel.lastMessage = @"[file]";
                    } else if (messageModel.msgType == 4) {
                        chatModel.lastMessage = @"[video]";
                    } else {
                        chatModel.lastMessage = messageModel.msg;
                    }
                } else {
                    chatModel.lastMessage = @"";
                }
               [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
            }
        }
    });
    
}
#pragma mark -----用户头像下载成功通知-----
- (void)userHeadDownloadSuccess:(NSNotification *)noti {
//    UserHeaderModel *model = noti.object;
    [_listView justReload];
}

/**
 生成用户头像视图

 @param name 昵称
 @param userKey 公钥
 @return 头像视图
 */
- (UIView *) getHeadViewWithName:(NSString *)name userKey:(NSString *)userKey {
    UIView *imgBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    imgBackView.backgroundColor = [UIColor clearColor];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:imgBackView.bounds];
//    NSString *userKey = [EntryModel getShareObject].signPublicKey;
    UIImage *defaultImg = [PNDefaultHeaderView getImageWithUserkey:userKey Name:[StringUtil getUserNameFirstWithName:name]];
    imgView.image = defaultImg;
    [imgBackView addSubview:imgView];
    return imgBackView;
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
    
    // imagePickerVc.photoWidth = 1000;
    
    // 2. Set the appearance
    // 2. 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    // imagePickerVc.navigationBar.translucent = NO;
    imagePickerVc.iconThemeColor = [UIColor colorWithRed:31 / 255.0 green:185 / 255.0 blue:34 / 255.0 alpha:1.0];
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    imagePickerVc.cannotSelectLayerColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
    [imagePickerVc setPhotoPickerPageUIConfigBlock:^(UICollectionView *collectionView, UIView *bottomToolBar, UIButton *previewButton, UIButton *originalPhotoButton, UILabel *originalPhotoLabel, UIButton *doneButton, UIImageView *numberImageView, UILabel *numberLabel, UIView *divideLine) {
        [doneButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }];
    /*
     [imagePickerVc setAssetCellDidSetModelBlock:^(TZAssetCell *cell, UIImageView *imageView, UIImageView *selectImageView, UILabel *indexLabel, UIView *bottomView, UILabel *timeLength, UIImageView *videoImgView) {
     cell.contentView.clipsToBounds = YES;
     cell.contentView.layer.cornerRadius = cell.contentView.tz_width * 0.5;
     }];
     */
    
    // 3. Set allow picking video & photo & originalPhoto or not
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
    
    // imagePickerVc.minPhotoWidthSelectable = 3000;
    // imagePickerVc.minPhotoHeightSelectable = 2000;
    
    /// 5. Single selection mode, valid when maxImagesCount = 1
    /// 5. 单选模式,maxImagesCount为1时才生效
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = NO;
    imagePickerVc.needCircleCrop = NO;
    // 设置竖屏下的裁剪尺寸
//    NSInteger left = 30;
//    NSInteger widthHeight = self.view.tz_width - 2 * left;
//    NSInteger top = (self.view.tz_height - widthHeight) / 2;
//    imagePickerVc.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
    // 设置横屏下的裁剪尺寸
    // imagePickerVc.cropRectLandscape = CGRectMake((self.view.tz_height - widthHeight) / 2, left, widthHeight, widthHeight);
    /*
     [imagePickerVc setCropViewSettingBlock:^(UIView *cropView) {
     cropView.layer.borderColor = [UIColor redColor].CGColor;
     cropView.layer.borderWidth = 2.0;
     }];*/
    
    //imagePickerVc.allowPreview = NO;
    // 自定义导航栏上的返回按钮
    /*
     [imagePickerVc setNavLeftBarButtonSettingBlock:^(UIButton *leftButton){
     [leftButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
     [leftButton setImageEdgeInsets:UIEdgeInsetsMake(0, -10, 0, 20)];
     }];
     imagePickerVc.delegate = self;
     */
    
    // Deprecated, Use statusBarStyle
    // imagePickerVc.isStatusBarDefault = NO;
    imagePickerVc.statusBarStyle = UIStatusBarStyleLightContent;
    // 设置是否显示图片序号
    imagePickerVc.showSelectedIndex = NO;
    // 自定义gif播放方案
//    [[TZImagePickerConfig sharedInstance] setGifImagePlayBlock:^(TZPhotoPreviewView *view, UIImageView *imageView, NSData *gifData, NSDictionary *info) {
//        FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:gifData];
//        FLAnimatedImageView *animatedImageView;
//        for (UIView *subview in imageView.subviews) {
//            if ([subview isKindOfClass:[FLAnimatedImageView class]]) {
//                animatedImageView = (FLAnimatedImageView *)subview;
//                animatedImageView.frame = imageView.bounds;
//                animatedImageView.animatedImage = nil;
//            }
//        }
//        if (!animatedImageView) {
//            animatedImageView = [[FLAnimatedImageView alloc] initWithFrame:imageView.bounds];
//            animatedImageView.runLoopMode = NSDefaultRunLoopMode;
//            [imageView addSubview:animatedImageView];
//        }
//        animatedImageView.animatedImage = animatedImage;
//    }];
    
    // 设置首选语言 / Set preferred language
    // imagePickerVc.preferredLanguage = @"zh-Hans";
    
    // 设置languageBundle以使用其它语言 / Set languageBundle to use other language
    // imagePickerVc.languageBundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"tz-ru" ofType:@"lproj"]];
    
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
 得到选中的图片并发送

 @param img 图片
 @param imgData 图片data
 */
- (void) sendImgageWithImage:(UIImage *) img imgData:(NSData *) imgData
{
    NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
    int msgid = [mill intValue];
    CDMessageModel *model = [[CDMessageModel alloc] init];
    model.msgType = CDMessageTypeImage;
    model.fileWidth = img.size.width;
    model.fileHeight = img.size.height;
    model.mediaImage = img;
    model.msg = @"";
    model.fileID = msgid;
    model.FromId = [UserConfig getShareObject].userId;
    model.ToId = self.friendModel.userId;
    model.msgState = CDMessageStateSending;
    model.messageId = [NSString stringWithFormat:@"%d",msgid];
    CTDataConfig config = [CTData defaultConfig];
    config.isOwner = YES;
    //            model.willDisplayTime = YES;
    model.messageStatu = -1;
    NSString *uploadFileName = [mill stringByAppendingString:@".jpg"];
    model.fileName = [mill stringByAppendingString:@".jpg"];
    model.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
    model.publicKey = self.friendModel.publicKey;
    model.ctDataconfig = config;
    NSString *nkName = [UserModel getUserModel].username;
    NSString *userKey = [EntryModel getShareObject].signPublicKey;
    model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName userKey:userKey]];
    NSString *filePath = [[SystemUtil getBaseFilePath:self.friendModel.userId] stringByAppendingPathComponent:model.fileName];
    [imgData writeToFile:filePath atomically:YES];
    
    // 保存时间
    [SystemUtil saveImageForTtimeWithToid:self.friendModel.userId fileName:model.fileName fileTime:model.TimeStatmp];
    
    [self.listView addMessagesToBottom:@[model]];
    
    [[ChatImgCacheUtil getChatImgCacheUtilShare].imgCacheDic objectForKey:[NSString stringWithFormat:@"%@_%@",model.ToId,model.fileName]];
    
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
}

/**
 导出视频并发送

 @param asset asset
 @param evImage 封面图
 */
- (void)extractedVideWithAsset:(AVURLAsset *)asset evImage:(UIImage *) evImage
{
    // [AppD.window showHudInView:AppD.window hint:@"File encrypting"];
    NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
    int msgid = [mill intValue];
    
    CDMessageModel *model = [[CDMessageModel alloc] init];
    model.msgType = CDMessageTypeMedia;
    model.messageStatu = -1;
    model.fileWidth = evImage.size.width;
    model.fileHeight = evImage.size.height;
    model.FromId = [UserConfig getShareObject].userId;
    model.ToId = self.friendModel.userId;
    model.msgState = CDMessageStateSending;
    model.messageId = [NSString stringWithFormat:@"%d",msgid];;
    model.fileID = msgid;
    CTDataConfig config = [CTData defaultConfig];
    config.isOwner = YES;
//    model.willDisplayTime = YES;
    model.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
    model.publicKey = self.friendModel.publicKey;
    model.ctDataconfig = config;
    model.mediaImage = evImage;
    NSString *nkName = [UserModel getUserModel].username;
    NSString *userKey = [EntryModel getShareObject].signPublicKey;
    model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName userKey:userKey]];
    [self.listView addMessagesToBottom:@[model]];
    
    NSString *outputPath = [NSString stringWithFormat:@"%@.mp4",mills];
    outputPath =  [[SystemUtil getBaseFilePath:self.friendModel.userId] stringByAppendingPathComponent:outputPath];
    NSURL *url = [NSURL fileURLWithPath:outputPath];
    
    BOOL result = [[NSFileManager defaultManager] copyItemAtURL:asset.URL toURL:url error:nil];
    
    if (result) {
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        //UIImage *img = [SystemUtil thumbnailImageForVideo:url];
        __block NSData *mediaData = [NSData dataWithContentsOfFile:outputPath];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            model.fileSize = mediaData.length;
            model.fileName = [[outputPath componentsSeparatedByString:@"/"] lastObject];
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
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
        NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
        int msgid = [mill intValue];
        CDMessageModel *model = [[CDMessageModel alloc] init];
        model.msgType = CDMessageTypeFile;
        model.FromId = [UserConfig getShareObject].userId;
        model.ToId = self.friendModel.userId;
        model.fileSize = txtData.length;
        model.msgState = CDMessageStateSending;
        model.messageId = [NSString stringWithFormat:@"%d",msgid];;
        model.fileID = msgid;
        model.messageStatu = -1;
        CTDataConfig config = [CTData defaultConfig];
        config.isOwner = YES;
//        model.willDisplayTime = YES;
        
        model.fileName = [NSString getUploadFileNameOfCorrectLength:fileUrl.lastPathComponent];
        NSString *uploadFileName = model.fileName;
        
        model.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
        model.publicKey = self.friendModel.publicKey;
        model.ctDataconfig = config;
        NSString *nkName = [UserModel getUserModel].username;
        NSString *userKey = [EntryModel getShareObject].signPublicKey;
        model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName userKey:userKey]];
        NSString *filePath = [[SystemUtil getBaseFilePath:self.friendModel.userId] stringByAppendingPathComponent:model.fileName];
        [txtData writeToFile:filePath atomically:YES];
        
        [self.listView addMessagesToBottom:@[model]];
        
        // 生成32位对称密钥
        NSString *msgKey = [SystemUtil getDoc32AESKey];
        NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
        NSString *symmetKey = [symmetData base64EncodedString];
        // 好友公钥加密对称密钥
        NSString *dsKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:self.friendModel.publicKey];
        // 自己公钥加密对称密钥
        NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
        
        NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
        txtData = aesEncryptData(txtData,msgKeyData);
        
        
        [self sendFileWithToid:self.friendModel.userId fileName:uploadFileName fileData:txtData fileId:msgid fileType:5 messageId:model.messageId srcKey:srcKey dsKey:dsKey publicKey:self.friendModel.publicKey msgKey:msgKey fileInfo:@""];
    }
}

/**
 保存图片到相册

 @param image 图片
 */
- (void)saveImage:(UIImage *)image{
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
    }
}

/**
 保存视频到相册
 
 @param videoPath 视频
 */
- (void)saveVideo:(NSString *)videoPath{
    if (videoPath) {
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath)) {
            //保存相册核心代码
            UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
        }
    }
}


//保存图片完成后调用的方法
- (void) savedPhotoImage:(UIImage*)image didFinishSavingWithError: (NSError *)error contextInfo: (void *)contextInfo {
    if (!error) {
        [AppD.window showSuccessHudInView:AppD.window hint:@"Saved"];
    } else {
        [AppD.window showFaieldHudInView:AppD.window hint:@"Failed to Save"];
    }
}

//保存视频完成之后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (!error) {
        [AppD.window showSuccessHudInView:AppD.window hint:@"Saved"];
    } else {
        [AppD.window showFaieldHudInView:AppD.window hint:@"Failed to Save"];
    }
    
}


#pragma mark --------群聊发送文件---------
- (void) sendGroupFileWithToid:(NSString *) toId fileName:(NSString *) fileName fileData:(NSData *) fileData fileId:(int) fileId fileType:(int) fileType messageId:(NSString *) messageId srcKey:(NSString *) srcKey dsKey:(NSString *) dsKey publicKey:(NSString *) publicKey msgKey:(NSString *) msgKey fileInfo:(NSString *) fileInfo
{
    if ([SystemUtil isSocketConnect]) {
        
        ChatModel *chatModel = [[ChatModel alloc] init];
        chatModel.fromId = [UserConfig getShareObject].userId;
        chatModel.toId = toId;
        chatModel.fileInfo = fileInfo;
        chatModel.toPublicKey = publicKey;
        chatModel.msgType = fileType;
        chatModel.fileSize = fileData.length;
        chatModel.msgid = (long)[messageId integerValue];
        chatModel.bg_tableName = CHAT_CACHE_TABNAME;
        chatModel.fileName = fileName;
        chatModel.filePath =[[SystemUtil getBaseFilePath:toId] stringByAppendingPathComponent:fileName];
        chatModel.srcKey = srcKey;
        chatModel.dsKey = dsKey;
        chatModel.msgKey = msgKey;
        chatModel.sendTime = [NSDate getTimestampFromDate:[NSDate date]];
        [chatModel bg_save];
        
        
        SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
        dataUtil.fileInfo = fileInfo;
        [dataUtil sendFileId:toId fileName:fileName fileData:fileData fileid:fileId fileType:fileType messageid:messageId srcKey:srcKey dstKey:dsKey isGroup:YES];
        [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
    } else {
        
        NSString *filePath = [[SystemUtil getTempBaseFilePath:toId] stringByAppendingPathComponent:[Base58Util Base58EncodeWithCodeName:fileName]];
        
        if ([fileData writeToFile:filePath atomically:YES]) {
            NSDictionary *parames = @{@"Action":@"GroupSendFileDone",@"UserId":[UserConfig getShareObject].userId,@"GId":toId,@"FileName":[Base58Util Base58EncodeWithCodeName:fileName],@"FileMD5":[MD5Util md5WithPath:filePath],@"FileSize":@(fileData.length),@"FileType":@(fileType),@"DstKey":dsKey,@"FileId":messageId,@"FileInfo":fileInfo};
            [SendToxRequestUtil sendFileWithFilePath:filePath parames:parames];
            //  [SendRequestUtil sendQueryFriendWithFriendId:self.friendModel.userId];
        }
    }
}
#pragma mark ----长按图片显示菜单--------
- (void)yb_imageBrowser:(YBImageBrowser *)imageBrowser pageIndexChanged:(NSUInteger)index data:(id<YBImageBrowserCellDataProtocol>)data
{
    YBImageBrowserSheetView *sheetView = imageBrowser.sheetView;
    NSMutableArray *mutArr = [self.actionArr mutableCopy];
    YBImageBrowseCellData *data1 = (YBImageBrowseCellData *)data;
    
    [HMScanner scaneImage:data1.image completion:^(NSArray *values) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!values || values.count == 0) {
                [mutArr removeLastObject];
                sheetView.actions = [NSArray arrayWithArray:mutArr];
            } else {
                sheetView.actions = [NSArray arrayWithArray:mutArr];
            }
        });
    }];
}

/**
 保存图片到本地

 @param image image
 */
- (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [AppD.window showSuccessHudInView:AppD.window hint:@"Saved"];
    } else {
        [AppD.window showFaieldHudInView:AppD.window hint:@"Failed to Save"];
    }
}

/**
 跳转到添加好友vc

 @param friendId friendId
 @param nickName nickName
 @param signpk signpk
 */
- (void)addFriendRequest:(NSString *)friendId nickName:(NSString *) nickName signpk:(NSString *) signpk
{
    FriendRequestViewController *vc = [[FriendRequestViewController alloc] initWithNickname:nickName userId:friendId signpk:signpk];
    [self.navigationController pushViewController:vc animated:YES];
    
}

/**
 跳转到codemsg vc

 @param codeValue codeValue
 */
- (void) jumpCodeValueVCWithCodeValue:(NSString *) codeValue
{
    CodeMsgViewController *vc = [[CodeMsgViewController alloc] initWithCodeValue:codeValue];
    [browser presentViewController:vc animated:YES completion:nil];
    
}

/**
 导入帐户

 @param values values
 */
- (void) showAlertImportAccount:(NSArray *) values
{
    NSString *signpk = values[1];
   // NSString *usersn = values[2];
    if ([signpk isEqualToString:[EntryModel getShareObject].signPrivateKey])
    {
        
        [AppD.window showHint:@"The same user."];
        return;
        
//        RouterModel *selectRouther = [RouterModel checkRoutherWithSn:usersn];
//        if (selectRouther) {
//            if ([[RouterConfig getRouterConfig].currentRouterToxid isEqualToString:selectRouther.toxid]) { // 是当前帐户
//                [AppD.window showHint:@"The same user."];
//                return;
//            }
//        }
    }
    
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"" message:@"This operation will overwrite the current account. Do you want to continue?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if (![signpk isEqualToString:[EntryModel getShareObject].signPrivateKey]) {
            // 清除所有数据
            [SystemUtil clearAppAllData];
            // 更改私钥
            [UserPrivateKeyUtil changeUserPrivateKeyWithPrivateKey:values[1]];
            NSString *name = [values[3] base64DecodedString];
            [UserModel createUserLocalWithName:name];
            // 删除所有路由
            [RouterModel delegateAllRouter];
            
            [AppD setRootLoginWithType:ImportType];
        }
            
//        } else {
//            RouterModel *selectRouther = [RouterModel checkRoutherWithSn:usersn];
//            if (selectRouther) {
//                [RouterConfig getRouterConfig].currentRouterToxid = selectRouther.toxid;
//                [RouterConfig getRouterConfig].currentRouterSn = selectRouther.userSn;
//                [[CircleOutUtil getCircleOutUtilShare] circleOutProcessingWithRid:selectRouther.toxid];
//            } else {
//                [AppD setRootLoginWithType:ImportType];
//            }
//        }
        
    }];
    
    [vc addAction:cancelAction];
    [vc addAction:confirm];
    
    [browser presentViewController:vc animated:YES completion:nil];
}

/**
 切换圈子

 @param values values
 @param isMac yes:mac帐户 no: 普通帐户
 */
- (void) showAlertVCWithValues:(NSArray *) values isMac:(BOOL) isMac
{
    self.view.hidden = YES;
    [self removeFromParentViewController];
    
    AppD.isScaner = YES;
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:nil message:@"Do you want to switch the circle?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (isMac) {
            [RouterConfig getRouterConfig].currentRouterMAC = values[0];
            [[CircleOutUtil getCircleOutUtilShare] circleOutProcessingWithRid:values[0]];
        } else {
            [RouterConfig getRouterConfig].currentRouterToxid = values[0];
            [RouterConfig getRouterConfig].currentRouterSn = values[1];
            [[CircleOutUtil getCircleOutUtilShare] circleOutProcessingWithRid:values[0]];
        }
    }];
    [alert1 setValue:UIColorFromRGB(0x2C2C2C) forKey:@"_titleTextColor"];
    [alertC addAction:alert1];
    
    UIAlertAction *alertCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertC addAction:alertCancel];
    
    [browser presentViewController:alertC animated:YES completion:nil];
    
}

@end
