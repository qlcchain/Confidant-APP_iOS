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

#define StatusH [[UIApplication sharedApplication] statusBarFrame].size.height
#define NaviH (64 + StatusH)
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

typedef void(^PullMoreBlock)(NSArray *arr);

@interface ChatViewController ()<ChatListProtocol,
CTInputViewProtocol,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,TZImagePickerControllerDelegate>



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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMessage:) name:ADD_MESSAGE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addMessageBefore:) name:ADD_MESSAGE_BEFORE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteMessageSuccess:) name:DELET_MESSAGE_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDeleteMessage:) name:RECEIVE_DELET_MESSAGE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageForward:) name:CHOOSE_FRIEND_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveFileMessage:) name:RECEVIE_FILE_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileSendSuccess:) name:FILE_SEND_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendTextMessageSuccess:) name:SEND_CHATMESSAGE_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveRedMsg:) name:REVER_RED_MSG_NOTI object:nil];
}

- (IBAction)rightAction:(id)sender {
//    FriendDetailViewController *vc = [[FriendDetailViewController alloc] init];
//    vc.friendModel = _friendModel;
//    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)leftAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}

- (instancetype) initWihtFriendMode:(FriendModel *) model
{
    if (self = [super init]) {
        model.username = [model.username base64DecodedString]?:model.username;
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
    [self pullMessageRequest];
    
    // 当前消息置为已读
    [[ChatListDataUtil getShareObject] cancelChatHDWithFriendid:self.friendModel.userId];
    [[NSNotificationCenter defaultCenter] postNotificationName:ADD_MESSAGE_NOTI object:nil];

//    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"1539912662170117"ofType:@"mp4"]];
//    UIImage *img = [SystemUtil thumbnailImageForVideo:url];
//    UIImageView *imgV = [[UIImageView alloc] initWithImage:img];
//    imgV.center = CGPointMake(ScreenW/2, ScreenH/2);
//    [AppD.window addSubview:imgV];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [SocketCountUtil getShareObject].chatToID = self.friendModel.userId;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [SocketCountUtil getShareObject].chatToID = @"";
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    
}

#pragma mark - Operation
- (void)pullMessageRequest {
    UserModel *userM = [UserModel getUserModel];
    NSString *MsgType = @"1"; // 0：所有记录  1：纯聊天消息   2：文件传输记录
    NSString *MsgStartId = [NSString stringWithFormat:@"%@",@(_msgStartId)]; // 从这个消息号往前（不包含该消息），为0表示默认从最新的消息回溯
    NSString *MsgNum = @"10"; // 期望拉取的消息条数
    NSDictionary *params = @{@"Action":@"PullMsg",@"FriendId":_friendModel.userId?:@"",@"UserId":userM.userId?:@"",@"MsgType":MsgType,@"MsgStartId":MsgStartId,@"MsgNum":MsgNum};
    [SocketMessageUtil sendTextWithParams:params];
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
    
//    // 加载本地聊天消息
//    NSString *jsonPath = [NSBundle.mainBundle pathForResource:@"messageHistory" ofType:@"json"];
//    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
//    NSArray *array = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
//    NSMutableArray <BaseMsgModel *>*msgs = [NSMutableArray arrayWithCapacity:array.count];
//    NSInteger autoInc = 1;
//    for (NSDictionary *dic in array) {
//        BaseMsgModel *model = [[BaseMsgModel alloc] init:dic];
//        if ([model.messageId isEqualToString:@"this is special"]) {
//            CTDataConfig config = [CTData defaultConfig];
//            config.matchLink = NO;
//            config.matchEmail = NO;
//            config.matchEmoji = NO;
//            config.matchPhone = NO;
//            model.ctDataconfig = config;
//        } else {
//             CTDataConfig config = [CTData defaultConfig];
//            if (!model.isLeft) {
//                config.textColor =[UIColor whiteColor].CGColor;
//            }
//            model.ctDataconfig = config;
//            model.messageId = [NSString stringWithFormat:@"%ld",(long)autoInc++];
//        }
//        [msgs addObject:model];
//    }
//    self.listView.msgArr = msgs;
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
    NSLog(@"%@",itemTitle);
    if ([itemTitle isEqualToString:@"Save"]) {
        
    } else if ([itemTitle isEqualToString:@"Forward"]){ // 转发
        ChooseContactViewController *vc = [[ChooseContactViewController alloc] init];
        [self presentModalVC:vc animated:YES];
    }  else if ([itemTitle isEqualToString:@"Withdraw"]){ // 删除
        NSString *msgId = self.selectMessageModel.messageId;
        _deleteMsgId = msgId;
        UserModel *userM = [UserModel getUserModel];
        NSString *msgIdStr = [NSString stringWithFormat:@"%@",((CDMessageModel *)msgModel).messageId];
        NSDictionary *params = @{@"Action":@"DelMsg",@"FriendId":_friendModel.userId?:@"",@"UserId":userM.userId?:@"",@"MsgId":msgIdStr};
        [SocketMessageUtil sendTextWithParams:params];
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
        NSString *createTtime = [NSString stringWithFormat:@"%ld",(long)[NSDate getTimestampFromDate:[NSDate date]]];
        CDMessageModel *mode = [[CDMessageModel alloc] init];
        mode.msgType = CDMessageTypeAudio;
        mode.msgState = CDMessageStateSending;
        
        mode.msg = amrPath;
        mode.FromId = [UserModel getUserModel].userId;
        mode.ToId = self.friendModel.userId;
        mode.fileName = [mill stringByAppendingString:@".amr"];
        
        NSString *uploadFileName = mode.fileName;
        mode.fileID = msgid;
        mode.createTime = createTtime;
        mode.publicKey = self.friendModel.publicKey;
        mode.messageId = mill;
        mode.willDisplayTime = YES;
        mode.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:[UserModel getUserModel].username]];
        mode.isLeft = NO;
        mode.audioSufix = @"amr";
        [self.listView addMessagesToBottom:@[mode]];
        
        NSString *msgKey = [SystemUtil get16AESKey];
        NSData *msgKeyData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
        data = aesEncryptData(data,msgKeyData);
        NSString *srcKey = [RSAUtil pubcliKeyEncryptValue:msgKey];
        NSString *dsKey = [RSAUtil publicEncrypt:self.friendModel.publicKey msgValue:msgKey];
        
        SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
        [dataUtil sendFileId:self.friendModel.userId fileName:uploadFileName fileData:data fileid:msgid fileType:2 messageid:mode.messageId srcKey:srcKey dstKey:dsKey];
        [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
        
    }else{
        NSLog(@"wav转amr失败");
    }
}

//调用系统相册
- (void)selectImage{
    
    @weakify_self
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            //调用系统相册的类
            UIImagePickerController *pickerController = [[UIImagePickerController alloc]init];
            //    更改titieview的字体颜色
            NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
            attrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
            [pickerController.navigationBar setTitleTextAttributes:attrs];
            pickerController.navigationBar.translucent = NO;
            pickerController.navigationBar.barTintColor = MAIN_PURPLE_COLOR;
            //设置相册呈现的样式
            pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //UIImagePickerControllerSourceTypeSavedPhotosAlbum;//图片分组列表样式
            pickerController.delegate = weakSelf;
            //使用模态呈现相册
            [weakSelf.navigationController presentViewController:pickerController animated:YES completion:nil];
        }else{
            [AppD.window showHint:@"Denied or Restricted"];
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
       NSString *txtPath = [[NSBundle mainBundle] pathForResource:@"测试文件" ofType:@"txt"];
        NSData *txtData = [NSData dataWithContentsOfFile:txtPath];
        NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
        NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
        int msgid = [mill intValue];
        CDMessageModel *model = [[CDMessageModel alloc] init];
        model.msgType = CDMessageTypeFile;
        model.FromId = [UserModel getUserModel].userId;
        model.ToId = self.friendModel.userId;
        model.fileSize = txtData.length;
        model.msgState = CDMessageStateSending;
        model.messageId = mill;
        model.fileID = msgid;
        CTDataConfig config = [CTData defaultConfig];
        config.isOwner = YES;
        model.willDisplayTime = YES;
        model.fileName = @"测试文件.txt";
        NSString *uploadFileName = model.fileName;
        model.createTime = [NSString stringWithFormat:@"%ld",(long)[NSDate getTimestampFromDate:[NSDate date]]];
        model.publicKey = self.friendModel.publicKey;
        model.ctDataconfig = config;
        NSString *nkName = [UserModel getUserModel].username;
        model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName]];
        NSString *filePath = [[SystemUtil getBaseFilePath:self.friendModel.userId] stringByAppendingPathComponent:model.fileName];
        [txtData writeToFile:filePath atomically:YES];
        [self.listView addMessagesToBottom:@[model]];
        
        NSString *msgKey = [SystemUtil get16AESKey];
        NSData *msgKeyData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
        txtData = aesEncryptData(txtData,msgKeyData);
        NSString *srcKey = [RSAUtil pubcliKeyEncryptValue:msgKey];
        NSString *dsKey = [RSAUtil publicEncrypt:self.friendModel.publicKey msgValue:msgKey];
        
        SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
        [dataUtil sendFileId:self.friendModel.userId fileName:uploadFileName fileData:txtData fileid:msgid fileType:5 messageid:model.messageId srcKey:srcKey dstKey:dsKey];
        [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
        
    } else if ([string isEqualToString:@"Short video"]) { // 视频
        
         //[self pushTZImagePickerController];
        
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        @weakify_self
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                if (authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied) {
                    // 无相机权限 做一个友好的提示
                    [AppD.window showHint:@"请在iPhone的""设置-隐私-相册""中允许访问相册"];
                } else if (authStatus == AVAuthorizationStatusNotDetermined) {
                    // fix issue 466, 防止用户首次拍照拒绝授权时相机页黑屏
                    [AppD.window showHint:@"请在iPhone的""设置-隐私-相册""中允许访问相册"];
                    // 拍照之前还需要检查相册权限
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf pushTZImagePickerController];
                    });
                    
                }
            }else{
                [AppD.window showHint:@"Denied or Restricted"];
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
    model.FromId = [UserModel getUserModel].userId;
    model.ToId = self.friendModel.userId;
    model.msgState = CDMessageStateSending;
    model.messageId = mill;
    CTDataConfig config = [CTData defaultConfig];
    config.isOwner = YES;
    model.willDisplayTime = YES;
    NSString *uploadFileName = mill;
    model.fileName = mill;
    model.createTime = [NSString stringWithFormat:@"%ld",(long)[NSDate getTimestampFromDate:[NSDate date]]];
    model.publicKey = self.friendModel.publicKey;
    model.ctDataconfig = config;
    NSString *nkName = [UserModel getUserModel].username;
    model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName]];
//    [[SDImageCache sharedImageCache] storeImage:img forKey:model.messageId completion:nil];
    NSString *filePath = [[SystemUtil getBaseFilePath:self.friendModel.userId] stringByAppendingPathComponent:mill];
    [imgData writeToFile:filePath atomically:YES];
    [self.listView addMessagesToBottom:@[model]];
    
    NSString *msgKey = [SystemUtil get16AESKey];
    NSData *msgKeyData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
    imgData = aesEncryptData(imgData, msgKeyData);
    NSString *srcKey = [RSAUtil pubcliKeyEncryptValue:msgKey];
    NSString *dsKey = [RSAUtil publicEncrypt:self.friendModel.publicKey msgValue:msgKey];
    
    SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
    [dataUtil sendFileId:self.friendModel.userId fileName:uploadFileName fileData:imgData fileid:msgid fileType:1 messageid:model.messageId srcKey:srcKey dstKey:dsKey];
    [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
    
    // NSDictionary *parames = [SocketDataUtil sendFileId:self.friendModel.userId fileName:@"img-1" fileData:imgData];
  //  [dataUtil sendFileWithParames:parames fileData:imgData];
   // UIImage *img2 = [UIImage imageNamed:@"timg1.jpeg"];
//    NSData *imgData2 = UIImageJPEGRepresentation(img,1.0);
//    NSDictionary *parames2 = [SocketDataUtil sendFileId:self.friendModel.userId fileName:@"img-2" fileData:imgData2];
//    SocketDataUtil *dataUtil2 = [[SocketDataUtil alloc] init];
//    [[SocketManageUtil getShareObject].socketArray addObject:dataUtil2];
//    [dataUtil2 sendFileWithParames:parames2 fileData:imgData2];
    
   // UIImage *img3 = [UIImage imageNamed:@"timg3.jpeg"];
//    NSData *imgData3 = UIImageJPEGRepresentation(img,1.0);
//    NSDictionary *parames3 = [SocketDataUtil sendFileId:self.friendModel.userId fileName:@"img-3" fileData:imgData3];
//    SocketDataUtil *dataUtil3 = [[SocketDataUtil alloc] init];
//    [[SocketManageUtil getShareObject].socketArray addObject:dataUtil3];
//    [dataUtil3 sendFileWithParames:parames3 fileData:imgData3];
    
     
    /*
     发送图片消息时，为了达到消息还没发出就已经展示在页面上的效果，需要SDImageCache预先缓存，用messageid作为Key，
     发送完成后，将图片的完整地址保存到此字段中。
     */
//    CDMessageModel *model = [[CDMessageModel alloc] init];
//    model.msgType = CDMessageTypeImage;
//    model.msg = info[UIImagePickerControllerMediaURL];
//    model.msgState = CDMessageStateSending;
//    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
//    double timeInter = recordTime;
//    model.messageId = [NSString stringWithFormat:@"%0.3f" ,timeInter] ;
//    [[SDImageCache sharedImageCache] storeImage:img forKey:model.messageId completion:nil];
//    [self.listView addMessagesToBottom:@[model]];
//
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        model.msgState = CDMessageStateNormal;
//        [self.listView updateMessage:model];
//    });
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// 输入框输出文字
- (void)inputViewPopSttring:(NSString *)string {
    if (string && ![string isEmptyString]) {
        UserModel *userM = [UserModel getUserModel];
        NSString *msgKey = [SystemUtil get16AESKey];
        NSString *msg =  aesEncryptString(string, msgKey);
        NSString *srcKey = [RSAUtil pubcliKeyEncryptValue:msgKey];
       // srcKey = [RSAUtil privateKeyDecryptValue:srcKey];
        NSString *dsKey = [RSAUtil publicEncrypt:self.friendModel.publicKey msgValue:msgKey];
        NSDictionary *params = @{@"Action":@"SendMsg",@"ToId":_friendModel.userId?:@"",@"FromId":userM.userId?:@"",@"Msg":msg?:@"",@"SrcKey":srcKey?:@"",@"DstKey":dsKey?:@""};
        NSString *msgid = [SocketMessageUtil sendChatTextWithParams:params];
        
        CDMessageModel *model = [[CDMessageModel alloc] init];
        model.FromId = [UserModel getUserModel].userId;
        model.ToId = self.friendModel.userId;
        model.publicKey = self.friendModel.publicKey;
        model.messageId = msgid;
        model.msg = string;
        model.msgState = CDMessageStateNormal;
        model.srckey = srcKey;
        model.dskey = dsKey;
        model.messageStatu = -1;
        [self addMessagesToList:model];
        
        // 添加到chatlist
        ChatListModel *chatModel = [[ChatListModel alloc] init];
        chatModel.myID = model.FromId;
        chatModel.friendID = model.ToId;
        chatModel.publicKey = self.friendModel.publicKey;
        chatModel.lastMessage = model.msg;
        chatModel.chatTime = [NSDate date];
        chatModel.isHD = ![chatModel.friendID isEqualToString:[SocketCountUtil getShareObject].chatToID];
        [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
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
    NSArray *modeArray = (NSArray *)noti.object;
    @weakify_self
    [modeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *model = obj;
        model.publicKey = [model.publicKey stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
        UserModel *userM = [UserModel getUserModel];
        NSString *msgKey = [SystemUtil get16AESKey];
        
        if (weakSelf.selectMessageModel.msgType == CDMessageTypeText) { // 转发文字
            
            NSString *msg =  aesEncryptString(weakSelf.selectMessageModel.msg, msgKey);
            NSString *srcKey = [RSAUtil pubcliKeyEncryptValue:msgKey];
            NSString *dsKey = [RSAUtil publicEncrypt:model.publicKey msgValue:msgKey];
            NSDictionary *params = @{@"Action":@"SendMsg",@"ToId":model.userId?:@"",@"FromId":userM.userId?:@"",@"Msg":msg?:@"",@"SrcKey":srcKey?:@"",@"DstKey":dsKey?:@""};
            NSString *msgid = [SocketMessageUtil sendChatTextWithParams:params];
            
            if ([model.userId isEqualToString:weakSelf.friendModel.userId]) {
                CDMessageModel *messageModel = [[CDMessageModel alloc] init];
                messageModel.FromId = [UserModel getUserModel].userId;
                messageModel.ToId = model.userId;
                messageModel.publicKey = model.publicKey;
                messageModel.messageId = msgid;
                messageModel.msg = weakSelf.selectMessageModel.msg;
                messageModel.msgState = CDMessageStateNormal;
                messageModel.srckey = srcKey;
                messageModel.dskey = dsKey;
                messageModel.messageStatu = -1;
                [self addMessagesToList:messageModel];
            }
            
            // 添加到chatlist
            ChatListModel *chatModel = [[ChatListModel alloc] init];
            chatModel.myID = [UserModel getUserModel].userId;
            chatModel.friendID = model.userId;
            chatModel.publicKey = model.publicKey;
            chatModel.lastMessage = weakSelf.selectMessageModel.msg;
            chatModel.chatTime = [NSDate date];
            chatModel.isHD = NO;
            [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
        } else { // 转发文件
            
            NSString *filePath = [[SystemUtil getBaseFilePath:weakSelf.friendModel.userId] stringByAppendingPathComponent:weakSelf.selectMessageModel.fileName];
            NSData *txtData = [NSData dataWithContentsOfFile:filePath];
            NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
            NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
            int msgid = [mill intValue];
            
            CDMessageModel *messageModel = [[CDMessageModel alloc] init];
           
            filePath = [[SystemUtil getBaseFilePath:model.userId] stringByAppendingPathComponent:messageModel.fileName];
            [txtData writeToFile:filePath atomically:YES];
            
            if ([model.userId isEqualToString: weakSelf.friendModel.userId]) {
                messageModel.msgType = weakSelf.selectMessageModel.msgType;
                messageModel.FromId = [UserModel getUserModel].userId;
                messageModel.ToId = model.userId;
                messageModel.fileSize = txtData.length;
                messageModel.msgState = CDMessageStateSending;
                messageModel.messageId = mill;
                messageModel.fileID = msgid;
                CTDataConfig config = [CTData defaultConfig];
                config.isOwner = YES;
                messageModel.willDisplayTime = YES;
                messageModel.fileName = weakSelf.selectMessageModel.fileName;
                messageModel.createTime = [NSString stringWithFormat:@"%ld",(long)[NSDate getTimestampFromDate:[NSDate date]]];
                messageModel.publicKey = model.publicKey;
                messageModel.ctDataconfig = config;
                NSString *nkName = [UserModel getUserModel].username;
                messageModel.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName]];
                [weakSelf.listView addMessagesToBottom:@[messageModel]];
            }
            
            NSData *msgKeyData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
            txtData = aesEncryptData(txtData,msgKeyData);
            NSString *srcKey = [RSAUtil pubcliKeyEncryptValue:msgKey];
            NSString *dsKey = [RSAUtil publicEncrypt:model.publicKey msgValue:msgKey];
            
            SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
            [dataUtil sendFileId:model.userId fileName:weakSelf.selectMessageModel.fileName fileData:txtData fileid:msgid fileType:weakSelf.selectMessageModel.msgType messageid:messageModel.messageId srcKey:srcKey dstKey:dsKey];
            [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
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
       __block NSUInteger fileIndex = 0;
        [self.listView.msgArr enumerateObjectsUsingBlock:^(CDChatMessage  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CDMessageModel *model = (id)obj;
            if ([[NSString stringWithFormat:@"%@",model.messageId] isEqualToString:arr[4]]) {
                fileIndex = idx;
                *stop = YES;
            }
        }];
        
         CDMessageModel *model = (CDMessageModel *)[self.listView.msgArr objectAtIndex:fileIndex];
        if ([arr[0] integerValue] == 0) { // 文件发送失败
            NSLog(@"文件发送失败");
            model.msgState = CDMessageStateSendFaild;
            model.messageStatu = -1;
        } else {
            NSLog(@"文件发送成功");
            // 添加到最后一条消息
            model.msgState = CDMessageStateNormal;
            model.messageStatu = 1;
            model.messageId = arr[5];
            // 添加到chatlist
            ChatListModel *chatModel = [[ChatListModel alloc] init];
            chatModel.myID = model.FromId;
            chatModel.friendID = model.ToId;
            chatModel.chatTime = [NSDate date];
            chatModel.isHD = NO;
            NSInteger msgType = [arr[3] integerValue];
            if (msgType == 1) {
                chatModel.lastMessage = @"[图片]";
            } else if (msgType == 2) {
                chatModel.lastMessage = @"[语音]";
            } else if (msgType == 5){
                chatModel.lastMessage = @"[文件]";
            } else if (msgType == 3){
                chatModel.lastMessage = @"[视频]";
            }
            [[ChatListDataUtil getShareObject] addFriendModel:chatModel];
            [[NSNotificationCenter defaultCenter] postNotificationName:ADD_MESSAGE_NOTI object:nil];
        }
        [self.listView updateMessage:model];
    }
}

- (void) receiveFileMessage:(NSNotification *) noti
{
    FileModel *fileModel = (FileModel *)noti.object;
    NSString *userId = [UserModel getUserModel].userId;
    if (!(([fileModel.ToId isEqualToString:userId] && [fileModel.FromId isEqualToString:self.friendModel.userId]) || ([fileModel.FromId isEqualToString:userId] && [fileModel.ToId isEqualToString:self.friendModel.userId]))) {
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
    model.createTime = [NSString stringWithFormat:@"%ld",(long)[NSDate getTimestampFromDate:[NSDate date]]];
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
    NSString *userId = [UserModel getUserModel].userId;
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
    model.createTime = [NSString stringWithFormat:@"%ld",(long)[NSDate getTimestampFromDate:[NSDate date]]];
    model.publicKey = self.friendModel.publicKey;
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
         NSString *userId = [UserModel getUserModel].userId;
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
            model.srckey = payloadModel.UserKey;
        } else {
            model.isLeft = YES;
            model.dskey = payloadModel.UserKey;
            [msgArr addObject:model.messageId];
        }
        
        NSString *msgkey = [RSAUtil privateKeyDecryptValue:payloadModel.UserKey];
        if (![msgkey isEmptyString] && model.msgType == 0) {
             model.msg = aesDecryptString(payloadModel.Msg,msgkey);
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
    [SendRequestUtil sendRedMsgWithFriendId:self.friendModel.userId msgid:msgid];
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
- (void)extracted:(PHAsset *)asset {
    [TZImageManager manager].friendid = self.friendModel.userId;
    [[TZImageManager manager] getVideoOutputPathWithAsset:asset presetName:AVAssetExportPreset640x480 success:^(NSString *outputPath) {
        NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
        //UIImage *img = [SystemUtil thumbnailImageForVideo:url];
        NSData *mediaData = [NSData dataWithContentsOfFile:outputPath];
        NSString *mills = [NSString stringWithFormat:@"%@",@([NSDate getMillisecondTimestampFromDate:[NSDate date]])];
        NSString *mill = [mills substringWithRange:NSMakeRange(mills.length-9, 9)];
        int msgid = [mill intValue];
        CDMessageModel *model = [[CDMessageModel alloc] init];
        model.msgType = CDMessageTypeMedia;
        model.FromId = [UserModel getUserModel].userId;
        model.ToId = self.friendModel.userId;
        model.fileSize = mediaData.length;
        model.msgState = CDMessageStateSending;
        model.messageId = mill;
        model.fileID = msgid;
        CTDataConfig config = [CTData defaultConfig];
        config.isOwner = YES;
        model.willDisplayTime = YES;
        model.fileName = [[outputPath componentsSeparatedByString:@"/"] lastObject];
        NSString *uploadFileName = model.fileName;
        model.createTime = [NSString stringWithFormat:@"%ld",(long)[NSDate getTimestampFromDate:[NSDate date]]];
        model.publicKey = self.friendModel.publicKey;
        model.ctDataconfig = config;
        NSString *nkName = [UserModel getUserModel].username;
        model.userThumImage =  [SystemUtil genterViewToImage:[self getHeadViewWithName:nkName]];
        [self.listView addMessagesToBottom:@[model]];
        
        NSString *msgKey = [SystemUtil get16AESKey];
        NSData *msgKeyData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
        mediaData = aesEncryptData(mediaData,msgKeyData);
        NSString *srcKey = [RSAUtil pubcliKeyEncryptValue:msgKey];
        NSString *dsKey = [RSAUtil publicEncrypt:self.friendModel.publicKey msgValue:msgKey];
        
        SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
        [dataUtil sendFileId:self.friendModel.userId fileName:uploadFileName fileData:mediaData fileid:msgid fileType:4 messageid:model.messageId srcKey:srcKey dstKey:dsKey];
        [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
        
    } failure:^(NSString *errorMessage, NSError *error) {
        [self.view showHint:@"不支持当前视频格式"];
    }];
}

- (void)pushTZImagePickerController {
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:3 delegate:self pushPhotoPickerVc:YES];
    // imagePickerVc.navigationBar.translucent = NO;
    
#pragma mark - 五类个性化设置，这些参数都可以不传，此时会走默认设置
    imagePickerVc.isSelectOriginalPhoto = YES;
    
    imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
    imagePickerVc.allowTakeVideo = YES;   // 在内部显示拍视频按
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
    imagePickerVc.allowPickingVideo = YES;
    imagePickerVc.allowPickingImage = NO;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    imagePickerVc.allowPickingGif = NO;
    imagePickerVc.allowPickingMultipleVideo = NO; // 是否可以多选视频
    
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    
    // imagePickerVc.minImagesCount = 3;
    // imagePickerVc.alwaysEnableDoneBtn = YES;
    
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
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
     // 你可以通过block或者代理，来得到用户选择的视频.
    @weakify_self
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *asset) {
        [weakSelf extracted:asset];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
