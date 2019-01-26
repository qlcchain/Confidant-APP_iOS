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
#import "LibsodiumUtil.h"
#import "EntryModel.h"
#import "NSString+Base64.h"
#import "AESCipher.h"
#import "SystemUtil.h"
#import "PNRouter-Swift.h"

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
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *fileData = [NSData dataWithContentsOfFile:self.filePath];
        NSString *datakey = [LibsodiumUtil asymmetricDecryptionWithSymmetry:self.userKey];
        if (datakey && datakey.length>0) {
            datakey  = [[[NSString alloc] initWithData:[datakey base64DecodedData] encoding:NSUTF8StringEncoding] substringToIndex:16];
            if (datakey && ![datakey isEmptyString]) {
                fileData = aesDecryptData(fileData, [datakey dataUsingEncoding:NSUTF8StringEncoding]);
                if (fileData) {
                   NSString *deFilePath = [SystemUtil getTempDeFilePath:[self.filePath lastPathComponent]];
                   BOOL isWriteFinsh = [fileData writeToFile:deFilePath atomically:YES];
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
        
    });
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
    
    NSString *fileNameBase58 = model.FileName.lastPathComponent;
    NSString *fileName = [Base58Util Base58DecodeWithCodeName:fileNameBase58]?:@"";
    [view showWithFileName:fileName];
}

- (void)otherApplicationOpen:(NSURL *)fileURL {
    NSArray *items = @[fileURL];
    UIActivityViewController *activityController=[[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:nil];
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)moreAction:(id)sender {
    [self showFileMoreAlertView:_fileListM];
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
- (void)jumpToDetailInformation:(FileListModel *)model  {
    DetailInformationViewController *vc = [[DetailInformationViewController alloc] init];
    vc.fileListM = model;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
