//
//  ChooseDownView.h
//  PNRouter
//
//  Created by 旷自辉 on 2018/9/25.
//  Copyright © 2018年 旷自辉. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseDownView : UIView

@property (weak, nonatomic) IBOutlet UILabel *lblContent;
@property (weak, nonatomic) IBOutlet UIView *confirmBackView;
@property (weak, nonatomic) IBOutlet UIButton *comfirmBtn;

+ (instancetype) loadChooseDownView;

@end
