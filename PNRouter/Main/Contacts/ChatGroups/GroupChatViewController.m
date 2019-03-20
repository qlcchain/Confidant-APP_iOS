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
#import "MsgPicViewController.h"
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

#define StatusH [[UIApplication sharedApplication] statusBarFrame].size.height
#define NaviH (44 + StatusH)
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

typedef void(^PullMoreBlock)(NSArray *arr);

@interface GroupChatViewController ()<ChatListProtocol,
CTInputViewProtocol,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,TZImagePickerControllerDelegate,UIDocumentPickerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *lblNavTitle;
@property (weak, nonatomic) IBOutlet UIView *tabBackView;
@property(nonatomic, weak)CDChatListView *listView;
@property(nonatomic, weak)CTInputView *msginputView;
@property (nonatomic ,assign) NSInteger msgStartId;

@property (nonatomic ,strong) CDMessageModel *selectMessageModel;
@property (nonatomic, copy) PullMoreBlock pullMoreB;
@property (nonatomic, strong) NSString *deleteMsgId;

@property (nonatomic ,strong) GroupInfoModel *groupModel;
@end

@implementation GroupChatViewController

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
    
    [self leftNavBarItemPressedWithPop:YES];
    [SocketCountUtil getShareObject].groupChatId = @"";
}

- (IBAction)rightAction:(id)sender {
    GroupDetailsViewController *vc = [[GroupDetailsViewController alloc] initWithGroupInfo:_groupModel];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNoti];
    
    // 拉取群好友
    [self pullGroupFriend];
    
    self.view.backgroundColor = RGB(246, 246, 246);
    _lblNavTitle.text = [self.groupModel.GName base64DecodedString];
    
    [self loadChatUI];
    _msgStartId = 0;
    [self.listView startRefresh];
    [SocketCountUtil getShareObject].groupChatId = self.groupModel.GId;
}

#pragma mark ----添加通知
- (void) addNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendMessageSuccessNoti:) name:GROUP_MESSAGE_SEND_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pullMessageListSuccessNoti:) name:PULL_GROUP_MESSAGE_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMessgePushNoti:) name:RECEVIED_GROUP_MESSAGE_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedSysMessgePushNoti:) name:RECEVIED_GROUP_SYSMSG_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedDelMessgePushNoti:) name:RECEVIED_Del_GROUP_MESSAGE_SUCCESS_NOTI object:nil];
    
    
    
}

#pragma mark ---pull message
- (void)pullMessageRequest {
    UserModel *userM = [UserModel getUserModel];
    NSString *MsgType = @"1"; // 0：所有记录  1：纯聊天消息   2：文件传输记录
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

- (void)clickFileCellWithMsgMode:(CDChatMessage)msgModel withFilePath:(NSString *)filePath
{
    [YWFilePreviewView previewFileWithPaths:filePath fileName:msgModel.fileName fileType:msgModel.msgType];
}
- (void)clickChatMenuItem:(NSString *)itemTitle withMsgMode:(CDChatMessage) msgModel
{
    self.selectMessageModel = (CDMessageModel *)msgModel;
    NSString *msgId = [NSString stringWithFormat:@"%@",self.selectMessageModel.messageId];
    NSLog(@"%@",itemTitle);
    if ([itemTitle isEqualToString:@"Save"]) {
        
    } else if ([itemTitle isEqualToString:@"Forward"]){ // 转发
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
            [SendRequestUtil sendDelGroupMessageWithType:@(0) GId:self.groupModel.GId MsgId:msgId FromID:userM.userId];
        }
        
    }
}
//cell 的点击事件
- (void)chatlistClickMsgEvent:(ChatListInfo *)listInfo {
    switch (listInfo.eventType) {
        case ChatClickEventTypeIMAGE:
        {
            CGRect newe =  [listInfo.containerView.superview convertRect:listInfo.containerView.frame toView:self.view];
            [MsgPicViewController addToRootViewController:listInfo.image ofMsgId:listInfo.msgModel.messageId in:newe from:self.listView.msgArr];
        }
            break;
        case ChatClickEventTypeTEXT:
            [self.view makeToast:listInfo.clickedText duration:0.5 position:CSToastPositionCenter];
            break;
    }
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
        
        NSString *uploadFileName = mode.fileName;
        mode.fileID = msgid;
        mode.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
      //  mode.publicKey = self.friendModel.publicKey;
        mode.messageId = [NSString stringWithFormat:@"%d",msgid];;
        mode.willDisplayTime = YES;
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
       // NSString *dsKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:self.friendModel.publicKey];
        // 自己公钥加密对称密钥
        NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
        
        NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
        data = aesEncryptData(data,msgKeyData);
        
        
     //   [self sendFileWithToid:self.friendModel.userId fileName:uploadFileName fileData:data fileId:msgid fileType:2 messageId:mode.messageId srcKey:srcKey dsKey:dsKey publicKey:self.friendModel.publicKey msgKey:msgKey];
        
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
#pragma mark -发送更多回调
- (void)inputViewPopCommand:(NSString *)string {
    if ([string isEqualToString:@"Album"]) {
        
        //        UIImagePickerController *imagePick = [[UIImagePickerController alloc] init];
        //        imagePick.navigationBar.translucent = NO;
        //        imagePick.delegate = self;
        //        [self presentViewController:imagePick animated:YES completion:^{}];
        [self selectImage];
        
    } else if ([string isEqualToString:@"Private\ndocument"]) {
        
        NSArray *documentTypes = @[@"public.content"];
        
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
        
    } else if ([string isEqualToString:@"Short video"]) { // 视频
        
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

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *img = info[UIImagePickerControllerOriginalImage];
    NSData *imgData = UIImageJPEGRepresentation(img,1.0);
    
    NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
    int msgid = [mill intValue];
    CDMessageModel *model = [[CDMessageModel alloc] init];
    model.msgType = CDMessageTypeImage;
    model.msg = info[UIImagePickerControllerMediaURL];
    model.fileID = msgid;
    model.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
    model.FromId = [UserConfig getShareObject].userId;
   // model.ToId = self.friendModel.userId;
    model.msgState = CDMessageStateSending;
    model.messageId = [NSString stringWithFormat:@"%d",msgid];
    CTDataConfig config = [CTData defaultConfig];
    config.isOwner = YES;
    model.willDisplayTime = YES;
    model.messageStatu = -1;
    NSString *uploadFileName = mill;
    model.fileName = mill;
    
    model.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
   // model.publicKey = self.friendModel.publicKey;
    model.ctDataconfig = config;
    NSString *nkName = [UserModel getUserModel].username;
    NSString *userKey = [EntryModel getShareObject].signPublicKey;
    model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName userKey:userKey]];
    NSString *filePath = [[SystemUtil getBaseFilePath:self.groupModel.GId] stringByAppendingPathComponent:mill];
    [imgData writeToFile:filePath atomically:YES];
    [self.listView addMessagesToBottom:@[model]];
    
    // 生成32位对称密钥
    NSString *msgKey = [SystemUtil get32AESKey];
    NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
    NSString *symmetKey = [symmetData base64EncodedString];
    // 好友公钥加密对称密钥
   // NSString *dsKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:self.friendModel.publicKey];
    // 自己公钥加密对称密钥
    NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
    
    NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
    imgData = aesEncryptData(imgData,msgKeyData);
    
   // [self sendFileWithToid:self.friendModel.userId fileName:uploadFileName fileData:imgData fileId:msgid fileType:1 messageId:model.messageId srcKey:srcKey dsKey:dsKey publicKey:self.friendModel.publicKey msgKey:msgKey];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -发送文件
- (void) sendFileWithToid:(NSString *) toId fileName:(NSString *) fileName fileData:(NSData *) fileData fileId:(int) fileId fileType:(int) fileType messageId:(NSString *) messageId srcKey:(NSString *) srcKey dsKey:(NSString *) dsKey publicKey:(NSString *) publicKey msgKey:(NSString *) msgKey
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
        [chatModel bg_save];
        
        SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
        [dataUtil sendFileId:toId fileName:fileName fileData:fileData fileid:fileId fileType:fileType messageid:messageId srcKey:srcKey dstKey:dsKey];
        [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
    } else {
        NSString *filePath = [[SystemUtil getTempBaseFilePath:toId] stringByAppendingPathComponent:[Base58Util Base58EncodeWithCodeName:fileName]];
        
        if ([fileData writeToFile:filePath atomically:YES]) {
            NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":[UserConfig getShareObject].userId,@"ToId":toId,@"FileName":[Base58Util Base58EncodeWithCodeName:fileName],@"FileMD5":[MD5Util md5WithPath:filePath],@"FileSize":@(fileData.length),@"FileType":@(fileType),@"SrcKey":srcKey,@"DstKey":dsKey,@"FileId":messageId};
            [SendToxRequestUtil sendFileWithFilePath:filePath parames:parames];
          //  [SendRequestUtil sendQueryFriendWithFriendId:self.friendModel.userId];
        }
    }
}

// 输入框输出文字
- (void)inputViewPopSttring:(NSString *)string {
    
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
        model.msgState = CDMessageStateNormal;
      
        model.messageStatu = -1;
        [self addMessagesToList:model];
        // 自己私钥解密
        NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:self.groupModel.UserKey];
        // 截取前16位
        datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
        // aes加密
        NSString *enMsg = aesEncryptString(string, datakey);
        // 发送消息
        [SendRequestUtil sendGroupMessageWithGid:self.groupModel.GId point:@"" msg:enMsg msgid:model.messageId];
        
//        if ([SystemUtil isSocketConnect]) {
//            ChatModel *chatModel = [[ChatModel alloc] init];
//            chatModel.fromId = model.FromId;
//            chatModel.toId = model.ToId;
//            chatModel.toPublicKey = model.publicKey;
//            chatModel.msgType = 0;
//            chatModel.msgid = tempMsgid;
//            chatModel.messageMsg = string;
//            chatModel.sendTime = [NSDate getTimestampFromDate:[NSDate date]];
//            chatModel.bg_tableName = CHAT_CACHE_TABNAME;
//            [chatModel bg_save];
//        }
        
       
       
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
    model.willDisplayTime = YES;
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
    imagePickerVc.allowTakePicture = isImage; // 在内部显示拍照按钮
    imagePickerVc.allowTakeVideo = !isImage;   // 在内部显示拍视频按
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
    imagePickerVc.allowPickingMultipleVideo = NO; // 是否可以多选视频
    
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    
    // imagePickerVc.minImagesCount = 3;
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
        if (photos.count > 0) {
            UIImage *img = photos[0];
            NSData *imgData = UIImageJPEGRepresentation(img,1.0);
            
            if (imgData.length/(1024*1024) > 100) {
                [AppD.window showHint:@"Image cannot be larger than 100MB"];
                return;
            }
            /*
            NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
            NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
            int msgid = [mill intValue];
            CDMessageModel *model = [[CDMessageModel alloc] init];
            model.msgType = CDMessageTypeImage;
            model.msg = @"";
            model.fileID = msgid;
            model.FromId = [UserConfig getShareObject].userId;
            model.ToId = weakSelf.groupModel.GId;
            model.msgState = CDMessageStateSending;
            model.messageId = [NSString stringWithFormat:@"%d",msgid];
            CTDataConfig config = [CTData defaultConfig];
            config.isOwner = YES;
            model.willDisplayTime = YES;
            model.messageStatu = -1;
            NSString *uploadFileName = [mill stringByAppendingString:@".jpg"];
            model.fileName = [mill stringByAppendingString:@".jpg"];
            model.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
           // model.publicKey = weakSelf.friendModel.publicKey;
            model.ctDataconfig = config;
            NSString *nkName = [UserModel getUserModel].username;
            NSString *userKey = [EntryModel getShareObject].signPublicKey;
            model.userThumImage =  [SystemUtil genterViewToImage:[weakSelf getHeadViewWithName:nkName userKey:userKey]];
            NSString *filePath = [[SystemUtil getBaseFilePath:weakSelf.friendModel.userId] stringByAppendingPathComponent:model.fileName];
            [imgData writeToFile:filePath atomically:YES];
            [weakSelf.listView addMessagesToBottom:@[model]];
            
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
            
            [self sendFileWithToid:self.friendModel.userId fileName:uploadFileName fileData:imgData fileId:msgid fileType:1 messageId:model.messageId srcKey:srcKey dsKey:dsKey publicKey:self.friendModel.publicKey msgKey:msgKey];
             */
        }
    }];
    // 你可以通过block或者代理，来得到用户选择的视频.
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *phAsset) {
        
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
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
        //        [weakSelf extracted:asset evImage:coverImage];
    }];
             
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)extractedVideWithAsset:(AVURLAsset *)asset evImage:(UIImage *) evImage
{
    // [AppD.window showHudInView:AppD.window hint:@"File encrypting"];
    NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
    int msgid = [mill intValue];
    /*
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
    model.willDisplayTime = YES;
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
                [self sendFileWithToid:self.friendModel.userId fileName:model.fileName fileData:mediaData fileId:msgid fileType:4 messageId:model.messageId srcKey:srcKey dsKey:dsKey publicKey:self.friendModel.publicKey msgKey:msgKey];
            });
        });
    } else {
        //  [AppD.window hideHud];
        [self.view showHint:@"The current video format is not supported"];
    }
     */
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
    NSMutableArray *msgArr = [NSMutableArray array];
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
        
        if (payloadModel.FileInfo && payloadModel.FileInfo.length>0) {
            NSArray *whs = [payloadModel.FileInfo componentsSeparatedByString:@"*"];
            model.fileWidth = [whs[0] floatValue];
            model.fileHeight = [whs[1] floatValue];
        }
        
        model.messageStatu = payloadModel.Status;
        model.messageId = [NSString stringWithFormat:@"%@",payloadModel.MsgId];
        model.TimeStatmp = payloadModel.TimeStatmp;
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
        
        if (!model.isLeft) {
           [msgArr addObject:model.messageId];
        }
        
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
        NSString *signPK = [[ChatListDataUtil getShareObject] getFriendSignPublickeyWithFriendid:model.FromId];
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
        /*
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
                    //                model.nonceKey = nonceString;
                    //                model.signKey = signString;
                    //                model.symmetKey = enSymmetString;
                    model.messageStatu = -1;
                } else {
                    model.fileSize = chatModel.fileSize;
                    model.msgState = CDMessageStateSending;
                    model.fileID = (int)chatModel.msgid;
                    model.messageStatu = -1;
                    model.fileName = chatModel.fileName;
                }
                [messageModelArr addObject:model];
            }];
            
        }
         */
        self.listView.msgArr = messageModelArr;
        
    } else { // 下拉刷新
        if (_pullMoreB) {
            _pullMoreB(messageModelArr);
        }
    }
    // 发送已读
    if (msgArr.count > 0) {
       // NSString *allMsgid = [msgArr componentsJoinedByString:@","];
       // [self sendRedMsgWithMsgId:allMsgid];
    }
    
    
    if (messageArr && messageArr.count > 0) { // 更新最开始的消息id
        _msgStartId = [((PayloadModel *)messageArr.firstObject).MsgId integerValue];
    }
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
    
    if (payloadModel.FileInfo && payloadModel.FileInfo.length>0) {
        NSArray *whs = [payloadModel.FileInfo componentsSeparatedByString:@"*"];
        model.fileWidth = [whs[0] floatValue];
        model.fileHeight = [whs[1] floatValue];
    }
    
    model.messageStatu = payloadModel.Status;
    model.messageId = [NSString stringWithFormat:@"%@",payloadModel.MsgId];
    model.TimeStatmp = payloadModel.TimeStatmp;
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
    NSString *signPK = [[ChatListDataUtil getShareObject] getFriendSignPublickeyWithFriendid:model.FromId];
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


@end
