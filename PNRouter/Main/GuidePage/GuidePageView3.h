//
//  GuidePageView3.h
//  Qlink
//
//  Created by 旷自辉 on 2018/6/21.
//  Copyright © 2018年 pan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GuidePageView3 : UIView

@property (weak, nonatomic) IBOutlet UIButton *scan1Btn;
@property (weak, nonatomic) IBOutlet UIButton *scan2Btn;
@property (weak, nonatomic) IBOutlet UIButton *scan3Btn;

@property (weak, nonatomic) IBOutlet UIButton *scanBtn;
@property (weak, nonatomic) IBOutlet UIButton *questionBtn;

+ (instancetype) loadGuidePageView3;


@end
