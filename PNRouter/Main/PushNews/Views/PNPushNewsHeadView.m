//
//  PNPushNewsHeadView.m
//  MyConfidant
//
//  Created by 旷自辉 on 2020/5/14.
//  Copyright © 2020 旷自辉. All rights reserved.
//

#import "PNPushNewsHeadView.h"

@implementation PNPushNewsHeadView

+ (instancetype) loadPNPushNewsHeadView
{
    PNPushNewsHeadView *view = [[[NSBundle mainBundle] loadNibNamed:@"PNPushNewsHeadView" owner:self options:nil] lastObject];
    view.frame = CGRectMake(0, 0, SCREEN_WIDTH, 185);
    return view;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
