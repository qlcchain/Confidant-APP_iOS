//
//  TermsViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/4/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "TermsViewController.h"
#import <WebKit/WebKit.h>

@interface TermsViewController ()
@property (weak, nonatomic) IBOutlet WKWebView *myWebView;
@property (weak, nonatomic) IBOutlet UIButton *topBtn1;
@property (weak, nonatomic) IBOutlet UIButton *topBtn2;
@property (weak, nonatomic) IBOutlet UIView *topBackView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineContranitLeft;
@property (nonatomic ,strong) UIButton *currentBtn;
@property (nonatomic ,strong) NSString *path1;
@property (nonatomic ,strong) NSString *path2;
@end

@implementation TermsViewController
- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}
- (IBAction)topBtn1Action:(id)sender {
    if (self.currentBtn == sender) {
        return;
    }
    _topBtn1.selected = YES;
    _topBtn2.selected = NO;
    self.currentBtn = sender;
    _lineContranitLeft.constant = 0;
    [_topBackView layoutIfNeeded];
    
    NSURL *fileUrl = [NSURL fileURLWithPath:self.path1];
    [_myWebView loadRequest:[NSURLRequest requestWithURL:fileUrl]];
}
- (IBAction)topBtn2Action:(id)sender {
    if (self.currentBtn == sender) {
        return;
    }
    _topBtn2.selected = YES;
    _topBtn1.selected = NO;
    self.currentBtn = sender;
    _lineContranitLeft.constant = SCREEN_WIDTH/2;
    [_topBackView layoutIfNeeded];
    NSURL *fileUrl = [NSURL fileURLWithPath:self.path2];
    [_myWebView loadRequest:[NSURLRequest requestWithURL:fileUrl]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentBtn = _topBtn1;
    self.currentBtn.selected = YES;
    self.path1 = [[NSBundle mainBundle] pathForResource:@"Terms of Service" ofType:@"html"];
    self.path2 = [[NSBundle mainBundle] pathForResource:@"Privacy Policy" ofType:@"html"];
    NSURL *fileUrl = [NSURL fileURLWithPath:self.path1];
    [_myWebView loadRequest:[NSURLRequest requestWithURL:fileUrl]];
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
