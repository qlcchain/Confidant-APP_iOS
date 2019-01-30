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
#import "FileData.h"
//#import <JCDownloader/JCDownloader.h>
//#import <JCDownloader/JCDownloadOperation.h>
#import "RequestService.h"
#import "NSDate+Category.h"
#import "PNRouter-Swift.h"
#import "OperationRecordModel.h"
#import "UserConfig.h"
#import "FileDownUtil.h"

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
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;

@end

@implementation FilePreviewDownloadViewController

#pragma mark - Observe
- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteFileCompleteNoti:) name:Delete_File_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downFileFaieldNoti:) name:TOX_PULL_FILE_FAIELD_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downFileSuccessNoti:) name:TOX_PULL_FILE_SUCCESS_NOTI object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downFileProgessNoti:) name:Tox_Down_File_Progess_Noti object:nil];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self addObserve];
    [self dataInit];
}

#pragma mark - Operation
- (void)dataInit {
//    _icon.image = [UIImage imageNamed:@"icon_doc_gray"];
    NSString *fileImgStr = @"";
    if ([_fileListM.FileType integerValue] == 1) { // 图片
        fileImgStr = @"icon_picture_gray";
    } else if ([_fileListM.FileType integerValue] == 4) { // 视频
        fileImgStr = @"icon_video_gray";
    } else if ([_fileListM.FileType integerValue] == 5) { // 文档
        fileImgStr = @"icon_document_gray";
    } else if ([_fileListM.FileType integerValue] == 6) { // 其他
        fileImgStr = @"icon_other_gray";
    }
    _icon.image = [UIImage imageNamed:fileImgStr];
    
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
        if (model.localPath == nil) {
            [AppD.window showHint:@"Please download first"];
        } else {
            
        }
    }];
    [view setDownloadB:^{
        
    }];
    [view setOtherApplicationOpenB:^{
        if (model.localPath == nil) {
            [AppD.window showHint:@"Please download first"];
        } else {
            [weakSelf otherApplicationOpen:[NSURL fileURLWithPath:model.localPath]];
        }
    }];
    [view setDetailInformationB:^{
        [weakSelf jumpToDetailInformation:model];
    }];
    [view setRenameB:^{
        
    }];
    [view setDeleteB:^{
        [weakSelf deleteFileWithModel:model];
    }];
    
    NSString *fileNameBase58 = model.FileName.lastPathComponent;
    NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58]?:@"";
    [view showWithFileName:fileName fileType:model.FileType];
}

#pragma mark -删除文件
- (void)deleteFileWithModel:(FileListModel *)model {
    [SendRequestUtil sendDelFileWithUserId:[UserConfig getShareObject].userId FileName:model.FileName showHud:YES];
}

- (void)otherApplicationOpen:(NSURL *)fileURL {
    NSArray *items = @[fileURL];
    UIActivityViewController *activityController=[[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

- (void)downloadFile {
    
    if ([SystemUtil isSocketConnect]) {
        @weakify_self
        [[FileDownUtil getShareObject] downFileWithFileModel:self.fileListM progressBlock:^(CGFloat progress) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.progressV.progress = progress;
            });
            
        } success:^(NSURLSessionDownloadTask * _Nonnull dataTask, NSString * _Nonnull filePath) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.progressV.progress = 1;
                weakSelf.progressV.hidden = YES;
                weakSelf.sizeLab.hidden = NO;
                weakSelf.fileExistType = FileExistTypeExistOrDownloaded;
                [weakSelf.previewBtn setTitle:@"File Preview" forState:UIControlStateNormal];
                [weakSelf.previewBtn setBackgroundColor:UIColorFromRGB(0x2C2C2C)];
                [weakSelf.previewBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
                weakSelf.downloadFilePath = filePath;
                weakSelf.fileListM.localPath = weakSelf.downloadFilePath;
                weakSelf.downloadTask = nil;
            });
            
        } failure:^(NSURLSessionDownloadTask * _Nonnull dataTask, NSError * _Nonnull error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"%@     %@   %@",error.localizedDescription, error.domain,@(error.code));
                if (error.code == -999) {
                    [AppD.window showHint:@"Download Cancel"];
                } else {
                    [AppD.window showHint:@"Download Fail"];
                }
                weakSelf.progressV.hidden = YES;
                weakSelf.sizeLab.hidden = NO;
                weakSelf.fileExistType = FileExistTypeNone;
                [weakSelf.previewBtn setTitle:@"Preview Download" forState:UIControlStateNormal];
                [weakSelf.previewBtn setBackgroundColor:UIColorFromRGB(0x2C2C2C)];
                [weakSelf.previewBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
                weakSelf.downloadTask = nil;
    
            });
            
        } downloadTaskB:^(NSURLSessionDownloadTask * _Nonnull downloadTask) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.downloadTask = downloadTask;
            });
        }];
    } else {
        [[FileDownUtil getShareObject] toxDownFileModel:self.fileListM];
    }
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
        _fileExistType = FileExistTypeDownloading;
        [self downloadFile];
    } else if (_fileExistType == FileExistTypeDownloading) {
        // 取消下载
        if (_downloadTask) {
            [_downloadTask cancel];
        }
    } else if (_fileExistType == FileExistTypeExistOrDownloaded) {
        // 预览
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
    NSString *fileNameBase58 = self.fileListM.FileName.lastPathComponent;
    NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58]?:@"";
    vc.fileName = fileName;
    vc.userKey = _fileListM.UserKey;
    vc.fileListM = _fileListM;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - Noti
- (void) downFileFaieldNoti:(NSNotification *)noti {
    int msgid = [noti.object intValue];
    if (msgid == [self.fileListM.MsgId intValue]) {
        @weakify_self
        dispatch_async(dispatch_get_main_queue(), ^{
            [AppD.window showHint:@"Download Fail"];
            weakSelf.progressV.hidden = YES;
            weakSelf.sizeLab.hidden = NO;
            weakSelf.fileExistType = FileExistTypeNone;
            [weakSelf.previewBtn setTitle:@"Preview Download" forState:UIControlStateNormal];
            [weakSelf.previewBtn setBackgroundColor:UIColorFromRGB(0x2C2C2C)];
            [weakSelf.previewBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        });
    }
}
- (void) downFileSuccessNoti:(NSNotification *)noti {
    NSArray *arr = noti.object;
    NSString *filePath = [[SystemUtil getTempBaseFilePath:arr[0]] stringByAppendingPathComponent:arr[1]];
    filePath = [filePath stringByAppendingString:[NSString stringWithFormat:@"%d",[arr[2] intValue]]];
    NSData *filedata = [NSData dataWithContentsOfFile:filePath];
    if (arr && arr.count > 0) {
        if ([arr[2] intValue] == [self.fileListM.MsgId intValue]) {
            @weakify_self
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.progressV.progress = 1;
                weakSelf.progressV.hidden = YES;
                weakSelf.sizeLab.hidden = NO;
                weakSelf.fileExistType = FileExistTypeExistOrDownloaded;
                [weakSelf.previewBtn setTitle:@"File Preview" forState:UIControlStateNormal];
                [weakSelf.previewBtn setBackgroundColor:UIColorFromRGB(0x2C2C2C)];
                [weakSelf.previewBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
                weakSelf.downloadFilePath = filePath;
            });
        }
    }
    
}

- (void) downFileProgessNoti:(NSNotification *) noti
{
    FileData *fileModel = noti.object;
    if (fileModel.msgId == [self.fileListM.MsgId intValue]) {
        if (fileModel.progess > 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressV.progress = fileModel.progess/[self.fileListM.FileSize intValue];
            });
        }
    }
}

- (void)deleteFileCompleteNoti:(NSNotification *) noti {
    // 删除成功-保存操作记录
    NSInteger timestamp = [NSDate getTimestampFromDate:[NSDate date]];
    NSString *operationTime = [NSDate getTimeWithTimestamp:[NSString stringWithFormat:@"%@",@(timestamp)] format:@"yyyy-MM-dd HH:mm:ss" isMil:NO];
    NSString *fileName = [Base58Util Base58DecodeWithCodeName:_fileListM.FileName.lastPathComponent];
    [OperationRecordModel saveOrUpdateWithFileType:_fileListM.FileType operationType:@(2) operationTime:operationTime operationFrom:[UserConfig getShareObject].userName operationTo:@"" fileName:fileName routerPath:_fileListM.FileName?:@"" localPath:@"" userId:[UserConfig getShareObject].userId];
    
    [self backAction:nil];
}


@end
