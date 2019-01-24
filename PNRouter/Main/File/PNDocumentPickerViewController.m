//
//  PNDocumentPickerViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/24.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "PNDocumentPickerViewController.h"

@interface PNDocumentPickerViewController () {
    UIColor *beforeColor;
}

@end

@implementation PNDocumentPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    beforeColor = UINavigationBar.appearance.tintColor;
    UINavigationBar.appearance.tintColor = MAIN_PURPLE_COLOR;
//    [UIBarButtonItem.appearance setTitleTextAttributes:@{NSForegroundColorAttributeName:MAIN_PURPLE_COLOR} forState:UIControlStateNormal];
//    UIButton.appearance.tintColor = MAIN_PURPLE_COLOR;
//    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
//    UINavigationBar.appearance.tintColor = beforeColor;
}

#pragma mark - Operation

#pragma mark - Action

- (IBAction)backAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)selectAction:(id)sender {
    
}

@end
