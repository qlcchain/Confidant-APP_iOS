//
//  FilePreviewViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/23.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "FilePreviewViewController.h"
#import <QuickLook/QuickLook.h>
#import "FileMoreAlertView.h"
#import "FileListModel.h"
#import "DetailInformationViewController.h"
#import "NSString+Base64.h"
#import "AESCipher.h"
#import "SystemUtil.h"
#import "MyConfidant-Swift.h"
#import "FileDownUtil.h"
#import "RequestService.h"

@interface FilePreviewViewController () <QLPreviewControllerDataSource, QLPreviewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic, strong) QLPreviewController *previewController;
@property (nonatomic, strong) NSMutableArray *sourceArr;

@end

@implementation FilePreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
  
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view showHudInView:self.view hint:@""];
    @weakify_self
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (weakSelf.fileType == DefaultFile) {
            
            NSData *fileData = [NSData dataWithContentsOfFile:weakSelf.filePath];
            if (!fileData || fileData.length == 0 ) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.view hideHud];
                    [weakSelf.view showHint:@"Decryption failure."];
                });
            } else {
                [weakSelf deFileWithFileData:fileData];
            }
            
        } else if (weakSelf.fileType == LocalPhotoFile) {
            [weakSelf deFileWithFileData:weakSelf.localFileData];
        } else if (weakSelf.fileType == NodePhotoFile) {
            [weakSelf downFileData];
        }
        
    });
}
#pragma mark ----下载节点文件
- (void) downFileData
{
    self.fileName = [Base58Util Base58DecodeWithCodeName:self.fileName]?:@"";
    NSString *downloadFilePath = [SystemUtil getTempDeFilePath:self.fileName];
    if (self.floderId && self.floderId.length > 0) {
       NSString *lastTypeStr = [[self.fileName componentsSeparatedByString:@"."] lastObject];
        downloadFilePath = [SystemUtil getPhotoTempDeFloderId:self.floderId fid:[NSString stringWithFormat:@"%@.%@",self.fileId,lastTypeStr]];
    }
   
    //[SystemUtil removeDocmentFilePath:downloadFilePath];
    if ([SystemUtil filePathisExist:downloadFilePath]) {
        @weakify_self
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.view hideHud];
            [weakSelf previewFilePath:downloadFilePath];
        });
    } else {
        
        if ([SystemUtil isSocketConnect]) {
            
            @weakify_self
            [RequestService downFileWithBaseURLStr:self.filePath filePath:downloadFilePath progressBlock:^(CGFloat progress) {
                
            } success:^(NSURLSessionDownloadTask *dataTask, NSString *filePath) {
            
                NSData *fileData = [NSData dataWithContentsOfFile:filePath];
                [SystemUtil removeDocmentFilePath:filePath];
                [weakSelf deFileWithFileData:fileData];
                
            } failure:^(NSURLSessionDownloadTask *dataTask, NSError *error) {
                [SystemUtil removeDocmentFilePath:downloadFilePath];
                [weakSelf.view hideHud];
                [weakSelf.view showHint:@"File download failed."];
            }];
        }
    }
    
}

- (void) deFileWithFileData:(NSData *) fileData
{
    
    NSString *deFilePath = [SystemUtil getTempDeFilePath:self.fileName];
    if (self.floderId && self.floderId.length > 0) {
       NSString *lastTypeStr = [[self.fileName componentsSeparatedByString:@"."] lastObject];
        deFilePath = [SystemUtil getPhotoTempDeFloderId:self.floderId fid:[NSString stringWithFormat:@"%@.%@",self.fileId,lastTypeStr]];
    }
    if ([SystemUtil filePathisExist:deFilePath]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view hideHud];
            [self previewFilePath:deFilePath];
        });
        return;
    }
    NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:self.userKey];
    if (datakey && datakey.length>0) {
        datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
        if (datakey && ![datakey isEmptyString]) {
            
           NSData *deFileData = aesDecryptData(fileData, [datakey dataUsingEncoding:NSUTF8StringEncoding]);
            if (deFileData) {
                BOOL isWriteFinsh = [deFileData writeToFile:deFilePath atomically:YES];
                if (isWriteFinsh) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.view hideHud];
                        [self previewFilePath:deFilePath];
                    });
                }
                
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view hideHud];
                    [self.view showHint:@"Decryption failure."];
                });
            }
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view hideHud];
            [self.view showHint:@"Decryption failure."];
        });
    }
}

#pragma mark - Operation
- (void)previewFilePath:(NSString *) filePath {
    
    _sourceArr = [NSMutableArray array];
    [_sourceArr addObject:filePath];
    
    _previewController = [[QLPreviewController alloc] init];
    _previewController.dataSource = self;
    _previewController.delegate = self;
    [_contentView addSubview:_previewController.view];
    
    @weakify_self
    [_previewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(weakSelf.contentView).offset(0);
    }];
    
//    if (fileType == 4) {
//        previewView.backView.backgroundColor = [UIColor blackColor];
//    }
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)moreAction:(id)sender {
//    [self showFileMoreAlertView:_fileListM];
}

#pragma mark - request methods

#pragma mark - QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return _sourceArr.count;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    NSURL *url = [NSURL fileURLWithPath:_sourceArr[index]];
    return  url;
}

- (CGRect)previewController:(QLPreviewController *)controller frameForPreviewItem:(id<QLPreviewItem>)item inSourceView:(UIView *__autoreleasing  _Nullable *)view{
    return _contentView.bounds;
}

#pragma mark - Transition
//- (void)jumpToDetailInformation:(FileListModel *)model  {
//    DetailInformationViewController *vc = [[DetailInformationViewController alloc] init];
//    vc.fileListM = model;
//    [self.navigationController pushViewController:vc animated:YES];
//}


@end
