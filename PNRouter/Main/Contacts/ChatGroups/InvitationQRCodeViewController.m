//
//  InvitationQRCodeViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/13.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "InvitationQRCodeViewController.h"

@interface InvitationQRCodeViewController ()
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *codeImgView;
@property (weak, nonatomic) IBOutlet UILabel *lblDesc;
@property (weak, nonatomic) IBOutlet UIButton *userHeadBtn;
@property (weak, nonatomic) IBOutlet UIView *backView;

@end

@implementation InvitationQRCodeViewController
#pragma mark - action

- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)shareAction:(id)sender {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _backView.layer.cornerRadius = 8.0f;
    _backView.layer.masksToBounds = YES;
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
