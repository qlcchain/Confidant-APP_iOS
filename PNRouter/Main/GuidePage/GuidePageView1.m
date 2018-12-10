//
//  GuidePageView1.m
//  Qlink
//
//  Created by 旷自辉 on 2018/6/21.
//  Copyright © 2018年 pan. All rights reserved.
//

#import "GuidePageView1.h"

@implementation GuidePageView1
- (void)awakeFromNib
{
    _nextBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    _nextBtn.layer.borderWidth = 1.5f;
    _nextBtn.layer.cornerRadius = 5;
    [super awakeFromNib];
}
+ (instancetype) loadGuidePageView1
{
    return [[[NSBundle mainBundle] loadNibNamed:@"GuidePageView1" owner:self options:nil] lastObject];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
