//
//  YWFilePreviewView.m
//  YWFilePreviewDemo
//
//  Created by dyw on 2017/3/16.
//  Copyright © 2017年 dyw. All rights reserved.
//

#import "YWFilePreviewView.h"
#import <QuickLook/QuickLook.h>


#define YWKeyWindow [UIApplication sharedApplication].keyWindow
#define YWS_W YWKeyWindow.bounds.size.width
#define YWS_H YWKeyWindow.bounds.size.height
#define YW_NAV_Hight 67

@interface YWFilePreviewView ()
<QLPreviewControllerDataSource, QLPreviewControllerDelegate>
@property (nonatomic, assign) BOOL hindNav;
@property (nonatomic, strong) QLPreviewController *previewController;
@property (nonatomic, strong) NSArray *filePathArr;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, assign) NSInteger fileType;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *navContraintH;
@property (weak, nonatomic) IBOutlet UIView *backView;

@end

@implementation YWFilePreviewView

#pragma mark - life cycle
- (void)awakeFromNib{
    [super awakeFromNib];
    self.frame = YWKeyWindow.bounds;
}
- (void) updateFileName {
    self.lblTitle.text = self.fileName;
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
    previewView.fileName = fileName;
    previewView.fileType = fileType;
    [previewView updateFileName];
    
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


#pragma mark - getters and setters

@end
