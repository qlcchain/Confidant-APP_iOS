//
//  ReconfigDiskViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/1/29.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "ReconfigDiskViewController.h"

@interface ReconfigDiskViewController ()

@end

@implementation ReconfigDiskViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
}

#pragma mark - Operation


#pragma mark - Action

- (IBAction)closeAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)tipAction:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)confirmAction:(id)sender {
    
}

@end
