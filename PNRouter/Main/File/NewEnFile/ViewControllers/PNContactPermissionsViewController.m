//
//  PNContactPermissionsViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/29.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNContactPermissionsViewController.h"
#import <Contacts/Contacts.h>
#import "TermsViewController.h"

@interface PNContactPermissionsViewController ()

@property (weak, nonatomic) IBOutlet UIButton *allowBtn;
@end

@implementation PNContactPermissionsViewController
- (IBAction)clickBackAction:(id)sender {
    AppD.contactStatus = 3;
    [self leftNavBarItemPressedWithPop:NO];
}
- (IBAction)clickAllowAction:(id)sender {
    
    CNContactStore *store = [[CNContactStore alloc] init];
    @weakify_self
    [store requestAccessForEntityType:CNEntityTypeContacts completionHandler:^(BOOL granted, NSError*  _Nullable error) {
        if (error) {
            NSLog(@"授权失败");
            dispatch_async(dispatch_get_main_queue(), ^{
                AppD.contactStatus = 2;
            });
        }else {
            NSLog(@"成功授权");
            dispatch_async(dispatch_get_main_queue(), ^{
                AppD.contactStatus = 1;
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf leftNavBarItemPressedWithPop:NO];
        });
        
    }];
}
- (IBAction)clickPolicyAction:(id)sender {
    TermsViewController *vc = [[TermsViewController alloc] init];
    [self presentModalVC:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _allowBtn.layer.cornerRadius = 8.0f;
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
