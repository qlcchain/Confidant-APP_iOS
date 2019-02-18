//
//  GuidePageView2.m
//  Qlink
//
//  Created by 旷自辉 on 2018/6/21.
//  Copyright © 2018年 pan. All rights reserved.
//

#import "GuidePageView2.h"

@implementation GuidePageView2

- (void)awakeFromNib {
//    _nextBtn.layer.borderColor = [UIColor whiteColor].CGColor;
//    _nextBtn.layer.borderWidth = 1.5f;
//    _nextBtn.layer.cornerRadius = 5;
    [super awakeFromNib];
}

+ (instancetype) loadGuidePageView2 {
    return [[[NSBundle mainBundle] loadNibNamed:@"GuidePageView2" owner:self options:nil] lastObject];
}

@end
