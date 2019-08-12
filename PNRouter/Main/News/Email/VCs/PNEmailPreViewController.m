//
//  PNEmailPreViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/7/18.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNEmailPreViewController.h"
#import <QuickLook/QuickLook.h>
#import "SystemUtil.h"

@interface PNEmailPreViewController ()<QLPreviewControllerDataSource, QLPreviewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@property (nonatomic, strong) QLPreviewController *previewController;
@property (nonatomic, strong) NSMutableArray *sourceArr;

@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSData *fileData;

@end

@implementation PNEmailPreViewController
- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}

- (instancetype)initWithFileName:(NSString *)fileN fileData:(NSData *)fileD
{
    if (self = [super init]) {
        self.fileName = fileN;
        self.fileData = fileD;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    _lblTitle.text = self.fileName;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view showHudInView:self.view hint:@""];
    @weakify_self
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (!weakSelf.fileData || weakSelf.fileData.length == 0 ) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view hideHud];
                [self.view showHint:@"Decryption failure."];
            });
        } else {
            NSString *deFilePath = [SystemUtil getTempDeFilePath:self.fileName];
            BOOL isWriteFinsh = [weakSelf.fileData writeToFile:deFilePath atomically:YES];
            if (isWriteFinsh) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view hideHud];
                    [self previewFilePath:deFilePath];
                });
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.view hideHud];
                    [self.view showHint:@"Decryption failure."];
                });
            }
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
