//
//  AddGroupMenuViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/3/12.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "AddGroupMenuViewController.h"
#import "AddNewMemberViewController.h"

@interface AddGroupMenuViewController ()

@end

@implementation AddGroupMenuViewController
#pragma mark - action

- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (IBAction)clickMenuAction:(UIButton *)sender {
    
    if (sender.tag == 10) { // create a group
        
    } else if (sender.tag == 20) { // scan to add contacts
        
    } else if (sender.tag == 30) { // share a contact card
        
    } else { // add a new member
        AddNewMemberViewController *vc = [[AddNewMemberViewController alloc] init];
        [self presentModalVC:vc animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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
