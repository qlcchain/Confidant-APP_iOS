//
//  FilePreviewViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/23.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "FilePreviewDownloadViewController.h"
#import "FilePreviewViewController.h"
#import "FileListModel.h"
#import "FileMoreAlertView.h"
#import "DetailInformationViewController.h"
#import "PNRouter-Swift.h"
#import "SystemUtil.h"
#import "RequestService.h"
//#import <JCDownloader/JCDownloader.h>
//#import <JCDownloader/JCDownloadOperation.h>
#import "RequestService.h"
#import "NSDate+Category.h"
#import "PNRouter-Swift.h"
#import "OperationRecordModel.h"
#import "UserConfig.h"

typedef enum : NSUInteger {
    FileExistTypeNone,
    FileExistTypeDownloading,
    FileExistTypeExistOrDownloaded,
} FileExistType;

#define OpenTip @"This file type cannot be previewed You can open it with other applications"

@interface FilePreviewDownloadViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *sizeLab;
@property (weak, nonatomic) IBOutlet UIProgressView *progressV;
@property (weak, nonatomic) IBOutlet UIButton *previewBtn;
@property (weak, nonatomic) IBOutlet UILabel *openTipLab;
@property (nonatomic) FileExistType fileExistType;
//@property (nonatomic, strong) NSString *requestUrl;
@property (nonatomic, strong) NSString *downloadFilePath;

@end

@implementation FilePreviewDownloadViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self dataInit];
}

#pragma mark - Operation
- (void)dataInit {
    _icon.image = [UIImage imageNamed:@"icon_doc_gray"];
    NSString *fileNameBase58 = self.fileListM.FileName.lastPathComponent;
    NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58]?:@"";
    _nameLab.text = fileName;
    _sizeLab.text = [NSString stringWithFormat:@"%@ KB",@([_fileListM.FileSize integerValue]/1024)];
    _progressV.hidden = YES;
    _openTipLab.text = nil;
    NSString *btnTitle = @"";
//    NSString *filePath = [SystemUtil getOwerUploadFilePathWithFileName:fileName];
//    if ([SystemUtil filePathisExist:filePath]) {
//        _fileExistType = FileExistTypeExistOrDownloaded;
//        btnTitle = @"File Preview";
//    } else {
        _fileExistType = FileExistTypeNone;
        btnTitle = @"Preview Download";
//    }
    [_previewBtn setTitle:btnTitle forState:UIControlStateNormal];
}

- (void)showFileMoreAlertView:(FileListModel *)model {
    FileMoreAlertView *view = [FileMoreAlertView getInstance];
    @weakify_self
    [view setSendB:^{
        
    }];
    [view setDownloadB:^{
        
    }];
    [view setOtherApplicationOpenB:^{
        [weakSelf otherApplicationOpen:[NSURL fileURLWithPath:@""]];
    }];
    [view setDetailInformationB:^{
        [weakSelf jumpToDetailInformation:model];
    }];
    [view setRenameB:^{
        
    }];
    [view setDeleteB:^{
        
    }];
    
    [view show];
}

- (void)otherApplicationOpen:(NSURL *)fileURL {
    NSArray *items = @[fileURL];
    UIActivityViewController *activityController=[[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

- (void)downloadFile {
    NSString *filePath = self.fileListM.FileName;
    NSString *fileNameBase58 = self.fileListM.FileName.lastPathComponent;
    NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58]?:@"";
//    _requestUrl = [NSString stringWithFormat:@"%@%@",[RequestService getPrefixUrl],filePath];
    NSString *downloadFilePath = [SystemUtil getTempDownloadFilePath:fileName];
    @weakify_self
    [RequestService downFileWithBaseURLStr:filePath filePath:downloadFilePath progressBlock:^(CGFloat progress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressV.progress = progress/100.000;
//            NSLog(@"progress = %@",@(progress));
        });
    } success:^(NSURLSessionDownloadTask *dataTask, NSString *filePath) {
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.progressV.progress = 1;
            weakSelf.progressV.hidden = YES;
            weakSelf.sizeLab.hidden = NO;
            weakSelf.fileExistType = FileExistTypeExistOrDownloaded;
            [weakSelf.previewBtn setTitle:@"File Preview" forState:UIControlStateNormal];
            [weakSelf.previewBtn setBackgroundColor:UIColorFromRGB(0x2C2C2C)];
            [weakSelf.previewBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
            weakSelf.downloadFilePath = downloadFilePath;
            
            // 下载成功-保存操作记录
            NSInteger timestamp = [NSDate getTimestampFromDate:[NSDate date]];
            NSString *operationTime = [NSDate getTimeWithTimestamp:[NSString stringWithFormat:@"%@",@(timestamp)] format:@"yyyy-MM-dd HH:mm:ss" isMil:NO];
            NSString *fileName = [Base58Util Base58DecodeWithCodeName:weakSelf.fileListM.FileName.lastPathComponent];
            [OperationRecordModel saveOrUpdateWithFileType:weakSelf.fileListM.FileType operationType:@(1) operationTime:operationTime operationFrom:[UserConfig getShareObject].userName operationTo:@"" fileName:fileName routerPath:weakSelf.fileListM.FileName?:@"" localPath:@""];
        });
        
    } failure:^(NSURLSessionDownloadTask *dataTask, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"download error********* %@",error);
            [AppD.window showHint:@"Download Fail"];
            weakSelf.progressV.hidden = YES;
            weakSelf.sizeLab.hidden = NO;
            weakSelf.fileExistType = FileExistTypeNone;
            [weakSelf.previewBtn setTitle:@"Preview Download" forState:UIControlStateNormal];
            [weakSelf.previewBtn setBackgroundColor:UIColorFromRGB(0x2C2C2C)];
            [weakSelf.previewBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        });
    }];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProgress:) name:JCDownloadProgressNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadComplete:) name:JCDownloadCompletionNotification object:nil];
//
////    NSMutableArray *downloadList = [NSMutableArray array];
//    JCDownloadItem *item = [[JCDownloadItem alloc] init];
//    item.groupId = File_Download_GroupId;
//    NSString *filePath = self.fileListM.FileName;
////    NSString *fileNameBase58 = self.fileListM.FileName.lastPathComponent;
////    NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58]?:@"";
////    NSString *filePath = [self.fileListM.FileName stringByReplacingOccurrencesOfString:fileNameBase58 withString:fileName];
//    _requestUrl = [NSString stringWithFormat:@"%@%@",[RequestService getPrefixUrl],filePath];
////    _requestUrl = @"http://img0.imgtn.bdimg.com/it/u=195646865,784966603&fm=11&gp=0.jpg";
//    item.downloadUrl = _requestUrl;
//    item.downloadFilePath = [JCDownloadUtilities filePathWithFileName:[item.downloadUrl lastPathComponent] folderName:File_Download_Task_List];
//    JCDownloadOperation *operation = [JCDownloadOperation operationWithItem:item];
////    [downloadList addObject:operation];
//    [[JCDownloadAgent sharedAgent] setSecurityPolicyWithSSLPinningMode:JCDownloadSSLPinningModeNone pinnedCertificates:nil allowInvalidCertificates:YES validatesDomainName:NO];
//    [[JCDownloadAgent sharedAgent] startDownload:operation];
////    [[JCDownloadQueue sharedQueue] startDownload:operation];
//
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)moreAction:(id)sender {
    [self showFileMoreAlertView:_fileListM];
}

- (IBAction)previewAction:(UIButton *)sender {
    if (_fileExistType == FileExistTypeNone) {
        // 下载操作
        [sender setBackgroundColor:UIColorFromRGB(0xffffff)];
        [sender setTitleColor:UIColorFromRGB(0x2C2C2C) forState:UIControlStateNormal];
        [sender setTitle:@"Cancel Download" forState:UIControlStateNormal];
        _sizeLab.hidden = YES;
        _progressV.hidden = NO;
        _progressV.progress = 0;
        [self downloadFile];
    } else if (_fileExistType == FileExistTypeDownloading) {
        // 取消下载
        [sender setBackgroundColor:UIColorFromRGB(0xffffff)];
        [sender setTitleColor:UIColorFromRGB(0x2c2c2c) forState:UIControlStateNormal];
        
    } else if (_fileExistType == FileExistTypeExistOrDownloaded) {
        // 预览
//        [sender setBackgroundColor:UIColorFromRGB(0x2C2C2C)];
//        [sender setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
//        NSString *fileNameBase58 = self.fileListM.FileName.lastPathComponent;
//        NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58]?:@"";
//        NSString *filePath = [SystemUtil getOwerUploadFilePathWithFileName:fileName];
        [self jumpToFilePreview:_downloadFilePath];
    }
}

#pragma mark - Transition
- (void)jumpToDetailInformation:(FileListModel *)model  {
    DetailInformationViewController *vc = [[DetailInformationViewController alloc] init];
    vc.fileListM = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)jumpToFilePreview:(NSString *)filePath{
    FilePreviewViewController *vc = [[FilePreviewViewController alloc] init];
    vc.filePath = filePath;
    vc.userKey = _fileListM.UserKey;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Noti
//- (void)downloadProgress:(NSNotification *)noti {
//    NSDictionary *dic = noti.userInfo;
////    @{JCDownloadIdKey:operation.item.downloadId, JCDownloadProgressKey:progress}
//    NSString *md5key = dic[JCDownloadIdKey];
//    NSString *progress = dic[JCDownloadProgressKey];
//    NSString *md5Url = [JCDownloadUtilities md5WithString:_requestUrl];
//    if ([md5Url isEqualToString:md5key]) {
//        _progressV.progress = [progress floatValue];
//    }
//}
//
//- (void)downloadComplete:(NSNotification *)noti {
//    NSDictionary *dic = noti.userInfo;
//    //    @{JCDownloadIdKey:operation.item.downloadId, JCDownloadProgressKey:progress}
//    NSString *md5key = dic[JCDownloadIdKey];
//    NSError *erro = dic[JCDownloadCompletionErrorKey];
//    NSURL *fileUrl = dic[JCDownloadCompletionFilePathKey];
//    _downloadFilePath = fileUrl.path;
//    NSString *md5Url = [JCDownloadUtilities md5WithString:_requestUrl];
//    if (erro) {
//        NSLog(@"download error********* %@",erro);
//        [AppD.window showHint:@"Download Fail"];
//        _progressV.hidden = YES;
//        _sizeLab.hidden = NO;
//        _fileExistType = FileExistTypeNone;
//        [_previewBtn setTitle:@"Preview Download" forState:UIControlStateNormal];
//        [_previewBtn setBackgroundColor:UIColorFromRGB(0x2C2C2C)];
//        [_previewBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
//    } else {
//        if ([md5Url isEqualToString:md5key]) {
//            _progressV.progress = 1;
//
//            _progressV.hidden = YES;
//            _sizeLab.hidden = NO;
//            _fileExistType = FileExistTypeExistOrDownloaded;
//            [_previewBtn setTitle:@"File Preview" forState:UIControlStateNormal];
//            [_previewBtn setBackgroundColor:UIColorFromRGB(0x2C2C2C)];
//            [_previewBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
//        }
//    }
//
//}

@end
