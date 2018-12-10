//
//  SocketAlertView.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/14.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SocketAlertView : UIView

@property (weak, nonatomic) IBOutlet UILabel *lblTtile;
@property (weak, nonatomic) IBOutlet UIButton *okBtn;
@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (nonatomic ,assign) BOOL isShow;
- (void) showAlertView;
+ (instancetype) loadSocketAlertView;
@end
