//
//  YWFilePreviewView.m
//  YWFilePreviewDemo
//
//  Created by dyw on 2017/3/16.
//  Copyright © 2017年 dyw. All rights reserved.
//

#import "YWFilePreviewView.h"
#import <QuickLook/QuickLook.h>
#import "CDChatListProtocols.h"
#import "SystemUtil.h"

#define YWKeyWindow [UIApplication sharedApplication].keyWindow
#define YWS_W YWKeyWindow.bounds.size.width
#define YWS_H YWKeyWindow.bounds.size.height
#define YW_NAV_Hight 67

@interface YWFilePreviewView ()
<QLPreviewControllerDataSource, QLPreviewControllerDelegate,UIDocumentInteractionControllerDelegate>

@property (nonatomic, assign) BOOL hindNav;
@property (nonatomic, strong) QLPreviewController *previewController;
@property (nonatomic, strong) NSArray *filePathArr;
@property (nonatomic, strong) NSArray *fileNameArr;
@property (nonatomic, strong) NSArray *fileTypeArr;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navContraintH;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (nonatomic, strong) UIDocumentInteractionController *documentIntertactionController;

@end

@implementation YWFilePreviewView

#pragma mark - life cycle
- (void)awakeFromNib{
    [super awakeFromNib];
    self.frame = YWKeyWindow.bounds;
}

- (void) updateFileName {
    self.lblTitle.text = self.fileNameArr[_previewController.currentPreviewItemIndex];
}

-(void)layoutSubviews{
    CGFloat viewY = IS_iPhoneX? YW_NAV_Hight+20:YW_NAV_Hight;
    _navContraintH.constant = viewY;
    //self.previewController.view.frame = CGRectMake(0, viewY, YWS_W,YWS_H-viewY);
//    if (self.fileType == 4) {
//        self.previewController.view.backgroundColor =[UIColor blackColor];
//    }
    
}

#pragma mark - private methods

#pragma mark - public methods
/** 预览多个文件 单个数组只传一个就好 */
+ (void)previewFileWithPaths:(NSString *)filePath fileName:(NSString *)fileName fileType:(NSInteger) fileType
{
    YWFilePreviewView *previewView = [[NSBundle mainBundle] loadNibNamed:@"YWFilePreviewView" owner:nil options:nil].lastObject;
    previewView.filePathArr = @[filePath];
    previewView.fileNameArr = @[fileName];
    previewView.fileTypeArr = @[@(fileType)];
    [previewView updateFileName];
    previewView.downloadBtn.hidden = YES;
//    if (fileType == CDMessageTypeImage || fileType == CDMessageTypeMedia) {
//        previewView.downloadBtn.hidden = NO;
//    } else {
//        previewView.downloadBtn.hidden = YES;
//    }
    
    previewView.previewController = [[QLPreviewController alloc] init];
    [previewView.backView addSubview:previewView.previewController.view];
    
    [previewView.previewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.mas_equalTo(previewView.backView).offset(0);
    }];
    
    previewView.previewController.dataSource = previewView;
    previewView.previewController.delegate = previewView;
    
    if (fileType == 4) {
        previewView.backView.backgroundColor = [UIColor blackColor];
    }
    
    previewView.frame = CGRectMake(YWS_W, 0, YWS_W, YWS_H);
    [YWKeyWindow addSubview:previewView];
    [UIView animateWithDuration:0.25 animations:^{
        previewView.frame = CGRectMake(0, 0, YWS_W, YWS_H);
    } completion:^(BOOL finished) {
        
    }];
}


#pragma mark - request methods

#pragma mark - QLPreviewControllerDataSource
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller{
    return self.filePathArr.count;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index{
    NSURL *url = [NSURL fileURLWithPath:self.filePathArr[index]];
    return  url;
}

- (CGRect)previewController:(QLPreviewController *)controller frameForPreviewItem:(id<QLPreviewItem>)item inSourceView:(UIView *__autoreleasing  _Nullable *)view{
    return YWKeyWindow.bounds;
}

#pragma mark - event response
- (IBAction)backButtonClick:(id)sender {
    [UIView animateWithDuration:0.25 animations:^{
        self.frame = CGRectMake(YWS_W, 0, YWS_W, YWS_H);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (IBAction)moreButtonClick:(id)sender {
    
    NSLog(@"更多按钮点击");
    
}

- (IBAction)downloadAction:(id)sender {
//    NSInteger fileType = [_fileTypeArr[_previewController.currentPreviewItemIndex] integerValue];
    
//    NSString *filePath = _filePathArr[_previewController.currentPreviewItemIndex];
//    UIDocumentInteractionController *documentController =
//    [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
//    documentController.delegate = self;
//    [documentController presentOpenInMenuFromRect:CGRectZero inView:self animated:YES];
    
    
    NSURL *pathUrl = [[NSBundle mainBundle] URLForResource:@"GoogleService-Info" withExtension:@".plist"];
    _documentIntertactionController = [UIDocumentInteractionController interactionControllerWithURL:pathUrl];
       // _documentIntertactionController.delegate = self;
        [self presentOptionsMenu];
    
    //    if (fileType == CDMessageTypeImage) {
    //        UIImage *img = [UIImage imageWithContentsOfFile:filePath];
    //        [self saveImage:img];
    //    } else if (fileType == CDMessageTypeMedia) {
    //        [self saveVideo:filePath];
    //    }
    
}


- (void)presentOptionsMenu{
    [_documentIntertactionController presentOptionsMenuFromRect:self.bounds inView:self animated:YES];
}
    

#pragma mark - getters and setters
-(void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{

}



-(void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application


{

}

-(void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller
{

}

@end
