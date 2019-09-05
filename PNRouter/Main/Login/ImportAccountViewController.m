//
//  ImportAccountViewController.m
//  PNRouter
//
//  Created by Jelly Foo on 2019/2/20.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "ImportAccountViewController.h"
#import "QRViewController.h"
#import "UserModel.h"
#import "NSString+Base64.h"
#import "UserPrivateKeyUtil.h"

@interface ImportAccountViewController ()

@end

@implementation ImportAccountViewController
- (void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
    [super viewWillAppear:animated];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)scannerAction:(id)sender {
    [self scannerOldCoder];
}
- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}

- (void) scannerOldCoder
{
    @weakify_self
    QRViewController *vc = [[QRViewController alloc] initWithCodeQRCompleteBlock:^(NSString *codeValue) {
        if (codeValue != nil && codeValue.length > 0) {
            NSArray *codeValues = [codeValue componentsSeparatedByString:@","];
            NSString *type = codeValues[0];
            if ([[NSString getNotNullValue:type] isEqualToString:@"type_3"]) {
                
                [UserPrivateKeyUtil changeUserPrivateKeyWithPrivateKey:codeValues[1]];
                NSString *name = [codeValues[3] base64DecodedString];
                [UserModel createUserLocalWithName:name];
                [AppD setRootLoginWithType:ImportType];
            } else {
                [weakSelf.view showHint:@"format error."];
            }
        }
    }];
    [self presentModalVC:vc animated:YES];
}

@end
