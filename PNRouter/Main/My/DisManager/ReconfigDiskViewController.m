//
//  ReconfigDiskViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/29.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "ReconfigDiskViewController.h"
#import "DiskToastView.h"
#import "DiskAlertView.h"
#import "DiskManagerViewController.h"

@interface ReconfigDiskViewController ()

@property (weak, nonatomic) IBOutlet UIButton *tipBtn;
@property (nonatomic, strong) DiskToastView *diskToastView;

@end

@implementation ReconfigDiskViewController

- (void)addObserve {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formatDiskSuccessNoti:) name:FormatDisk_Success_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(formatDiskFailNoti:) name:FormatDisk_Fail_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rebootSuccessNoti:) name:Reboot_Success_Noti object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rebootFailNoti:) name:Reboot_Fail_Noti object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addObserve];
}

#pragma mark - Operation
- (void)sendFormatDisk {
    [self showToast:@"Formatting in progress..."];
    [SendRequestUtil sendFormatDiskWithMode:_selectMode showHud:NO];
}

- (void)sendReboot {
    [self showToast:@"Rebooting..."];
    [SendRequestUtil sendRebootWithShowHud:NO];
}

- (void)showToast:(NSString *)title {
    _diskToastView = [DiskToastView getInstance];
    [_diskToastView showWithTitle:title];
}

- (void)hideToast {
    if (_diskToastView) {
        [_diskToastView hide];
    }
}

- (void)showRebootAlertView {
    DiskAlertView *view = [DiskAlertView getInstance];
    @weakify_self
    view.okBlock = ^{
        [weakSelf sendReboot];
    };
    [view show];
}

#pragma mark - Action

- (IBAction)closeAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tipAction:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)confirmAction:(id)sender {
    if (!_tipBtn.isSelected) {
        [AppD.window showHint:@"Please agree first"];
        return;
    }
    
    [self sendFormatDisk];
}

#pragma mark - Transition
- (void)backToDiskManager {
    @weakify_self
    [self.navigationController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[DiskManagerViewController class]]) {
            [weakSelf.navigationController popToViewController:obj animated:YES];
            *stop = YES;
        }
    }];
    
}

#pragma mark - Noti
- (void)formatDiskSuccessNoti:(NSNotification *)noti {
    [self hideToast];
//    NSDictionary *receiveDic = noti.object;
//    NSDictionary *paramsDic = receiveDic[@"params"];
    
    [self showRebootAlertView];
}

- (void)formatDiskFailNoti:(NSNotification *)noti {
    [self hideToast];
}

- (void)rebootSuccessNoti:(NSNotification *)noti {
    [self hideToast];
//    NSDictionary *receiveDic = noti.object;
//    NSDictionary *paramsDic = receiveDic[@"params"];
    [self backToDiskManager];
}

- (void)rebootFailNoti:(NSNotification *)noti {
    [self hideToast];
}


@end
