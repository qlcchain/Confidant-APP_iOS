//
//  UploadFilesViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "UploadFilesViewController.h"
#import "UploadFilesCell.h"
#import "UploadFilesHeaderView.h"
#import "SendRequestUtil.h"
#import "UserConfig.h"
#import "NSString+File.h"
#import "PNRouter-Swift.h"
#import "FriendModel.h"
#import "SystemUtil.h"
#import "SocketDataUtil.h"
#import "SocketCountUtil.h"
#import "NSString+Base64.h"
#import "NSData+Base64.h"
#import "LibsodiumUtil.h"
#import "EntryModel.h"
#import "AESCipher.h"
#import "SocketManageUtil.h"
#import "MD5Util.h"
#import "UploadFileManager.h"
#import "TaskListViewController.h"


#define UploadFileURL @"UploadFileURL"

@implementation UploadFilesShowModel

@end

@interface UploadFilesViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *sourceArr;
@property (weak, nonatomic) IBOutlet UITableView *mainTable;
@property (weak, nonatomic) IBOutlet UIImageView *fileImg;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLab;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLab;
@property (nonatomic, strong) NSMutableArray *uploadParams;

@end

@implementation UploadFilesViewController

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFileReqSuccessNoti:) name:UploadFileReq_Success_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chooseShareFriendNoti:) name:CHOOSE_Share_FRIEND_NOTI object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFileReqSuccessNoti:) name:FILE_SEND_NOTI object:nil];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addObserve];
    [self dataInit];
    [self viewInit];
}

#pragma mark - Operation
- (void)dataInit {
    _sourceArr = [NSMutableArray array];
    UploadFilesShowModel *model = [[UploadFilesShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = NO;
    model.showCell = NO;
    model.title = @"Private Files";
    model.detail = @"Just me";
    model.cellArr = nil;
    [_sourceArr addObject:model];
    
    model = [[UploadFilesShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = NO;
    model.showCell = NO;
    model.title = @"Public Files";
    model.detail = @"Share with all friends";
    model.cellArr = nil;
    [_sourceArr addObject:model];
    
    model = [[UploadFilesShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = YES;
    model.showCell = NO;
    model.title = @"Share to";
    model.detail = @"Selected friends";
    model.cellArr = [NSMutableArray array];
    [_sourceArr addObject:model];
    
    model = [[UploadFilesShowModel alloc] init];
    model.isSelect = NO;
    model.showArrow = YES;
    model.showCell = NO;
    model.title = @"Don't share to";
    model.detail = @"Exclude selected friends";
    model.cellArr = [NSMutableArray array];
    [_sourceArr addObject:model];
    
    [_mainTable registerNib:[UINib nibWithNibName:UploadFilesCellReuse bundle:nil] forCellReuseIdentifier:UploadFilesCellReuse];
    [_mainTable registerNib:[UINib nibWithNibName:UploadFilesHeaderViewReuse bundle:nil] forHeaderFooterViewReuseIdentifier:UploadFilesHeaderViewReuse];
}

- (void)viewInit {
    NSString *imgStr = @"";
    NSString *nameStr = @"";
    if (_documentType == DocumentPickerTypePhoto) {
        imgStr = @"icon_picture_gray";
        nameStr = [NSString stringWithFormat:@"Upload Photos (%@)",@(_urlArr.count)];
    } else if (_documentType == DocumentPickerTypeVideo) {
        imgStr = @"icon_video_gray";
        nameStr = [NSString stringWithFormat:@"Upload Videos (%@)",@(_urlArr.count)];
    } else if (_documentType == DocumentPickerTypeDocument) {
        imgStr = @"icon_compress_gray";
        nameStr = [NSString stringWithFormat:@"Upload Documents (%@)",@(_urlArr.count)];
    } else if (_documentType == DocumentPickerTypeOther) {
        imgStr = @"icon_compress_gray";
        nameStr = [NSString stringWithFormat:@"Upload Others (%@)",@(_urlArr.count)];
    }
    _fileImg.image = [UIImage imageNamed:imgStr];
    _fileNameLab.text = nameStr;
    
    __block NSInteger size = 0;
    [_urlArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *fileUrl = obj;
        size += [NSString fileSizeAtPath:fileUrl.path];
    }];
    _fileSizeLab.text = [NSString stringWithFormat:@"%@KB",@(size/1024)];
}

#pragma mark - Action

- (IBAction)cancelAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)uploadAction:(id)sender {
    UploadFileManager *uploadFileM = [UploadFileManager getShareObject];
    //TODO:赋值
    
    _uploadParams = [NSMutableArray array];
    @weakify_self
    [_urlArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSURL *url = obj;
        NSString *UserId = [UserConfig getShareObject].userId;
        NSString *FileName = [Base58Util Base58EncodeWithCodeName:url.pathExtension];
        NSNumber *FileSize = @([NSString fileSizeAtPath:url.path]);
        NSNumber *FileType = @(0);
        if (weakSelf.documentType == DocumentPickerTypePhoto) {
            FileType = @(1);
        } else if (weakSelf.documentType == DocumentPickerTypeVideo) {
            FileType = @(4);
        } else if (weakSelf.documentType == DocumentPickerTypeDocument) {
            FileType = @(5);
        } else if (weakSelf.documentType == DocumentPickerTypeOther) {
            FileType = @(6);
        }
        [SendRequestUtil sendUploadFileReqWithUserId:UserId FileName:FileName FileSize:FileSize FileType:FileType showHud:YES fetchParam:^(NSDictionary * _Nonnull dic) {
            NSMutableDictionary *muDic = [NSMutableDictionary dictionaryWithDictionary:dic];
            [muDic setObject:url forKey:UploadFileURL];
            [weakSelf.uploadParams addObject:muDic];
        }];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
   // return _sourceArr.count;
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    UploadFilesShowModel *model = _sourceArr[section];
    if (model.showCell) {
        return model.cellArr.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UploadFilesCell *cell = [tableView dequeueReusableCellWithIdentifier:UploadFilesCellReuse];
    
    UploadFilesShowModel *model = _sourceArr[indexPath.section];
    if (indexPath.row == 0) {
        
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UploadFilesCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return UploadFilesHeaderViewHeight;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UploadFilesShowModel *model = _sourceArr[section];
    
    UploadFilesHeaderView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:UploadFilesHeaderViewReuse];
    [headerView configHeaderWithModel:model];
    @weakify_self
    [headerView setSelectB:^{
        model.isSelect = !model.isSelect;
        [weakSelf.mainTable reloadData];
    }];
    [headerView setShowCellB:^{
        if (model.showArrow) {
            model.showCell = !model.showCell;
            [weakSelf.mainTable reloadData];
        }
    }];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UploadFilesShowModel *model = _sourceArr[indexPath.section];
}

#pragma mark - Noti
- (void)uploadFileReqSuccessNoti:(NSNotification *)noti {
    NSString *msgId = noti.object;
    @weakify_self
    [_uploadParams enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = obj;
        NSString *tempMsgId = dic[@"msgid"];
        if ([tempMsgId isEqualToString:msgId]) {
            // 上传文件
            NSURL *fileUrl = dic[UploadFileURL];
            NSString *fileName = [fileUrl lastPathComponent];
            NSData *fileData = [NSData dataWithContentsOfURL:fileUrl];
            int fileType = [@(weakSelf.documentType) intValue];
            int fileId = [SocketCountUtil getShareObject].fileIDCount;
            fileId += 1;
            
            // 生成32位对称密钥
            NSString *msgKey = [SystemUtil get32AESKey];
            NSData *symmetData =[msgKey dataUsingEncoding:NSUTF8StringEncoding];
            NSString *symmetKey = [symmetData base64EncodedString];
            // 自己公钥加密对称密钥
            NSString *srcKey =[LibsodiumUtil asymmetricEncryptionWithSymmetry:symmetKey enPK:[EntryModel getShareObject].publicKey];
            
            NSData *msgKeyData =[[msgKey substringToIndex:16] dataUsingEncoding:NSUTF8StringEncoding];
            fileData = aesEncryptData(fileData,msgKeyData);
            
            if ([SystemUtil isSocketConnect]) {
                SocketDataUtil *dataUtil = [[SocketDataUtil alloc] init];
                dataUtil.srcKey = srcKey;
                dataUtil.fileid = [NSString stringWithFormat:@"%d",fileId];
                [dataUtil sendFileId:@"" fileName:fileName fileData:fileData fileid:fileId fileType:fileType messageid:@"" srcKey:srcKey dstKey:@""];
                [[SocketManageUtil getShareObject].socketArray addObject:dataUtil];
            }
            
        }
    }];
    
    TaskListViewController *vc = [[TaskListViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)chooseShareFriendNoti:(NSNotification *)noti {
    NSArray *modeArray = noti.object;
    @weakify_self
    [modeArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FriendModel *friendM = obj;
        
        
    }];
}

@end
