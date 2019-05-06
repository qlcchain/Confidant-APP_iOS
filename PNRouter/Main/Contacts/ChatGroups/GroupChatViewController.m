//
//  GroupChatViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "GroupChatViewController.h"
#import "FriendDetailViewController.h"
#import "BaseMsgModel.h"
#import "CDChatList.h"
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "UserModel.h"
#import "SocketMessageUtil.h"
#import "FriendModel.h"
#import "CDMessageModel.h"
#import "NSDate+Category.h"
#import "PNRouter-Swift.h"
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
#import "LibsodiumUtil.h"
#import "EntryModel.h"
#import "PNDocumentPickerViewController.h"
#import "ChatModel.h"
#import "PNDefaultHeaderView.h"
#import "UserHeadUtil.h"
#import "UserHeaderModel.h"
#import "GroupInfoModel.h"
#import "GroupDetailsViewController.h"
#import "UpdateGroupMemberAvatarUtil.h"
#import <YBImageBrowser/YBImageBrowser.h>
#import "NSString+Trim.h"
#import "ChatImgCacheUtil.h"
#import "NSString+File.h"
#import "GroupMembersViewController.h"
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
#import "GroupMembersModel.h"
#import "AtUserModel.h"

#define StatusH [[UIApplication sharedApplication] statusBarFrame].size.height
#define NaviH (44 + StatusH)
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

typedef void(^PullMoreBlock)(NSArray *arr);

@interface GroupChatViewController ()<ChatListProtocol,
CTInputViewProtocol,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,TZImagePickerControllerDelegate,UIDocumentPickerDelegate,YBImageBrowserDelegate>
{
    BOOL isGroupChatViewController;
    YBImageBrowser *browser;
    NSInteger insertIndex;
}
@property (weak, nonatomic) IBOutlet UILabel *lblNavTitle;
@property (weak, nonatomic) IBOutlet UIView *tabBackView;
@property(nonatomic, weak)CDChatListView *listView;
@property(nonatomic, weak)CTInputView *msginputView;
@property (nonatomic ,assign) NSInteger msgStartId;

@property (nonatomic ,strong) CDMessageModel *selectMessageModel;
@property (nonatomic, copy) PullMoreBlock pullMoreB;
@property (nonatomic, strong) NSString *deleteMsgId;

@property (nonatomic ,strong) GroupInfoModel *groupModel;

@property (nonatomic ,strong) NSMutableArray *actionArr;
@property (nonatomic ,strong) NSMutableArray *atModels;
@end

@implementation GroupChatViewController

#pragma mark ---layz
- (NSMutableArray *)actionArr
{
    if (!_actionArr) {
        _actionArr = [NSMutableArray array];
    }
    return _actionArr;
}
- (NSMutableArray *)atModels
{
    if (!_atModels) {
        _atModels = [NSMutableArray array];
    }
    return _atModels;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    NSString *showTitle = _groupModel.Remark&&_groupModel.Remark.length>0?_groupModel.Remark:_groupModel.GName;
    _lblNavTitle.text = [showTitle base64DecodedString]?:showTitle;
    isGroupChatViewController = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    isGroupChatViewController = NO;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype) initWihtGroupMode:(GroupInfoModel *) model
{
    if (self = [super init]) {
        self.groupModel = model;
    }
    return self;
}
- (IBAction)backAction:(id)sender {
    
    NSString *textString = [self.msginputView getTextViewString];
    textString = [NSString trimNewline:textString];
    
    if (![[NSString getNotNullValue:textString] isEmptyString]) {
        // 添加到chatlist
        ChatListModel *chatModel = [[ChatListModel alloc] init];
        chatModel.myID = [UserModel getUserModel].userId;
        chatModel.groupName = _lblNavTitle.text;
        chatModel.groupUserkey = self.groupModel.UserKey;
        chatModel.isGroup = YES;
        chatModel.groupID = self.groupModel.GId;
        chatModel.isHD = NO;
        // 解密消息
        chatModel.isDraft = YES;
        chatModel.draftMessage = textString;
        
        if (self.msginputView.atStrings.count > 0) {
            NSString *atIds = @"";
            NSString *atNames = @"";
            for (int i = 0; i<self.msginputView.atStrings.count; i++) {
                AtUserModel *atModel = self.msginputView.atStrings[i];
                atIds = [atIds stringByAppendingString:atModel.userId];
                atNames = [atNames stringByAppendingString:atModel.atName];
                if (i != self.msginputView.atStrings.count-1) {
                    atIds = [atIds stringByAppendingString:@","];
                    atNames = [atNames stringByAppendingString:@","];
                }
            }
            chatModel.isAT = YES;
            chatModel.atNames = atNames;
            chatModel.atIds = atIds;
            // 清除所有@
            [self.msginputView.atStrings removeAllObjects];
        }
        [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
    } else {
        NSArray *friends = [ChatListModel bg_find:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"groupID"),bg_sqlValue(self.groupModel.GId),bg_sqlKey(@"myID"),bg_sqlValue([UserModel getUserModel].userId)]];
        if (friends && friends.count > 0) {
            ChatListModel *chatModel = friends[0];
            if (chatModel.isDraft) {
                chatModel.isDraft = NO;
                chatModel.draftMessage = @"";
                // 清除at消息
                chatModel.isAT = NO;
                chatModel.atNames = @"";
                chatModel.atIds = @"";
                
                [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
            }
        }
    }
    [SocketCountUtil getShareObject].groupChatId = @"";
    if ([self.navigationController.viewControllers count] == 2) {
        self.tabBarController.selectedIndex = 0;
    }
    [self leftNavBarItemPressedWithPop:YES];
   
}

- (IBAction)rightAction:(id)sender {
    GroupDetailsViewController *vc = [[GroupDetailsViewController alloc] initWithGroupInfo:_groupModel];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNoti];
    
    self.view.backgroundColor = RGB(246, 246, 246);
   
    [self loadChatUI];
    _msgStartId = 0;
    [self.listView startRefresh];
    [SocketCountUtil getShareObject].groupChatId = self.groupModel.GId;
    
    NSArray *friends = [ChatListModel bg_find:FRIEND_CHAT_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"groupID"),bg_sqlValue(self.groupModel.GId),bg_sqlKey(@"myID"),bg_sqlValue([UserModel getUserModel].userId)]];
    if (friends && friends.count > 0) {
        ChatListModel *chatModel = friends[0];
        if (chatModel.isATYou) {
            chatModel.isATYou = NO;
            chatModel.isOwerClearAtYour = YES;
            [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
        }
        if (chatModel.isDraft) {
            [self.msginputView setTextViewString:chatModel.draftMessage];
            if (chatModel.isAT) {
                NSArray *atIds = [chatModel.atIds componentsSeparatedByString:@","];
                NSArray *atNames = [chatModel.atNames componentsSeparatedByString:@","];
                if (atIds && atIds.count > 0) {
                    for (int i = 0; i<atIds.count; i++) {
                        AtUserModel *atModel = [[AtUserModel alloc] init];
                        atModel.userId = atIds[i];
                        atModel.atName = atNames[i];
                        [self.msginputView.atStrings addObject:atModel];
                    }
                }
            }
        }
    }
}

#pragma mark ----添加通知
- (void) addNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessageSuccessNoti:) name:GROUP_MESSAGE_SEND_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullMessageListSuccessNoti:) name:PULL_GROUP_MESSAGE_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessgePushNoti:) name:RECEVIED_GROUP_MESSAGE_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSysMessgePushNoti:) name:RECEVIED_GROUP_SYSMSG_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDelMessgePushNoti:) name:RECEVIED_Del_GROUP_MESSAGE_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userHeadDownloadSuccess:) name:USER_HEAD_DOWN_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupFileSendSuccess:) name:GROUP_FILE_SEND_SUCCESS_NOTI object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupFileSendFaield:) name:GROUP_FILE_SEND_FAIELD_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toxDownFileSuccess:) name:REVER_GROUP_FILE_PULL_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileSendingNoti:) name:FILE_SENDING_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageForward:) name:CHOOSE_FRIEND_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remindUserNoti:) name:REMIND_USER_SUCCESS_NOTI object:nil];
}

#pragma mark ---pull message
- (void)pullMessageRequest {
    NSString *MsgType = @"0"; // 0：所有记录  1：纯聊天消息   2：文件传输记录
    NSString *MsgStartId = [NSString stringWithFormat:@"%@",@(_msgStartId)]; // 从这个消息号往前（不包含该消息），为0表示默认从最新的消息回溯
    NSString *MsgNum = @"10"; // 期望拉取的消息条数
    [SendRequestUtil sendPullGroupMessageListWithGId:self.groupModel.GId MsgType:MsgType msgStartId:MsgStartId msgNum:MsgNum];
}
- (void) pullGroupFriend

{
   // [SendRequestUtil sendGroupUserPullWithGId:self.groupModel.GId TargetNum:@(0) StartId:@"" showHud:NO];
}

#pragma mark ------loadui
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
#pragma mark ChatListProtocol

-(void)chatlistBecomeFirstResponder{
    [self.msginputView resignFirstResponder];
}

- (void)clickFileCellWithMsgMode:(CDChatMessage)msgModel withFilePath:(NSString *)filePath {
    [YWFilePreviewView previewFileWithPaths:filePath fileName:msgModel.fileName fileType:msgModel.msgType];
}
- (void)clickHeadWithMessage:(CDChatMessage)clickMessage
{
    FriendModel *fModel = [[ChatListDataUtil getShareObject] getFriendWithUserid:clickMessage.FromId];
    FriendModel *friendModel = [[FriendModel alloc] init];
    if (!fModel) {
        friendModel.userId = clickMessage.FromId;
        friendModel.username = clickMessage.userName;
        friendModel.signPublicKey = clickMessage.publicKey;
        friendModel.noFriend = YES;
    } else {
        
        friendModel.userId = fModel.userId;
        friendModel.username = [fModel.username base64DecodedString]?:fModel.username;
        friendModel.publicKey = fModel.publicKey;
        friendModel.remarks = [fModel.remarks base64DecodedString]?:fModel.remarks;
        friendModel.Index = fModel.Index;
        friendModel.onLineStatu = fModel.onLineStatu;
        friendModel.signPublicKey = fModel.signPublicKey;
        friendModel.RouteId = fModel.RouteId;
        friendModel.RouteName = fModel.RouteName;
        friendModel.signPublicKey = fModel.publicKey;
       
    }
    
    FriendDetailViewController *vc = [[FriendDetailViewController alloc] init];
    vc.friendModel = friendModel;
    vc.isGroup = YES;
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)clickChatMenuItem:(NSString *)itemTitle withMsgMode:(CDChatMessage) msgModel
{
    self.selectMessageModel = (CDMessageModel *)msgModel;
    NSString *msgId = [NSString stringWithFormat:@"%@",self.selectMessageModel.messageId];
    NSLog(@"%@",itemTitle);
    if ([itemTitle isEqualToString:@"Forward"]){ // 转发
        ChooseContactViewController *vc = [[ChooseContactViewController alloc] init];
        [self presentModalVC:vc animated:YES];
    }  else if ([itemTitle isEqualToString:@"Withdraw"]){ // 删除
        
        if ([SystemUtil isSocketConnect]) {
            // 取消文件发送，删除记录
            [ChatModel bg_delete:CHAT_CACHE_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"fromId"),bg_sqlValue([UserConfig getShareObject].userId),bg_sqlKey(@"msgid"),bg_sqlValue(msgId)]];
        }
        
        if (self.selectMessageModel.fileID > 0 && self.selectMessageModel.msgState == CDMessageStateSending) { // 是文件
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
            NSInteger optionType = 0;
            if (self.selectMessageModel.isLeft) {
                optionType = 1;
            }
            [SendRequestUtil sendDelGroupMessageWithType:@(optionType) GId:self.groupModel.GId MsgId:msgId FromID:userM.userId];
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
    }
}
//cell 的点击事件
- (void)chatlistClickMsgEvent:(ChatListInfo *)listInfo imgView:(UIImageView *)imgV {
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
            
            NSString *fileDocs = [SystemUtil getBaseFilePath:self.groupModel.GId];
            NSFileManager *fm = [NSFileManager defaultManager];
            NSDirectoryEnumerator *dirEnumerater = [fm enumeratorAtPath:fileDocs];
            NSString *filePath = nil;
            __block NSInteger cidx = 0;
            
            NSMutableArray *imgDataArr = [NSMutableArray array];
            NSMutableDictionary *timeDics = [NSMutableDictionary dictionaryWithContentsOfFile:[[SystemUtil getBaseFileTimePathWithToid:self.groupModel.GId] stringByAppendingPathComponent:@"times"]];
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
        }
            break;
        case ChatClickEventTypeTEXT:
            [self.view makeToast:listInfo.clickedText duration:0.5 position:CSToastPositionCenter];
            break;
    }
}

#pragma mark ---长按头像@
- (void) longPressHeadWithMessage:(CDChatMessage)clickMessage
{
    insertIndex = [self.msginputView getTextViewString].length;
    NSString *insertString = [NSString stringWithFormat:kATFormat,clickMessage.userName];
    NSMutableString *string = [NSMutableString stringWithString:[self.msginputView getTextViewString]];
    [string insertString:insertString atIndex:insertIndex];
    if (string.length > 245) {
        [self.view showHint:@"The length of the sent content is out of range."];
        return;
    }
    [self.msginputView setTextViewString:string delayTime:0];
    [self.msginputView setSelectedRange:NSMakeRange(insertIndex + insertString.length, 0)];
    
    AtUserModel *atModel = [[AtUserModel alloc] init];
    atModel.userId = clickMessage.FromId;
    atModel.userName = clickMessage.userName;
    atModel.atName = insertString;
    [self.msginputView.atStrings addObject:atModel];
}

// 下拉加载更多
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
}

#pragma mark CTInputViewProtocol

- (void)inputViewPopAudioath:(NSURL *)path {
    
    // 此处会存到内存和本地， 内存地址不会加密，本地地址会加密
    NSString *mill = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    mill = [mill substringWithRange:NSMakeRange(mill.length-9, 9)];
    int msgid = [mill intValue];
    
    NSString *amrPath = [[SystemUtil getBaseFilePath:self.groupModel.GId] stringByAppendingPathComponent:[mill stringByAppendingString:@".amr"]];
    
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
        mode.ToId = self.groupModel.GId;
        mode.fileName = [mill stringByAppendingString:@".amr"];
        mode.isGroup = YES;
        NSString *uploadFileName = mode.fileName;
        mode.fileID = msgid;
        mode.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
        mode.publicKey = self.groupModel.UserKey;
        mode.messageId = [NSString stringWithFormat:@"%d",msgid];;
//        mode.willDisplayTime = YES;
        NSString *userKey = [EntryModel getShareObject].signPublicKey;
        mode.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:[UserModel getUserModel].username userKey:userKey]];
        mode.isLeft = NO;
        mode.audioSufix = @"amr";
        mode.dskey = self.groupModel.UserKey;
        mode.srckey = self.groupModel.UserKey;
        [self.listView addMessagesToBottom:@[mode]];
        
        // 自己私钥解密
        NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:self.groupModel.UserKey];
        NSString *symmetKey = [[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding];
        NSData *msgKeyData =[[symmetKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
        data = aesEncryptData(data,msgKeyData);
        
        [self sendFileWithToid:self.groupModel.GId fileName:uploadFileName fileData:data fileId:msgid fileType:2 messageId:mode.messageId srcKey:@"" dsKey:@"" publicKey:@"" msgKey:@"" fileInfo:@""];
        
    }else{
        NSLog(@"wav转amr失败");
    }
}

//调用系统相册
- (void)selectImage{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    @weakify_self
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
                // 无相机权限 做一个友好的提示
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view endEditing:YES];
                    [AppD.window showHint:@"请在iPhone的""设置-隐私-相册""中允许访问相册"];
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

// 调用系统相机
- (void)selectCamera:(BOOL)isCamera {
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view endEditing:YES];
            [AppD.window showHint:@"Denied or Restricted"];
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

#pragma UIImagePickerController delegate
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

#pragma mark -发送更多回调
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
        
        
    } else if ([string isEqualToString:@"Short Video"]) { // 视频
        
        //[self pushTZImagePickerController];
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        @weakify_self
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.view endEditing:YES];
                        [AppD.window showHint:@"请在iPhone的""设置-隐私-相册""中允许访问相册"];
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



#pragma mark -发送文件
- (void) sendFileWithToid:(NSString *) toId fileName:(NSString *) fileName fileData:(NSData *) fileData fileId:(int) fileId fileType:(int) fileType messageId:(NSString *) messageId srcKey:(NSString *) srcKey dsKey:(NSString *) dsKey publicKey:(NSString *) publicKey msgKey:(NSString *) msgKey fileInfo:(NSString *) fileInfo
{
    if ([SystemUtil isSocketConnect]) {
        
        ChatModel *chatModel = [[ChatModel alloc] init];
        chatModel.fromId = [UserConfig getShareObject].userId;
        chatModel.toId = toId;
        chatModel.fileInfo = fileInfo;
        if ([publicKey isEmptyString]) {
            chatModel.toPublicKey = self.groupModel.UserKey;
        } else {
            chatModel.toPublicKey = publicKey;
        }
        
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
// 输入@
- (void) inputViewPopRemid
{
    // 去选择@的人
    [self.msginputView setTextUnmarkText];
    insertIndex = self.msginputView.getTextViewString.length;
    
    if (self.msginputView.isFirstResponder)
    {
        insertIndex  = self.msginputView.selectedRange.location + self.msginputView.selectedRange.length;
       // [self.msginputView resignFirstResponder];
    }
    
    GroupMembersViewController *vc  = [[GroupMembersViewController alloc] init];
    vc.groupInfoM = self.groupModel;
    vc.optionType = RemindType;
    [self presentModalVC:vc animated:YES];
}

// 输入框输出文字
- (void)inputViewPopSttring:(NSString *)string {
    // 去掉前后换行符
    string = [NSString trimNewline:string];
    
    if (string && ![string isEmptyString]) {
        
        CDMessageModel *model = [[CDMessageModel alloc] init];
        model.FromId = [UserConfig getShareObject].userId;
        model.ToId = self.groupModel.GId;
        model.publicKey = self.groupModel.UserKey;
        model.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
        long tempMsgid = (long)[ChatListDataUtil getShareObject].tempMsgId++;
        tempMsgid = [NSDate getTimestampFromDate:[NSDate date]]+tempMsgid;
        model.messageId = [NSString stringWithFormat:@"%ld",(long)tempMsgid];
        model.msg = string;
        model.isGroup = YES;
        model.isAdmin = self.groupModel.UserType+GROUP_IDF;;
        model.msgState = CDMessageStateNormal;
      
        model.messageStatu = -1;
        [self addMessagesToList:model];
        // 自己私钥解密
        NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:self.groupModel.UserKey];
        // 截取前16位
        if (!datakey || datakey.length == 0) {
            return;
        }
        datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
        // aes加密
        NSString *enMsg = aesEncryptString(string, datakey);
        NSString *points = @"";
        if (self.msginputView.atStrings.count > 0) {
            for (int i = 0; i<self.msginputView.atStrings.count; i++) {
                AtUserModel *atModel = self.msginputView.atStrings[i];
                if ([atModel.userId isEqualToString:@"all"]) {
                    points = atModel.userId;
                    break;
                }
                points = [points stringByAppendingString:atModel.userId];
                if (i != self.msginputView.atStrings.count-1) {
                    points = [points stringByAppendingString:@","];
                }
            }
            // 清除所有@
            [self.msginputView.atStrings removeAllObjects];
        }
        // 发送消息
        [SendRequestUtil sendGroupMessageWithGid:self.groupModel.GId point:points msg:enMsg msgid:model.messageId];
        
        if ([SystemUtil isSocketConnect]) {
            ChatModel *chatModel = [[ChatModel alloc] init];
            chatModel.fromId = model.FromId;
            chatModel.toId = model.ToId;
            chatModel.atIds = points;
            chatModel.toPublicKey = model.publicKey;
            chatModel.msgType = 0;
            chatModel.msgid = tempMsgid;
            chatModel.messageMsg = string;
            chatModel.sendTime = [NSDate getTimestampFromDate:[NSDate date]];
            chatModel.bg_tableName = CHAT_CACHE_TABNAME;
            [chatModel bg_save];
        }
    }
}
#pragma mark -得到一条文字消息 并添加到listview
- (void) addMessagesToList:(CDMessageModel *) model
{
    NSString *userId = [UserConfig getShareObject].userId;
    if (![model.ToId isEqualToString:self.groupModel.GId]) {
        return;
    }
    if ([model.FromId isEqualToString:userId]) {
        model.isLeft = NO;
    } else {
        model.isLeft = YES;
    }
    
    NSString *signPK = [[ChatListDataUtil getShareObject] getFriendSignPublickeyWithFriendid:model.FromId];
    NSString *nickName = model.userName?:@"";
    CTDataConfig config = [CTData defaultConfig];
    
    if (!model.isLeft) {
        // config.textColor = MAIN_PURPLE_COLOR.CGColor;
        config.isOwner = YES;
        signPK = [EntryModel getShareObject].signPublicKey;
        nickName = [UserConfig getShareObject].userName;
    }
//    model.willDisplayTime = YES;
    model.ctDataconfig = config;
   
    model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nickName userKey:signPK]];
    [self.listView addMessagesToBottom:@[model]];
}
#pragma mark - 当输入框frame变化是，会回调此方法
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
//        NSIndexPath *index = [NSIndexPath indexPathForRow:num inSection:0];
//        [self.listView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//    }
   
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}

#pragma mark --------删除消息
- (void)deleteMsg:(NSString *)MsgId {
    dispatch_async(dispatch_get_main_queue(), ^{
        __block BOOL isExist = NO;
        __block NSInteger index = 0;
        [self.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CDMessageModel *model = (id)obj;
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
                chatModel.groupID = self.groupModel.GId;
                chatModel.friendID = [UserModel getUserModel].userId;
                chatModel.isGroup = YES;
                if (self.listView.msgArr.count > 0) {
                    CDMessageModel *messageModel = (id)[tempArr lastObject];
                    chatModel.chatTime = [NSDate date];
                    chatModel.isHD = NO;
                    chatModel.groupName = self.lblNavTitle.text;
                    if (messageModel.isLeft) {
                        chatModel.friendID = messageModel.FromId;
                        chatModel.friendName = messageModel.userName;
                    }
                    chatModel.friendName = @"";
                    chatModel.groupUserkey = self.groupModel.UserKey;
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

#pragma mark -得到自己头像
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


#pragma mark ----选择图片和视频
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
        if (photos.count > 0 && assets.count > 0) {
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

- (void) sendImgageWithImage:(UIImage *) img imgData:(NSData *) imgData
{
    NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
    int msgid = [mill intValue];
    CDMessageModel *model = [[CDMessageModel alloc] init];
    model.msgType = CDMessageTypeImage;
    model.msg = @"";
    model.fileID = msgid;
    model.fileWidth = img.size.width;
    model.fileHeight = img.size.height;
    model.mediaImage = img;
    model.FromId = [UserConfig getShareObject].userId;
    model.ToId = self.groupModel.GId;
    model.msgState = CDMessageStateSending;
    model.messageId = [NSString stringWithFormat:@"%d",msgid];
    CTDataConfig config = [CTData defaultConfig];
    config.isOwner = YES;
    model.isGroup = YES;
    model.isAdmin = self.groupModel.UserType+GROUP_IDF;
    //            model.willDisplayTime = YES;
    model.messageStatu = -1;
    NSString *uploadFileName = [mill stringByAppendingString:@".jpg"];
    model.fileName = [mill stringByAppendingString:@".jpg"];
    model.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
    model.publicKey = self.groupModel.UserKey;
    model.ctDataconfig = config;
    NSString *nkName = [UserModel getUserModel].username;
    NSString *userKey = [EntryModel getShareObject].signPublicKey;
    model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName userKey:userKey]];
    NSString *filePath = [[SystemUtil getBaseFilePath:self.groupModel.GId] stringByAppendingPathComponent:model.fileName];
    [imgData writeToFile:filePath atomically:YES];
    
    [SystemUtil saveImageForTtimeWithToid:self.groupModel.GId fileName:model.fileName fileTime:model.TimeStatmp];
    
    model.dskey = self.groupModel.UserKey;
    model.srckey = self.groupModel.UserKey;
    [self.listView addMessagesToBottom:@[model]];
    
     [[ChatImgCacheUtil getChatImgCacheUtilShare].imgCacheDic objectForKey:[NSString stringWithFormat:@"%@_%@",model.ToId,model.fileName]];
    
    // 自己私钥解密
    NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:self.groupModel.UserKey];
    NSString *symmetKey = [[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding];
    NSData *msgKeyData =[[symmetKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
    imgData = aesEncryptData(imgData,msgKeyData);
    
    [self sendFileWithToid:self.groupModel.GId fileName:uploadFileName fileData:imgData fileId:msgid fileType:1 messageId:model.messageId srcKey:@"" dsKey:@"" publicKey:@"" msgKey:@"" fileInfo:[NSString stringWithFormat:@"%f*%f",model.fileWidth,model.fileHeight]];
}

- (void)extractedVideWithAsset:(AVURLAsset *)asset evImage:(UIImage *) evImage
{
    // [AppD.window showHudInView:AppD.window hint:@"File encrypting"];
    NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
    int msgid = [mill intValue];
    
    CDMessageModel *model = [[CDMessageModel alloc] init];
    model.msgType = CDMessageTypeMedia;
    model.messageStatu = -1;
    model.FromId = [UserConfig getShareObject].userId;
    model.ToId = self.groupModel.GId;
    model.msgState = CDMessageStateSending;
    model.messageId = [NSString stringWithFormat:@"%d",msgid];;
    model.fileID = msgid;
    CTDataConfig config = [CTData defaultConfig];
    config.isOwner = YES;
//    model.willDisplayTime = YES;
    model.fileHeight = evImage.size.height;
    model.fileWidth = evImage.size.width;
    model.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
    model.publicKey = self.groupModel.UserKey;
    model.isGroup = YES;
    model.isAdmin = self.groupModel.UserType+GROUP_IDF;
    model.ctDataconfig = config;
    model.mediaImage = evImage;
    NSString *nkName = [UserModel getUserModel].username;
    NSString *userKey = [EntryModel getShareObject].signPublicKey;
    model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName userKey:userKey]];
    model.dskey = self.groupModel.UserKey;
    model.srckey = self.groupModel.UserKey;
    [self.listView addMessagesToBottom:@[model]];
    
    NSString *outputPath = [NSString stringWithFormat:@"%@.mp4",mills];
    outputPath =  [[SystemUtil getBaseFilePath:self.groupModel.GId] stringByAppendingPathComponent:outputPath];
    NSURL *url = [NSURL fileURLWithPath:outputPath];
    
    BOOL result = [[NSFileManager defaultManager] copyItemAtURL:asset.URL toURL:url error:nil];
    
    if (result) {
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        //UIImage *img = [SystemUtil thumbnailImageForVideo:url];
        __block NSData *mediaData = [NSData dataWithContentsOfFile:outputPath];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            model.fileSize = mediaData.length;
            model.fileName = [[outputPath componentsSeparatedByString:@"/"] lastObject];
            // 自己私钥解密
            NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:self.groupModel.UserKey];
            NSString *symmetKey = [[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding];
            NSData *msgKeyData =[[symmetKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
            mediaData = aesEncryptData(mediaData,msgKeyData);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self sendFileWithToid:self.groupModel.GId fileName:model.fileName fileData:mediaData fileId:msgid fileType:4 messageId:model.messageId srcKey:@"" dsKey:@"" publicKey:@"" msgKey:@"" fileInfo:[NSString stringWithFormat:@"%f*%f",model.fileWidth,model.fileHeight]];
            });
        });
    } else {
        //  [AppD.window hideHud];
        [self.view showHint:@"The current video format is not supported"];
    }
}

#pragma mark - UIDocumentPickerDelegate
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
        model.ToId = self.groupModel.GId;
        model.fileSize = txtData.length;
        model.msgState = CDMessageStateSending;
        model.messageId = [NSString stringWithFormat:@"%d",msgid];;
        model.fileID = msgid;
        model.messageStatu = -1;
        CTDataConfig config = [CTData defaultConfig];
        config.isOwner = YES;
        model.isGroup = YES;
        model.isAdmin = self.groupModel.UserType+GROUP_IDF;
        
        model.fileName = [NSString getUploadFileNameOfCorrectLength:fileUrl.lastPathComponent];
        NSString *uploadFileName = model.fileName;
        
        model.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
        model.publicKey = self.groupModel.UserKey;
        model.ctDataconfig = config;
        NSString *nkName = [UserModel getUserModel].username;
        NSString *userKey = [EntryModel getShareObject].signPublicKey;
        model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName userKey:userKey]];
        model.dskey = self.groupModel.UserKey;
        model.srckey = self.groupModel.UserKey;
        NSString *filePath = [[SystemUtil getBaseFilePath:self.groupModel.GId] stringByAppendingPathComponent:model.fileName];
        [txtData writeToFile:filePath atomically:YES];
        [self.listView addMessagesToBottom:@[model]];
        
        // 自己私钥解密
        NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:self.groupModel.UserKey];
        NSString *symmetKey = [[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding];
        NSData *msgKeyData =[[symmetKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
        txtData = aesEncryptData(txtData,msgKeyData);
        
        
        [self sendFileWithToid:self.groupModel.GId fileName:uploadFileName fileData:txtData fileId:msgid fileType:5 messageId:model.messageId srcKey:@"" dsKey:@"" publicKey:@"" msgKey:@"" fileInfo:@""];
    }
}


#pragma mark ---消息回调
- (void) sendMessageSuccessNoti:(NSNotification *) noti
{
    NSArray *resultArr = noti.object;
    if (resultArr && resultArr.count == 4) {
        if ([resultArr[1] isEqualToString: self.groupModel.GId]) {
            
            NSString *sendMsgid = resultArr[3];
            NSString *msgid = resultArr[2];
       
            @weakify_self
            [self.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                CDMessageModel *model = (id)obj;
                if ([model.messageId integerValue] == [sendMsgid integerValue]) {
                    if ([resultArr[0] integerValue] == 0) { // 发送成功
                        model.messageId = msgid;
                        model.msgState = CDMessageStateNormal;
                        model.messageStatu = 1;
                        [weakSelf.listView updateMessage:model];
                    }
                
                    *stop = YES;
                }
            }];
        }
    }
}
- (void) pullMessageListSuccessNoti:(NSNotification *) noti
{
    [self.listView stopRefresh];
    
    NSArray *resultArr = noti.object;
    NSArray *messageArr = resultArr[0];
    self.groupModel.UserType = [resultArr[1] intValue];
    if (!messageArr || messageArr.count == 0) {
        return;
    }
    if (self.listView.msgArr && self.listView.msgArr.count > 0) {
        if (_msgStartId == 0) {
            return;
        }
    }
   // NSMutableArray *msgArr = [NSMutableArray array];
    NSMutableArray *messageModelArr = [NSMutableArray array];
    [messageArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PayloadModel *payloadModel = obj;
        CDMessageModel *model = [[CDMessageModel alloc] init];
        NSString *userId = [UserConfig getShareObject].userId;
        if (payloadModel.From && payloadModel.From.length>0) {
            model.FromId = payloadModel.From;
            model.userName = [payloadModel.UserName base64DecodedString]?:@"";
            model.isLeft = YES;
        } else {
            model.FromId = userId?:@"";
            model.isLeft = NO;
        }
        model.ToId = self.groupModel.GId;
        model.isGroup = YES;
        model.isAdmin = self.groupModel.UserType+GROUP_IDF;
        if (payloadModel.FileInfo && payloadModel.FileInfo.length>0) {
            NSArray *whs = [payloadModel.FileInfo componentsSeparatedByString:@"*"];
            model.fileWidth = [whs[0] floatValue];
            model.fileHeight = [whs[1] floatValue];
        }
        
        model.messageStatu = payloadModel.Status;
        model.messageId = [NSString stringWithFormat:@"%@",payloadModel.MsgId];
        model.publicKey = payloadModel.UserKey;
        model.TimeStatmp = payloadModel.TimeStamp;
        model.msgType = payloadModel.MsgType;
        if (model.msgType >=1 && model.msgType !=5 && model.msgType !=4) { // 图片
            model.msgState = CDMessageStateDownloading;
        }
        if (payloadModel.FileName && payloadModel.FileName.length>0) {
            model.fileName = [Base58Util Base58DecodeWithCodeName:payloadModel.FileName];
        }
        model.fileMd5 = payloadModel.FileMD5;
        model.filePath = payloadModel.FilePath;
        model.fileSize = payloadModel.FileSize;
        model.dskey = self.groupModel.UserKey;
        model.srckey = self.groupModel.UserKey;
        model.fileKey = payloadModel.FileKey;
        
//        if (!model.isLeft) {
//           [msgArr addObject:model.messageId];
//        }
        
        // 自己私钥解密
        NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:self.groupModel.UserKey];
        if (!datakey || datakey.length == 0) {
            return ;
        }
        // 截取前16位
        datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
        
        if (model.msgType == 0) { // 文字
           model.msg = aesDecryptString(payloadModel.Msg, datakey);
        }
        NSString *signPK = payloadModel.UserKey;
        NSString *nickName = model.userName?:@"";
        
        CTDataConfig config = [CTData defaultConfig];
        if (!model.isLeft) {
            config.isOwner = YES;
            signPK = [EntryModel getShareObject].signPublicKey;
            nickName = [UserConfig getShareObject].userName;
        }
        model.ctDataconfig = config;
      
        model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nickName userKey:signPK]];
        [messageModelArr addObject:model];
    }];
    
    if (_msgStartId == 0) { // 第一次自动加载
        
       // NSArray *chats = [ChatModel bg_find:CHAT_CACHE_TABNAME where:[NSString stringWithFormat:@"where %@=%@ and %@=%@",bg_sqlKey(@"fromId"),bg_sqlValue([UserModel getUserModel].userId),bg_sqlKey(@"toId"),bg_sqlValue(self.groupModel.GId)]];
         NSArray *chats = [ChatModel bg_find:CHAT_CACHE_TABNAME where:[NSString stringWithFormat:@"where %@=%@",bg_sqlKey(@"toId"),bg_sqlValue(self.groupModel.GId)]];
        if (chats && chats.count > 0) {
            @weakify_self
            [chats enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                ChatModel *chatModel = obj;
                
                CDMessageModel *model = [[CDMessageModel alloc] init];
                model.FromId = chatModel.fromId;
                model.isGroup = YES;
                model.isAdmin = self.groupModel.UserType+GROUP_IDF;
                model.ToId = chatModel.toId;
                model.msgType = chatModel.msgType;
                model.publicKey = weakSelf.groupModel.UserKey;
                model.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
                model.messageId = [NSString stringWithFormat:@"%ld",(long)chatModel.msgid];
                model.dskey = self.groupModel.UserKey;
                model.srckey = self.groupModel.UserKey;
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
                    model.fileName = chatModel.fileName;
                    if (chatModel.fileInfo && chatModel.fileInfo.length > 0) {
                       NSArray *whs = [chatModel.fileInfo componentsSeparatedByString:@"*"];
                        if (whs.count >=2) {
                            model.fileWidth = [whs[0] floatValue];
                            model.fileHeight = [whs[1] floatValue];
                        }
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
//    if (msgArr.count > 0) {
//        NSString *allMsgid = [msgArr componentsJoinedByString:@","];
//        [self sendRedMsgWithMsgId:allMsgid];
//    }
    
    
    if (messageArr && messageArr.count > 0) { // 更新最开始的消息id
        _msgStartId = [((PayloadModel *)messageArr.firstObject).MsgId integerValue];
    }
    
#pragma mark - 查找暂无头像的用户 更新头像
    NSMutableArray *userIdArr = [NSMutableArray array];
    [messageArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PayloadModel *model = obj;
        if (model.From && model.From.length) {
            NSString *userHeaderImg64Str = [UserHeaderModel getUserHeaderImg64StrWithKey:model.UserKey];
            if (!userHeaderImg64Str) { // 如果没有头像
                [userIdArr addObject:model.From];
            }
        }
    }];
    [UpdateGroupMemberAvatarUtil updateAvatar:userIdArr];
}


- (void) receivedMessgePushNoti:(NSNotification *) noti
{
    PayloadModel *payloadModel = noti.object;
    CDMessageModel *model = [[CDMessageModel alloc] init];
    
    model.FromId = payloadModel.From;
    model.userName = [payloadModel.UserName base64DecodedString]?:@"";
    model.isLeft = YES;
    model.ToId = self.groupModel.GId;
    model.isGroup = YES;
    model.isAdmin = self.groupModel.UserType+GROUP_IDF;
    if (payloadModel.FileInfo && payloadModel.FileInfo.length>0) {
        NSArray *whs = [payloadModel.FileInfo componentsSeparatedByString:@"*"];
        model.fileWidth = [whs[0] floatValue];
        model.fileHeight = [whs[1] floatValue];
    }
    
    model.messageStatu = payloadModel.Status;
    model.messageId = [NSString stringWithFormat:@"%@",payloadModel.MsgId];
    model.TimeStatmp = payloadModel.TimeStamp;
    model.msgType = payloadModel.MsgType;
    if (model.msgType >=1 && model.msgType !=5 && model.msgType !=4) { // 图片
        model.msgState = CDMessageStateDownloading;
    }
    if (payloadModel.FileName && payloadModel.FileName.length >0) {
        model.fileName = [Base58Util Base58DecodeWithCodeName:payloadModel.FileName];
    }
    model.fileMd5 = payloadModel.FileMD5;
    model.filePath = payloadModel.FilePath;
    model.fileSize = payloadModel.FileSize;
    model.fileKey = payloadModel.FileKey;
    model.dskey = self.groupModel.UserKey;
    model.srckey = self.groupModel.UserKey;
    
    // 自己私钥解密
    NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:self.groupModel.UserKey];
    // 截取前16位
    datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
    if (!datakey || datakey.length == 0) {
        return ;
    }
    if (model.msgType == 0) { // 文字
        model.msg = aesDecryptString(payloadModel.Msg, datakey);
    }
    NSString *signPK = payloadModel.UserKey;
    NSString *nickName = model.userName?:@"";
    CTDataConfig config = [CTData defaultConfig];
    if (!model.isLeft) {
        config.isOwner = YES;
        signPK = [EntryModel getShareObject].signPublicKey;
        nickName = [UserConfig getShareObject].userName;
    }
    model.ctDataconfig = config;
    model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nickName userKey:signPK]];
    [self.listView addMessagesToBottom:@[model]];
}
- (void) receivedSysMessgePushNoti:(NSNotification *) noti {
    
    NSDictionary *receiveDic = noti.object;
    
    NSString *UserId = receiveDic[@"UserId"];
    NSString *GId = receiveDic[@"GId"];
    int Type = [receiveDic[@"Type"] intValue];
    NSString *From = receiveDic[@"From"];
    NSString *To = receiveDic[@"To"];
    NSInteger MsgId =receiveDic[@"MsgId"]? [receiveDic[@"MsgId"] integerValue]:-1;
    NSString *Name = receiveDic[@"Name"];
    NSString *FromUserName = receiveDic[@"FromUserName"];
    NSString *ToUserName = receiveDic[@"ToUserName"];
   
    if (Type == 0x01) { //群名称修改
        // 更新群的名字
       NSString *groupName = [[NSString getNotNullValue:Name] base64DecodedString];
        NSString *showTitle = _groupModel.Remark&&_groupModel.Remark.length>0?_groupModel.Remark:Name;
        _lblNavTitle.text = [showTitle base64DecodedString];
        
        CDMessageModel *messageModel = [[CDMessageModel alloc] init];
        messageModel.msgType = 3;
        messageModel.msg = [NSString stringWithFormat:@"Change the group name to \"%@\"",groupName];
        [self.listView addMessagesToBottom:@[messageModel]];
    } else if (Type == 0x03) { //撤回某条消息
        // 删除撤回的消息
        [self deleteMsg:[NSString stringWithFormat:@"%ld",(long)MsgId]];
        
        CDMessageModel *messageModel = [[CDMessageModel alloc] init];
        messageModel.msgType = 3;
        messageModel.msg = [NSString stringWithFormat:@"\"%@\" deleted a message",[FromUserName base64DecodedString]];
        [self.listView addMessagesToBottom:@[messageModel]];
    } else if (Type == 0xF1) { //新用户入群
        CDMessageModel *messageModel = [[CDMessageModel alloc] init];
        messageModel.msgType = 3;
        messageModel.msg = [NSString stringWithFormat:@"\"%@\" invites \"%@\" to join the group chat",[FromUserName base64DecodedString],[ToUserName base64DecodedString]];
        [self.listView addMessagesToBottom:@[messageModel]];
    } else if (Type == 0xF2) { //用户退群
        CDMessageModel *messageModel = [[CDMessageModel alloc] init];
        messageModel.msgType = 3;
        messageModel.msg = [NSString stringWithFormat:@"\"%@\" quit group chat",[FromUserName base64DecodedString]];
        [self.listView addMessagesToBottom:@[messageModel]];
    }  else if (Type == 0xF3) { //有用户被踢出群
        // 自己被踢出群聊
        if ([To isEqualToString:[UserConfig getShareObject].userId] && isGroupChatViewController) {
            [self leftNavBarItemPressedWithPop:YES];
        } else {
            CDMessageModel *messageModel = [[CDMessageModel alloc] init];
            messageModel.msgType = 3;
            messageModel.msg = [NSString stringWithFormat:@"\"%@\" removed \"%@\" from the group",[FromUserName base64DecodedString],[ToUserName base64DecodedString]];
            [self.listView addMessagesToBottom:@[messageModel]];
        }
    } else if (Type == 0xF4 && isGroupChatViewController) { //群主解散子群聊
        [self leftNavBarItemPressedWithPop:YES];
    }
    /*
     群系统推送类型：
     0x01：群名称修改
     0x02：群审核权限变更
     0x03: 撤回某条消息
     0x04:群主删除某条消息
     0xF1:新用户入群
     0xF2:有用户退群
     0xF3:有用户被踢出群
     
     */
}
- (void) receivedDelMessgePushNoti:(NSNotification *) noti
{
    NSString *msgid = [NSString stringWithFormat:@"%@",noti.object];
    [self deleteMsg:msgid];
    if (self.selectMessageModel) {
        if (self.selectMessageModel.fileName && ![self.selectMessageModel.fileName isBlankString]) {
            // 删除本的文件
            [SystemUtil removeDocmentFileName:self.selectMessageModel.fileName friendid:self.groupModel.GId];
        }
    }
}

- (void) groupFileSendFaield:(NSNotification *) noti
{
    NSArray *arr = (NSArray *)noti.object;
    if (arr && arr.count > 0) {
        
        if (![arr[1] isEqualToString:self.groupModel.GId]) {
            return;
        }
        __block NSInteger fileIndex = -1;
        @weakify_self
        [self.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CDMessageModel *model = (id)obj;
            if ([[NSString stringWithFormat:@"%@",model.messageId] isEqualToString:[NSString stringWithFormat:@"%@",arr[2]]]) {
                fileIndex = idx;
                *stop = YES;
            }
        }];
        if (fileIndex < 0) {
            return;
        }
        CDMessageModel *model = (CDMessageModel *)[weakSelf.listView.msgArr objectAtIndex:fileIndex];
        // 文件发送失败
        NSLog(@"文件发送失败");
        model.msgState = CDMessageStateSendFaild;
        model.messageStatu = -1;
        [weakSelf.listView updateMessage:model];
        
        if ([arr[0] integerValue] == 5) {
            CDMessageModel *messageModel = [[CDMessageModel alloc] init];
            messageModel.msgType = 3;
            messageModel.msg = @"You have been kicked out of this group by group manager.";
            [weakSelf.listView addMessagesToBottom:@[messageModel]];
        }
    }
}

- (void) groupFileSendSuccess:(NSNotification *) noti
{
    NSDictionary *resultDic = noti.object;
    if (resultDic && resultDic.count > 0) {
        NSString *gid = resultDic[@"GId"];
        NSString *messageID = resultDic[@"FileId"];
        NSString *msgID = [NSString stringWithFormat:@"%@",resultDic[@"MsgId"]];
        if (![gid isEqualToString:self.groupModel.GId]) {
            return;
        }
        __block NSInteger fileIndex = -1;
        @weakify_self
        [self.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CDMessageModel *model = (id)obj;
            if ([[NSString stringWithFormat:@"%@",model.messageId] isEqualToString:messageID]) {
                fileIndex = idx;
                *stop = YES;
            }
        }];
        if (fileIndex < 0) {
            return;
        }
        CDMessageModel *model = (CDMessageModel *)[weakSelf.listView.msgArr objectAtIndex:fileIndex];
        NSLog(@"文件发送成功");
            // 添加到最后一条消息
        model.msgState = CDMessageStateNormal;
        if (model.messageStatu == 1) {
            return;
        }
        model.messageStatu = 1;
        model.messageId = msgID;
        [weakSelf.listView updateMessage:model];
    }
}

#pragma mark ---tox下载文件成功
- (void) toxDownFileSuccess:(NSNotification *) noti
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
                    NSString *docPath = [[SystemUtil getBaseFilePath:weakSelf.groupModel.GId] stringByAppendingPathComponent:fileName];
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
                                [SystemUtil saveImageForTtimeWithToid:weakSelf.groupModel.GId fileName:fileName fileTime:obj.TimeStatmp];
                            }
                           
                            
                            obj.msgState = CDMessageStateNormal;
                            obj.isDown = NO;
                            [weakSelf.listView updateMessage:obj];
                            *stop = YES;
                            NSLog(@"下载文件成功! filePath = %@",docPath);
                        });
                    }
//                    if (array.count > 2) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            obj.msgState = CDMessageStateDownloadFaild;
//                            obj.isDown = NO;
//                            [weakSelf.listView updateMessage:obj];
//                            *stop = YES;
//                            NSLog(@"下载文件失败! ");
//                        });
//
//                    } else {
//
//                    }
                });
            }
        }];
    }
}
#pragma mark -- 未发成功文件发送中通知
- (void) fileSendingNoti:(NSNotification *) noti
{
    NSArray *resultArr = noti.object;
    @weakify_self
    [weakSelf.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([resultArr[0] isEqualToString:weakSelf.groupModel.GId]) {
            if ([resultArr[1] integerValue] == [obj.messageId integerValue]) {
                obj.msgState = CDMessageStateSending;
                [weakSelf.listView updateMessage:obj];
            }
        }
    }];
}
- (void)userHeadDownloadSuccess:(NSNotification *)noti {
    [_listView reloadData];
}

#pragma mark - 保存图片视频
// 保存图片到相册
- (void)saveImage:(UIImage *)image{
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(savedPhotoImage:didFinishSavingWithError:contextInfo:), nil);
    }
}

// 保存视频到相册
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
    if (error) {
        NSLog(@"保存图片出错%@", error.localizedDescription);
    }
    else {
        NSLog(@"保存图片成功");
        [AppD.window showHint:@"Save success."];
    }
}

//保存视频完成之后的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        NSLog(@"保存视频失败%@", error.localizedDescription);
    }
    else {
        NSLog(@"保存视频成功");
        [AppD.window showHint:@"Save success."];
    }
}

#pragma mark ---@用户通知
- (void) remindUserNoti:(NSNotification *)noti {
   
    id objectValue = noti.object;
    if ([objectValue isKindOfClass:[GroupMembersModel class]]) {
        GroupMembersModel *memberModel = objectValue;
        if (memberModel) {
            NSString *insertString = [NSString stringWithFormat:kATFormat,[memberModel.showName base64DecodedString]];
            
            NSMutableString *string = [NSMutableString stringWithString:[self.msginputView getTextViewString]];
            [string insertString:insertString atIndex:insertIndex];
            if (string.length > 245) {
                [self.view showHint:@"The length of the sent content is out of range."];
                return;
            }
            [self.msginputView setTextViewString:string delayTime:0];
            [self.msginputView setSelectedRange:NSMakeRange(insertIndex + insertString.length, 0)];
            
            AtUserModel *atModel = [[AtUserModel alloc] init];
            atModel.userId = memberModel.ToxId;
            atModel.userName = [memberModel.showName base64DecodedString];
            atModel.atName = insertString;
            [self.msginputView.atStrings addObject:atModel];
            
            // NSString *inputStirng = [self.msginputView getTextViewString];
            // inputStirng = [inputStirng substringToIndex:inputStirng.length-1];
            // inputStirng = [inputStirng stringByAppendingString:[NSString stringWithFormat:@"%@ ",[memberModel.showName base64DecodedString]]];
            // [self.msginputView setTextViewString:inputStirng];
        }
    } else if ([objectValue isKindOfClass:[NSString class]]) {
        
        NSString *insertString = [NSString stringWithFormat:kATFormat,@"All"];
        NSMutableString *string = [NSMutableString stringWithString:[self.msginputView getTextViewString]];
        [string insertString:insertString atIndex:insertIndex];
        if (string.length > 245) {
            [self.view showHint:@"The length of the sent content is out of range."];
            return;
        }
        [self.msginputView setTextViewString:string delayTime:0];
        [self.msginputView setSelectedRange:NSMakeRange(insertIndex + insertString.length, 0)];
        
        AtUserModel *atModel = [[AtUserModel alloc] init];
        atModel.userId = @"all";
        atModel.userName = @"all";
        atModel.atName = insertString;
        [self.msginputView.atStrings addObject:atModel];
        
    } else {
        [self.msginputView becomeFirstResponder];
    }
}

#pragma mark ----转发
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
                
                if ([model.userId isEqualToString:weakSelf.groupModel.GId]) {
                    
                    CDMessageModel *messageModel = [[CDMessageModel alloc] init];
                    messageModel.FromId = [UserConfig getShareObject].userId;
                    messageModel.ToId = weakSelf.groupModel.GId;
                    messageModel.publicKey = weakSelf.groupModel.UserKey;
                    messageModel.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
                    messageModel.messageId = [NSString stringWithFormat:@"%ld",(long)tempMsgid];
                    messageModel.msg = weakSelf.selectMessageModel.msg;
                    messageModel.isGroup = YES;
                    messageModel.isAdmin = self.groupModel.UserType+GROUP_IDF;
                    messageModel.msgState = CDMessageStateNormal;
                    messageModel.messageStatu = -1;
                    [self addMessagesToList:messageModel];
                }
                
                if ([SystemUtil isSocketConnect]) {
                    ChatModel *chatModel = [[ChatModel alloc] init];
                    chatModel.fromId = [UserModel getUserModel].userId;
                    chatModel.toId = model.userId;
                    chatModel.toPublicKey = model.publicKey;
                    chatModel.msgType = 0;
                    chatModel.msgid = tempMsgid;
                    chatModel.messageMsg = weakSelf.selectMessageModel.msg;
                    chatModel.sendTime = [NSDate getTimestampFromDate:[NSDate date]];
                    chatModel.bg_tableName = CHAT_CACHE_TABNAME;
                    [chatModel bg_save];
                }
                
                // aes加密
                NSString *enMsg = aesEncryptString(weakSelf.selectMessageModel.msg, datakey);
                // 发送消息
                [SendRequestUtil sendGroupMessageWithGid:model.userId point:@"" msg:enMsg msgid:[NSString stringWithFormat:@"%ld",(long)tempMsgid]];
                
                
            } else {
                
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    NSString *filePath = [[SystemUtil getBaseFilePath:weakSelf.groupModel.GId] stringByAppendingPathComponent:weakSelf.selectMessageModel.fileName];
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
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                       if ([model.userId isEqualToString:weakSelf.groupModel.GId]) {
                           CDMessageModel *messageModel = [[CDMessageModel alloc] init];
                           messageModel.msgType = weakSelf.selectMessageModel.msgType;
                           messageModel.msg = @"";
                           messageModel.fileID = msgid;
                           messageModel.fileWidth = weakSelf.selectMessageModel.fileWidth;
                           messageModel.fileHeight = weakSelf.selectMessageModel.fileHeight;
                           messageModel.FromId = [UserConfig getShareObject].userId;
                           messageModel.ToId = weakSelf.groupModel.GId;
                           messageModel.msgState = CDMessageStateSending;
                           messageModel.messageId = [NSString stringWithFormat:@"%d",msgid];
                           CTDataConfig config = [CTData defaultConfig];
                           config.isOwner = YES;
                           messageModel.isGroup = YES;
                           messageModel.isAdmin = weakSelf.groupModel.UserType+GROUP_IDF;
//                           messageModel.willDisplayTime = YES;
                           messageModel.messageStatu = -1;
                           messageModel.fileName = [mill stringByAppendingString:@".jpg"];
                           messageModel.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
                           messageModel.publicKey = weakSelf.groupModel.UserKey;
                           messageModel.ctDataconfig = config;
                           NSString *nkName = [UserModel getUserModel].username;
                           NSString *userKey = [EntryModel getShareObject].signPublicKey;
                           messageModel.userThumImage =  [SystemUtil genterViewToImage:[weakSelf getHeadViewWithName:nkName userKey:userKey]];
                           messageModel.dskey = weakSelf.groupModel.UserKey;
                           messageModel.srckey = weakSelf.groupModel.UserKey;
                           [weakSelf.listView addMessagesToBottom:@[messageModel]];
                       }
                        [weakSelf sendFileWithToid:model.userId fileName:weakSelf.selectMessageModel.fileName fileData:fileDatas fileId:msgid fileType:weakSelf.selectMessageModel.msgType messageId:[NSString stringWithFormat:@"%d",msgid] srcKey:@"" dsKey:@"" publicKey:model.publicKey msgKey:@"" fileInfo:fileInfo];
                    });
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
                
                long tempMsgid = (long)[ChatListDataUtil getShareObject].tempMsgId++;
                tempMsgid = [NSDate getTimestampFromDate:[NSDate date]]+tempMsgid;
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
                    
                    NSString *filePath = [[SystemUtil getBaseFilePath:weakSelf.groupModel.GId] stringByAppendingPathComponent:weakSelf.selectMessageModel.fileName];
                    if (!fileDatas) {
                        fileDatas = [NSData dataWithContentsOfFile:filePath];
                    }
                    NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
                    NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
                    int msgid = [mill intValue];
                    
                   
                    filePath = [[SystemUtil getBaseFilePath:model.userId] stringByAppendingPathComponent:weakSelf.selectMessageModel.fileName];
                    [fileDatas writeToFile:filePath atomically:YES];
                    
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
                    [weakSelf sendChatFileWithToid:model.userId fileName:weakSelf.selectMessageModel.fileName fileData:enData fileId:msgid fileType:weakSelf.selectMessageModel.msgType messageId:[NSString stringWithFormat:@"%d",msgid] srcKey:srcKey dsKey:dsKey publicKey:model.publicKey msgKey:msgKey fileInfo:fileInfo];
                    
                });
            }
        }
        
    }];
}

#pragma mark -发送单聊文件
- (void) sendChatFileWithToid:(NSString *) toId fileName:(NSString *) fileName fileData:(NSData *) fileData fileId:(int) fileId fileType:(int) fileType messageId:(NSString *) messageId srcKey:(NSString *) srcKey dsKey:(NSString *) dsKey publicKey:(NSString *) publicKey msgKey:(NSString *) msgKey fileInfo:(NSString *) fileInfo
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
        }
    }
}











- (void)yb_imageBrowser:(YBImageBrowser *)imageBrowser pageIndexChanged:(NSUInteger)index data:(id<YBImageBrowserCellDataProtocol>)data
{
    NSLog(@"------------------------------------");
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

- (void)loadImageFinished:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (!error) {
        [self.view showHint:@"Save Success"];
    } else {
        [self.view showHint:@"Save Failed"];
    }
}


#pragma mark - Transition
- (void)addFriendRequest:(NSString *)friendId nickName:(NSString *) nickName signpk:(NSString *) signpk
{
    
    FriendRequestViewController *vc = [[FriendRequestViewController alloc] initWithNickname:nickName userId:friendId signpk:signpk];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void) jumpCodeValueVCWithCodeValue:(NSString *) codeValue
{
    
    CodeMsgViewController *vc = [[CodeMsgViewController alloc] initWithCodeValue:codeValue];
    [browser presentViewController:vc animated:YES completion:nil];
    
}

- (void) showAlertImportAccount:(NSArray *) values
{
    
    NSString *signpk = values[1];
    //NSString *usersn = values[2];
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
            [LibsodiumUtil changeUserPrivater:values[1]];
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
