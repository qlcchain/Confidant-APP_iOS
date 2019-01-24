//
//  FilePreviewViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/23.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "FilePreviewDownloadViewController.h"
#import "FilePreviewViewController.h"

@interface FilePreviewDownloadViewController ()

@end

@implementation FilePreviewDownloadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
}

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)moreAction:(id)sender {
    
}

#pragma mark - Transition
- (void)jumpToFilePreview {
    FilePreviewViewController *vc = [[FilePreviewViewController alloc] init];
    vc.filePath = _filePath;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
