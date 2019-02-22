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

#define StatusH [[UIApplication sharedApplication] statusBarFrame].size.height
#define NaviH (44 + StatusH)
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

typedef void(^PullMoreBlock)(NSArray *arr);

@interface ChatViewController ()<ChatListProtocol,
CTInputViewProtocol,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,TZImagePickerControllerDelegate,UIDocumentPickerDelegate>



@property (weak, nonatomic) IBOutlet UILabel *lblNavTitle;
@property (weak, nonatomic) IBOutlet UIView *tabBackView;
@property(nonatomic, weak)CDChatListView *listView;
@property(nonatomic, weak)CTInputView *msginputView;

@property (nonatomic ,strong) FriendModel *friendModel;
@property (nonatomic) NSInteger msgStartId;
@property (nonatomic, copy) PullMoreBlock pullMoreB;
@property (nonatomic, strong) NSString *deleteMsgId;
@property (nonatomic ,strong) CDMessageModel *selectMessageModel;
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@end

@implementation ChatViewController
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

#pragma mark - Observe
- (void)observe {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMessage:) name:RECEIVE_MESSAGE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMessageBefore:) name:ADD_MESSAGE_BEFORE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMessageSuccess:) name:DELET_MESSAGE_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDeleteMessage:) name:RECEIVE_DELET_MESSAGE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageForward:) name:CHOOSE_FRIEND_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFileMessage:) name:RECEVIE_FILE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileSendSuccess:) name:FILE_SEND_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendTextMessageSuccess:) name:SEND_CHATMESSAGE_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRedMsg:) name:REVER_RED_MSG_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileSendFaield:) name:REVER_FILE_SEND_FAIELD_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(filePullSuccess:) name:REVER_FILE_PULL_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileToxPullSuccess:) name:REVER_FILE_PULL_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(queryFriendSuccess:) name:REVER_QUERY_FRIEND_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterFore) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
}

- (IBAction)rightAction:(id)sender {
//    FriendDetailViewController *vc = [[FriendDetailViewController alloc] init];
//    vc.friendModel = _friendModel;
//    [self.navigationController pushViewController:vc animated:YES];
    
    DebugLogViewController *vc = [[DebugLogViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)leftAction:(id)sender {
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
    _lblNavTitle.text = self.friendModel.username;
    [self observe];
    [self loadChatUI];
    _msgStartId = 0;
   // [self.listView startRefresh];
     [SocketCountUtil getShareObject].chatToId = self.friendModel.userId;
    [self pullMessageRequest];
    
    // 当前消息置为已读
    [[ChatListDataUtil getShareObject] cancelChatHDWithFriendid:self.friendModel.userId];
    


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

#pragma mark - Operation
- (void)pullMessageRequest {
    UserModel *userM = [UserModel getUserModel];
    NSString *MsgType = @"1"; // 0：所有记录  1：纯聊天消息   2：文件传输记录
    NSString *MsgStartId = [NSString stringWithFormat:@"%@",@(_msgStartId)]; // 从这个消息号往前（不包含该消息），为0表示默认从最新的消息回溯
    NSString *MsgNum = @"10"; // 期望拉取的消息条数
    NSDictionary *params = @{@"Action":Action_PullMsg,@"FriendId":_friendModel.userId?:@"",@"UserId":userM.userId?:@"",@"MsgType":MsgType,@"MsgStartId":MsgStartId,@"MsgNum":MsgNum};
    [SocketMessageUtil sendVersion3WithParams:params];
}

#pragma mark -初始化聊天界面
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
        if ((self.selectMessageModel.fileID > 0) && (self.selectMessageModel.msgState != CDMessageStateNormal)) { // 是文件
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

#pragma mark CTInputViewProtocol

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
        mode.willDisplayTime = YES;
        mode.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:[UserModel getUserModel].username]];
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
        

        [self sendFileWithToid:self.friendModel.userId fileName:uploadFileName fileData:data fileId:msgid fileType:2 messageId:mode.messageId srcKey:srcKey dsKey:dsKey publicKey:self.friendModel.publicKey];
        
    }else{
        NSLog(@"wav转amr失败");
    }
}

//调用系统相册
- (void)selectImage{
    
//    @weakify_self
//    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
//        if (status == PHAuthorizationStatusAuthorized) {
//            /*
//            //调用系统相册的类
//            UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
//            //    更改titieview的字体颜色
//            NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
//            attrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
//            [pickerController.navigationBar setTitleTextAttributes:attrs];
//            pickerController.navigationBar.translucent = NO;
//            pickerController.navigationBar.barTintColor = MAIN_PURPLE_COLOR;
//            //设置相册呈现的样式
//            pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //UIImagePickerControllerSourceTypeSavedPhotosAlbum;//图片分组列表样式
//            pickerController.delegate = weakSelf;
//            //使用模态呈现相册
//            [weakSelf.navigationController presentViewController:pickerController animated:YES completion:nil];
//             */
//
//        }else{
//            [AppD.window showHint:@"Denied or Restricted"];
//        }
//    }];
    
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
    model.ToId = self.friendModel.userId;
    model.msgState = CDMessageStateSending;
    model.messageId = [NSString stringWithFormat:@"%d",msgid];
    CTDataConfig config = [CTData defaultConfig];
    config.isOwner = YES;
    model.willDisplayTime = YES;
    model.messageStatu = -1;
    NSString *uploadFileName = mill;
    model.fileName = mill;
    
    model.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
    model.publicKey = self.friendModel.publicKey;
    model.ctDataconfig = config;
    NSString *nkName = [UserModel getUserModel].username;
    model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName]];
//    [[SDImageCache sharedImageCache] storeImage:img forKey:model.messageId completion:nil];
    NSString *filePath = [[SystemUtil getBaseFilePath:self.friendModel.userId] stringByAppendingPathComponent:mill];
    [imgData writeToFile:filePath atomically:YES];
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
    imgData = aesEncryptData(imgData,msgKeyData);
    
    [self sendFileWithToid:self.friendModel.userId fileName:uploadFileName fileData:imgData fileId:msgid fileType:1 messageId:model.messageId srcKey:srcKey dsKey:dsKey publicKey:self.friendModel.publicKey];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -发送文件
- (void) sendFileWithToid:(NSString *) toId fileName:(NSString *) fileName fileData:(NSData *) fileData fileId:(int) fileId fileType:(int) fileType messageId:(NSString *) messageId srcKey:(NSString *) srcKey dsKey:(NSString *) dsKey publicKey:(NSString *) publicKey
{
    if ([SystemUtil isSocketConnect]) {
        SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
        [dataUtil sendFileId:toId fileName:fileName fileData:fileData fileid:fileId fileType:fileType messageid:messageId srcKey:srcKey dstKey:dsKey];
        [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
    } else {
        NSString *filePath = [[SystemUtil getTempBaseFilePath:toId] stringByAppendingPathComponent:[Base58Util Base58EncodeWithCodeName:fileName]];
        
        if ([fileData writeToFile:filePath atomically:YES]) {
            NSDictionary *parames = @{@"Action":@"SendFile",@"FromId":[UserConfig getShareObject].userId,@"ToId":toId,@"FileName":[Base58Util Base58EncodeWithCodeName:fileName],@"FileMD5":[MD5Util md5WithPath:filePath],@"FileSize":@(fileData.length),@"FileType":@(fileType),@"SrcKey":srcKey,@"DstKey":dsKey,@"FileId":messageId};
            [SendToxRequestUtil sendFileWithFilePath:filePath parames:parames];
            [SendRequestUtil sendQueryFriendWithFriendId:self.friendModel.userId];
        }
    }
    
    // 添加到chatlist
    ChatListModel *chatModel = [[ChatListModel alloc] init];
    chatModel.myID = [UserConfig getShareObject].userId;
    chatModel.friendID = toId;
    chatModel.publicKey = publicKey;
    chatModel.chatTime = [NSDate date];
    chatModel.isHD = NO;
    NSInteger msgType = fileType;
    if (msgType == 1) {
        chatModel.lastMessage = @"[photo]";
    } else if (msgType == 2) {
        chatModel.lastMessage = @"[voice]";
    } else if (msgType == 5){
        chatModel.lastMessage = @"[file]";
    } else if (msgType == 4){
        chatModel.lastMessage = @"[video]";
    }
    chatModel.routerName = [self.friendModel.RouteName base64DecodedString]?:@"";
    [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
}

// 输入框输出文字
- (void)inputViewPopSttring:(NSString *)string {
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
        DDLogDebug(@"临时公钥：%@   对称密钥：%@",[EntryModel getShareObject].tempPublicKey,symmetryString);
       
        NSDictionary *params = @{@"Action":@"SendMsg",@"To":_friendModel.userId?:@"",@"From":userM.userId?:@"",@"Msg":msg?:@"",@"Sign":signString?:@"",@"Nonce":nonceString?:@"",@"PriKey":enSymmetString?:@""};
        NSString *msgid = [SocketMessageUtil sendChatTextWithParams:params];
        
        CDMessageModel *model = [[CDMessageModel alloc] init];
        model.FromId = [UserConfig getShareObject].userId;
        model.ToId = self.friendModel.userId;
        model.publicKey = self.friendModel.publicKey;
        model.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
        model.messageId = msgid;
        model.msg = string;
        model.msgState = CDMessageStateNormal;
        model.nonceKey = nonceString;
        model.signKey = signString;
        model.symmetKey = enSymmetString;
        model.messageStatu = -1;
        [self addMessagesToList:model];
        
        // 添加到chatlist
        ChatListModel *chatModel = [[ChatListModel alloc] init];
        chatModel.myID = [UserConfig getShareObject].userId;
        chatModel.friendID = self.friendModel.userId;
      
        chatModel.publicKey = self.friendModel.publicKey;
        chatModel.lastMessage = model.msg;
        chatModel.chatTime = [NSDate date];
        chatModel.isHD = ![chatModel.friendID isEqualToString:[SocketCountUtil getShareObject].chatToId];
        chatModel.signPublicKey = self.friendModel.signPublicKey;
        chatModel.routerName = [self.friendModel.RouteName base64DecodedString]?:@"";
        [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
        
        if (![SystemUtil isSocketConnect]) {
            [SendRequestUtil sendQueryFriendWithFriendId:self.friendModel.userId];
        }
    }
    
    
//    CDMessageModel *model = [[CDMessageModel alloc] init];
//    model.msg = string;
//    [self.listView addMessagesToBottom:@[model]];
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

#pragma mark - NOTI
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

- (void) fileToxPullSuccess:(NSNotification *) noti
{
    NSArray *array = noti.object;
    if (array && array.count>0) {
      __block NSString *fileName = [Base58Util Base58DecodeWithCodeName:array[1]];
        @weakify_self
        [weakSelf.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.fileName isEqualToString:fileName]) { // 收到tox文件
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    if (array.count > 2) {
                        obj.msgState = CDMessageStateDownloadFaild;
                        obj.isDown = NO;
                        [weakSelf.listView updateMessage:obj];
                        *stop = YES;
                        NSLog(@"下载文件失败! ");
                    } else {
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
                                obj.msgState = CDMessageStateNormal;
                                obj.isDown = NO;
                                [weakSelf.listView updateMessage:obj];
                                *stop = YES;
                                NSLog(@"下载文件成功! filePath = %@",docPath);
                            });
                        }
                    }
                });
            }
        }];
    }
    
}
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

- (void) messageForward:(NSNotification *)noti {
   __block NSData *fileDatas = nil;
    NSArray *modeArray = (NSArray *)noti.object;
    @weakify_self
    [modeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        model.publicKey = [model.publicKey stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        UserModel *userM = [UserModel getUserModel];
        NSString *msgKey = [SystemUtil get16AESKey];
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
            NSString *msgid = [SocketMessageUtil sendChatTextWithParams:params];

            if ([model.userId isEqualToString:weakSelf.friendModel.userId]) {
                CDMessageModel *messageModel = [[CDMessageModel alloc] init];
                messageModel.FromId = [UserConfig getShareObject].userId;
                messageModel.ToId = model.userId;
                messageModel.publicKey = model.publicKey;
                messageModel.messageId = msgid;
                messageModel.msg = weakSelf.selectMessageModel.msg;
                messageModel.msgState = CDMessageStateNormal;
                messageModel.nonceKey = nonceString;
                messageModel.signKey = signString;
                messageModel.symmetKey = enSymmetString;
                messageModel.messageStatu = -1;
                [self addMessagesToList:messageModel];
            }
            // 添加到chatlist
            ChatListModel *chatModel = [[ChatListModel alloc] init];
            chatModel.myID = [UserConfig getShareObject].userId;
            chatModel.friendID = model.userId;
            chatModel.publicKey = model.publicKey;
            chatModel.signPublicKey = model.signPublicKey;
            chatModel.lastMessage = weakSelf.selectMessageModel.msg;
            chatModel.chatTime = [NSDate date];
            chatModel.isHD = NO;
            chatModel.routerName = [self.friendModel.RouteName base64DecodedString]?:@"";
            [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
            
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
                    messageModel.msgState = CDMessageStateSending;
                    messageModel.messageId = [NSString stringWithFormat:@"%d",msgid];
                    messageModel.fileID = msgid;
                    messageModel.messageStatu = -1;
                    CTDataConfig config = [CTData defaultConfig];
                    config.isOwner = YES;
                    messageModel.willDisplayTime = YES;
                    messageModel.fileName = weakSelf.selectMessageModel.fileName;
                     messageModel.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
                    messageModel.publicKey = model.publicKey;
                    messageModel.ctDataconfig = config;
                    NSString *nkName = [UserModel getUserModel].username;
                    messageModel.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName]];
                    
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
                
                [self sendFileWithToid:model.userId fileName:weakSelf.selectMessageModel.fileName fileData:enData fileId:msgid fileType:weakSelf.selectMessageModel.msgType messageId:[NSString stringWithFormat:@"%d",msgid] srcKey:srcKey dsKey:dsKey publicKey:model.publicKey];
                
            });
        }
    }];
}

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
    model.fileName = [Base58Util Base58DecodeWithCodeName:fileModel.FileName];
    model.messageId = [NSString stringWithFormat:@"%@",fileModel.MsgId];
    model.FromId = fileModel.FromId;
    model.ToId = fileModel.ToId;
    model.msgType = fileModel.FileType;
    model.isLeft = YES;
    model.srckey = fileModel.SrcKey;
    model.dskey = fileModel.DstKey;
    CTDataConfig config = [CTData defaultConfig];
    config.isOwner = NO;
    model.willDisplayTime = YES;
    model.TimeStatmp = fileModel.timestamp;
    model.publicKey = self.friendModel.publicKey;
    model.ctDataconfig = config;
    NSString *nkName = self.friendModel.username;
    model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName]];
    [self.listView addMessagesToBottom:@[model]];
}

#pragma mark -消息发送成功通知
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
                } else if ([array[0] integerValue] == 2) {
                    CDMessageModel *messageModel = [[CDMessageModel alloc] init];
                    messageModel.msgType = 3;
                    messageModel.msg = @"You are not his (her) friend, please send him (her) friend request.";
                    [weakSelf.listView addMessagesToBottom:@[messageModel]];
                }
                index = idx;
                *stop = YES;
            }
        }];
    }
}


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

#pragma mark -得到一条文字消息 并添加到listview
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
        config.textColor =[UIColor whiteColor].CGColor;
        config.isOwner = YES;
    }
    model.publicKey = self.friendModel.publicKey;
    model.willDisplayTime = YES;
    model.ctDataconfig = config;
    NSString *nkName = [UserModel getUserModel].username;
    if (model.isLeft) {
        nkName = self.friendModel.username;
    }
    model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName]];
    [self.listView addMessagesToBottom:@[model]];
}

- (void)addMessageBefore:(NSNotification *)noti {
    NSArray *messageArr = noti.object;
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
        model.messageStatu = payloadModel.Status;
        model.publicKey = self.friendModel.publicKey;
        model.messageId = [NSString stringWithFormat:@"%@",payloadModel.MsgId];
        model.TimeStatmp = payloadModel.TimeStatmp;
        model.msgType = payloadModel.MsgType;
        if (model.msgType >=1 && model.msgType !=5 && model.msgType !=4) { // 图片
            model.msgState = CDMessageStateDownloading;
        }
        if (payloadModel.FileName) {
             model.fileName = [Base58Util Base58DecodeWithCodeName:payloadModel.FileName];
        }
       
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
            config.textColor =[UIColor whiteColor].CGColor;
            config.isOwner = YES;
        }
        model.ctDataconfig = config;
        NSString *nkName = [UserModel getUserModel].username;
        if (model.isLeft) {
            nkName = self.friendModel.username;
        }
        model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName]];
        [messageModelArr addObject:model];
    }];
    
    if (_msgStartId == 0) { // 第一次自动加载
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
}

#pragma mark -发送已读
- (void) sendRedMsgWithMsgId:(NSString *) msgid
{
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    BOOL result = (state != UIApplicationStateBackground);
    if (result) {
         [SendRequestUtil sendRedMsgWithFriendId:self.friendModel.userId msgid:msgid];
    }
   
}

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
            }
        }
    });
    
}

- (UIView *) getHeadViewWithName:(NSString *) name
{
    UIView *imgBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    imgBackView.backgroundColor = [UIColor clearColor];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:imgBackView.bounds];
    imgView.image = [UIImage imageNamed:@"icon_headportrait"];
    UILabel *lblName = [[UILabel alloc] initWithFrame:imgBackView.bounds];
    lblName.textColor = [UIColor whiteColor];
    lblName.textAlignment = NSTextAlignmentCenter;
    lblName.font = [UIFont systemFontOfSize:16];
    lblName.text = [StringUtil getUserNameFirstWithName:name];
    [imgBackView addSubview:imgView];
    [imgBackView addSubview:lblName];
    return imgBackView;
}

#pragma mark -视频导出到本地完成 并发送
- (void)extracted:(PHAsset *)asset evImage:(UIImage *) evImage {
    
    NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
    int msgid = [mill intValue];
    CDMessageModel *model = [[CDMessageModel alloc] init];
    model.msgType = CDMessageTypeMedia;
    model.messageStatu = -1;
    model.FromId = [UserConfig getShareObject].userId;
    model.ToId = self.friendModel.userId;
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
    model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName]];
    [self.listView addMessagesToBottom:@[model]];
    
//    NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
    NSString *outputPath = [NSString stringWithFormat:@"%@.mp4",mills];
    outputPath =  [[SystemUtil getBaseFilePath:self.friendModel.userId] stringByAppendingPathComponent:outputPath];
    [TZImageManager manager].outputPath = outputPath;
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPreset640x480 success:^(NSString *outputPath) {
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
                 [self sendFileWithToid:self.friendModel.userId fileName:model.fileName fileData:mediaData fileId:msgid fileType:4 messageId:model.messageId srcKey:srcKey dsKey:dsKey publicKey:self.friendModel.publicKey];
            });
        });
        
        
    } failure:^(NSString *errorMessage, NSError *error) {
        [self.view showHint:@"不支持当前视频格式"];
    }];
}

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
            NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
            NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
            int msgid = [mill intValue];
            CDMessageModel *model = [[CDMessageModel alloc] init];
            model.msgType = CDMessageTypeImage;
            model.msg = @"";
            model.fileID = msgid;
            model.FromId = [UserConfig getShareObject].userId;
            model.ToId = weakSelf.friendModel.userId;
            model.msgState = CDMessageStateSending;
            model.messageId = [NSString stringWithFormat:@"%d",msgid];
            CTDataConfig config = [CTData defaultConfig];
            config.isOwner = YES;
            model.willDisplayTime = YES;
            model.messageStatu = -1;
            NSString *uploadFileName = [mill stringByAppendingString:@".jpg"];
            model.fileName = [mill stringByAppendingString:@".jpg"];
             model.TimeStatmp = [NSDate getTimestampFromDate:[NSDate date]];
            model.publicKey = weakSelf.friendModel.publicKey;
            model.ctDataconfig = config;
            NSString *nkName = [UserModel getUserModel].username;
            model.userThumImage =  [SystemUtil genterViewToImage:[weakSelf getHeadViewWithName:nkName]];
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
            
            [self sendFileWithToid:self.friendModel.userId fileName:uploadFileName fileData:imgData fileId:msgid fileType:1 messageId:model.messageId srcKey:srcKey dsKey:dsKey publicKey:self.friendModel.publicKey];
        }
    }];
     // 你可以通过block或者代理，来得到用户选择的视频.
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *asset) {
        [weakSelf extracted:asset evImage:coverImage];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        model.fileName = fileUrl.lastPathComponent;
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
        NSString *msgKey = [SystemUtil getDoc32AESKey];
        NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
        NSString *symmetKey = [symmetData base64EncodedString];
        // 好友公钥加密对称密钥
        NSString *dsKey = [LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:self.friendModel.publicKey];
        // 自己公钥加密对称密钥
        NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
        
        NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
        txtData = aesEncryptData(txtData,msgKeyData);
        
        
        [self sendFileWithToid:self.friendModel.userId fileName:uploadFileName fileData:txtData fileId:msgid fileType:5 messageId:model.messageId srcKey:srcKey dsKey:dsKey publicKey:self.friendModel.publicKey];
    }
}

@end
