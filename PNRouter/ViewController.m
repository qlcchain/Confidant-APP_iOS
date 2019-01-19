//
//  ViewController.m
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/4.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import "ViewController.h"
#import "PNRouter-Swift.h"
#import "SocketMessageUtil.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITextField *messageTF;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
}

- (IBAction)connectAction:(id)sender {
   // [SocketUtil.shareInstance connectWithUrl:SOCKET_URL_DEFAULT];
}

- (IBAction)disconnectAction:(id)sender {
    [SocketUtil.shareInstance disconnect];
}

- (IBAction)sendMeassge:(id)sender {
//    NSString *message = _messageTF.text?:@"";
    NSDictionary *params = @{@"Action":@"Login",@"RouteId":@"",@"UserId":@"",@"UserDataVersion":SOCKET_USETDATAVERSION};
    [SocketMessageUtil sendVersion1WithParams:params];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
