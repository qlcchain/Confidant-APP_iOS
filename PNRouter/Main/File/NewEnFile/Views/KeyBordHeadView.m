//
//  KeyBordHeadView.m
//  MyConfidant
//
//  Created by 旷自辉 on 2019/11/22.
//  Copyright © 2019 旷自辉. All rights reserved.
//

#import "KeyBordHeadView.h"

@implementation KeyBordHeadView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

+ (instancetype) getKeyBordHeadView
{
    KeyBordHeadView *headV = [[[NSBundle mainBundle] loadNibNamed:@"KeyBordHeadView" owner:self options:nil] lastObject];
    headV.frame = CGRectMake(0,SCREEN_HEIGHT, SCREEN_WIDTH, 163);
    headV.tfbackView.layer.cornerRadius = 8.0f;
    
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, SCREEN_WIDTH, 163) byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(16,16)];//圆角大小
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, 163);//_backView.bounds;
    maskLayer.path = maskPath.CGPath;
    headV.layer.mask = maskLayer;
    
    return headV;
}
// 关闭输入
- (IBAction)clickCloseAction:(id)sender {
    [_floderTF resignFirstResponder];
}
@end
