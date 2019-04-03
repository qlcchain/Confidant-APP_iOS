//
//  CodeMsgViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2019/4/1.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "CodeMsgViewController.h"

@interface CodeMsgViewController ()
@property (weak, nonatomic) IBOutlet UITextView *msgTF;
@property (nonatomic ,strong) NSString *codeResult;
@end

@implementation CodeMsgViewController

- (IBAction)backAction:(id)sender {
    [self leftNavBarItemPressedWithPop:YES];
}
- (id)initWithCodeValue:(NSString *)codeValue
{
    if (self = [super init]) {
        self.codeResult = codeValue;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.msgTF.text = self.codeResult;
    self.msgTF.editable = NO;
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
