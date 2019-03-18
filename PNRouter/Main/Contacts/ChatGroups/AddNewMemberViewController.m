//
//  AddNewMemberViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "AddNewMemberViewController.h"
#import "InvitationQRCodeViewController.h"

@interface AddNewMemberViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end

@implementation AddNewMemberViewController
#pragma mark - action
- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}
- (IBAction)nextAction:(id)sender {
    
}
- (IBAction)qrCodeAction:(id)sender {
    InvitationQRCodeViewController *vc = [[InvitationQRCodeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _nextBtn.layer.cornerRadius = 3.0f;
    _nextBtn.layer.masksToBounds = YES;
    
    _nameTF.delegate = self;
   // _nameTF.enablesReturnKeyAutomatically = YES; //这里设置为无文字就灰色不可点
    [_nameTF addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    
}
#pragma -mark uitextfeildchange
- (void) textFieldTextChange:(UITextField *) tf
{
    if ([tf.text.trim isEmptyString]) {
        _nextBtn.backgroundColor = RGB(213, 213, 213);
        _nextBtn.enabled = NO;
    } else {
        _nextBtn.backgroundColor = MAIN_PURPLE_COLOR;
        _nextBtn.enabled = YES;
    }
}

#pragma textfeild delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField endEditing:YES];
    NSLog(@"textFieldShouldReturn");
    return YES;
}
@end
