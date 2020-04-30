//
//  PNInstructionsViewController.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/4/26.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNInstructionsViewController.h"
#import "WebViewController.h"

@interface PNInstructionsViewController()
@property (weak, nonatomic) IBOutlet UIView *createBackView;
@property (weak, nonatomic) IBOutlet UIView *joinBackView;
@property (weak, nonatomic) IBOutlet UIView *importBackView;


@end

@implementation PNInstructionsViewController
- (IBAction)clickBackAction:(id)sender {
    [self leftNavBarItemPressedWithPop:NO];
}
- (IBAction)clickCreateCircleAction:(id)sender {
    WebViewController *vc = [[WebViewController alloc] init];
    vc.fromType = WebFromTypeCreateCircle;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)clickJoinCircleAction:(id)sender {
    WebViewController *vc = [[WebViewController alloc] init];
    vc.fromType = WebFromTypeJoinCircle;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)clickImportCircleAction:(id)sender {
    WebViewController *vc = [[WebViewController alloc] init];
    vc.fromType = WebFromTypeImportCircle;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = MAIN_GRAY_COLOR;
    
    _createBackView.layer.cornerRadius = 8.0;
    _joinBackView.layer.cornerRadius = 8.0;
    _importBackView.layer.cornerRadius = 8.0;
    

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
